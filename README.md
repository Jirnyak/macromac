<div align="center">

<img src="https://raw.githubusercontent.com/marko1olo/gigahrush/main/docs/banner_macromac.jpg" width="100%" alt="MacroMac Banner"/>

# 🍎 MacroMac — JSON Macro Runner for macOS Desktop Automation

[![Language](https://img.shields.io/badge/Language-Swift-orange?style=for-the-badge&logo=swift)]()
[![Platform](https://img.shields.io/badge/Platform-macOS-black?style=for-the-badge&logo=apple)]()
[![License](https://img.shields.io/badge/License-Open-brightgreen?style=for-the-badge)](LICENSE)

> **Open-source JSON macro runner for macOS — records mouse and keyboard input over live apps, replays with delays, shell commands, file signals.**

</div>

---

<div align="center">

# 🍎 MacroMac — JSON Macro Runner for macOS Desktop Automation

[![Language](https://img.shields.io/badge/Swift-macOS-orange?style=for-the-badge&logo=swift)]()
[![Platform](https://img.shields.io/badge/Platform-macOS%20only-black?style=for-the-badge&logo=apple)]()
[![License](https://img.shields.io/badge/License-Open%20Source-brightgreen?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Jirnyak/macromac?style=for-the-badge&color=gold)]()

> **Open-source JSON macro runner for macOS — records mouse and keyboard input over live applications, stores as editable JSON, replays with delays, shell commands, file signals, and polling conditions.**

[📥 Download](#getting-started) &nbsp;·&nbsp; [📖 Examples](macros/) &nbsp;·&nbsp; [🐛 Issues](../../issues) &nbsp;·&nbsp; [🤝 Contribute](#contributing)

</div>

---

## 📖 About

**MacroMac** records mouse and keyboard input over live macOS applications, stores it as human-editable JSON, and replays it with structured synchronization primitives: delays, shell commands, file signals, and polling conditions.

It operates at a universal low level — no app-specific APIs, no browser extensions, no per-site integrations. If a workflow can be driven by mouse, keyboard, files, and shell commands, MacroMac can represent it.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🖱️ **Input Recording** | Records mouse moves, clicks, drags, scroll, and keyboard input with precise timestamps |
| 📝 **Editable JSON** | All macros are human-readable JSON — edit, version control, diff, share |
| ⏱️ **Delay Blocks** | Fixed and relative delays between actions for reliable replay |
| 🖥️ **Shell Commands** | Execute terminal commands as part of a macro sequence |
| 📁 **File Signals** | Watch files as synchronization signals — wait until a file appears/changes |
| 🔄 **Polling Conditions** | Loop and retry until a condition is met |
| ⌨️ **Hotkeys** | Trigger macros via configurable hotkeys (`Hotkeys.command`) |

---

## 🔨 Getting Started

```bash
git clone https://github.com/Jirnyak/macromac.git
cd macromac

# Build
swift build -c release

# Or run directly
bash Macro.command
```

### Example Macro JSON

```json
{
  "steps": [
    { "type": "move", "x": 500, "y": 300 },
    { "type": "click", "button": "left" },
    { "type": "delay", "ms": 500 },
    { "type": "shell", "cmd": "osascript -e 'tell app "Safari" to activate'" },
    { "type": "type", "text": "hello world" }
  ]
}
```

---

## ⚠️ Limitations

MacroMac is **intentionally low-level** — it does not understand UI semantics, recover from layout changes, or ensure the correct window is focused. It replays exact coordinates and timings. Use with stable, predictable UIs.

---

## 📜 License

**Open Source License** — Jirnyak. See [LICENSE](LICENSE).

---

<details>
<summary>🇷🇺 Русская Версия</summary>

**MacroMac** — open-source JSON-раннер макросов для автоматизации macOS. Записывает ввод мыши и клавиатуры, сохраняет как редактируемый JSON, воспроизводит с задержками, shell-командами и условиями ожидания. Работает на низком уровне — не нужны API конкретных приложений.

</details>
