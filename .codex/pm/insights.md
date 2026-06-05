# PM Insights

## Renderer performance model
The liquid_glass_renderer pipeline is 3 GPU passes per layer. The key insight: geometry is cached when shapes don't move. This makes the background glass near-free while static, but expensive if animated. Our architecture exploits this by keeping glass static and using plain Flutter for interaction feedback.

## FakeGlass auto-fallback
`LiquidGlassLayer` automatically falls back to `FakeGlass` when `ImageFilter.isShaderFilterSupported` is false (Skia, Web, Windows, Linux). No code needed — the layer handles it internally. Our `impellerSupported` flag triggers `_LegacyNavBar` one level higher, which is a more complete visual fallback.

## `LiquidGlassSettings` equality
`LiquidGlassSettings` uses `EquatableMixin` with value-based equality. If settings don't change across `setState` rebuilds, no geometry rebuild fires. This means our `isDark` branch is cheap — settings equal = geometry cached.

## Pub.dev visibility
Package has 872 likes on `liquid_glass_renderer`. `liquid_glass_bottom_nav` is new — first impression matters. A rich example app (LGN-007) and customization API (LGN-004) will be the biggest drivers of adoption.
