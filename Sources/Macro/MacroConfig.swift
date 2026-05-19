import AppKit
import Foundation

struct MacroConfig: Codable {
    var version: Int
    var controls: MacroControls?

    static let filename = "macro.config.json"

    static func load() -> MacroConfig {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            return MacroConfig(version: 1, controls: nil)
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(MacroConfig.self, from: data)
        } catch {
            NSLog("Macro config ignored: \(error.localizedDescription)")
            return MacroConfig(version: 1, controls: nil)
        }
    }

    var controlBindings: ControlBindings {
        ControlBindings(controls: controls)
    }
}

struct MacroControls: Codable {
    var record: HotKey?
    var cancelStep: HotKey?
    var playback: HotKey?
    var quit: HotKey?
}

struct ControlBindings {
    private var map: [ControlCommand: HotKey]

    static let `default` = ControlBindings(map: [
        .record: HotKey(key: "F1"),
        .cancelStep: HotKey(key: "F2"),
        .playback: HotKey(key: "F3"),
        .quit: HotKey(key: "F4")
    ])

    init(controls: MacroControls?) {
        self = .default
        if let record = controls?.record {
            map[.record] = record
        }
        if let cancelStep = controls?.cancelStep {
            map[.cancelStep] = cancelStep
        }
        if let playback = controls?.playback {
            map[.playback] = playback
        }
        if let quit = controls?.quit {
            map[.quit] = quit
        }
    }

    private init(map: [ControlCommand: HotKey]) {
        self.map = map
    }

    func command(forKeyCode keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> ControlCommand? {
        for command in ControlCommand.allCases {
            guard let hotkey = map[command],
                  hotkey.matches(keyCode: keyCode, modifiers: modifiers) else {
                continue
            }
            return command
        }
        return nil
    }

    func hotkey(for command: ControlCommand) -> HotKey {
        map[command] ?? Self.default.map[command]!
    }

    func contains(keyCode: UInt16) -> Bool {
        map.values.contains { $0.resolvedKeyCode == keyCode }
    }
}
