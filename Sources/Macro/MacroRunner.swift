import AppKit

final class MacroRunner: NSObject, MacroPlayerDelegate {
    private let store = MacroStore()
    private let player = MacroPlayer()
    private var lastCommand: ControlCommand?
    private var lastCommandTime = -Double.infinity

    override init() {
        super.init()
        player.delegate = self
    }

    var isRunning: Bool {
        player.isRunning
    }

    func play() {
        startPlayback()
    }

    func handle(_ command: ControlCommand) {
        let now = CACurrentMediaTime()
        guard lastCommand != command || now - lastCommandTime > 0.25 else {
            return
        }

        lastCommand = command
        lastCommandTime = now

        switch command {
        case .playback:
            toggle()
        case .quit:
            NSApp.terminate(nil)
        case .record, .cancelStep:
            break
        }
    }

    func stop() {
        player.stop()
    }

    private func toggle() {
        if player.isRunning {
            player.stop()
            return
        }

        startPlayback()
    }

    private func startPlayback() {
        do {
            guard ScreenSupport.requestAccessibilityTrust() else {
                NSLog("Macro runner needs Accessibility permission")
                return
            }

            let document = try store.load()
            guard document.hasBlocks else {
                NSLog("Macro runner loaded empty macro")
                return
            }
            player.start(document: document)
            NSLog("Macro runner started: \(document.blocks.count) block(s), \(document.stepCount) step(s), loop=\(document.loop)")
        } catch {
            NSLog("Macro runner load failed: \(error.localizedDescription)")
        }
    }

    func macroPlayerDidEmit(_ action: MacroAction) {}

    func macroPlayerDidStop(loopCount: Int) {
        NSLog("Macro runner stopped after \(loopCount) loop(s)")
    }

}
