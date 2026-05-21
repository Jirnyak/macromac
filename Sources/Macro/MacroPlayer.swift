import AppKit
import CoreGraphics
import Foundation

protocol MacroPlayerDelegate: AnyObject {
    func macroPlayerDidEmit(_ action: MacroAction)
    func macroPlayerDidStop(loopCount: Int)
}

final class MacroPlayer {
    private struct RepeatFrame {
        var blocks: [MacroBlock]
        var index: Int
        var remaining: Int
    }

    weak var delegate: MacroPlayerDelegate?

    private var timer: Timer?
    private var document: MacroDocument?
    private var displayBounds = CGRect.zero
    private var playbackStart = CACurrentMediaTime()
    private var blockStart = CACurrentMediaTime()
    private var stepStart = CACurrentMediaTime()
    private var blockIndex = 0
    private var actionIndex = 0
    private var emittedLoops = 0
    private var repeatStack: [RepeatFrame] = []
    private var blockIsRunning = false
    private var waitSignalSnapshot: SignalSnapshot?
    private var nextPoll = 0.0
    private var activeProcess: Process?
    private var leftButtonIsDown = false
    private var rightButtonIsDown = false
    private let source = CGEventSource(stateID: .hidSystemState)

    var isRunning: Bool {
        timer != nil
    }

    func start(document: MacroDocument, delay: TimeInterval = 0.8) {
        stop(notify: false)
        guard document.hasBlocks else {
            delegate?.macroPlayerDidStop(loopCount: 0)
            return
        }

        self.document = document
        displayBounds = ScreenSupport.mainDisplayBounds()
        playbackStart = CACurrentMediaTime() + delay
        blockIndex = 0
        actionIndex = 0
        emittedLoops = 0
        repeatStack.removeAll(keepingCapacity: true)
        resetBlockState()
        leftButtonIsDown = false
        rightButtonIsDown = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        stop(notify: true)
    }

    private func stop(notify: Bool) {
        releasePressedButtons()
        activeProcess?.terminate()
        activeProcess = nil
        timer?.invalidate()
        timer = nil
        document = nil
        blockIndex = 0
        actionIndex = 0
        repeatStack.removeAll(keepingCapacity: true)
        resetBlockState()
        if notify {
            delegate?.macroPlayerDidStop(loopCount: emittedLoops)
        }
    }

    private func tick() {
        guard let document else {
            stop()
            return
        }

        let now = CACurrentMediaTime()
        guard now >= playbackStart else {
            return
        }

        guard let block = activeBlock(in: document) else {
            return
        }

        run(block, now: now)
    }

    private func run(_ block: MacroBlock, now: Double) {
        switch block.kind {
        case .step:
            runStep(block, now: now)
        case .delay:
            runDelay(block, now: now)
        case .signal:
            runSignal(block, now: now)
        case .condition:
            runCondition(block, now: now)
        case .command:
            runCommand(block, now: now)
        case .repeatBlock:
            runRepeat(block)
        }
    }

    private func runStep(_ block: MacroBlock, now: Double) {
        if !blockIsRunning {
            blockIsRunning = true
            stepStart = CACurrentMediaTime()
            actionIndex = 0
        }

        let actions = block.actions ?? []
        let elapsed = now - stepStart
        while actionIndex < actions.count {
            let action = actions[actionIndex]
            guard action.t <= elapsed else {
                return
            }

            post(action)
            delegate?.macroPlayerDidEmit(action)
            actionIndex += 1
        }

        if elapsed >= block.stepDuration {
            finishBlock()
        }
    }

    private func runDelay(_ block: MacroBlock, now: Double) {
        if !blockIsRunning {
            blockStart = now
            blockIsRunning = true
        }

        if now - blockStart >= max(block.seconds ?? 0, 0) {
            finishBlock()
        }
    }

    private func runSignal(_ block: MacroBlock, now: Double) {
        if !blockIsRunning {
            waitSignalSnapshot = signalSnapshot(path: block.path)
            nextPoll = 0
            blockIsRunning = true
            return
        }

        guard now >= nextPoll else {
            return
        }
        nextPoll = now + max(block.poll ?? 0.1, 0.01)

        guard let waitSignalSnapshot else {
            return
        }

        if signalSnapshot(path: block.path) != waitSignalSnapshot {
            finishBlock()
        }
    }

