# PM Insights

## Renderer performance model
The liquid_glass_renderer pipeline is 3 GPU passes per layer. Geometry is cached when shapes don't move — background glass is near-free while static, but expensive if animated. Our architecture exploits this by keeping glass static and using plain Flutter for interaction feedback.

## FakeGlass auto-fallback
`LiquidGlassLayer` automatically falls back to `FakeGlass` when `ImageFilter.isShaderFilterSupported` is false (Skia, Web, Windows, Linux). The `impellerSupported` flag triggers `_LegacyNavBar` one level higher — a more complete visual fallback.

## `LiquidGlassSettings` equality
Uses `EquatableMixin` with value-based equality. Settings unchanged across `setState` = no geometry rebuild. Our `isDark` branch is cheap.

## Pub.dev positioning
`liquid_glass_renderer` has 872 likes. `liquid_glass_bottom_nav` is new — a rich example app (LGN-007) and a settings passthrough API (LGN-004) will drive adoption.
