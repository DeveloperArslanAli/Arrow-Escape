# SOP-11: Feature Modification & Change Control Protocol
## Purpose & Scope
Mandates the step-by-step engineering workflow whenever an engineer or AI agent adds or alters a feature in Arrow Escape. Prevents scope drift, circular regressions, and codebase bloat.

---

## 1. THE 5-STEP CHANGE CONTROL WORKFLOW

```
[User Request / Feature Need]
            │
            ▼
┌───────────────────────────────┐
│ 1. ROUTER ISOLATION           │ Consult MEMORY_GRAPH.md.
│                               │ Load ONLY relevant SOPs (Saves tokens).
└──────────────┬────────────────┘
               ▼
┌───────────────────────────────┐
│ 2. CONTRACT SPECIFICATION     │ Define signal types, GDScript method
│                               │ signatures, and boundary contracts.
└──────────────┬────────────────┘
               ▼
┌───────────────────────────────┐
│ 3. SURGICAL IMPLEMENTATION    │ Modify target scripts. Maintain strict
│                               │ static typing & no cyclic dependencies.
└──────────────┬────────────────┘
               ▼
┌───────────────────────────────┐
│ 4. HEADLESS V&V EXECUTION     │ Run automated test runner via Godot CLI:
│                               │ tests/run_all_tests.gd
└──────────────┬────────────────┘
               ▼
┌───────────────────────────────┐
│ 5. MEMORY GRAPH COMMITTAL     │ Update ADR / Invariant table if architecture
│                               │ changed. Report concise results.
└───────────────────────────────┘
```

---

## 2. HALLUCINATION & DRIFT DEFENSE RULES

1. **Never guess API signatures**: Always verify against the existing codebase or Godot 4.x documentation.
2. **Never break existing headless tests**: If an edit causes any test in `tests/` to fail, the change is considered rejected until fixed.
3. **No hidden global state**: Do not store transient level states in Autoloads. Autoloads are for persistent services and cross-scene coordination only.
4. **Preserve backward compatibility**: Level JSON schemas and Save files must remain backwards compatible via version numbers (`schema_version`).
