import AppKit
import ApplicationServices
import CoreGraphics

enum ScreenSupport {
    static func mainScreenFrame() -> CGRect {
        NSScreen.main?.frame ?? CGDisplayBounds(CGMainDisplayID())
    }

    static func mainDisplayBounds() -> CGRect {
        CGDisplayBounds(CGMainDisplayID())
    }

    static func requestAccessibilityTrust() -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}

enum CoordinateMapper {
    static func normalized(_ point: CGPoint, in bounds: CGRect) -> (x: Double, y: Double) {
        let width = max(bounds.width, 1)
        let height = max(bounds.height, 1)
        let x = min(max(point.x / width, 0), 1)
        let y = min(max(point.y / height, 0), 1)
        return (Double(x), Double(y))
    }

    static func viewPoint(_ action: MacroAction, in bounds: CGRect) -> CGPoint {
        CGPoint(x: bounds.width * action.x, y: bounds.height * action.y)
    }

    static func displayPoint(_ action: MacroAction, in displayBounds: CGRect) -> CGPoint {
        CGPoint(
            x: displayBounds.minX + displayBounds.width * action.x,
            y: displayBounds.minY + displayBounds.height * action.y
        )
    }
}