    private func runCommand(_ block: MacroBlock, now: Double) {
        if !blockIsRunning {
            blockStart = now
            blockIsRunning = true
            startProcess(block)
            return
        }

        guard !timedOut(block, now: now) else {
            fail("command timed out: \(block.command ?? "")")
            return
        }

        guard let process = activeProcess else {
            finishBlock()
            return
        }

        guard !process.isRunning else {
            return
        }

        let status = process.terminationStatus
        activeProcess = nil
        if status == 0 {
            finishBlock()
        } else {
            fail("command failed with exit \(status): \(block.command ?? "")")
        }
    }

    private func runCondition(_ block: MacroBlock, now: Double) {
        if !blockIsRunning {
            blockStart = now
            nextPoll = 0
            blockIsRunning = true
        }

        guard !timedOut(block, now: now) else {
            fail("condition timed out: \(block.command ?? "")")
            return
        }

        if let process = activeProcess {
            guard !process.isRunning else {
                return
            }

            let status = process.terminationStatus
            activeProcess = nil
            if status == 0 {
                finishBlock()
            } else {
                nextPoll = now + max(block.poll ?? 1, 0.05)
            }
            return
        }

        guard now >= nextPoll else {
            return
        }

        startProcess(block)
    }

    private func runRepeat(_ block: MacroBlock) {
        let count = max(block.count ?? 1, 0)
        let blocks = block.blocks ?? []
        guard count > 0, !blocks.isEmpty else {
            finishBlock()
            return
        }

        repeatStack.append(RepeatFrame(blocks: blocks, index: 0, remaining: count))
        resetBlockState()
    }

    private func startProcess(_ block: MacroBlock) {
        guard let command = block.command, !command.isEmpty else {
            fail("empty command block")
            return
        }

        let process = Process()
        let shell = block.shell
            ?? ProcessInfo.processInfo.environment["SHELL"]
            ?? "/bin/zsh"
        process.executableURL = URL(fileURLWithPath: shell)
        process.arguments = ["-lc", command]
        if let cwd = block.cwd, !cwd.isEmpty {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        }

        do {
            try process.run()
            activeProcess = process
        } catch {
            fail("command launch failed: \(error.localizedDescription)")
        }
    }

    private func timedOut(_ block: MacroBlock, now: Double) -> Bool {
        guard let timeout = block.timeout, timeout > 0 else {
            return false
        }
        return now - blockStart > timeout
    }

    private func finishBlock() {
        if repeatStack.isEmpty {
            blockIndex += 1
        } else {
            repeatStack[repeatStack.count - 1].index += 1
        }
        actionIndex = 0
        resetBlockState()
    }

    private func activeBlock(in document: MacroDocument) -> MacroBlock? {
        while true {
            if !repeatStack.isEmpty {
                let frameIndex = repeatStack.count - 1
                if repeatStack[frameIndex].index < repeatStack[frameIndex].blocks.count {
                    return repeatStack[frameIndex].blocks[repeatStack[frameIndex].index]
                }

                if repeatStack[frameIndex].remaining > 1 {
                    repeatStack[frameIndex].remaining -= 1
                    repeatStack[frameIndex].index = 0
                    resetBlockState()
                    continue
                }

                repeatStack.removeLast()
                finishBlock()
                continue
            }

            if blockIndex < document.blocks.count {
                return document.blocks[blockIndex]
            }

            guard document.loop else {
                emittedLoops = max(emittedLoops, 1)
                stop()
                return nil
            }

            emittedLoops += 1
            blockIndex = 0
            resetBlockState()
        }
    }

    private func resetBlockState() {
        blockIsRunning = false
        waitSignalSnapshot = nil
        nextPoll = 0
        activeProcess = nil
    }

    private func fail(_ message: String) {
        NSLog("Macro player: \(message)")
        stop()
    }

