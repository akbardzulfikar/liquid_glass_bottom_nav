# PM Decisions Log

## 2026-06-05 — Initial package structure
**Decision:** Embed `liquid_glass_renderer` source directly instead of declaring it as a pub.dev dependency.
**Why:** The package is pre-release (0.2.0-dev.4) with no stable version. Embedding avoids version churn for consumers and ensures the package works standalone with a single `flutter pub add`.
**Outcome:** Source lives in `lib/src/liquid_glass_renderer/`. Consumers only need `liquid_glass_bottom_nav`.

## 2026-06-05 — Glass background vs animated bubble
**Decision:** Glass layer is static background only; the active tab bubble indicator is plain Flutter (BoxDecoration + AnimatedPositioned).
**Why:** Animating a LiquidGlass shape position forces `toImageSync()` every frame — expensive on mobile. The visual effect is identical with a plain Flutter bubble since it sits on top of the glass, not inside it.
**Outcome:** Zero shader cost during drag/tilt animation.

## 2026-06-05 — Impeller fallback strategy
**Decision:** `impellerSupported` flag is the caller's responsibility. The package provides `_LegacyNavBar` as the fallback but does not include a platform channel for detection.
**Why:** Platform detection logic (checking Android API level, Impeller manifest flag) belongs in the host app, not in a UI-only package. This keeps the package dependency-free on the native side.
**Outcome:** Host app passes `impellerSupported: false` → `_LegacyNavBar` is rendered.

## 2026-06-05 — Task ID prefix
**Decision:** Use `LGN-` prefix (Liquid Glass Nav) for all task IDs.
**Why:** Distinguishes tasks from other projects if backlog.json is ever referenced outside context.

## 2026-06-05 — Workflow rules added to CLAUDE.md and AGENTS.md
**Decision:** Before any commit, ask the user whether a version bump is needed. After any change, update `.claude/tasks/backlog.json` and `.codex/pm/decisions.md`. Both `CLAUDE.md` and `AGENTS.md` must stay in sync.
**Why:** User explicitly requested this to prevent version drift and keep .claude/.codex current with the actual codebase state.

## 2026-06-08 — LGN-010 LiquidGlassContainer API expansion (v0.0.8)
**Decision:** Added `ownLayer`, `backgroundColor`, `saturation`, `thickness` params to `LiquidGlassContainer`; exported `LiquidGlassLayer` + `LiquidGlassSettings`; added `LiquidGlassRenderScope.maybeOf()`.
**Why:** Host apps (islam-time) needed: (1) shared layer support to reduce N→1 shader passes for card grids, (2) true solid background fill (not shader tint) for white iOS-style cards, (3) vibrancy/saturation tuning for iOS material look.
**Outcome:** `backgroundColor` is a `ColoredBox` painted before content — opaque, independent of shader. `ownLayer: false` requires a parent `LiquidGlassLayer` ancestor; falls back to own layer if none found via `maybeOf()`.

## 2026-06-08 — Nav bar light mode bubble color
**Decision:** Active bubble indicator in light mode now uses `activeColor` tint (e.g. green) instead of white.
**Why:** After increasing capsule `glassColor` alpha to 0.76 for visible white background, the white bubble blended into the white capsule and became invisible. Using `activeColor` restores contrast.
**Outcome:** Capsule = white (glassColor 0.76), bubble = activeColor tint (alpha 0.15 idle / 0.22 drag).

## 2026-06-05 — LGN-007 example app shipped
**Decision:** Example app at `example/lib/main.dart` includes interactive demos: dark/light toggle, 3/4/5 tab selector, active color swatches, icon size slider, legacy fallback toggle.
**Why:** The example app is the primary way pub.dev users evaluate the package before adding it.
