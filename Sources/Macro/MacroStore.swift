import Foundation

final class MacroStore {
    let directoryURL: URL
    let explicitSelection: Bool
    private(set) var url: URL

    init() {
        let fileManager = FileManager.default
        let baseURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        directoryURL = baseURL.appendingPathComponent("macros", isDirectory: true)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        explicitSelection = Self.selectedValue(arguments: CommandLine.arguments) != nil
        url = Self.selectedURL(arguments: CommandLine.arguments, directoryURL: directoryURL)
        migrateRootMacroIfNeeded(baseURL: baseURL)
    }

    func save(_ document: MacroDocument) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(document)
        try data.write(to: url, options: .atomic)
    }

    func load() throws -> MacroDocument {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(MacroDocument.self, from: data)
    }

    func useTimestampedMacro() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        url = directoryURL.appendingPathComponent("macro-\(formatter.string(from: Date())).json")
    }

    private static func selectedURL(arguments: [String], directoryURL: URL) -> URL {
        guard let value = selectedValue(arguments: arguments) else {
            return directoryURL.appendingPathComponent("macro.json")
        }

        if value.hasPrefix("/") {
            return URL(fileURLWithPath: value)
        }
        if value.contains("/") {
            return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent(value)
        }

        let filename = value.hasSuffix(".json") ? value : "\(value).json"
        return directoryURL.appendingPathComponent(filename)
    }

    private static func selectedValue(arguments: [String]) -> String? {
        if let value = value(after: "--dialog", in: arguments) {
            return value
        }
        if arguments.contains("--dialog") {
            return "dialog.json"
        }
        return value(after: "--macro", in: arguments)
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else {
            return nil
        }

        let value = arguments[index + 1]
        return value.hasPrefix("--") ? nil : value
    }

    private func migrateRootMacroIfNeeded(baseURL: URL) {
        let fileManager = FileManager.default
        let oldURL = baseURL.appendingPathComponent("macro.json")
        guard url == directoryURL.appendingPathComponent("macro.json"),
              fileManager.fileExists(atPath: oldURL.path),
              !fileManager.fileExists(atPath: url.path) else {
            return
        }

        try? fileManager.copyItem(at: oldURL, to: url)
    }
}
