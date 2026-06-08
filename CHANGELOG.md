## 0.0.8

* Add `ownLayer` param to `LiquidGlassContainer` — when `false`, the container joins a parent `LiquidGlassLayer` instead of creating its own layer, reducing N shader passes to 1 for grouped cards.
* Add `backgroundColor` param to `LiquidGlassContainer` — true opaque solid fill inside the glass shape, independent of the `glassColor` shader tint. Enables iOS-native-style solid-color glass containers.
* Add `saturation` and `thickness` params to `LiquidGlassContainer` — previously hardcoded, now fully customizable for vibrancy and refraction tuning.
* Export `LiquidGlassLayer` and `LiquidGlassSettings` from the main library entry point.
* Add `LiquidGlassRenderScope.maybeOf(BuildContext)` for safe scope detection.
* Nav bar light mode: active bubble indicator now uses `activeColor` tint instead of white, making it visible against the white capsule background.
* Nav bar light mode: capsule `glassColor` alpha increased to 0.76 and `blur` settled at 1 for clean vibrant white appearance without fogging.

## 0.0.7

* Add `LiquidGlassBackButton` — floating frosted-glass back button with chevron icon, touch glow via `GlassGlow`, and press scale feedback. Falls back to plain `IconButton` on non-Impeller targets.
* Tune glass settings for stronger liquid glass refraction: higher `thickness` (32), lower `blur` (1), reduced `glassColor` opacity — applies to both nav bar and back button.

## 0.0.6

* Add demo GIF placeholder to README — drop `assets/demo.gif` to activate.
* Wire `assets/` directory for hosting demo media.

## 0.0.5

* Add `example/` app with interactive demos: dark/light mode toggle, 3/4/5 tab selector, active color picker, icon size slider, and legacy fallback toggle.
* Add `CLAUDE.md` and `AGENTS.md` with commit convention, renderer performance rules, and workflow guidelines.

## 0.0.4

* Add `iconSize` param to control icon size across all tabs (default: 22).
* Add `labelStyle` param for custom label typography, merged over `bodySmall`. Color always follows active/inactive color.
* Add `iconWidget` to `LiquidGlassNavItem` for custom icon widgets (SVG, asset, painter). Takes priority over `icon`; wrapped in `IconTheme` for automatic color inheritance.
* Make `icon` optional in `LiquidGlassNavItem` — required only when `iconWidget` is not provided.
* Fix held bubble capsule clipping outside leftmost/rightmost tab boundaries during drag.
* Rewrite README with full API reference, usage examples, and Impeller setup instructions.

## 0.0.3

* Embed `liquid_glass_renderer` internally for zero-dependency usage.
* Add physics-based squish and stretch animations that react smoothly to drag velocity.

## 0.0.2

* Update metadata and prepare for initial release.

## 0.0.1

* Initial release of liquid_glass_bottom_nav.
