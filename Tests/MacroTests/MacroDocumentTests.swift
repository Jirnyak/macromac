import CoreGraphics
import XCTest
@testable import Macro

final class MacroDocumentTests: XCTestCase {
    func testRepeatBlockDecodesNestedBlocks() throws {
        let data = Data("""
        {
          "version": 3,
          "sourceScreen": { "width": 100, "height": 100 },
          "loop": false,
          "blocks": [
            {
              "kind": "repeat",
              "count": 3,
              "blocks": [
                {
                  "kind": "step",
                  "name": "inside",
                  "pace": 0.2,
                  "actions": [
                    { "kind": "move", "x": 0.1, "y": 0.2 }
                  ]
                },
                { "kind": "delay", "seconds": 1 }
              ]
            }
          ]
        }
        """.utf8)

        let document = try JSONDecoder().decode(MacroDocument.self, from: data)
        let repeatBlock = try XCTUnwrap(document.blocks.first)
        let nestedStep = try XCTUnwrap(repeatBlock.blocks?.first)

        XCTAssertEqual(repeatBlock.kind, .repeatBlock)
        XCTAssertEqual(repeatBlock.count, 3)
        XCTAssertEqual(document.stepCount, 1)
        XCTAssertEqual(document.actions.count, 1)
        XCTAssertEqual(nestedStep.actions?.first?.t, 0)
    }

    func testReplaceStepFindsNestedRepeatSteps() {
        var document = MacroDocument(
            sourceScreen: CGSize(width: 100, height: 100),
            blocks: [
                MacroBlock(
                    kind: .repeatBlock,
                    count: 2,
                    blocks: [
                        MacroBlock.step(
                            name: "inside",
                            actions: [MacroAction(kind: .move, x: 0.1, y: 0.2)]
                        )
                    ]
                )
            ]
        )

        let didReplace = document.replaceStep(
            at: 0,
            actions: [MacroAction(kind: .leftClick, x: 0.3, y: 0.4)]
        )
        let nestedAction = document.blocks.first?.blocks?.first?.actions?.first

        XCTAssertTrue(didReplace)
        XCTAssertEqual(nestedAction?.kind, .leftClick)
        XCTAssertEqual(nestedAction?.t, 0)
    }
}
