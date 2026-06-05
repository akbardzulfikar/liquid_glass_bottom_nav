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

Use `[LGN-000]` for work not tied to a specific task (e.g. repo setup).

## Task tracking

Backlog: `.claude/tasks/backlog.json` — source of truth for both Claude and Codex.
GitHub Project: https://github.com/users/akbardzulfikar/projects/3
Status values: `backlog` → `in_progress` → `review` → `done`

## Renderer performance rules

- **Never animate a `LiquidGlass` shape's position or size** — forces `toImageSync()` every frame.
- Keep the glass background static. All interaction feedback (bubble, tilt) must use plain Flutter widgets.
- Set `blur` on `LiquidGlassLayer`, never inside `LiquidGlassBlendGroup` — causes artifacts.
- Max 16 shapes per `LiquidGlassBlendGroup`.
- `LiquidGlassLayer` auto-falls back to `FakeGlass` on non-Impeller targets.

## Workflow rules

- **Before any commit** — ask the user whether a version bump is needed. Do not commit without confirming.
- **After any change** — update both `.claude/` and `.codex/` to reflect the current state:
  - `.claude/tasks/backlog.json` — update task status, `updated` date
  - `.codex/pm/decisions.md` — log any significant decisions made
  - `.codex/plans/` — create or update a plan file for non-trivial work
- `CLAUDE.md` and `AGENTS.md` must stay in sync — changes to one apply to both.

## Publishing

1. Ask user if version bump is needed before committing
2. Bump `version` in `pubspec.yaml`
3. Add entry to `CHANGELOG.md`
4. `flutter pub publish --dry-run`
5. `flutter pub publish`
