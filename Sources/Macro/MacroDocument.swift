import CoreGraphics
import Foundation

struct ScreenSize: Codable {
    var width: Double
    var height: Double

    init(_ size: CGSize) {
        width = size.width
        height = size.height
    }
}

enum MacroActionKind: String, Codable {
    case move
    case leftClick
    case rightClick
    case leftDown
    case leftUp
    case rightDown
    case rightUp
    case keyDown
    case keyUp
}

enum MacroBlockKind: String, Codable {
    case step
    case delay
    case signal
    case condition
    case command
    case repeatBlock = "repeat"
}

struct MacroAction: Codable {
    var kind: MacroActionKind
    var t: Double
    var x: Double
    var y: Double
    var keyCode: UInt16? = nil
    var modifiers: UInt64? = nil

    private enum CodingKeys: String, CodingKey {
        case kind
        case x
        case y
        case keyCode
        case modifiers
    }

    init(
        kind: MacroActionKind,
        t: Double = -1,
        x: Double,
        y: Double,
        keyCode: UInt16? = nil,
        modifiers: UInt64? = nil
    ) {
        self.kind = kind
        self.t = t
        self.x = x
        self.y = y
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(MacroActionKind.self, forKey: .kind)
        t = -1
        x = try container.decode(Double.self, forKey: .x)
        y = try container.decode(Double.self, forKey: .y)
        keyCode = try container.decodeIfPresent(UInt16.self, forKey: .keyCode)
        modifiers = try container.decodeIfPresent(UInt64.self, forKey: .modifiers)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encodeIfPresent(keyCode, forKey: .keyCode)
        try container.encodeIfPresent(modifiers, forKey: .modifiers)
    }
}

struct MacroBlock: Codable {
    var kind: MacroBlockKind
    var name: String? = nil
    var seconds: Double? = nil
    var path: String? = nil
    var command: String? = nil
    var cwd: String? = nil
    var shell: String? = nil
    var timeout: Double? = nil
    var poll: Double? = nil
    var pace: Double? = nil
    var compactMoves: Bool? = nil
    var count: Int? = nil
    var actions: [MacroAction]? = nil
    var blocks: [MacroBlock]? = nil

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
        case seconds
        case path
        case command
        case cwd
        case shell
        case timeout
        case poll
        case pace
        case compactMoves
        case count
        case actions
        case blocks
    }

    static func step(name: String, actions: [MacroAction]) -> MacroBlock {
        MacroBlock(
            kind: .step,
            name: name,
            actions: actions
        )
    }

    var stepDuration: Double {
        max(actions?.last?.t ?? 0, 0.05)
    }

    var nominalSeconds: Double {
        switch kind {
        case .delay:
            return max(seconds ?? 0, 0)
        case .step:
            return stepDuration
        case .signal, .condition, .command:
            return 0
        case .repeatBlock:
            let childSeconds = blocks?.reduce(0) { $0 + $1.nominalSeconds } ?? 0
            return Double(max(count ?? 1, 0)) * childSeconds
        }
    }

    init(
        kind: MacroBlockKind,
        name: String? = nil,
        seconds: Double? = nil,
        path: String? = nil,
        command: String? = nil,
        cwd: String? = nil,
        shell: String? = nil,
        timeout: Double? = nil,
        poll: Double? = nil,
        pace: Double? = nil,
        compactMoves: Bool? = nil,
        count: Int? = nil,
        actions: [MacroAction]? = nil,
        blocks: [MacroBlock]? = nil
    ) {
        self.kind = kind
        self.name = name
        self.seconds = seconds
        self.path = path
        self.command = command
        self.cwd = cwd
        self.shell = shell
        self.timeout = timeout
        self.poll = poll
        self.pace = pace
        self.compactMoves = compactMoves
        self.count = count
        self.actions = actions
        self.blocks = blocks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(MacroBlockKind.self, forKey: .kind)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        seconds = try container.decodeIfPresent(Double.self, forKey: .seconds)
        path = try container.decodeIfPresent(String.self, forKey: .path)
        command = try container.decodeIfPresent(String.self, forKey: .command)
        cwd = try container.decodeIfPresent(String.self, forKey: .cwd)
        shell = try container.decodeIfPresent(String.self, forKey: .shell)
        timeout = try container.decodeIfPresent(Double.self, forKey: .timeout)
        poll = try container.decodeIfPresent(Double.self, forKey: .poll)
        pace = try container.decodeIfPresent(Double.self, forKey: .pace)
        compactMoves = try container.decodeIfPresent(Bool.self, forKey: .compactMoves)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        actions = try container.decodeIfPresent([MacroAction].self, forKey: .actions)
        blocks = try container.decodeIfPresent([MacroBlock].self, forKey: .blocks)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(seconds, forKey: .seconds)
        try container.encodeIfPresent(path, forKey: .path)
        try container.encodeIfPresent(command, forKey: .command)
        try container.encodeIfPresent(cwd, forKey: .cwd)
        try container.encodeIfPresent(shell, forKey: .shell)
        try container.encodeIfPresent(timeout, forKey: .timeout)
        try container.encodeIfPresent(poll, forKey: .poll)
        try container.encodeIfPresent(pace, forKey: .pace)
        try container.encodeIfPresent(compactMoves, forKey: .compactMoves)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(actions, forKey: .actions)
        try container.encodeIfPresent(blocks, forKey: .blocks)
    }
}

