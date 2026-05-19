import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()

let runnerMode = CommandLine.arguments.contains("--runner")
    || CommandLine.arguments.contains("--dialog")

app.setActivationPolicy(runnerMode ? .accessory : .regular)
app.delegate = delegate
app.run()
