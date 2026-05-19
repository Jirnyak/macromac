import AppKit
import CoreGraphics

enum ControlKey {
    private static var bindings = ControlBindings.default

    static let systemEventSubtype: Int16 = 8
    static let systemKeyDown = 0x0A
    static let systemKeyUp = 0x0B
    static let brightnessUp = 2
    static let brightnessDown = 3
    static let launchPanel = 13
    static let missionControl = 32
    static let exposeAll = 160
    static let dashboard = 130
    static let launchpad = 33
    static let launchpadVendor = 0x2A2
    static let spotlight = 0x221
    static let usagePageGenericDesktop = 0x01
    static let usagePageKeyboard = 0x07
    static let usagePageConsumer = 0x0c
    static let usagePageAppleVendorKeyboard = 0xff01
    static let usagePageAppleVendorTopCase = 0x00ff
    static let keyboardF1 = 0x3a
    static let keyboardF2 = 0x3b
    static let keyboardF3 = 0x3c
    static let keyboardF4 = 0x3d
    static let consumerBrightnessUp = 0x6f
    static let consumerBrightnessDown = 0x70
    static let consumerSearch = 0x221
    static let appleVendorTopCaseBrightnessUp = 0x04
    static let appleVendorTopCaseBrightnessDown = 0x05

    static func configure(_ newBindings: ControlBindings) {
        bindings = newBindings
    }

    static func contains(_ keyCode: UInt16) -> Bool {
        bindings.contains(keyCode: keyCode)
    }

    static var editorHint: String {
        "\(displayName(for: .record)) record   " +
        "\(displayName(for: .cancelStep)) cancel step   " +
        "\(displayName(for: .playback)) real run   " +
        "\(displayName(for: .quit)) quit"
    }

    static func displayName(for command: ControlCommand) -> String {
        bindings.hotkey(for: command).displayName
    }

    static func controlEvent(usagePage: Int, usage: Int, isPress: Bool) -> ControlEvent? {
        let keyCode: UInt16?
        switch (usagePage, usage) {
        case (usagePageKeyboard, keyboardF1):
            keyCode = KeyMap.code(.f1)
        case (usagePageKeyboard, keyboardF2):
            keyCode = KeyMap.code(.f2)
        case (usagePageKeyboard, keyboardF3):
            keyCode = KeyMap.code(.f3)
        case (usagePageKeyboard, keyboardF4):
            keyCode = KeyMap.code(.f4)
        case (usagePageConsumer, consumerBrightnessDown):
            keyCode = KeyMap.code(.f1)
        case (usagePageConsumer, consumerBrightnessUp):
            keyCode = KeyMap.code(.f2)
        case (usagePageConsumer, consumerSearch):
            keyCode = KeyMap.code(.f4)
        case (usagePageAppleVendorKeyboard, brightnessDown):
            keyCode = KeyMap.code(.f1)
        case (usagePageAppleVendorKeyboard, brightnessUp):
            keyCode = KeyMap.code(.f2)
        case (usagePageAppleVendorKeyboard, missionControl), (usagePageAppleVendorKeyboard, exposeAll):
            keyCode = KeyMap.code(.f3)
        case (usagePageAppleVendorKeyboard, launchPanel),
             (usagePageAppleVendorKeyboard, launchpad),
             (usagePageAppleVendorKeyboard, spotlight),
             (usagePageAppleVendorKeyboard, dashboard):
            keyCode = KeyMap.code(.f4)
        case (usagePageAppleVendorTopCase, appleVendorTopCaseBrightnessDown):
            keyCode = KeyMap.code(.f1)
        case (usagePageAppleVendorTopCase, appleVendorTopCaseBrightnessUp):
            keyCode = KeyMap.code(.f2)
        default:
            keyCode = nil
        }

        guard let keyCode,
              let command = bindings.command(forKeyCode: keyCode, modifiers: []) else {
            return nil
        }
        return ControlEvent(command: command, isPress: isPress)
    }

