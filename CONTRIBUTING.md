# 🛠️ Contributing to Jirnyak/macromac

> **Engineering Guidelines, Architecture Invariants & Pull Request Lifecycle**  
> Maintained by the **Жирняк & Адольф Петушков** Engineering Syndicate

Thank you for your interest in contributing to **Jirnyak/macromac**. This project operates under strict technical standards: deep mathematical and domain correctness, zero-slop code, explicit typing, and zero unverified assumptions.

---

## 🏛️ 1. Core Engineering Invariants

Before proposing any changes, verify that your implementation satisfies our domain invariants:

1. **Atomic Event Injection**:  CGEventCreateKeyboardEvent sequences must guarantee key-up execution after key-down.
2. **Repeat Block Recursion Limit**:  JSON macro repeat loops must enforce maximum nesting depth to prevent stack overflow.
3. **Permission Verification**:  Accessibility and Input Monitoring permissions must be verified before event dispatcher starts.
4. **Low-Latency Execution**:  Keystroke injection latency must remain below 1.5 milliseconds per event.

---

## 💻 2. Local Development & Toolchain

### 2.1 Prerequisites
* **Tech Stack**: `C++ / Objective-C++ / macOS CoreGraphics / ApplicationServices`
* Ensure your compiler / runtime matches the repository configuration exactly.

### 2.2 Setup Workflow
```bash
# Clone the repository
git clone https://github.com/Jirnyak/macromac.git
cd macromac

# Install dependencies / configure build
npm install # or make / dotnet restore depending on project

# Run the test suite
make test || clang++ -std=c++20 tests/test.cpp -o test_bin && ./test_bin
```

---

## 📐 3. Coding Standards & Style

1. **Zero AI-Slop & Filler**:
   * Do NOT add generic, conversational comments (e.g. `// This function handles...`, `// This is useful because...`).
   * Code must be self-explanatory through precise naming, mathematical clarity, and strong types.
   * Only document non-obvious mathematical invariants, hardware quirks, or algorithmic complexity bounds.

2. **Strong Typing & Strict Validation**:
   * Zero `any`, `unknown` bypasses, or untyped data flows.
   * All external inputs, network payloads, and deserialized states must pass strict schema validation at the system boundary.

3. **Performance & Memory Hygiene**:
   * Render and simulation loops must produce zero heap allocations per frame.
   * Reuse pre-allocated buffers, typed arrays, or object pools.
   * Guarantee deterministic cleanup of native resources, file handles, and event listeners.

---

## 🧪 4. Testing & Verification Requirements

Every pull request must be accompanied by empirical proof of correctness:
1. **Unit Tests**: Add targeted tests covering both the nominal path and boundary edge cases.
2. **Regression Verification**: Ensure all existing test suites pass cleanly with `make test || clang++ -std=c++20 tests/test.cpp -o test_bin && ./test_bin`.
3. **No Mocks in Core Solvers**: Domain logic must be tested against real mathematical and architectural invariants, not mock interfaces.

---

## 🚀 5. Pull Request & Review Protocol

```mermaid
graph LR
    A[Fork & Create Branch] --> B[Implement Fix / Feature]
    B --> C[Pass Local Test Suite]
    C --> D[Submit PR with Detailed Rationale]
    D --> E[Syndicate Review & CI Matrix]
    E -->|Approved| F[Squash & Merge to main]
    E -->|Changes Requested| B
```

1. **Branch Naming**: Use descriptive prefixes: `fix/<issue-name>`, `feat/<feature-name>`, `perf/<optimization>`.
2. **Commit Messages**: Follow Conventional Commits format: `fix(subsystem): brief summary of change`.
3. **PR Description**: Include:
   * Root cause analysis of the bug or architectural rationale for the feature.
   * Exact commands used to verify correctness and raw test output snippets.
   * Confirmation that no unrelated files or stylistic diffs were introduced.

---

### 👥 Engineering Syndicate
Maintained by **Жирняк** & **Адольф Петушков**.
