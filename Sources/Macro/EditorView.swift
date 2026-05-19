import AppKit

enum EditorMode {
    case idle
    case recording
    case playing
}

final class EditorView: NSView {
    weak var controller: MacroController?

    var actions: [MacroAction] = [] {
        didSet { needsDisplay = true }
    }

    var stepCount = 0 {
        didSet { needsDisplay = true }
    }

    var cursorPoint: CGPoint? {
        didSet { needsDisplay = true }
    }

    var mode: EditorMode = .idle {
        didSet { needsDisplay = true }
    }

    var message = "Ready" {
        didSet { needsDisplay = true }
    }

    var controlHint = "F1 record   F2 cancel step   F3 real run   F4 quit" {
        didSet { needsDisplay = true }
    }

    var recordKeyName = "F1" {
        didSet { needsDisplay = true }
    }

    override var isFlipped: Bool {
        true
    }

    override var isOpaque: Bool {
        false
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    private var tracking: NSTrackingArea?

    override func updateTrackingAreas() {
        if let tracking {
            removeTrackingArea(tracking)
        }

        let tracking = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(tracking)
        self.tracking = tracking
        super.updateTrackingAreas()
    }

    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.current?.cgContext.clear(dirtyRect)

        drawTrail()
        drawCursor()
        drawHUD()
    }

    override func mouseMoved(with event: NSEvent) {
        updateCursor(for: event)
    }

    override func mouseDragged(with event: NSEvent) {
        updateCursor(for: event)
    }

    override func mouseDown(with event: NSEvent) {
        let point = boundedPoint(for: event)
        controller?.leftDown(at: point, modifiers: event.modifierFlags)
    }

    override func mouseUp(with event: NSEvent) {
        controller?.leftUp(at: boundedPoint(for: event), modifiers: event.modifierFlags)
    }

    override func rightMouseDown(with event: NSEvent) {
        let point = boundedPoint(for: event)
        controller?.rightDown(at: point, modifiers: event.modifierFlags)
    }

    override func rightMouseUp(with event: NSEvent) {
        controller?.rightUp(at: boundedPoint(for: event), modifiers: event.modifierFlags)
    }

    override func keyDown(with event: NSEvent) {
        controller?.handleKey(event)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        controller?.handleKey(event)
        return true
    }

    override func keyUp(with event: NSEvent) {
        controller?.handleKeyUp(event)
    }

    override func flagsChanged(with event: NSEvent) {
        controller?.handleFlagsChanged(event)
    }

    private func boundedPoint(for event: NSEvent) -> CGPoint {
        let point = convert(event.locationInWindow, from: nil)
        return CGPoint(
            x: min(max(point.x, bounds.minX), bounds.maxX),
            y: min(max(point.y, bounds.minY), bounds.maxY)
        )
    }

    private func updateCursor(for event: NSEvent) {
        let point = boundedPoint(for: event)
        controller?.cursorMoved(to: point)
    }

    private func drawTrail() {
        guard !actions.isEmpty else {
            return
        }

        let path = NSBezierPath()
        path.lineWidth = 2
        var started = false

        for action in actions where drawsTrail(action.kind) {
            let point = CoordinateMapper.viewPoint(action, in: bounds)
            if !started {
                path.move(to: point)
                started = true
            } else {
                path.line(to: point)
            }
        }

        NSColor.systemCyan.withAlphaComponent(0.75).setStroke()
        path.stroke()

        for action in actions where action.kind == .leftClick || action.kind == .leftDown || action.kind == .leftUp {
            let point = CoordinateMapper.viewPoint(action, in: bounds)
            let rect = CGRect(x: point.x - 9, y: point.y - 9, width: 18, height: 18)
            NSColor.systemRed.withAlphaComponent(0.95).setStroke()
            let marker = NSBezierPath(ovalIn: rect)
            marker.lineWidth = 3
            marker.stroke()
            drawActionLabel(mouseLabel(action.kind), at: point, color: .systemRed)
        }

        for action in actions where action.kind == .rightClick || action.kind == .rightDown || action.kind == .rightUp {
            let point = CoordinateMapper.viewPoint(action, in: bounds)
            let rect = CGRect(x: point.x - 8, y: point.y - 8, width: 16, height: 16)
            NSColor.systemOrange.withAlphaComponent(0.95).setStroke()
            let marker = NSBezierPath(rect: rect)
            marker.lineWidth = 3
            marker.stroke()
            drawActionLabel(mouseLabel(action.kind), at: point, color: .systemOrange)
        }

        for action in actions where action.kind == .keyDown {
            guard let keyCode = action.keyCode else {
                continue
            }

            let point = CoordinateMapper.viewPoint(action, in: bounds)
            drawActionLabel(keyName(keyCode), at: point, color: .systemYellow)
        }
    }

