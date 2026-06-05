import 'dart:async';
import 'package:flutter/material.dart';
import 'src/liquid_glass_renderer/liquid_glass_renderer.dart'
    show LiquidGlass, LiquidGlassSettings, LiquidRoundedSuperellipse,
        GlassGlow, GlassGlowLayer;

class LiquidGlassNavItem {
  final String id;
  final String label;

  /// Material/Cupertino icon. Required unless [iconWidget] is provided.
  final IconData? icon;

  /// Custom icon widget. Takes priority over [icon] when provided.
  /// Wrapped in [IconTheme] so widgets that respect it (Icon, SvgPicture, etc.)
  /// automatically inherit the active/inactive color.
  final Widget? iconWidget;

  const LiquidGlassNavItem({
    required this.id,
    required this.label,
    this.icon,
    this.iconWidget,
  }) : assert(
          icon != null || iconWidget != null,
          'LiquidGlassNavItem requires either icon or iconWidget.',
        );
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

  /// Icon and label color for the selected tab.
  /// Defaults to [ColorScheme.primary].
  final Color? activeColor;

  /// Icon and label color for unselected tabs.
  /// Defaults to [ColorScheme.onSurface].
  final Color? inactiveColor;

  /// Size of the icon in each tab. Defaults to 22.
  final double iconSize;

