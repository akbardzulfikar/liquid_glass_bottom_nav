# Meeting Notes

## 2026-06-05 — Renderer deep-dive
**Agenda:** Understand liquid_glass_renderer costs and limitations before adding features.

**Key findings:**
- 3-pass GPU pipeline per `LiquidGlassLayer`
- Static glass = cached geometry, near-zero ongoing cost
- Moving glass shapes = `toImageSync()` every frame (expensive — don't do it)
- Bubble indicator correctly uses plain `BoxDecoration` — no shader cost during drag
- `alwaysNeedsAddToScene = true` on transform-tracking layers — transform checked every compositing frame
- Memory spike risk on animation from Flutter bug in texture disposal (upstream issue)

**Rule going forward:** Never animate `LiquidGlass` shape position/size. All interaction feedback stays as plain Flutter.
