import AppKit
import CoreGraphics

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: MacroController?
    private var runner: MacroRunner?
    private var launcher: MacroLauncher?
    private var hardwareKeys: HardwareKeyMonitor?
    private var eventTap: CFMachPort?
    private var eventTapSource: CFRunLoopSource?
    private var globalKeyMonitor: Any?
    private var runnerMode = false
    private var runnerAutoPlay = false
    private var editorMode = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        runnerMode = CommandLine.arguments.contains("--runner")
            || CommandLine.arguments.contains("--dialog")
        editorMode = CommandLine.arguments.contains("--editor")
            || CommandLine.arguments.contains("--macro")
            || CommandLine.arguments.contains("--rewrite-steps")
            || CommandLine.arguments.contains("--rewrite")
        runnerAutoPlay = CommandLine.arguments.contains("--play")
            || CommandLine.arguments.contains("--run")
            || CommandLine.arguments.contains("--run-now")
            || CommandLine.arguments.contains("--dialog")

        installMenu()
        if runnerMode {
            runner = MacroRunner()
            NSApp.setActivationPolicy(.accessory)
        } else if editorMode {
            let controller = MacroController()
            self.controller = controller
            controller.start()
        } else {
            let launcher = MacroLauncher()
            self.launcher = launcher
            launcher.start()
            return
        }

        installInputMonitors()

        if runnerMode, runnerAutoPlay {
            DispatchQueue.main.async { [weak self] in
                self?.runner?.play()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let globalKeyMonitor {
            NSEvent.removeMonitor(globalKeyMonitor)
        }
        if let eventTapSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), eventTapSource, .commonModes)
        }
        if let eventTap {
            CFMachPortInvalidate(eventTap)
        }
        hardwareKeys?.stop()
        runner?.stop()
        controller?.cleanup()
    }

    private func installInputMonitors() {
        let hardwareKeys = HardwareKeyMonitor()
        self.hardwareKeys = hardwareKeys
        installEventTap()
        hardwareKeys.onUsage = { [weak self] page, usage, isPress in
            DispatchQueue.main.async {
                self?.handleHIDUsage(page: page, usage: usage, isPress: isPress)
            }
        }
        hardwareKeys.start()
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            DispatchQueue.main.async {
                self?.handleGlobalKey(event)
            }
        }
    }

    private func handleHIDUsage(page: Int, usage: Int, isPress: Bool) {
        if runnerMode {
            guard let event = ControlKey.controlEvent(usagePage: page, usage: usage, isPress: isPress) else {
                return
            }

            if event.isPress {
                runner?.handle(event.command)
            }
            return
        }

        controller?.handleHIDUsage(page: page, usage: usage, isPress: isPress)
    }

    private func handleGlobalKey(_ event: NSEvent) {
        if runnerMode {
            guard let controlEvent = ControlKey.controlEvent(for: event), controlEvent.isPress else {
                return
            }
            runner?.handle(controlEvent.command)
            return
        }

        controller?.handleGlobalKey(event)
    }

    private func handleHardwareControlEvent(_ event: CGEvent, type: CGEventType) -> Bool {
        if runnerMode {
            if let controlEvent = ControlKey.controlEvent(for: event, type: type) {
                if controlEvent.isPress {
                    runner?.handle(controlEvent.command)
                }
                return true
            }

            return false
        }

        return controller?.handleHardwareControlEvent(event, type: type) ?? false
    }

    private func installEventTap() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
            | CGEventMask(1 << CGEventType.keyUp.rawValue)
            | CGEventMask(1 << CGEventType.flagsChanged.rawValue)
            | CGEventMask(1 << CGEventType.mouseMoved.rawValue)
            | CGEventMask(1 << CGEventType.leftMouseDown.rawValue)
            | CGEventMask(1 << CGEventType.leftMouseUp.rawValue)
            | CGEventMask(1 << CGEventType.leftMouseDragged.rawValue)
            | CGEventMask(1 << CGEventType.rightMouseDown.rawValue)
            | CGEventMask(1 << CGEventType.rightMouseUp.rawValue)
            | CGEventMask(1 << CGEventType.rightMouseDragged.rawValue)
            | CGEventMask(1 << 14)

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let delegate = Unmanaged<AppDelegate>
                    .fromOpaque(userInfo)
                    .takeUnretainedValue()

                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    if let eventTap = delegate.eventTap {
                        CGEvent.tapEnable(tap: eventTap, enable: true)
                    }
                    return Unmanaged.passUnretained(event)
                }

                let handledControl = delegate.handleHardwareControlEvent(event, type: type)
                if !delegate.runnerMode && !handledControl {
                    delegate.controller?.handleOverlayEvent(event, type: type)
                }

                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        eventTap = tap
        eventTapSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func installMenu() {
        let menu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(
            title: "Quit Macro",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: ""
        ))
        appMenuItem.submenu = appMenu
        menu.addItem(appMenuItem)
        NSApp.mainMenu = menu
    }
}
