import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiquidGlass Nav Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: DemoShell(
        onToggleTheme: () => setState(() {
          _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class DemoShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const DemoShell({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int _selectedIndex = 0;
  int _tabCount = 4;
  Color _activeColor = const Color(0xFF4CAF50);
  double _iconSize = 22.0;
  bool _forceLegacy = false;

  static const List<_TabConfig> _tabOptions = [
    _TabConfig(Icons.home_rounded, 'Home'),
    _TabConfig(Icons.search_rounded, 'Search'),
    _TabConfig(Icons.bookmark_rounded, 'Saved'),
    _TabConfig(Icons.notifications_rounded, 'Alerts'),
    _TabConfig(Icons.person_rounded, 'Profile'),
  ];

  static const List<Color> _colorOptions = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  List<LiquidGlassNavItem> get _items => List.generate(
        _tabCount,
        (i) => LiquidGlassNavItem(
          id: _tabOptions[i].label.toLowerCase(),
          icon: _tabOptions[i].icon,
          label: _tabOptions[i].label,
        ),
      );

  Widget get _currentPage => switch (_selectedIndex) {
        0 => _SettingsPage(
            tabCount: _tabCount,
            activeColor: _activeColor,
            iconSize: _iconSize,
            forceLegacy: _forceLegacy,
            isDark: widget.isDark,
            onTabCountChange: (v) =>
                setState(() => _tabCount = v.clamp(3, 5)),
            onColorChange: (c) => setState(() => _activeColor = c),
            onIconSizeChange: (v) => setState(() => _iconSize = v),
            onForceLegacyChange: (v) => setState(() => _forceLegacy = v),
            onToggleTheme: widget.onToggleTheme,
            colorOptions: _colorOptions,
          ),
        _ => _PlaceholderPage(
            icon: _tabOptions[_selectedIndex].icon,
            label: _tabOptions[_selectedIndex].label,
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _currentPage),
          LiquidGlassNavBar(
            items: _items,
            selectedIndex: _selectedIndex.clamp(0, _tabCount - 1),
            onTap: (i) => setState(() => _selectedIndex = i),
            activeColor: _activeColor,
            iconSize: _iconSize,
            impellerSupported: !_forceLegacy,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings / controls page (first tab)
// ---------------------------------------------------------------------------

class _SettingsPage extends StatelessWidget {
  final int tabCount;
  final Color activeColor;
  final double iconSize;
  final bool forceLegacy;
  final bool isDark;
  final ValueChanged<int> onTabCountChange;
  final ValueChanged<Color> onColorChange;
  final ValueChanged<double> onIconSizeChange;
  final ValueChanged<bool> onForceLegacyChange;
  final VoidCallback onToggleTheme;
  final List<Color> colorOptions;

  const _SettingsPage({
    required this.tabCount,
    required this.activeColor,
    required this.iconSize,
    required this.forceLegacy,
    required this.isDark,
    required this.onTabCountChange,
    required this.onColorChange,
    required this.onIconSizeChange,
    required this.onForceLegacyChange,
    required this.onToggleTheme,
    required this.colorOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 20,
        right: 20,
        bottom: LiquidGlassNavBar.contentBottomInset + 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LiquidGlass Nav',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Interactive demo',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onToggleTheme,
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                tooltip: 'Toggle dark mode',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Tab count
          _SectionHeader('Tab count'),
          const SizedBox(height: 12),
          Row(
            children: [3, 4, 5].map((n) {
              final selected = tabCount == n;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$n tabs'),
                  selected: selected,
                  onSelected: (_) => onTabCountChange(n),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Active color
          _SectionHeader('Active color'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colorOptions.map((c) {
              final selected = activeColor.toARGB32() == c.toARGB32();
              return GestureDetector(
                onTap: () => onColorChange(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.onSurface
                          : Colors.transparent,
                      width: selected ? 3 : 0,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Icon size
          _SectionHeader('Icon size: ${iconSize.round()}px'),
          Slider(
            value: iconSize,
            min: 16,
            max: 32,
            divisions: 8,
            activeColor: activeColor,
            onChanged: onIconSizeChange,
          ),
          const SizedBox(height: 20),

          // Legacy fallback toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: forceLegacy,
            onChanged: onForceLegacyChange,
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.5),
            title: Text(
              'Force legacy nav bar',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Simulates non-Impeller fallback (Skia, web, older Android)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'contentBottomInset',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  'This page uses LiquidGlassNavBar.contentBottomInset (${LiquidGlassNavBar.contentBottomInset}dp) as scroll '
                  'padding so content never hides behind the floating pill.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic placeholder for non-settings tabs
// ---------------------------------------------------------------------------

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Switch tabs using the nav bar below',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              // Glass back button demo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiquidGlassBackButton(
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LiquidGlassBackButton',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: LiquidGlassNavBar.contentBottomInset),
            ],
          ),
        ),
        // Top-left back button overlay (as it would appear in a real screen)
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: LiquidGlassBackButton(onTap: () {}),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _TabConfig {
  final IconData icon;
  final String label;
  const _TabConfig(this.icon, this.label);
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
