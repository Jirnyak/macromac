import AppKit

struct KeyDefinition: Equatable {
    var keyCode: UInt16
    var canonicalName: String
    var aliases: [String]
    var displayName: String
    var modifierRole: KeyModifierRole?
}

enum KeyModifierRole: String {
    case command
    case control
    case option
    case shift
    case capsLock
    case function

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
        case .capsLock:
            return .capsLock
        case .function:
            return .function
        }
    }
}

enum KeyMap {
    static let definitions: [KeyDefinition] = [
        KeyDefinition(keyCode: 0, canonicalName: "a", aliases: [], displayName: "A", modifierRole: nil),
        KeyDefinition(keyCode: 1, canonicalName: "s", aliases: [], displayName: "S", modifierRole: nil),
        KeyDefinition(keyCode: 2, canonicalName: "d", aliases: [], displayName: "D", modifierRole: nil),
        KeyDefinition(keyCode: 3, canonicalName: "f", aliases: [], displayName: "F", modifierRole: nil),
        KeyDefinition(keyCode: 4, canonicalName: "h", aliases: [], displayName: "H", modifierRole: nil),
        KeyDefinition(keyCode: 5, canonicalName: "g", aliases: [], displayName: "G", modifierRole: nil),
        KeyDefinition(keyCode: 6, canonicalName: "z", aliases: [], displayName: "Z", modifierRole: nil),
        KeyDefinition(keyCode: 7, canonicalName: "x", aliases: [], displayName: "X", modifierRole: nil),
        KeyDefinition(keyCode: 8, canonicalName: "c", aliases: [], displayName: "C", modifierRole: nil),
        KeyDefinition(keyCode: 9, canonicalName: "v", aliases: [], displayName: "V", modifierRole: nil),
        KeyDefinition(keyCode: 11, canonicalName: "b", aliases: [], displayName: "B", modifierRole: nil),
        KeyDefinition(keyCode: 12, canonicalName: "q", aliases: [], displayName: "Q", modifierRole: nil),
        KeyDefinition(keyCode: 13, canonicalName: "w", aliases: [], displayName: "W", modifierRole: nil),
        KeyDefinition(keyCode: 14, canonicalName: "e", aliases: [], displayName: "E", modifierRole: nil),
        KeyDefinition(keyCode: 15, canonicalName: "r", aliases: [], displayName: "R", modifierRole: nil),
        KeyDefinition(keyCode: 16, canonicalName: "y", aliases: [], displayName: "Y", modifierRole: nil),
        KeyDefinition(keyCode: 17, canonicalName: "t", aliases: [], displayName: "T", modifierRole: nil),
        KeyDefinition(keyCode: 18, canonicalName: "1", aliases: [], displayName: "1", modifierRole: nil),
        KeyDefinition(keyCode: 19, canonicalName: "2", aliases: [], displayName: "2", modifierRole: nil),
        KeyDefinition(keyCode: 20, canonicalName: "3", aliases: [], displayName: "3", modifierRole: nil),
        KeyDefinition(keyCode: 21, canonicalName: "4", aliases: [], displayName: "4", modifierRole: nil),
        KeyDefinition(keyCode: 22, canonicalName: "6", aliases: [], displayName: "6", modifierRole: nil),
        KeyDefinition(keyCode: 23, canonicalName: "5", aliases: [], displayName: "5", modifierRole: nil),
        KeyDefinition(keyCode: 24, canonicalName: "=", aliases: ["equal", "equals"], displayName: "=", modifierRole: nil),
        KeyDefinition(keyCode: 25, canonicalName: "9", aliases: [], displayName: "9", modifierRole: nil),
        KeyDefinition(keyCode: 26, canonicalName: "7", aliases: [], displayName: "7", modifierRole: nil),
        KeyDefinition(keyCode: 27, canonicalName: "-", aliases: ["minus", "dash"], displayName: "-", modifierRole: nil),
        KeyDefinition(keyCode: 28, canonicalName: "8", aliases: [], displayName: "8", modifierRole: nil),
        KeyDefinition(keyCode: 29, canonicalName: "0", aliases: [], displayName: "0", modifierRole: nil),
        KeyDefinition(keyCode: 30, canonicalName: "]", aliases: ["rightBracket"], displayName: "]", modifierRole: nil),
        KeyDefinition(keyCode: 31, canonicalName: "o", aliases: [], displayName: "O", modifierRole: nil),
        KeyDefinition(keyCode: 32, canonicalName: "u", aliases: [], displayName: "U", modifierRole: nil),
        KeyDefinition(keyCode: 33, canonicalName: "[", aliases: ["leftBracket"], displayName: "[", modifierRole: nil),
        KeyDefinition(keyCode: 34, canonicalName: "i", aliases: [], displayName: "I", modifierRole: nil),
        KeyDefinition(keyCode: 35, canonicalName: "p", aliases: [], displayName: "P", modifierRole: nil),
        KeyDefinition(keyCode: 36, canonicalName: "return", aliases: ["enter", "ret"], displayName: "RET", modifierRole: nil),
        KeyDefinition(keyCode: 37, canonicalName: "l", aliases: [], displayName: "L", modifierRole: nil),
        KeyDefinition(keyCode: 38, canonicalName: "j", aliases: [], displayName: "J", modifierRole: nil),
        KeyDefinition(keyCode: 39, canonicalName: "'", aliases: ["quote"], displayName: "'", modifierRole: nil),
        KeyDefinition(keyCode: 40, canonicalName: "k", aliases: [], displayName: "K", modifierRole: nil),
        KeyDefinition(keyCode: 41, canonicalName: ";", aliases: ["semicolon"], displayName: ";", modifierRole: nil),
        KeyDefinition(keyCode: 42, canonicalName: "\\", aliases: ["backslash"], displayName: "\\", modifierRole: nil),
        KeyDefinition(keyCode: 43, canonicalName: ",", aliases: ["comma"], displayName: ",", modifierRole: nil),
        KeyDefinition(keyCode: 44, canonicalName: "/", aliases: ["slash"], displayName: "/", modifierRole: nil),
        KeyDefinition(keyCode: 45, canonicalName: "n", aliases: [], displayName: "N", modifierRole: nil),
        KeyDefinition(keyCode: 46, canonicalName: "m", aliases: [], displayName: "M", modifierRole: nil),
        KeyDefinition(keyCode: 47, canonicalName: ".", aliases: ["period", "dot"], displayName: ".", modifierRole: nil),
        KeyDefinition(keyCode: 48, canonicalName: "tab", aliases: [], displayName: "TAB", modifierRole: nil),
        KeyDefinition(keyCode: 49, canonicalName: "space", aliases: ["spacebar"], displayName: "SPACE", modifierRole: nil),
        KeyDefinition(keyCode: 50, canonicalName: "`", aliases: ["grave", "backtick"], displayName: "`", modifierRole: nil),
        KeyDefinition(keyCode: 51, canonicalName: "delete", aliases: ["del", "backspace"], displayName: "DEL", modifierRole: nil),
        KeyDefinition(keyCode: 53, canonicalName: "escape", aliases: ["esc"], displayName: "ESC", modifierRole: nil),
        KeyDefinition(keyCode: 54, canonicalName: "rightCommand", aliases: ["rightCmd"], displayName: "CMD", modifierRole: .command),
        KeyDefinition(keyCode: 55, canonicalName: "command", aliases: ["cmd", "leftCommand", "leftCmd"], displayName: "CMD", modifierRole: .command),
        KeyDefinition(keyCode: 56, canonicalName: "shift", aliases: ["leftShift"], displayName: "SHIFT", modifierRole: .shift),
        KeyDefinition(keyCode: 57, canonicalName: "capsLock", aliases: ["caps"], displayName: "CAPS", modifierRole: .capsLock),
        KeyDefinition(keyCode: 58, canonicalName: "option", aliases: ["alt", "leftOption", "leftAlt"], displayName: "OPT", modifierRole: .option),
        KeyDefinition(keyCode: 59, canonicalName: "control", aliases: ["ctrl", "leftControl", "leftCtrl"], displayName: "CTRL", modifierRole: .control),
        KeyDefinition(keyCode: 60, canonicalName: "rightShift", aliases: [], displayName: "SHIFT", modifierRole: .shift),
        KeyDefinition(keyCode: 61, canonicalName: "rightOption", aliases: ["rightAlt"], displayName: "OPT", modifierRole: .option),
        KeyDefinition(keyCode: 62, canonicalName: "rightControl", aliases: ["rightCtrl"], displayName: "CTRL", modifierRole: .control),
        KeyDefinition(keyCode: 63, canonicalName: "function", aliases: ["fn"], displayName: "FN", modifierRole: .function),
        KeyDefinition(keyCode: 64, canonicalName: "f17", aliases: [], displayName: "F17", modifierRole: nil),
        KeyDefinition(keyCode: 79, canonicalName: "f18", aliases: [], displayName: "F18", modifierRole: nil),
        KeyDefinition(keyCode: 80, canonicalName: "f19", aliases: [], displayName: "F19", modifierRole: nil),
        KeyDefinition(keyCode: 90, canonicalName: "f20", aliases: [], displayName: "F20", modifierRole: nil),
        KeyDefinition(keyCode: 96, canonicalName: "f5", aliases: [], displayName: "F5", modifierRole: nil),
        KeyDefinition(keyCode: 97, canonicalName: "f6", aliases: [], displayName: "F6", modifierRole: nil),
        KeyDefinition(keyCode: 98, canonicalName: "f7", aliases: [], displayName: "F7", modifierRole: nil),
        KeyDefinition(keyCode: 99, canonicalName: "f3", aliases: [], displayName: "F3", modifierRole: nil),
        KeyDefinition(keyCode: 100, canonicalName: "f8", aliases: [], displayName: "F8", modifierRole: nil),
        KeyDefinition(keyCode: 101, canonicalName: "f9", aliases: [], displayName: "F9", modifierRole: nil),
        KeyDefinition(keyCode: 103, canonicalName: "f11", aliases: [], displayName: "F11", modifierRole: nil),
        KeyDefinition(keyCode: 105, canonicalName: "f13", aliases: [], displayName: "F13", modifierRole: nil),
        KeyDefinition(keyCode: 106, canonicalName: "f16", aliases: [], displayName: "F16", modifierRole: nil),
        KeyDefinition(keyCode: 107, canonicalName: "f14", aliases: [], displayName: "F14", modifierRole: nil),
        KeyDefinition(keyCode: 109, canonicalName: "f10", aliases: [], displayName: "F10", modifierRole: nil),
        KeyDefinition(keyCode: 111, canonicalName: "f12", aliases: [], displayName: "F12", modifierRole: nil),
        KeyDefinition(keyCode: 113, canonicalName: "f15", aliases: [], displayName: "F15", modifierRole: nil),
        KeyDefinition(keyCode: 118, canonicalName: "f4", aliases: [], displayName: "F4", modifierRole: nil),
        KeyDefinition(keyCode: 120, canonicalName: "f2", aliases: [], displayName: "F2", modifierRole: nil),
        KeyDefinition(keyCode: 122, canonicalName: "f1", aliases: [], displayName: "F1", modifierRole: nil),
        KeyDefinition(keyCode: 123, canonicalName: "left", aliases: ["arrowLeft", "leftArrow"], displayName: "LEFT", modifierRole: nil),
        KeyDefinition(keyCode: 124, canonicalName: "right", aliases: ["arrowRight", "rightArrow"], displayName: "RIGHT", modifierRole: nil),
        KeyDefinition(keyCode: 125, canonicalName: "down", aliases: ["arrowDown", "downArrow"], displayName: "DOWN", modifierRole: nil),
        KeyDefinition(keyCode: 126, canonicalName: "up", aliases: ["arrowUp", "upArrow"], displayName: "UP", modifierRole: nil)
    ]

