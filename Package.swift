// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Macro",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "macro", targets: ["Macro"])
    ],
    targets: [
        .executableTarget(name: "Macro")
    ]
)
