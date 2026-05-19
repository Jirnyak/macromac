import AppKit
import CoreGraphics
import Foundation

final class MacroHotkeyService: NSObject, MacroPlayerDelegate {
    private struct Binding {
        var url: URL
        var hotkey: HotKey
    }

    private let player = MacroPlayer()
    private let directoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("macros", isDirectory: true)
    private var bindings: [Binding] = []
    private var activeURL: URL?
    private var lastSignature: String?
    private var lastPressTime = -Double.infinity

    override init() {
        super.init()
        player.delegate = self
    }

    func start() {
        reload()
        NSLog("Macro hotkeys ready: \(bindings.count) binding(s)")
    }

    func stop() {
        player.stop()
    }

    func reload() {
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        var seen = Set<String>()
        bindings = macroURLs().compactMap { url in
            guard let binding = binding(for: url),
                  let signature = signature(for: binding.hotkey) else {
                return nil
            }
            guard !seen.contains(signature) else {
                NSLog("Macro hotkey conflict ignored: \(url.lastPathComponent) uses \(binding.hotkey.displayName)")
                return nil
            }
            seen.insert(signature)
            return binding
        }
    }

    func handle(_ event: NSEvent) {
        guard event.type == .keyDown else {
            return
        }
        handle(keyCode: event.keyCode, modifiers: event.modifierFlags)
    }

    func handle(_ cgEvent: CGEvent, type: CGEventType) -> Bool {
        guard type == .keyDown else {
            return false
        }

        let keyCode = UInt16(cgEvent.getIntegerValueField(.keyboardEventKeycode))
        let modifiers = NSEvent.ModifierFlags(rawValue: UInt(cgEvent.flags.rawValue))
        return handle(keyCode: keyCode, modifiers: modifiers)
    }

    func handleControl(_ command: ControlCommand) {
        switch command {
        case .playback:
            player.stop()
        case .quit:
            NSApp.terminate(nil)
        case .record, .cancelStep:
            break
        }
    }

    @discardableResult
    private func handle(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        let signature = "\(keyCode):\(modifiers.intersection(HotKey.relevantFlags).rawValue)"
        let now = CACurrentMediaTime()
        guard lastSignature != signature || now - lastPressTime > 0.25 else {
            return true
        }

        lastSignature = signature
        lastPressTime = now

        if let binding = bindings.first(where: { $0.hotkey.matches(keyCode: keyCode, modifiers: modifiers) }) {
            run(binding)
            return true
        }

        if let command = ControlKey.controlEvent(
            keyCode: keyCode,
            modifiers: modifiers,
            isPress: true
        )?.command {
            handleControl(command)
            return true
        }

        return false
    }

    private func run(_ binding: Binding) {
        if player.isRunning, activeURL == binding.url {
            player.stop()
            return
        }

        if player.isRunning {
            player.stop()
        }

        do {
            guard ScreenSupport.requestAccessibilityTrust() else {
                NSLog("Macro hotkey needs Accessibility permission")
                return
            }

            let data = try Data(contentsOf: binding.url)
            let document = try JSONDecoder().decode(MacroDocument.self, from: data)
            guard document.hasBlocks else {
                NSLog("Macro hotkey loaded empty macro: \(binding.url.lastPathComponent)")
                return
            }

            activeURL = binding.url
            player.start(document: document)
            NSLog("Macro hotkey started \(binding.url.lastPathComponent) via \(binding.hotkey.displayName)")
        } catch {
            NSLog("Macro hotkey run failed for \(binding.url.lastPathComponent): \(error.localizedDescription)")
        }
    }

    private func macroURLs() -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return urls
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func binding(for url: URL) -> Binding? {
        do {
            let data = try Data(contentsOf: url)
            let document = try JSONDecoder().decode(MacroDocument.self, from: data)
            guard let hotkey = document.hotkey,
                  hotkey.resolvedKeyCode != nil else {
                return nil
            }
            return Binding(url: url, hotkey: hotkey)
        } catch {
            NSLog("Macro hotkey ignored \(url.lastPathComponent): \(error.localizedDescription)")
            return nil
        }
    }

    private func signature(for hotkey: HotKey) -> String? {
        guard let keyCode = hotkey.resolvedKeyCode else {
            return nil
        }
        return "\(keyCode):\(hotkey.modifierFlags.rawValue)"
    }

    func macroPlayerDidEmit(_ action: MacroAction) {}

    func macroPlayerDidStop(loopCount: Int) {
        NSLog("Macro hotkey stopped after \(loopCount) loop(s)")
        activeURL = nil
    }
}
