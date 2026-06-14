# Agent Notes

## Densepose / Claude Memory Sync

When working in `/mnt/windows/Users/densepose/Documents/densepose` or its subdirectories, sync context with Claude's persisted project memory before doing non-trivial debugging or project-state analysis.

Start here:

- `/home/q1/.claude/projects/-mnt-windows-Users-densepose-Documents-densepose/memory/MEMORY.md`

Then read the relevant linked `memory/*.md` files for the task. The most commonly useful ones are:

- `project_context.md` for repo layout and project history
- `project_pi_access.md` for Pi/router access details
- `project_pi_overlayroot_timesync.md` for Pi reboot, overlayroot, timestamp, CSI MAC-filter, and re-arm gotchas
- `project_qtc_benchmark_provenance.md` for QTC benchmark/training interpretation
- `project_recording_session.md` for older capture-pipeline state
- `reference_yuehung_notes.md` for where Yue Hung's docs live

Treat Claude memory as helpful context, not absolute truth: the user's newest message and live system/repo state win when they conflict.

Do not paste secrets or credentials from memory into replies unless the user explicitly asks and the task requires it. Use them operationally only when needed.
