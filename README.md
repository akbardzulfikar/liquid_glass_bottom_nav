# liquid_glass_bottom_nav

A floating frosted-glass pill bottom navigation bar for Flutter. Features a physics-based sliding bubble indicator, drag-to-switch gestures, and a squash-and-stretch tilt animation. Built on top of [`liquid_glass_renderer`](https://pub.dev/packages/liquid_glass_renderer) — embedded directly, so no extra dependency is needed.

Automatically falls back to a standard Material bottom nav on devices that don't support Impeller (Skia, web, Windows, Linux).

---

## Installation

```yaml
dependencies:
  liquid_glass_bottom_nav: ^0.0.5
```

---

## Quick start

Wrap your `Scaffold` body in a `Stack` and place `LiquidGlassNavBar` as a `Positioned` overlay at the bottom. Add `LiquidGlassNavBar.contentBottomInset` as bottom padding on any scrollable content so it clears the nav bar.

```dart
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final _items = const [
    LiquidGlassNavItem(id: 'home',    icon: Icons.home_rounded,   label: 'Home'),
    LiquidGlassNavItem(id: 'search',  icon: Icons.search_rounded,  label: 'Search'),
    LiquidGlassNavItem(id: 'profile', icon: Icons.person_rounded,  label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your page content — add bottom padding so it clears the nav bar
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: LiquidGlassNavBar.contentBottomInset,
              ),
              child: /* your content */,
            ),
          ),

          // The nav bar
          LiquidGlassNavBar(
            items: _items,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),
    );
  }
}
```

---

## Customization

### Colors

```dart
LiquidGlassNavBar(
  items: _items,
  selectedIndex: _selectedIndex,
  onTap: (i) => setState(() => _selectedIndex = i),
  activeColor: const Color(0xFF4CAF50),   // active icon + label
  inactiveColor: Colors.white60,          // inactive icon + label
),
```

### Icon size and label style

```dart
LiquidGlassNavBar(
  items: _items,
  selectedIndex: _selectedIndex,
  onTap: (i) => setState(() => _selectedIndex = i),
  iconSize: 24,
  labelStyle: const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  ),
),
```

### Custom icon widget

Use `iconWidget` when you need an SVG, asset image, or any custom painter instead of a `IconData`. The widget is wrapped in `IconTheme` so any widget that respects it (including `SvgPicture.asset` with `colorFilter: ColorFilter.mode(iconTheme.color!, BlendMode.srcIn)`) will automatically receive the active/inactive color.

```dart
LiquidGlassNavItem(
  id: 'mosque',
  label: 'Prayer',
  iconWidget: SvgPicture.asset(
    'assets/icons/mosque.svg',
    colorFilter: ColorFilter.mode(
      IconTheme.of(context).color ?? Colors.white,
      BlendMode.srcIn,
    ),
  ),
),
```

### Insets

```dart
LiquidGlassNavBar(
  items: _items,
  selectedIndex: _selectedIndex,
  onTap: (i) => setState(() => _selectedIndex = i),
  insets: 12.0,   // horizontal margin from screen edge + bottom margin above safe area
),
```

---

## API reference

### `LiquidGlassNavBar`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<LiquidGlassNavItem>` | required | Navigation items |
| `selectedIndex` | `int` | required | Index of the active tab |
| `onTap` | `ValueChanged<int>` | required | Called when a tab is tapped or dragged to |
| `activeColor` | `Color?` | `colorScheme.primary` | Icon and label color for the active tab |
| `inactiveColor` | `Color?` | `colorScheme.onSurface` | Icon and label color for inactive tabs |
| `iconSize` | `double` | `22` | Size of the icon in each tab |
| `labelStyle` | `TextStyle?` | `bodySmall + w500` | Merged over the default label style. Color is always driven by active/inactive color. |
| `insets` | `double` | `16` | Horizontal margin from screen edge and bottom margin above the system safe area |
| `impellerSupported` | `bool` | `true` | Pass `false` to force the legacy Material fallback (useful when Impeller is unavailable) |

### `LiquidGlassNavItem`

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `String` | yes | Unique identifier for this item |
| `label` | `String` | yes | Tab label text |
| `icon` | `IconData?` | one of `icon`/`iconWidget` | Material or Cupertino icon |
| `iconWidget` | `Widget?` | one of `icon`/`iconWidget` | Custom icon widget — takes priority over `icon`. Wrapped in `IconTheme`. |

### Static constants

| Constant | Value | Description |
|---|---|---|
| `LiquidGlassNavBar.contentBottomInset` | `96.0` | Bottom padding to add to scrollable content so it clears the floating nav bar |

---

## Impeller note

The glass effect requires Flutter's **Impeller** renderer.

- **iOS** — Impeller is on by default. No action needed.
- **Android** — Impeller must be enabled in `AndroidManifest.xml`:

```xml
<meta-data
  android:name="io.flutter.embedding.android.EnableImpeller"
  android:value="true" />
```

When Impeller is unavailable (older Android, web, desktop), the widget automatically renders a standard Material bottom navigation bar. You can also force the fallback by passing `impellerSupported: false`.

---

## License

MIT
