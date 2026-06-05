# PM Decisions Log

## 2026-06-05 — Embed liquid_glass_renderer source
**Decision:** Embed `liquid_glass_renderer` source directly instead of declaring it as a pub.dev dependency.
**Why:** The package is pre-release (0.2.0-dev.4) with no stable version. Embedding avoids version churn for consumers and ensures the package works standalone.
**Outcome:** Source lives in `lib/src/liquid_glass_renderer/`. Consumers only need `liquid_glass_bottom_nav`.

## 2026-06-05 — Glass background static; bubble is plain Flutter
**Decision:** Glass layer is static background only; the active tab bubble indicator is plain Flutter (BoxDecoration + AnimatedPositioned).
**Why:** Animating a LiquidGlass shape position forces `toImageSync()` every frame. The visual effect is identical with a plain Flutter bubble since it sits on top of the glass.
**Outcome:** Zero shader cost during drag/tilt animation.

## 2026-06-05 — Impeller detection is caller's responsibility
**Decision:** `impellerSupported` flag is passed by the host app. The package provides `_LegacyNavBar` as fallback but does not include a platform channel.
**Why:** Platform detection belongs in the host app, not in a UI-only package. Keeps the package native-side dependency-free.

## 2026-06-05 — Task ID prefix: LGN-
**Decision:** Use `LGN-` prefix (Liquid Glass Nav) for all task IDs in backlog.json.