    private func post(_ action: MacroAction) {
        let point = CoordinateMapper.displayPoint(action, in: displayBounds)

        switch action.kind {
        case .move:
            postMove(at: point, modifiers: action.modifiers)
        case .leftClick:
            postMouse(type: .mouseMoved, at: point, modifiers: action.modifiers)
            postMouse(type: .leftMouseDown, at: point, modifiers: action.modifiers)
            usleep(35_000)
            postMouse(type: .leftMouseUp, at: point, modifiers: action.modifiers)
        case .rightClick:
            postMouse(type: .mouseMoved, at: point, modifiers: action.modifiers)
            postMouse(type: .rightMouseDown, at: point, button: .right, modifiers: action.modifiers)
            usleep(35_000)
            postMouse(type: .rightMouseUp, at: point, button: .right, modifiers: action.modifiers)
        case .leftDown:
            postMouse(type: .mouseMoved, at: point, modifiers: action.modifiers)
            postMouse(type: .leftMouseDown, at: point, modifiers: action.modifiers)
            leftButtonIsDown = true
        case .leftUp:
            postMouse(type: .leftMouseUp, at: point, modifiers: action.modifiers)
            leftButtonIsDown = false
        case .rightDown:
            postMouse(type: .mouseMoved, at: point, button: .right, modifiers: action.modifiers)
            postMouse(type: .rightMouseDown, at: point, button: .right, modifiers: action.modifiers)
            rightButtonIsDown = true
        case .rightUp:
            postMouse(type: .rightMouseUp, at: point, button: .right, modifiers: action.modifiers)
            rightButtonIsDown = false
        case .keyDown:
            postKey(action, down: true)
        case .keyUp:
            postKey(action, down: false)
        }
    }

    private func postMove(at point: CGPoint, modifiers: UInt64?) {
        if leftButtonIsDown {
            postMouse(type: .leftMouseDragged, at: point, modifiers: modifiers)
        } else if rightButtonIsDown {
            postMouse(type: .rightMouseDragged, at: point, button: .right, modifiers: modifiers)
        } else {
            postMouse(type: .mouseMoved, at: point, modifiers: modifiers)
        }
    }

    private func postMouse(
        type: CGEventType,
        at point: CGPoint,
        button: CGMouseButton = .left,
        modifiers: UInt64? = nil
    ) {
        let event = CGEvent(
            mouseEventSource: source,
            mouseType: type,
            mouseCursorPosition: point,
            mouseButton: button
        )
        if let modifiers {
            event?.flags = CGEventFlags(rawValue: modifiers)
        }
        event?.post(tap: .cghidEventTap)
    }

    private func postKey(_ action: MacroAction, down: Bool) {
        guard let keyCode = action.keyCode else {
            return
        }

        let event = CGEvent(
            keyboardEventSource: source,
            virtualKey: CGKeyCode(keyCode),
            keyDown: down
        )
        if let modifiers = action.modifiers {
            event?.flags = CGEventFlags(rawValue: modifiers)
        }
        event?.post(tap: .cghidEventTap)
    }

    private func releasePressedButtons() {
        guard leftButtonIsDown || rightButtonIsDown,
              let event = CGEvent(source: nil) else {
            return
        }

        let point = event.location
        if leftButtonIsDown {
            postMouse(type: .leftMouseUp, at: point)
            leftButtonIsDown = false
        }
        if rightButtonIsDown {
            postMouse(type: .rightMouseUp, at: point, button: .right)
            rightButtonIsDown = false
        }
    }

    private func signalSnapshot(path: String?) -> SignalSnapshot {
        let url = fileURL(path: path, fallback: "signal.txt")
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return SignalSnapshot(exists: false, size: 0, modifiedAt: 0)
        }

        let size = (attributes[.size] as? NSNumber)?.uint64Value ?? 0
        let modifiedAt = (attributes[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
        return SignalSnapshot(exists: true, size: size, modifiedAt: modifiedAt)
    }

    private func fileURL(path: String?, fallback: String) -> URL {
        let rawPath = path?.isEmpty == false ? path! : fallback
        if rawPath.hasPrefix("/") {
            return URL(fileURLWithPath: rawPath)
        }

        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(rawPath)
    }
}

private struct SignalSnapshot: Equatable {
    var exists: Bool
    var size: UInt64
    var modifiedAt: Double
}
