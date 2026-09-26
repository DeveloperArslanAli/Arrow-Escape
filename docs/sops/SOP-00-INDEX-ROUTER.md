# SOP-00: Agent Routing & Token-Saving Protocol
## Purpose & Scope
This SOP defines the operational protocol that any AI agent or software engineer must strictly follow before reading or altering any code in the Arrow Escape repository. Its goal is to achieve **zero architectural drift**, eliminate hallucination, and **minimize token consumption by up to 85%** by loading only target-bounded context.

---

## 1. AGENT PRE-FLIGHT CHECKLIST

Whenever a user requests an update, bug fix, or new feature:
1. **Identify the Functional Domain** from the request (e.g., "Change the arrow blocked animation" -> Domain: UI/Animation -> Target: `SOP-02` + `SOP-06`).
2. **Consult the Lookup Table** in [MEMORY_GRAPH.md](file:///e:/Projects/mobile%20application/Arrow%20Puzzle%20Game/MEMORY_GRAPH.md).
3. **Load ONLY the designated SOP(s)**. Do NOT load general requirements or unneeded source files.
4. **Inspect target files** using precise line ranges (`view_file`).
5. **Never introduce circular dependencies** or violate the signal-up, method-down paradigm.
6. **Execute headless verification** via the Godot CLI test runner to confirm zero regression before reporting completion.

---

## 2. MODULAR SOP DOMAIN MAP

```
[User Request]
       │
       ▼
[SOP-00: Router Check]
       │
  ┌────┴──────────────────────────────┬──────────────────────────────┐
  ▼                                   ▼                              ▼
[Core Gameplay]                 [Level & Data]                 [UI & System]
├─ SOP-01 (Architecture)         ├─ SOP-03 (Solver & Hints)     ├─ SOP-06 (UI Design & Themes)
├─ SOP-02 (Grid & Movement)      ├─ SOP-04 (Level Data Schema)  ├─ SOP-07 (Audio & Haptics)
└─ SOP-05 (State & GameFlow)     └─ SOP-08 (Save & Persistence) ├─ SOP-10 (Android & Perf)
                                                                └─ SOP-09 (V&V Test Harness)
```

---

## 3. DRIFT PREVENTION INVARIANTS

Any agent modifying code must observe these non-negotiable rules:
1. **No External Framework Bloat**: No third-party plugins that add massive dependencies. Stick to native Godot 4.x Control nodes, Tweens, and GDScript.
2. **Explicit Static Typing**: Every GDScript variable, function argument, and return value must be strictly typed (e.g., `func validate_path(pos: Vector2i, dir: Vector2i) -> bool:`).
3. **No Magic Strings or Numbers**: All coordinates, directions, states, and audio bus names must be defined via enums or constants (`GlobalConstants.gd`).
4. **Zero Main-Thread Blocking**: All file I/O and heavy algorithmic operations (like solver depth search) must complete in under 5ms or yield to the frame loop.
