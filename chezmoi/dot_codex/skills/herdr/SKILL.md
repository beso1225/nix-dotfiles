---
name: herdr
description: Control workspaces, tabs, panes, or agents in a running herdr session. Use only when HERDR_ENV=1.
---

# herdr

Check `HERDR_ENV=1` before using this skill. If it is absent, stop: the CLI
controls only the running herdr session. Discover current IDs with `herdr pane
list`, `herdr tab list`, or `herdr workspace list`; IDs can change after panes
or tabs close.

Read the relevant section of [commands](references/commands.md) for the
requested operation. Use the CLI to inspect current state before mutating a
pane or workspace, and verify the resulting state. Do not spawn another agent
without authorization from the user or applicable project instructions.