  /// Label style applied to all tab labels.
  /// Merged over [TextTheme.bodySmall] — only the properties you set override
  /// the defaults. Color is always driven by [activeColor] / [inactiveColor].
  final TextStyle? labelStyle;

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
    this.iconSize = 22.0,
    this.labelStyle,
    this.insets = 16.0,
  });

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tiltCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    lowerBound: -1.0,
    upperBound: 1.0,
    value: 0.0,
  );
  Timer? _dragDecayTimer;

  int? _dragIndex;
  double? _dragX;

  @override
  void dispose() {
    _tiltCtrl.dispose();
    _dragDecayTimer?.cancel();
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
        iconSize: widget.iconSize,
        labelStyle: widget.labelStyle,
        insets: widget.insets,
      );
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth < 360 ? widget.insets / 2 : widget.insets;
    final activeColor = widget.activeColor ?? Theme.of(context).colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: horizontalMargin,
      right: horizontalMargin,
      bottom: bottomPadding + widget.insets,
      child: Container(
        decoration: ShapeDecoration(
          shape: const LiquidRoundedSuperellipse(borderRadius: 34.0),
          shadows: [
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
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                foregroundDecoration: ShapeDecoration(
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: 34.0,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                ),
                child: LiquidGlass.withOwnLayer(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 34.0),
                  settings: LiquidGlassSettings(
                    glassColor: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.05),
                    thickness: 32,
                    blur: 1,
                    saturation: 1.8,
                    lightIntensity: isDark ? 0.15 : 0.9,
                    ambientStrength: 0.2,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            SizedBox(
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
                      final x = details.localPosition.dx;
                      final index = _indexFromX(x, itemWidth);
                      setState(() {
                        _dragIndex = index;
                        _dragX = x;
                      });
                    },
                    onHorizontalDragUpdate: (details) {
                      final x = details.localPosition.dx;
                      final index = _indexFromX(x, itemWidth);
                      setState(() {
                        _dragIndex = index;
                        _dragX = x;
                      });
                      
                      // Map delta.dx to tilt range [-1, 1]
                      final targetTilt = (details.delta.dx / 12.0).clamp(-1.0, 1.0);
                      _tiltCtrl.animateTo(targetTilt, duration: const Duration(milliseconds: 50), curve: Curves.easeOut);
                      
                      // Auto-reset if finger stops moving
                      _dragDecayTimer?.cancel();
                      _dragDecayTimer = Timer(const Duration(milliseconds: 80), () {
                        if (mounted) {
                          _tiltCtrl.animateTo(0.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                        }
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (_dragIndex != null) widget.onTap(_dragIndex!);
                      setState(() {
                        _dragIndex = null;
                        _dragX = null;
                      });
                      _dragDecayTimer?.cancel();
                      _tiltCtrl.animateTo(0.0, duration: const Duration(milliseconds: 250), curve: Curves.elasticOut);
                    },
                    onHorizontalDragCancel: () {
                      setState(() {
                        _dragIndex = null;
                        _dragX = null;
                      });
                      _dragDecayTimer?.cancel();
                      _tiltCtrl.animateTo(0.0, duration: const Duration(milliseconds: 250), curve: Curves.elasticOut);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Builder(
                          builder: (context) {
                            final isDragging = _dragIndex != null;
                            
                            // Normal state: Original stadium pill capsule
                            final normalWidth = itemWidth - 8; 
                            final normalHeight = 58.0; // Taller, closer to the edges
                            final normalTop = (68.0 - normalHeight) / 2;
                            final normalLeft = displayIndex * itemWidth + 4.0;

                            // Held state: Enlarged capsule (maintains horizontal pill shape)
                            final heldWidth = itemWidth + 16.0; 
                            final heldHeight = 74.0; // Overlaps top and bottom of 68px container
                            final heldTop = (68.0 - heldHeight) / 2;
                            
                            // Track exact finger position clamped within the bar bounds
                            final exactCenterX = _dragX?.clamp(0.0, constraints.maxWidth) 
                                ?? (displayIndex * itemWidth + itemWidth / 2);
                            final heldLeft = exactCenterX - (heldWidth / 2);

                            return AnimatedPositioned(
                              duration: Duration(
                                // Shorter duration for position changes when dragging so it tightly tracks the finger
                                milliseconds: isDragging ? 50 : 400,
                              ),
                              curve: isDragging ? Curves.easeOut : Curves.elasticOut,
                              left: isDragging ? heldLeft : normalLeft,
                              width: isDragging ? heldWidth : normalWidth,
                              top: isDragging ? heldTop : normalTop,
                              height: isDragging ? heldHeight : normalHeight,
                              child: AnimatedBuilder(
                                animation: _tiltCtrl,
                                builder: (context, child) {
                                  final tilt = _tiltCtrl.value;
                                  final bounce = tilt.abs();
                                  final rotation = tilt * 0.15; // Max 0.15 rad tilt
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.diagonal3Values(1.0 + bounce * 0.15, 1.0 - bounce * 0.1, 1.0)
                                      ..rotateZ(rotation),
                                    child: child,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: isDragging ? 150 : 400,
                                  ),
                                  curve: isDragging ? Curves.easeOut : Curves.elasticOut,
                                  decoration: BoxDecoration(
                                    color: activeColor.withValues(
                                      alpha: isDragging ? 0.25 : 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: isDragging 
                                        ? Border.all(
                                            color: activeColor.withValues(alpha: 0.4),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                        Row(
                          children: List.generate(widget.items.length, (index) {
                            final item = widget.items[index];
                            final bool isActive = index == displayIndex;
                            final color = isActive ? activeColor : inactiveColor;
                            return SizedBox(
                              width: itemWidth,
                              height: 68,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                      color: color,
                                      size: widget.iconSize,
                                    ),
                                    child: item.iconWidget ??
                                        Icon(
                                          item.icon,
                                          size: widget.iconSize,
                                          color: color,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.merge(widget.labelStyle)
                                        .copyWith(color: color, fontWeight: widget.labelStyle?.fontWeight ?? FontWeight.w500),
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
          ],
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
  final double iconSize;
  final TextStyle? labelStyle;
  final double insets;

  const _LegacyNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    required this.iconSize,
    this.labelStyle,
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
                      IconTheme(
                        data: IconThemeData(
                          color: isActive ? themeActiveColor : themeInactiveColor,
                          size: iconSize,
                        ),
                        child: item.iconWidget ??
                            Icon(
                              item.icon,
                              size: iconSize,
                              color: isActive ? themeActiveColor : themeInactiveColor,
                            ),
                      ),
                      SizedBox(height: insets * 0.375),
                      Text(
                        item.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.merge(labelStyle)
                            .copyWith(
                              color: isActive ? themeActiveColor : themeInactiveColor,
                              fontWeight: labelStyle?.fontWeight ?? FontWeight.w500,
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

// ---------------------------------------------------------------------------
// LiquidGlassBackButton
// ---------------------------------------------------------------------------

/// A floating frosted-glass back button with a chevron icon.
///
/// The glass shape is always static — press feedback is handled by a plain
/// Flutter [AnimatedScale] so no shader cost occurs during interaction.
///
/// Falls back to a plain [IconButton] when [impellerSupported] is false.
class LiquidGlassBackButton extends StatefulWidget {
  /// Called when the button is tapped. Defaults to [Navigator.maybePop].
  final VoidCallback? onTap;

  /// Color of the chevron icon. Defaults to [ColorScheme.onSurface].
  final Color? color;

  /// Size of the glass pill. Defaults to 44.
  final double size;

  /// Corner radius of the glass shape. Defaults to 14.
  final double borderRadius;

  /// Whether the device supports Impeller. Defaults to true.
  final bool impellerSupported;

  const LiquidGlassBackButton({
    super.key,
    this.onTap,
    this.color,
    this.size = 44.0,
    this.borderRadius = 14.0,
    this.impellerSupported = true,
  });

  @override
  State<LiquidGlassBackButton> createState() => _LiquidGlassBackButtonState();
}

class _LiquidGlassBackButtonState extends State<LiquidGlassBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    reverseDuration: const Duration(milliseconds: 200),
    lowerBound: 0.88,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressCtrl.reverse();
  void _onTapUp(_) => _pressCtrl.forward();
  void _onTapCancel() => _pressCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.color ?? Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!widget.impellerSupported) {
      return IconButton(
        onPressed: widget.onTap ?? () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.chevron_left_rounded, color: iconColor),
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap ?? () => Navigator.of(context).maybePop(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) => Transform.scale(
          scale: _pressCtrl.value,
          child: child,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: ShapeDecoration(
            shape: LiquidRoundedSuperellipse(borderRadius: widget.borderRadius),
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 0,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: LiquidRoundedSuperellipse(borderRadius: widget.borderRadius),
            ),
            child: GlassGlowLayer(
              child: GlassGlow(
                glowColor: Colors.white.withValues(alpha: 0.35),
                glowRadius: 1.2,
                child: LiquidGlass.withOwnLayer(
                  shape: LiquidRoundedSuperellipse(borderRadius: widget.borderRadius),
                  settings: LiquidGlassSettings(
                    glassColor: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.05),
                    thickness: 32,
                    blur: 1,
                    saturation: 1.8,
                    lightIntensity: isDark ? 0.15 : 0.9,
                    ambientStrength: 0.2,
                  ),
                  child: SizedBox.expand(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: widget.size * 0.55,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
