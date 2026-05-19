import AppKit

final class MacroLauncher: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let macroPopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let nameField = NSTextField(frame: .zero)
    private let statusLabel = NSTextField(labelWithString: "")
    private let directoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("macros", isDirectory: true)

    func start() {
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 520, height: 260),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Macro"
        window.center()
        window.delegate = self

        let content = NSView(frame: window.contentView?.bounds ?? .zero)
        content.autoresizingMask = [.width, .height]
        window.contentView = content

        layout(in: content)
        refreshMacros()

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }

    private func layout(in content: NSView) {
        let title = NSTextField(labelWithString: "Macro Launcher")
        title.font = .systemFont(ofSize: 22, weight: .semibold)
        title.frame = CGRect(x: 24, y: 210, width: 300, height: 28)
        content.addSubview(title)

        let hint = NSTextField(labelWithString: "Choose a macro, or type a new name. JSON lives in ./macros.")
        hint.textColor = .secondaryLabelColor
        hint.frame = CGRect(x: 24, y: 184, width: 460, height: 18)
        content.addSubview(hint)

        macroPopup.frame = CGRect(x: 24, y: 144, width: 220, height: 28)
        macroPopup.target = self
        macroPopup.action = #selector(selectMacro)
        content.addSubview(macroPopup)

        nameField.frame = CGRect(x: 260, y: 145, width: 236, height: 26)
        nameField.placeholderString = "name.json"
        content.addSubview(nameField)

        addButton("New / Overwrite", x: 24, y: 96, width: 148, action: #selector(newMacro))
        addButton("Edit Steps", x: 188, y: 96, width: 132, action: #selector(rewriteSteps))
        addButton("Run", x: 336, y: 96, width: 76, action: #selector(runMacro))
        addButton("Open JSON", x: 24, y: 56, width: 112, action: #selector(openJSON))
        addButton("Refresh", x: 152, y: 56, width: 88, action: #selector(refreshMacrosAction))
        addButton("Hotkeys", x: 256, y: 56, width: 92, action: #selector(runHotkeys))
        addButton("Quit", x: 420, y: 56, width: 76, action: #selector(quit))

        statusLabel.textColor = .secondaryLabelColor
        statusLabel.frame = CGRect(x: 24, y: 22, width: 472, height: 18)
        content.addSubview(statusLabel)

        func addButton(_ title: String, x: CGFloat, y: CGFloat, width: CGFloat, action: Selector) {
            let button = NSButton(title: title, target: self, action: action)
            button.bezelStyle = .rounded
            button.frame = CGRect(x: x, y: y, width: width, height: 30)
            content.addSubview(button)
        }
    }

    @objc private func selectMacro() {
        nameField.stringValue = selectedMacroName() ?? ""
    }

    @objc private func refreshMacrosAction() {
        refreshMacros()
    }

    @objc private func newMacro() {
        if let name = normalizedName() {
            spawn(["--editor", "--macro", name])
        } else {
            spawn(["--editor"])
        }
    }

    @objc private func rewriteSteps() {
        guard let name = normalizedName() else {
            statusLabel.stringValue = "Choose or type a macro name first."
            return
        }
        spawn(["--editor", "--rewrite-steps", "--macro", name])
    }

    @objc private func runMacro() {
        guard let name = normalizedName() else {
            statusLabel.stringValue = "Choose or type a macro name first."
            return
        }
        spawn(["--runner", "--play", "--macro", name])
    }

    @objc private func runHotkeys() {
        spawn(["--hotkeys"])
    }

    @objc private func openJSON() {
        guard let name = normalizedName() else {
            statusLabel.stringValue = "Choose or type a macro name first."
            return
        }
        NSWorkspace.shared.open(fileURL(for: name))
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func refreshMacros() {
        let names = macroNames()
        macroPopup.removeAllItems()
        if names.isEmpty {
            macroPopup.addItem(withTitle: "No macros yet")
            macroPopup.isEnabled = false
            statusLabel.stringValue = "Use New / Overwrite to record the first macro."
            return
        }

        macroPopup.isEnabled = true
        macroPopup.addItems(withTitles: names)
        nameField.stringValue = names.first ?? ""
        statusLabel.stringValue = "\(names.count) macro(s) found."
    }

    private func macroNames() -> [String] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return urls
            .filter { $0.pathExtension == "json" }
            .map(\.lastPathComponent)
            .sorted()
    }

    private func selectedMacroName() -> String? {
        guard macroPopup.isEnabled else {
            return nil
        }
        return macroPopup.titleOfSelectedItem
    }

    private func normalizedName() -> String? {
        let raw = nameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            return selectedMacroName()
        }
        if raw.hasPrefix("/") || raw.contains("/") {
            return raw
        }
        return raw.hasSuffix(".json") ? raw : "\(raw).json"
    }

    private func fileURL(for name: String) -> URL {
        if name.hasPrefix("/") {
            return URL(fileURLWithPath: name)
        }
        if name.contains("/") {
            return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent(name)
        }
        return directoryURL.appendingPathComponent(name)
    }

    private func spawn(_ arguments: [String]) {
        guard let executableURL = Bundle.main.executableURL else {
            statusLabel.stringValue = "Cannot locate macro executable."
            return
        }

        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        do {
            try process.run()
            NSApp.terminate(nil)
        } catch {
            statusLabel.stringValue = "Launch failed: \(error.localizedDescription)"
        }
    }
}