struct MacroDocument: Codable {
    var version: Int
    var hotkey: HotKey?
    var sourceScreen: ScreenSize
    var loop: Bool
    var blocks: [MacroBlock]

    static let defaultPace = 0.1

    private enum CodingKeys: String, CodingKey {
        case version
        case hotkey
        case sourceScreen
        case loop
        case blocks
    }

    init(sourceScreen: CGSize, blocks: [MacroBlock] = []) {
        version = 3
        hotkey = nil
        self.sourceScreen = ScreenSize(sourceScreen)
        loop = true
        self.blocks = blocks.map { Self.normalizedBlock($0) }
    }

    var stepCount: Int {
        blocks.reduce(0) { $0 + Self.stepCount(in: $1) }
    }

    var hasBlocks: Bool {
        !blocks.isEmpty
    }

    var actions: [MacroAction] {
        blocks.flatMap(Self.actions(in:))
    }

    mutating func appendStep(_ step: MacroBlock) {
        blocks.append(Self.normalizedBlock(step))
    }

    mutating func replaceStep(at ordinal: Int, actions: [MacroAction]) -> Bool {
        var current = 0
        return Self.replaceStep(in: &blocks, ordinal: ordinal, current: &current, actions: actions)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 3
        hotkey = try container.decodeIfPresent(HotKey.self, forKey: .hotkey)
        sourceScreen = try container.decodeIfPresent(ScreenSize.self, forKey: .sourceScreen)
            ?? ScreenSize(CGDisplayBounds(CGMainDisplayID()).size)
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? true
        blocks = try container.decodeIfPresent([MacroBlock].self, forKey: .blocks) ?? []
        blocks = blocks.map { Self.normalizedBlock($0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(hotkey, forKey: .hotkey)
        try container.encode(sourceScreen, forKey: .sourceScreen)
        try container.encode(loop, forKey: .loop)
        try container.encode(blocks, forKey: .blocks)
    }

    private static func normalizedBlock(_ block: MacroBlock) -> MacroBlock {
        if block.kind == .repeatBlock {
            var next = block
            next.count = max(next.count ?? 1, 0)
            next.blocks = (next.blocks ?? []).map(normalizedBlock)
            return next
        }

        guard block.kind == .step else {
            return block
        }

        var next = block
        if next.compactMoves ?? true {
            next.actions = compactedMoves(next.actions ?? [])
            next.compactMoves = true
        }

        let pace = max(next.pace ?? defaultPace, 0.01)
        var cursor = 0.0
        var actions = next.actions ?? []
        for index in actions.indices {
            actions[index].t = cursor
            cursor = max(cursor, actions[index].t + pace)
        }

        next.actions = actions
        return next
    }

    private static func stepCount(in block: MacroBlock) -> Int {
        switch block.kind {
        case .step:
            return 1
        case .repeatBlock:
            return block.blocks?.reduce(0) { $0 + stepCount(in: $1) } ?? 0
        case .delay, .signal, .condition, .command:
            return 0
        }
    }

    private static func actions(in block: MacroBlock) -> [MacroAction] {
        switch block.kind {
        case .step:
            return block.actions ?? []
        case .repeatBlock:
            return block.blocks?.flatMap(actions(in:)) ?? []
        case .delay, .signal, .condition, .command:
            return []
        }
    }

    private static func replaceStep(
        in blocks: inout [MacroBlock],
        ordinal: Int,
        current: inout Int,
        actions: [MacroAction]
    ) -> Bool {
        for index in blocks.indices {
            switch blocks[index].kind {
            case .step:
                if current == ordinal {
                    blocks[index].actions = actions
                    blocks[index] = normalizedBlock(blocks[index])
                    return true
                }
                current += 1
            case .repeatBlock:
                var childBlocks = blocks[index].blocks ?? []
                if replaceStep(in: &childBlocks, ordinal: ordinal, current: &current, actions: actions) {
                    blocks[index].blocks = childBlocks
                    blocks[index] = normalizedBlock(blocks[index])
                    return true
                }
            case .delay, .signal, .condition, .command:
                break
            }
        }
        return false
    }

    private static func compactedMoves(_ actions: [MacroAction]) -> [MacroAction] {
        var result: [MacroAction] = []
        var run: [MacroAction] = []

        func flushRun() {
            guard !run.isEmpty else {
                return
            }

            if run.count == 1 {
                result.append(run[0])
            } else {
                result.append(run[0])
                result.append(run[run.count - 1])
            }
            run.removeAll(keepingCapacity: true)
        }

        for action in actions {
            if action.kind == .move {
                run.append(action)
            } else {
                flushRun()
                result.append(action)
            }
        }

        flushRun()
        return result
    }
}
