import AppKit
import ImageIO
import UniformTypeIdentifiers

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetURL = root.appendingPathComponent("assets", isDirectory: true)
try FileManager.default.createDirectory(at: assetURL, withIntermediateDirectories: true)

let outputURL = assetURL.appendingPathComponent("demo.gif")
let width = 960
let height = 540
let size = NSSize(width: width, height: height)

struct Slide {
    var title: String
    var body: [String]
    var accent: NSColor
}

let slides = [
    Slide(
        title: "1. Record real input",
        body: [
            "Press F1, click and type in any Mac app.",
            "Press F1 again. The step is saved."
        ],
        accent: NSColor.systemRed
    ),
    Slide(
        title: "2. Inspect editable JSON",
        body: [
            "{ \"version\": 3, \"blocks\": [ { \"kind\": \"step\" } ] }",
            "Actions are plain data, not a closed project file."
        ],
        accent: NSColor.systemGreen
    ),
    Slide(
        title: "3. Add a hotkey",
        body: [
            "\"hotkey\": { \"key\": \"F8\", \"modifiers\": [\"control\", \"option\"] }",
            "Each macro can carry its own launch shortcut."
        ],
        accent: NSColor.systemYellow
    ),
    Slide(
        title: "4. Replay from anywhere",
        body: [
            "Start the hotkey supervisor.",
            "Press control + option + F8 to run the macro."
        ],
        accent: NSColor.systemBlue
    )
]

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: 1
    )
}

func drawText(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, color: NSColor, weight: NSFont.Weight = .regular) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color
    ]
    (text as NSString).draw(at: NSPoint(x: x, y: CGFloat(height) - y - size), withAttributes: attrs)
}

func rect(x: CGFloat, y: CGFloat, width: CGFloat, height rectHeight: CGFloat) -> NSRect {
    NSRect(x: x, y: CGFloat(height) - y - rectHeight, width: width, height: rectHeight)
}

func image(for slide: Slide, index: Int) -> CGImage {
    let image = NSImage(size: size)
    image.lockFocus()

    color(0x0d1117).setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()

    drawText("MacroMac", x: 44, y: 34, size: 42, color: .white, weight: .semibold)
    drawText(
        "open-source JSON macro runner for macOS desktop automation",
        x: 44,
        y: 88,
        size: 22,
        color: color(0x8b949e)
    )

    color(0x161b22).setFill()
    NSBezierPath(roundedRect: rect(x: 44, y: 136, width: 872, height: 312), xRadius: 14, yRadius: 14).fill()
    color(0x30363d).setStroke()
    let outline = NSBezierPath(roundedRect: rect(x: 44, y: 136, width: 872, height: 312), xRadius: 14, yRadius: 14)
    outline.lineWidth = 2
    outline.stroke()

    slide.accent.setFill()
    NSBezierPath(roundedRect: rect(x: 74, y: 174, width: 70, height: 70), xRadius: 12, yRadius: 12).fill()
    drawText("\(index + 1)", x: 100, y: 189, size: 34, color: .white, weight: .bold)

    drawText(slide.title, x: 170, y: 178, size: 36, color: .white, weight: .semibold)

    for (lineIndex, line) in slide.body.enumerated() {
        let y = 260 + CGFloat(lineIndex * 44)
        drawText(line, x: 170, y: y, size: 24, color: color(0xc9d1d9))
    }

    if index == 0 {
        NSColor.systemRed.setFill()
        NSBezierPath(roundedRect: rect(x: 170, y: 362, width: 164, height: 46), xRadius: 23, yRadius: 23).fill()
        drawText("REC  F1 STOP", x: 194, y: 373, size: 20, color: .white, weight: .semibold)
    } else if index == 1 {
        color(0x0d1117).setFill()
        NSBezierPath(roundedRect: rect(x: 170, y: 356, width: 470, height: 58), xRadius: 8, yRadius: 8).fill()
        drawText("\"kind\": \"step\", \"pace\": 0.1", x: 194, y: 373, size: 21, color: color(0x7ee787))
    } else if index == 2 {
        color(0x0d1117).setFill()
        NSBezierPath(roundedRect: rect(x: 170, y: 356, width: 430, height: 58), xRadius: 8, yRadius: 8).fill()
        drawText("control + option + F8", x: 194, y: 373, size: 22, color: color(0xffd33d), weight: .semibold)
    } else {
        NSColor.systemBlue.setFill()
        NSBezierPath(roundedRect: rect(x: 170, y: 356, width: 310, height: 58), xRadius: 8, yRadius: 8).fill()
        drawText("Recorded step -> run", x: 194, y: 373, size: 22, color: .white, weight: .semibold)
    }

    drawText(
        "Recorded step -> JSON -> hotkey run",
        x: 44,
        y: 486,
        size: 23,
        color: color(0x8b949e)
    )

    image.unlockFocus()

    guard let data = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: data),
          let cgImage = rep.cgImage else {
        fatalError("Failed to render slide")
    }
    return cgImage
}

guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.gif.identifier as CFString,
    slides.count,
    nil
) else {
    fatalError("Failed to create GIF destination")
}

CGImageDestinationSetProperties(destination, [
    kCGImagePropertyGIFDictionary: [
        kCGImagePropertyGIFLoopCount: 0
    ]
] as CFDictionary)

for (index, slide) in slides.enumerated() {
    CGImageDestinationAddImage(
        destination,
        image(for: slide, index: index),
        [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: 5.0
            ]
        ] as CFDictionary
    )
}

if !CGImageDestinationFinalize(destination) {
    fatalError("Failed to write GIF")
}

print("Rendered: \(outputURL.path)")