    private func drawActionLabel(_ text: String, at point: CGPoint, color: NSColor) {
        guard !text.isEmpty else {
            return
        }

        let font = NSFont(name: "Menlo-Bold", size: 11)
            ?? NSFont.systemFont(ofSize: 11, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white
        ]
        let size = CGSize(width: CGFloat(text.count) * 7, height: 13)
        let rect = CGRect(
            x: min(point.x + 12, bounds.maxX - size.width - 18),
            y: max(point.y - 24, bounds.minY + 8),
            width: size.width + 12,
            height: size.height + 6
        )

        color.withAlphaComponent(0.9).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 5, yRadius: 5).fill()
        (text as NSString).draw(in: rect.insetBy(dx: 6, dy: 3), withAttributes: attributes)
    }

    private func drawsTrail(_ kind: MacroActionKind) -> Bool {
        switch kind {
        case .move, .leftClick, .rightClick, .leftDown, .leftUp, .rightDown, .rightUp:
            return true
        case .keyDown, .keyUp:
            return false
        }
    }

    private func mouseLabel(_ kind: MacroActionKind) -> String {
        switch kind {
        case .leftDown:
            return "LMB down"
        case .leftUp:
            return "LMB up"
        case .rightDown:
            return "RMB down"
        case .rightUp:
            return "RMB up"
        case .leftClick:
            return "LMB"
        case .rightClick:
            return "RMB"
        case .move, .keyDown, .keyUp:
            return ""
        }
    }

    private func keyName(_ keyCode: UInt16) -> String {
        KeyMap.displayName(for: keyCode)
    }

    private func drawCursor() {
        guard let cursorPoint else {
            return
        }

        let size: CGFloat = 15
        let path = NSBezierPath()
        path.lineWidth = 2
        path.move(to: CGPoint(x: cursorPoint.x - size, y: cursorPoint.y))
        path.line(to: CGPoint(x: cursorPoint.x + size, y: cursorPoint.y))
        path.move(to: CGPoint(x: cursorPoint.x, y: cursorPoint.y - size))
        path.line(to: CGPoint(x: cursorPoint.x, y: cursorPoint.y + size))

        NSColor.white.setStroke()
        path.stroke()

        NSColor.black.withAlphaComponent(0.7).setStroke()
        let ring = NSBezierPath(ovalIn: CGRect(x: cursorPoint.x - 4, y: cursorPoint.y - 4, width: 8, height: 8))
        ring.lineWidth = 2
        ring.stroke()
    }

    private func drawHUD() {
        let modeText: String
        switch mode {
        case .idle:
            modeText = "IDLE"
        case .recording:
            modeText = "REC"
        case .playing:
            modeText = "PLAY"
        }

        drawStatusIndicator(modeText)

        let clickCount = actions.filter { drawsTrail($0.kind) && $0.kind != .move }.count
        let keyCount = actions.filter { $0.kind == .keyDown }.count
        let text = """
        \(modeText)  steps \(stepCount)  actions \(actions.count)  clicks \(clickCount)  keys \(keyCount)
        \(controlHint)
        \(message)
        """

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let textSize = (text as NSString).boundingRect(
            with: CGSize(width: 760, height: 200),
            options: [.usesLineFragmentOrigin],
            attributes: attributes
        ).size
        let rect = CGRect(x: 18, y: 56, width: textSize.width + 24, height: textSize.height + 18)
        NSColor.black.withAlphaComponent(0.68).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6).fill()
        (text as NSString).draw(in: rect.insetBy(dx: 12, dy: 9), withAttributes: attributes)
    }

    private func drawStatusIndicator(_ modeText: String) {
        let color: NSColor
        switch mode {
        case .idle:
            color = .systemGreen
        case .recording:
            color = .systemRed
        case .playing:
            color = .systemOrange
        }

        let text = mode == .recording ? "\(recordKeyName) STOP" : modeText
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let rect = CGRect(
            x: (bounds.width - textSize.width - 34) * 0.5,
            y: 16,
            width: textSize.width + 34,
            height: 28
        )

        color.withAlphaComponent(0.92).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 14, yRadius: 14).fill()
        (text as NSString).draw(
            in: CGRect(
                x: rect.minX + 17,
                y: rect.minY + 6,
                width: textSize.width,
                height: textSize.height
            ),
            withAttributes: attributes
        )
    }
}
