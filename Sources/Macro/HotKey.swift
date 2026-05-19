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
        let keyText = key ?? keyCode.map { "#\($0)" } ?? "unbound"
        return modifierText.isEmpty ? keyText : "\(modifierText)+\(keyText)"
    }

    func matches(keyCode actualKeyCode: UInt16, modifiers actualModifiers: NSEvent.ModifierFlags) -> Bool {
        guard resolvedKeyCode == actualKeyCode else {
            return false
        }
        return actualModifiers.intersection(Self.relevantFlags) == modifierFlags
    }

    static func keyCode(named rawName: String) -> UInt16? {
        let name = rawName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if let code = functionKeyCodes[name] {
            return code
        }
        if let code = commonKeyCodes[name] {
            return code
        }

        return nil
    }

    private static let functionKeyCodes: [String: UInt16] = [
        "f1": 122,
        "f2": 120,
        "f3": 99,
        "f4": 118,
        "f5": 96,
        "f6": 97,
        "f7": 98,
        "f8": 100,
        "f9": 101,
        "f10": 109,
        "f11": 103,
        "f12": 111,
        "f13": 105,
        "f14": 107,
        "f15": 113,
        "f16": 106,
        "f17": 64,
        "f18": 79,
        "f19": 80,
        "f20": 90
    ]

    private static let commonKeyCodes: [String: UInt16] = [
        "a": 0,
        "s": 1,
        "d": 2,
        "f": 3,
        "h": 4,
        "g": 5,
        "z": 6,
        "x": 7,
        "c": 8,
        "v": 9,
        "b": 11,
        "q": 12,
        "w": 13,
        "e": 14,
        "r": 15,
        "y": 16,
        "t": 17,
        "1": 18,
        "2": 19,
        "3": 20,
        "4": 21,
        "6": 22,
        "5": 23,
        "9": 25,
        "7": 26,
        "8": 28,
        "0": 29,
        "o": 31,
        "u": 32,
        "i": 34,
        "p": 35,
        "return": 36,
        "enter": 36,
        "l": 37,
        "j": 38,
        "k": 40,
        "n": 45,
        "m": 46,
        "tab": 48,
        "space": 49,
        "escape": 53,
        "esc": 53
    ]
}
