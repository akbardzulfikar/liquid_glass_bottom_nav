import 'package:flutter/material.dart';
import 'src/liquid_glass_renderer/liquid_glass_renderer.dart'
    show LiquidGlass, LiquidGlassSettings, LiquidRoundedSuperellipse;

class LiquidGlassNavItem {
  final String id;
  final IconData icon;
  final String label;

  const LiquidGlassNavItem({
    required this.id,
    required this.icon,
    required this.label,
  });
}

/// Floating pill bottom navigation bar with a sliding glass bubble indicator.
///
/// On Impeller-capable devices the active indicator is an [AnimatedPositioned]
/// bubble that bounces between tabs on tap and follows a drag when the user
/// long-presses and slides. Falls back to [_LegacyNavBar] on devices without
/// Impeller/Vulkan support (Android API < 24) or if [impellerSupported] is false.
class LiquidGlassNavBar extends StatefulWidget {
  final List<LiquidGlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  
  /// Whether the device supports Impeller rendering. Defaults to true.
  final bool impellerSupported;

  /// Custom active color. Defaults to Theme.of(context).colorScheme.primary
  final Color? activeColor;
  
  /// Custom inactive color. Defaults to Theme.of(context).colorScheme.onSurface (or onSurfaceVariant for legacy)
  final Color? inactiveColor;
  
  /// Inset padding (default is 16.0)
  final double insets;

  /// Vertical space the floating nav occupies above the system bottom inset.
  /// Tab screens with scrollable content should add this as bottom padding.
  /// Composition: pill height 68 + bottom margin 16 + 12px breathing buffer = 96.0.
  static const double contentBottomInset = 96.0;

  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.impellerSupported = true,
    this.activeColor,
    this.inactiveColor,
    this.insets = 16.0,
  });

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.12,
  ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));

  int? _dragIndex;

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  int _indexFromX(double x, double itemWidth) =>
      (x / itemWidth).floor().clamp(0, widget.items.length - 1);

  @override
  Widget build(BuildContext context) {
    if (!widget.impellerSupported) {
      return _LegacyNavBar(
        items: widget.items,
        selectedIndex: widget.selectedIndex,
        onTap: widget.onTap,
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
        insets: widget.insets,
      );
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final activeColor = widget.activeColor ?? Theme.of(context).colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: widget.insets,
      right: widget.insets,
      bottom: bottomPadding + widget.insets,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 0,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: LiquidGlass.withOwnLayer(
          shape: LiquidRoundedSuperellipse(borderRadius: 34.0),
          settings: LiquidGlassSettings(
            glassColor: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.15),
            thickness: 18,
            blur: 3,
            saturation: 2.2,
            lightIntensity: 0.6,
            ambientStrength: 0.15,
          ),
          child: SizedBox(
            height: 68,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / widget.items.length;
                final displayIndex = _dragIndex ?? widget.selectedIndex;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    widget.onTap(
                      _indexFromX(details.localPosition.dx, itemWidth),
                    );
                  },
                  onHorizontalDragStart: (details) {
                    final index =
                        _indexFromX(details.localPosition.dx, itemWidth);
                    setState(() => _dragIndex = index);
                    _scaleCtrl.forward();
                  },
                  onHorizontalDragUpdate: (details) {
                    final index =
                        _indexFromX(details.localPosition.dx, itemWidth);
                    if (index != _dragIndex) {
                      setState(() => _dragIndex = index);
                    }
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragIndex != null) widget.onTap(_dragIndex!);
                    setState(() => _dragIndex = null);
                    _scaleCtrl.reverse();
                  },
                  onHorizontalDragCancel: () {
                    setState(() => _dragIndex = null);
                    _scaleCtrl.reverse();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: Duration(
                          milliseconds: _dragIndex != null ? 120 : 400,
                        ),
                        curve: _dragIndex != null
                            ? Curves.easeOut
                            : Curves.elasticOut,
                        left: displayIndex * itemWidth + 4,
                        width: itemWidth - 8,
                        top: 8,
                        height: 52,
                        child: AnimatedBuilder(
                          animation: _scale,
                          builder: (context, child) => Transform.scale(
                            scale: _scale.value,
                            child: child,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(widget.items.length, (index) {
                          final item = widget.items[index];
                          final bool isActive = index == displayIndex;
                          return SizedBox(
                            width: itemWidth,
                            height: 68,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isActive ? activeColor : inactiveColor,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isActive
                                            ? activeColor
                                            : inactiveColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legacy fallback — identical visuals to the pre-existing flat white nav bar.
// ---------------------------------------------------------------------------

class _LegacyNavBar extends StatelessWidget {
  final List<LiquidGlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final double insets;

  const _LegacyNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    required this.insets,
  });

  @override
  Widget build(BuildContext context) {
    final themeActiveColor = activeColor ?? Theme.of(context).colorScheme.primary;
    final themeInactiveColor = inactiveColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: insets * 0.625, // AppSpacing.sm is ~10 which is 16 * 0.625
          vertical: insets * 0.625,
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final bool isActive = index == selectedIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(insets),
                onTap: () => onTap(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: insets * 0.375), // AppSpacing.xs is ~6
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 26,
                        color: isActive ? themeActiveColor : themeInactiveColor,
                      ),
                      SizedBox(height: insets * 0.375),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isActive
                                  ? themeActiveColor
                                  : themeInactiveColor,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: insets * 0.625 - 2), // AppSpacing.sm - 2 = 8
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: isActive ? 28.0 : 0.0,
                        decoration: BoxDecoration(
                          color: isActive ? themeActiveColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
