import CoreGraphics
import Foundation
import XCTest
@testable import Macro

final class MacroPlayerTests: XCTestCase, MacroPlayerDelegate {
    private var player: MacroPlayer?
    private var stopExpectation: XCTestExpectation?
    private var stoppedLoopCount: Int?

    func testRepeatBlockRunsNestedCommandCountTimes() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("macro-repeat-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }

        let output = directory.appendingPathComponent("output.txt")
        var document = MacroDocument(
            sourceScreen: CGSize(width: 100, height: 100),
            blocks: [
                MacroBlock(
                    kind: .repeatBlock,
                    count: 3,
                    blocks: [
                        MacroBlock(
                            kind: .command,
                            command: "printf x >> \(Self.shellQuote(output.path))",
                            timeout: 2
                        )
                    ]
                )
            ]
        )
        document.loop = false

        let expectation = expectation(description: "macro stopped")
        stopExpectation = expectation
        player = MacroPlayer()
        player?.delegate = self
        player?.start(document: document, delay: 0)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(try String(contentsOf: output), "xxx")
        XCTAssertEqual(stoppedLoopCount, 1)
    }

    func macroPlayerDidEmit(_ action: MacroAction) {}

    func macroPlayerDidStop(loopCount: Int) {
        stoppedLoopCount = loopCount
        stopExpectation?.fulfill()
    }

    private static func shellQuote(_ text: String) -> String {
        "'\(text.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}
