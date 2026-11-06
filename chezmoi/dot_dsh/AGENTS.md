# DSH-specific instructions

When using `poteto-mode` or a pstack workflow, read
`~/.config/pstack/dsh-tools.md` and apply its DSH mappings alongside the skill.

## Coding-Memory

- When an MCP server named `coding_memory` or starting with `coding_memory_` is
  available, use its memory search tool before investigating recurring failures
  or relying on project-specific constraints. DSH exposes these tools as
  `mcp__<serverName>__<toolName>`, such as
  `mcp__coding_memory__memory_search` or
  `mcp__coding_memory_tanikun__memory_search`.
- Use short English technical queries, read relevant notes, and check their
  applicability. Select the server bound to the current project; do not use a
  server bound to another project as its replacement.
