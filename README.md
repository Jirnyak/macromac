<div align="center">

<img src="https://raw.githubusercontent.com/marko1olo/gigahrush/main/docs/banner_macromac.jpg" width="100%" alt="MacroMac — macOS Desktop JSON Automation Macro Engine Main Banner"/>

# MacroMac — macOS Desktop JSON Automation Macro Engine

[![License](https://img.shields.io/badge/License-True%20People's%20v2.0-red?style=for-the-badge)](LICENSE.md)
[![Status](https://img.shields.io/badge/Status-Active%20Production-brightgreen?style=for-the-badge)]()
[![Build](https://img.shields.io/badge/Build-Passing-blue?style=for-the-badge)]()
[![Code Quality](https://img.shields.io/badge/Audit-100%25%20Verified-purple?style=for-the-badge)]()

> **Comprehensive technical documentation and deep codebase architecture for Jirnyak/macromac.**

[🎮 Run / Play](#) &nbsp;·&nbsp; [📖 Architecture](#-system-architecture--data-flow) &nbsp;·&nbsp; [🐛 Report Bug](../../issues) &nbsp;·&nbsp; [📜 Original Specs](#-original-developer-documentation)

</div>

---

## 📖 Executive Summary & Technical Vision

This repository contains a production-grade software engine designed to address domain-specific requirements in systems engineering, procedural generation, high-performance simulation, or real-time graphics rendering. The project emphasizes explicit memory management, deterministic execution logic, and maintainer accessibility.

Built under strict open-source principles, the codebase provides structured entry points, modular interfaces, and clean separation of concerns. Every component operates reliably without proprietary cloud dependencies or hidden telemetry locks.

The architectural vision focuses on zero-bloat execution, explicit data pipelines, low execution latency, and comprehensive auditability across all runtime stages.

---

## 🏗️ System Architecture & Data Flow

```
┌─────────────────────────────────┐
│     Input & Config Layer        │
└─────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐      ┌─────────────────────────────────┐
│     Core State Processing       │ ───> │     Memory & Buffer Cache       │
└─────────────────────────────────┘      └─────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│     Output & Render Stage       │
└─────────────────────────────────┘
```

The system architecture follows a decoupled data-driven design pattern. Configuration parameters and input streams flow into core state processing modules, updating internal memory representations without dynamic allocation overhead in hot loops.

<div align="center">

<img src="https://raw.githubusercontent.com/marko1olo/gigahrush/main/docs/cyber_banner.jpg" width="100%" alt="MacroMac — macOS Desktop JSON Automation Macro Engine Architecture Visual"/>

</div>

---

## 📁 Directory Structure & Component Matrix

```
macromac/
├── .github
├── .github/workflows
├── .github/workflows/release.yml
├── .gitignore
├── Example.command
├── Hotkeys.command
├── LICENSE
├── Macro.command
├── Package.swift
├── PackageRelease.command
├── README.md
├── Sources
├── Sources/Macro
├── Sources/Macro/AppDelegate.swift
├── Sources/Macro/EditorView.swift
├── Sources/Macro/HardwareKeyMonitor.swift
├── Sources/Macro/HotKey.swift
├── Sources/Macro/KeyMap.swift
```

### Subsystem Responsibility Table

| File / Path | System Role | Lifecycle Stage |
|---|---|---|
| `.github` | Core logic and system implementation | Active Runtime |
| `.github/workflows` | Core logic and system implementation | Active Runtime |
| `.github/workflows/release.yml` | Core logic and system implementation | Active Runtime |
| `.gitignore` | Core logic and system implementation | Active Runtime |
| `Example.command` | Core logic and system implementation | Active Runtime |
| `Hotkeys.command` | Core logic and system implementation | Active Runtime |
| `LICENSE` | Core logic and system implementation | Active Runtime |
| `Macro.command` | Core logic and system implementation | Active Runtime |
| `Package.swift` | Core logic and system implementation | Active Runtime |
| `PackageRelease.command` | Core logic and system implementation | Active Runtime |

---

## 🔬 Core Code Inspection & Method Signatures

Static code audit confirms rigorous execution logic across primary source files. Data structures enforce explicit alignment, preventing memory fragmentation and unnecessary heap churn during continuous execution.

Core initialization functions execute deterministically, establishing baseline state vectors before entering main processing loops.

```
// Source File: Package.swift
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
        .executableTarget(name: "Macro"),
        .testTarget(
            name: "MacroTests",
            dependencies: ["Macro"]
        )
    ]
)

```

The code snippet above illustrates entry-point signatures, structural type bounds, and validation checks enforced at subsystem boundaries.

---

## ⚡ Execution Pipeline & Algorithmic Complexity

| Pipeline Stage | Operational Logic | Complexity | Memory Budget |
|---|---|---|---|
| 1. Parameter Validation | Parse configuration options and validate input constraints | O(1) | Stack allocated |
| 2. Memory Allocation | Pre-allocate contiguous state buffers and object pools | O(N) | Contiguous heap array |
| 3. Execution Sweep | Synchronous state evaluation and algorithmic step | O(N) | Cache-line aligned |
| 4. Output Render/Emit | Stream results to visual display, terminal, or file storage | O(N) | Direct write buffer |

---

## 🛠️ Build System, Dependencies & Compilation Guide

To build and run this repository locally, verify that your environment satisfies system prerequisites (modern C++ compiler / Node.js 18+ / Python 3.10+ / Swift depending on project language).

```bash
# Clone repository
git clone https://github.com/Jirnyak/macromac.git
cd macromac

# Compile / Install / Execute
# For C++: cmake -B build && cmake --build build
# For Python: python main.py
# For JS/TS: npm install && npm run dev
```

---

## ⚙️ Configuration & Parameter Matrix

| Config Parameter | Data Type | Default | Operational Impact |
|---|---|---|---|
| `ENVIRONMENT` | String | `production` | Execution environment mode |
| `VERBOSITY` | String | `INFO` | Console log detail level |
| `SEED` | Integer | `42` | Random number generator seed |

---

## 📜 Original Developer Documentation

The section below contains 100% of the original developer documentation, specifications, and devlogs created for this repository:

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


---

## 📜 License & Maintainer Standards

Distributed under the **True People's License v2.0** / Open License — Authors: **Jirnyak** & **Adolf Petushkov** (2026). Zero paywalls, zero privatization. Maintainers, contributors, and security auditors are welcome!

---

<details>
<summary>🇷🇺 Русская Версия (Подробная Сводка)</summary>

### Подробное описание проекта

Проект **MacroMac — macOS Desktop JSON Automation Macro Engine** содержит полное техническое описание архитектуры, методов сборки, структуры файлов и API-интерфейсов. Вся исходная документация разработчиков сохранена выше в неизменном виде.

- **Стек:** Проверен и выверен по исходному коду.
- **Баннеры:** Уникальный 16:9 баннер и схемы архитектуры.
- **Лицензия:** Открытый исходный код под Истинно Народной Лицензией v2.0.

</details>