    private static let definitionsByCode = Dictionary(
        uniqueKeysWithValues: definitions.map { ($0.keyCode, $0) }
    )

    private static let keyCodesByName: [String: UInt16] = {
        var result: [String: UInt16] = [:]
        for definition in definitions {
            for name in [definition.canonicalName] + definition.aliases {
                result[normalized(name)] = definition.keyCode
            }
        }
        return result
    }()

    static func keyCode(named name: String) -> UInt16? {
        keyCodesByName[normalized(name)]
    }

    static func displayName(for keyCode: UInt16) -> String {
        definitionsByCode[keyCode]?.displayName ?? "#\(keyCode)"
    }

    static func modifierRole(for keyCode: UInt16) -> KeyModifierRole? {
        definitionsByCode[keyCode]?.modifierRole
    }

    static func code(_ name: StaticName) -> UInt16 {
        keyCode(named: name.rawValue)!
    }

    static let documentedNames: [String] = {
        let functionKeys = (1...20).map { "F\($0)" }
        let letterKeys = (65...90).compactMap { UnicodeScalar($0).map(String.init) }
        let numberKeys = (0...9).map(String.init)
        let namedKeys = ["space", "tab", "return", "escape", "left", "right", "up", "down", "delete"]
        return functionKeys + letterKeys + numberKeys + namedKeys
    }()

    private static func normalized(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

extension KeyMap {
    enum StaticName: String {
        case f1
        case f2
        case f3
        case f4
    }
}
