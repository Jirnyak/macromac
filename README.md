# 🍏 MacroMac — macOS Low-Level HID Event Injection & Automation

[![Live Demo](https://img.shields.io/badge/Live_Showcase-GitHub_Pages-22c55e?style=for-the-badge&logo=github)](https://jirnyak.github.io/macromac/)
[![AI Index](https://img.shields.io/badge/LLM_Search-llms.txt-38bdf8?style=for-the-badge)](https://raw.githubusercontent.com/Jirnyak/macromac/main/llms.txt)
[![C++23](https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus)](https://isocpp.org/)
[![CoreGraphics](https://img.shields.io/badge/macOS-CoreGraphics_HID-000000?style=for-the-badge&logo=apple)](https://developer.apple.com/documentation/coregraphics)

A zero-latency, deterministic macOS keystroke and mouse event injector leveraging native **CoreGraphics `CGEventSource` APIs** and declarative JSON macro automation schemas for high-speed workflow orchestration.

---

## 🏛️ Event Dispatch Pipeline

```mermaid
graph LR
    Macro[JSON Macro Schema] --> Parser[Zero-Allocation AST Parser]
    Parser --> Time[Microsecond Monotonic Timer]
    Time --> CG[CoreGraphics CGEventCreateMouseEvent / Keyboard]
    CG --> Post[CGEventPost (kCGHIDEventTap / kCGSessionEventTap)]
    Post --> OS[macOS Window Server Direct Injection]
```

---

## 🔬 Core Capabilities

1. **Hardware-Accurate HID Timings:** Microsecond jitter reduction avoiding anti-macro detection in automation pipelines.
2. **Declarative JSON Schema:** Complex chording, modifier combinations (Cmd, Option, Ctrl, Shift), and bezier mouse path interpolation.
3. **CoreGraphics Direct Tap:** Bypass user-space bottlenecks by posting directly to `kCGSessionEventTap`.

---

### 👨‍💻 Engineering Syndicate & Authors
- **Жирняк (Jirnyak)** — Core macOS Systems Engineering & HID Intercept.  
  GitHub: [@Jirnyak](https://github.com/Jirnyak)
- **Адольф Петушков (Adolf Petushkov)** — High-Concurrency Systems & Automation Architecture.  
  GitHub: [@marko1olo](https://github.com/marko1olo)
