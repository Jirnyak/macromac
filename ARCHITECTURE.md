# MacroMac — macOS HID Architecture Specification

## 1. CoreGraphics Event Tap Pipeline
Posts hardware-level keyboard and mouse events directly to `kCGSessionEventTap`:

```mermaid
graph LR
    MacroJSON[Declarative JSON Schema] --> Parser[Zero-GC AST Parser]
    Parser --> CGEvent[CGEventCreateMouseEvent / KeyboardEvent]
    CGEvent --> SessionTap[kCGSessionEventTap WindowServer Dispatch]
```

## 2. Dual Authorship
- **Жирняк (Jirnyak)** — macOS Core Systems & HID Intercept.
- **Адольф Петушков (Adolf Petushkov)** — Systems Architecture.