    static func controlEvent(
        keyCode: UInt16,
        modifiers: NSEvent.ModifierFlags,
        isPress: Bool
    ) -> ControlEvent? {
        guard let command = command(forKeyCode: keyCode, modifiers: modifiers) else {
            return nil
        }
        return ControlEvent(command: command, isPress: isPress)
    }

    static func controlEvent(for cgEvent: CGEvent, type: CGEventType) -> ControlEvent? {
        switch type {
        case .keyDown, .keyUp:
            let keyCode = UInt16(cgEvent.getIntegerValueField(.keyboardEventKeycode))
            let modifiers = NSEvent.ModifierFlags(rawValue: UInt(cgEvent.flags.rawValue))
            return controlEvent(keyCode: keyCode, modifiers: modifiers, isPress: type == .keyDown)
        default:
            guard type.rawValue == 14, let event = NSEvent(cgEvent: cgEvent) else {
                return nil
            }

            if let pressState = systemPressState(for: event) {
                let keyCode = UInt16(cgEvent.getIntegerValueField(.keyboardEventKeycode))
                if let command = command(forKeyCode: keyCode, modifiers: event.modifierFlags) {
                    return ControlEvent(command: command, isPress: pressState)
                }
            }

            return systemControlEvent(for: event)
        }
    }

    static func controlEvent(for event: NSEvent) -> ControlEvent? {
        switch event.type {
        case .keyDown:
            guard let command = command(forKeyCode: event.keyCode, modifiers: event.modifierFlags) else {
                return nil
            }
            return ControlEvent(command: command, isPress: true)
        case .keyUp:
            guard let command = command(forKeyCode: event.keyCode, modifiers: event.modifierFlags) else {
                return nil
            }
            return ControlEvent(command: command, isPress: false)
        case .systemDefined:
            return systemControlEvent(for: event)
        default:
            return nil
        }
    }

    private static func command(
        forKeyCode keyCode: UInt16,
        modifiers: NSEvent.ModifierFlags
    ) -> ControlCommand? {
        bindings.command(forKeyCode: keyCode, modifiers: modifiers)
    }

    private static func systemControlEvent(for event: NSEvent) -> ControlEvent? {
        guard let isPress = systemPressState(for: event) else {
            return nil
        }

        let keyType = (event.data1 & 0xFFFF0000) >> 16

        let keyCode: UInt16?
        switch keyType {
        case brightnessDown:
            keyCode = KeyMap.code(.f1)
        case brightnessUp:
            keyCode = KeyMap.code(.f2)
        case missionControl, exposeAll:
            keyCode = KeyMap.code(.f3)
        case launchPanel, launchpad, launchpadVendor, spotlight, dashboard:
            keyCode = KeyMap.code(.f4)
        default:
            keyCode = nil
        }

        guard let keyCode,
              let command = command(forKeyCode: keyCode, modifiers: event.modifierFlags) else {
            return nil
        }
        return ControlEvent(command: command, isPress: isPress)
    }

    private static func systemPressState(for event: NSEvent) -> Bool? {
        guard event.subtype.rawValue == systemEventSubtype else {
            return nil
        }

        let state = (event.data1 & 0x0000FF00) >> 8
        switch state {
        case systemKeyDown:
            return true
        case systemKeyUp:
            return false
        default:
            return nil
        }
    }
}

enum ControlCommand: String, CaseIterable, Codable, Equatable {
    case record
    case cancelStep
    case playback
    case quit
}

struct ControlEvent {
    var command: ControlCommand
    var isPress: Bool
}

