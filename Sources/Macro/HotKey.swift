import AppKit

enum HotKeyModifier: String, Codable {
    case command
    case control
    case option
    case shift
    case function

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch raw {
        case "command", "cmd":
            self = .command
        case "control", "ctrl":
            self = .control
        case "option", "alt":
            self = .option
        case "shift":
            self = .shift
        case "function", "fn":
            self = .function
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown hotkey modifier: \(raw)"
            )
        }
    }

    var flag: NSEvent.ModifierFlags {
        switch self {
        case .command:
            return .command
        case .control:
            return .control
        case .option:
            return .option
        case .shift:
            return .shift
        case .function:
            return .function
        }
    }
}

struct HotKey: Codable, Equatable {
    var key: String? = nil
    var keyCode: UInt16? = nil
    var modifiers: [HotKeyModifier]? = nil

    static let relevantFlags: NSEvent.ModifierFlags = [
        .command,
        .control,
        .option,
        .shift,
        .function
    ]

    init(key: String? = nil, keyCode: UInt16? = nil, modifiers: [HotKeyModifier]? = nil) {
        self.key = key
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    var resolvedKeyCode: UInt16? {
        keyCode ?? key.flatMap(Self.keyCode(named:))
    }

    var modifierFlags: NSEvent.ModifierFlags {
        (modifiers ?? []).reduce([]) { result, modifier in
            result.union(modifier.flag)
        }
    }

    var displayName: String {
        let modifierText = (modifiers ?? [])
            .map(\.rawValue)
            .joined(separator: "+")
        let keyText = resolvedKeyCode.map(KeyMap.displayName) ?? key ?? "unbound"
        return modifierText.isEmpty ? keyText : "\(modifierText)+\(keyText)"
    }

    func matches(keyCode actualKeyCode: UInt16, modifiers actualModifiers: NSEvent.ModifierFlags) -> Bool {
        guard resolvedKeyCode == actualKeyCode else {
            return false
        }
        return actualModifiers.intersection(Self.relevantFlags) == modifierFlags
    }

    static func keyCode(named rawName: String) -> UInt16? {
        KeyMap.keyCode(named: rawName)
    }
}
