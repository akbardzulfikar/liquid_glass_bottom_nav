# liquid_glass_bottom_nav

Flutter package providing a floating frosted-glass pill bottom navigation bar.

## Commit message convention

```
[LGN-XXX] type: short description
```

Types: `feat`, `fix`, `perf`, `refactor`, `docs`, `chore`, `test`

Examples:
```
[LGN-002] feat: add badge count support to nav items
[LGN-005] perf: confirm glass geometry stays cached during drag
[LGN-007] feat: add example app with dark mode and color demos
```

Use `[LGN-000]` for work not tied to a specific task.

## Task tracking

Backlog: `.claude/tasks/backlog.json` — source of truth for both Claude and Codex.
GitHub Project: https://github.com/users/akbardzulfikar/projects/3

## Key constraints

- **Never animate a `LiquidGlass` shape's position or size** — forces expensive GPU re-render every frame.
- The glass pill background must stay static. Interaction feedback (bubble, tilt) uses plain Flutter `BoxDecoration` / `Transform`.
- `icon` on `LiquidGlassNavItem` is optional when `iconWidget` is provided; one of the two is required.

## Package structure

```
lib/
  liquid_glass_bottom_nav.dart   ← public API
  src/
    liquid_glass_renderer/       ← embedded liquid_glass_renderer 0.2.0-dev.4
example/
  lib/main.dart                  ← runnable demo app
```