final class MacroController: NSObject, MacroPlayerDelegate {
    private let store = MacroStore()
    private let player = MacroPlayer()
    private let view = EditorView(frame: .zero)
    private let rewriteStepsMode = CommandLine.arguments.contains("--rewrite-steps")
        || CommandLine.arguments.contains("--rewrite")
    private var window: NSWindow?
    private var document = MacroDocument(sourceScreen: .zero)
    private var currentStepActions: [MacroAction] = []
    private var recordingSessionStarted = false
    private var isRecording = false
    private var rewriteStepOrdinal = 0
    private var lastControlCommand: ControlCommand?
    private var lastControlPressTime = -Double.infinity
    private var lastMovePoint: CGPoint?
    private var accessibilityTrusted = false

    func start() {
        player.delegate = self
        accessibilityTrusted = ScreenSupport.requestAccessibilityTrust()

        let frame = ScreenSupport.mainScreenFrame()
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: NSScreen.main
        )
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.acceptsMouseMovedEvents = true
        window.sharingType = .none
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        view.frame = CGRect(origin: .zero, size: frame.size)
        view.autoresizingMask = [.width, .height]
        view.controller = self
        view.controlHint = ControlKey.editorHint
        view.recordKeyName = recordKey
        window.contentView = view

        self.window = window
        view.message = rewriteStepsMode
            ? "Rewrite steps mode. \(recordKey) rewrites existing steps; \(playbackKey) runs; \(quitKey) quits."
            : "Live overlay. \(recordKey) records new macro; \(playbackKey) runs; \(quitKey) quits."
        loadSavedMacroIfAvailable()
        showEditor()
    }

    func cleanup() {
        player.stop()
    }

    func cursorMoved(to point: CGPoint) {
        view.cursorPoint = point
        guard isRecording else {
            return
        }
        recordMove(to: point)
    }

    func leftDown(at point: CGPoint, modifiers: NSEvent.ModifierFlags) {
        recordMouseButton(kind: .leftDown, at: point, modifiers: modifiers)
    }

    func leftUp(at point: CGPoint, modifiers: NSEvent.ModifierFlags) {
        recordMouseButton(kind: .leftUp, at: point, modifiers: modifiers)
    }

    func rightDown(at point: CGPoint, modifiers: NSEvent.ModifierFlags) {
        recordMouseButton(kind: .rightDown, at: point, modifiers: modifiers)
    }

    func rightUp(at point: CGPoint, modifiers: NSEvent.ModifierFlags) {
        recordMouseButton(kind: .rightUp, at: point, modifiers: modifiers)
    }

    func handleKey(_ event: NSEvent) {
        if let controlEvent = ControlKey.controlEvent(for: event) {
            if controlEvent.isPress {
                handleControlPress(controlEvent.command)
            }
            return
        }

        recordKey(event, kind: .keyDown)
    }

    func handleKeyUp(_ event: NSEvent) {
        guard ControlKey.controlEvent(for: event) == nil else {
            return
        }
        recordKey(event, kind: .keyUp)
    }

    func handleFlagsChanged(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard isRecording else {
            return
        }

        guard let kind = modifierActionKind(keyCode: event.keyCode, flags: flags) else {
            return
        }

        recordKeyCode(event.keyCode, kind: kind, modifiers: flags)
    }

    func handleGlobalKey(_ event: NSEvent) {
        guard let controlEvent = ControlKey.controlEvent(for: event), controlEvent.isPress else {
            return
        }

        switch controlEvent.command {
        case .playback:
            stopPlaybackAndShow()
        case .quit:
            NSApp.terminate(nil)
        case .record, .cancelStep:
            break
        }
    }

    func handleHardwareControlEvent(_ event: NSEvent) -> Bool {
        guard let controlEvent = ControlKey.controlEvent(for: event) else {
            return false
        }

        if controlEvent.isPress {
            handleControlPress(controlEvent.command)
        }
        return true
    }

    func handleHardwareControlEvent(_ cgEvent: CGEvent, type: CGEventType) -> Bool {
        if let controlEvent = ControlKey.controlEvent(for: cgEvent, type: type) {
            if controlEvent.isPress {
                handleControlPress(controlEvent.command)
            }
            return true
        }

        return false
    }

    func handleHIDUsage(page: Int, usage: Int, isPress: Bool) {
        guard let controlEvent = ControlKey.controlEvent(
            usagePage: page,
            usage: usage,
            isPress: isPress
        ) else {
            return
        }

        if controlEvent.isPress {
            handleControlPress(controlEvent.command)
        }
    }

    func stopPlaybackAndShow() {
        guard player.isRunning else {
            showEditor()
            return
        }
        player.stop()
        showEditor()
    }

    func handleOverlayEvent(_ event: CGEvent, type: CGEventType) {
        switch type {
        case .mouseMoved, .leftMouseDragged, .rightMouseDragged:
            cursorMoved(to: viewPoint(from: event.location))
        case .leftMouseDown:
            leftDown(at: viewPoint(from: event.location), modifiers: eventModifiers(event))
        case .leftMouseUp:
            leftUp(at: viewPoint(from: event.location), modifiers: eventModifiers(event))
        case .rightMouseDown:
            rightDown(at: viewPoint(from: event.location), modifiers: eventModifiers(event))
        case .rightMouseUp:
            rightUp(at: viewPoint(from: event.location), modifiers: eventModifiers(event))
        case .keyDown:
            guard let nsEvent = NSEvent(cgEvent: event) else {
                return
            }
            recordKey(nsEvent, kind: .keyDown)
        case .keyUp:
            guard let nsEvent = NSEvent(cgEvent: event) else {
                return
            }
            recordKey(nsEvent, kind: .keyUp)
        case .flagsChanged:
            guard let nsEvent = NSEvent(cgEvent: event) else {
                return
            }
            handleFlagsChanged(nsEvent)
        default:
            break
        }
    }

    func macroPlayerDidEmit(_ action: MacroAction) {
        view.cursorPoint = CoordinateMapper.viewPoint(action, in: view.bounds)
    }

    func macroPlayerDidStop(loopCount: Int) {
        view.mode = .idle
        view.message = loopCount > 0 ? "Playback finished." : "Playback stopped."
        showEditor()
    }

    private func showEditor() {
        guard let window else {
            return
        }
        window.orderFrontRegardless()
    }

    private var recordKey: String {
        ControlKey.displayName(for: .record)
    }

    private var cancelKey: String {
        ControlKey.displayName(for: .cancelStep)
    }

    private var playbackKey: String {
        ControlKey.displayName(for: .playback)
    }

    private var quitKey: String {
        ControlKey.displayName(for: .quit)
    }

    private func hideEditor() {
        window?.orderOut(nil)
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func handleControlCommand(_ command: ControlCommand) {
        switch command {
        case .record:
            toggleRecording()
        case .cancelStep:
            cancelCurrentStep()
        case .playback:
            togglePlayback()
        case .quit:
            NSApp.terminate(nil)
        }
    }

    private func handleControlPress(_ command: ControlCommand) {
        let now = CACurrentMediaTime()
        guard lastControlCommand != command || now - lastControlPressTime > 0.25 else {
            return
        }

        lastControlCommand = command
        lastControlPressTime = now
        handleControlCommand(command)
    }

    private func startRecording() {
        if player.isRunning {
            player.stop()
        }

        if rewriteStepsMode {
            guard document.stepCount > 0 else {
                view.message = "Rewrite mode needs an existing macro with step blocks."
                return
            }
            guard rewriteStepOrdinal < document.stepCount else {
                view.message = "All \(document.stepCount) step(s) already rewritten. \(playbackKey) runs."
                return
            }
            recordingSessionStarted = true
        } else if !recordingSessionStarted {
            if !store.explicitSelection {
                store.useTimestampedMacro()
            }
            document = MacroDocument(sourceScreen: view.bounds.size)
            recordingSessionStarted = true
        }

        isRecording = true
        lastMovePoint = nil
        currentStepActions = []
        view.actions = document.actions
        view.stepCount = rewriteStepsMode ? document.stepCount : document.stepCount + 1
        view.mode = .recording
        let stepNumber = rewriteStepsMode ? rewriteStepOrdinal + 1 : document.stepCount + 1
        view.message = rewriteStepsMode
            ? "Rewriting step \(stepNumber)/\(document.stepCount). \(recordKey) saves replacement."
            : "Recording step \(stepNumber). \(recordKey) saves; \(cancelKey) cancels this step."

        if let point = view.cursorPoint {
            recordMove(to: point, force: true)
        }
    }

    private func stopRecording() {
        isRecording = false
        guard !currentStepActions.isEmpty else {
            view.stepCount = document.stepCount
            view.mode = .idle
            let stepNumber = rewriteStepsMode ? rewriteStepOrdinal + 1 : document.stepCount + 1
            view.message = "Empty step ignored. \(recordKey) records step \(stepNumber)."
            return
        }

        let stepNumber: Int
        let messagePrefix: String
        if rewriteStepsMode {
            stepNumber = rewriteStepOrdinal + 1
            guard document.replaceStep(at: rewriteStepOrdinal, actions: currentStepActions) else {
                currentStepActions = []
                view.mode = .idle
                view.message = "Rewrite failed: step \(stepNumber) does not exist."
                return
            }
            rewriteStepOrdinal += 1
            messagePrefix = rewriteStepOrdinal < document.stepCount
                ? "Step \(stepNumber) rewritten. \(recordKey) rewrites step \(rewriteStepOrdinal + 1)."
                : "Step \(stepNumber) rewritten. All steps done; \(playbackKey) runs."
        } else {
            stepNumber = document.stepCount + 1
            document.appendStep(MacroBlock.step(
                name: "step \(stepNumber)",
                actions: currentStepActions
            ))
            messagePrefix = "Step \(stepNumber) saved. \(recordKey) records next; \(playbackKey) runs."
        }
        currentStepActions = []
        view.actions = document.actions
        view.stepCount = document.stepCount
        view.mode = .idle
        saveCurrentMacro(messagePrefix: messagePrefix)
    }

    private func cancelCurrentStep() {
        guard isRecording else {
            let stepNumber = rewriteStepsMode ? rewriteStepOrdinal + 1 : document.stepCount + 1
            view.message = "No active recording. \(recordKey) records step \(stepNumber)."
            return
        }

        isRecording = false
        currentStepActions = []
        lastMovePoint = nil
        view.actions = document.actions
        view.stepCount = document.stepCount
        view.mode = .idle
        let stepNumber = rewriteStepsMode ? rewriteStepOrdinal + 1 : document.stepCount + 1
        view.message = "Step \(stepNumber) canceled. \(recordKey) records it again."
    }

    private func recordMouseButton(
        kind: MacroActionKind,
        at point: CGPoint,
        modifiers: NSEvent.ModifierFlags
    ) {
        view.cursorPoint = point
        guard isRecording else {
            return
        }

        recordMove(to: point, force: true)
        let normalized = CoordinateMapper.normalized(point, in: view.bounds)
        let action = MacroAction(
            kind: kind,
            x: normalized.x,
            y: normalized.y,
            modifiers: cgModifierFlags(modifiers)
        )
        append(action)
        view.message = "Captured \(mouseActionLabel(kind))"
    }

    private func recordKey(_ event: NSEvent, kind: MacroActionKind) {
        guard isRecording else {
            return
        }
        recordKeyCode(event.keyCode, kind: kind, modifiers: event.modifierFlags)
    }

    private func recordKeyCode(
        _ keyCode: UInt16,
        kind: MacroActionKind,
        modifiers: NSEvent.ModifierFlags
    ) {
        guard keyCode != 63 else {
            return
        }

        let normalized = normalizedCursorPoint()
        let action = MacroAction(
            kind: kind,
            x: normalized.x,
            y: normalized.y,
            keyCode: keyCode,
            modifiers: cgModifierFlags(modifiers)
        )
        append(action)
        if kind == .keyDown {
            view.message = "Captured key \(keyCode)"
        }
    }

    private func recordMove(to point: CGPoint, force: Bool = false) {
        let dx = point.x - (lastMovePoint?.x ?? point.x)
        let dy = point.y - (lastMovePoint?.y ?? point.y)
        let movedEnough = dx * dx + dy * dy >= 4

        guard force || movedEnough else {
            return
        }

        let normalized = CoordinateMapper.normalized(point, in: view.bounds)
        let action = MacroAction(kind: .move, x: normalized.x, y: normalized.y)
        append(action)
        lastMovePoint = point
    }

    private func append(_ action: MacroAction) {
        currentStepActions.append(action)
        view.actions = document.actions + currentStepActions
    }

    private func mouseActionLabel(_ kind: MacroActionKind) -> String {
        switch kind {
        case .leftDown:
            return "left down"
        case .leftUp:
            return "left up"
        case .rightDown:
            return "right down"
        case .rightUp:
            return "right up"
        case .leftClick:
            return "left click"
        case .rightClick:
            return "right click"
        case .move, .keyDown, .keyUp:
            return "input"
        }
    }

    private func togglePlayback() {
        if player.isRunning {
            stopPlaybackAndShow()
            return
        }

        if isRecording {
            stopRecording()
        }

        guard document.hasBlocks else {
            view.message = "No macro blocks. Press \(recordKey) and record first step."
            return
        }

        accessibilityTrusted = ScreenSupport.requestAccessibilityTrust()
        guard accessibilityTrusted else {
            view.message = "Accessibility permission is required for real playback."
            return
        }

        saveCurrentMacro(messagePrefix: "Playback starts after editor hides.")
        view.mode = .playing
        view.message = "Real playback running. Press \(playbackKey)/\(quitKey) to stop."
        hideEditor()
        player.start(document: document)
    }

    private func saveCurrentMacro(messagePrefix: String = "Saved.") {
        do {
            try store.save(document)
            view.message = "\(messagePrefix) \(store.url.path)"
        } catch {
            view.message = "Save failed: \(error.localizedDescription)"
        }
    }

    private func loadSavedMacroIfAvailable() {
        guard FileManager.default.fileExists(atPath: store.url.path) else {
            return
        }

        do {
            document = try store.load()
            view.actions = document.actions
            view.stepCount = document.stepCount
            let baseMessage = view.message
            view.message = rewriteStepsMode
                ? "\(baseMessage) Loaded \(document.blocks.count) block(s), \(document.stepCount) step(s). \(recordKey) rewrites step 1."
                : "\(baseMessage) Loaded \(document.blocks.count) block(s), \(document.stepCount) step(s). \(recordKey) starts a new macro file."
        } catch {
            view.message = "Load failed: \(error.localizedDescription)"
        }
    }

    private func normalizedCursorPoint() -> (x: Double, y: Double) {
        if let cursorPoint = view.cursorPoint {
            return CoordinateMapper.normalized(cursorPoint, in: view.bounds)
        }
        return (0.5, 0.5)
    }

    private func cgModifierFlags(_ flags: NSEvent.ModifierFlags) -> UInt64 {
        UInt64(flags.intersection(.deviceIndependentFlagsMask).rawValue)
    }

    private func eventModifiers(_ event: CGEvent) -> NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: UInt(event.flags.rawValue))
    }

    private func viewPoint(from displayPoint: CGPoint) -> CGPoint {
        let displayBounds = ScreenSupport.mainDisplayBounds()
        return CGPoint(
            x: displayPoint.x - displayBounds.minX,
            y: displayPoint.y - displayBounds.minY
        )
    }

    private func modifierActionKind(
        keyCode: UInt16,
        flags: NSEvent.ModifierFlags
    ) -> MacroActionKind? {
        guard let role = KeyMap.modifierRole(for: keyCode) else {
            return nil
        }

        return flags.contains(role.flag) ? .keyDown : .keyUp
    }
}
