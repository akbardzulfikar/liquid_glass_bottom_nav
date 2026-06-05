# Meeting Notes

## 2026-06-05 — Codebase review session
**Attendees:** Akbar, Billy (async via Claude Code)
**Agenda:** Understand liquid_glass_renderer costs and limitations before adding features.

**Key findings:**
- 3-pass GPU pipeline per `LiquidGlassLayer`
- Static glass = cached geometry, near-zero cost
- Moving glass shapes = `toImageSync()` every frame (expensive)
- Our bubble indicator correctly uses plain `BoxDecoration` — no shader cost during drag
- `alwaysNeedsAddToScene = true` on transform-tracking layers means transform is checked every compositing frame — cheap but not free
- Memory leak risk on animation from Flutter bug in texture disposal (upstream issue — upvote to fix)

**Actions:**
- Never animate `LiquidGlass` shape position/size in this package
- Secondary visual feedback (bubble, tilt, squish) stays as plain Flutter
- LGN-005 performance audit to validate on real hardware
