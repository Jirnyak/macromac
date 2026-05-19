import AppKit
import XCTest
@testable import Macro

final class KeyMapTests: XCTestCase {
    func testDocumentedNamesParseAndDisplay() throws {
        for name in KeyMap.documentedNames {
            let code = try XCTUnwrap(KeyMap.keyCode(named: name), name)
            XCTAssertFalse(KeyMap.displayName(for: code).isEmpty, name)
        }
    }

    func testNamesAreCaseAndWhitespaceInsensitive() {
        XCTAssertEqual(KeyMap.keyCode(named: " f8 "), 100)
        XCTAssertEqual(KeyMap.keyCode(named: "SPACE"), 49)
        XCTAssertEqual(KeyMap.keyCode(named: " Escape "), 53)
    }

    func testAliasesParse() {
        XCTAssertEqual(KeyMap.keyCode(named: "enter"), 36)
        XCTAssertEqual(KeyMap.keyCode(named: "esc"), 53)
        XCTAssertEqual(KeyMap.keyCode(named: "del"), 51)
        XCTAssertEqual(KeyMap.keyCode(named: "backspace"), 51)
        XCTAssertEqual(KeyMap.keyCode(named: "leftArrow"), 123)
        XCTAssertEqual(KeyMap.keyCode(named: "arrowRight"), 124)
    }

    func testFunctionKeysUseStableMacVirtualKeyCodes() {
        let expected: [String: UInt16] = [
            "F1": 122,
            "F2": 120,
            "F3": 99,
            "F4": 118,
            "F5": 96,
            "F6": 97,
            "F7": 98,
            "F8": 100,
            "F9": 101,
            "F10": 109,
            "F11": 103,
            "F12": 111,
            "F13": 105,
            "F14": 107,
            "F15": 113,
            "F16": 106,
            "F17": 64,
            "F18": 79,
            "F19": 80,
            "F20": 90
        ]

        for (name, code) in expected {
            XCTAssertEqual(KeyMap.keyCode(named: name), code, name)
            XCTAssertEqual(KeyMap.displayName(for: code), name)
        }
    }

    func testModifierRoles() {
        XCTAssertEqual(KeyMap.modifierRole(for: 54), .command)
        XCTAssertEqual(KeyMap.modifierRole(for: 55), .command)
        XCTAssertEqual(KeyMap.modifierRole(for: 56), .shift)
        XCTAssertEqual(KeyMap.modifierRole(for: 60), .shift)
        XCTAssertEqual(KeyMap.modifierRole(for: 58), .option)
        XCTAssertEqual(KeyMap.modifierRole(for: 61), .option)
        XCTAssertEqual(KeyMap.modifierRole(for: 59), .control)
        XCTAssertEqual(KeyMap.modifierRole(for: 62), .control)
        XCTAssertEqual(KeyMap.modifierRole(for: 57), .capsLock)
        XCTAssertEqual(KeyMap.modifierRole(for: 63), .function)
        XCTAssertNil(KeyMap.modifierRole(for: 0))
    }

    func testHotKeyUsesKeyMap() {
        let hotkey = HotKey(key: "left", modifiers: [.control, .option])
        XCTAssertEqual(hotkey.resolvedKeyCode, 123)
        XCTAssertEqual(hotkey.displayName, "control+option+LEFT")
    }
}
