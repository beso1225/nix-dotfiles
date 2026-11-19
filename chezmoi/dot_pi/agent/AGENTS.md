# Notion shared memory

- Use Notion as shared long-term memory across agents.
- Before user- or project-dependent work, read the Agent
  Operating Guide v0.0.6 once per session:
  https://app.notion.com/p/410b3a3685b681e1aba6f9ca5438d593
- Search relevant Notion Memories when previous decisions,
  preferences, or project state may affect the task.
- Proactively update an existing Memory when a meaningful
  project milestone, design decision, blocker, or durable
  preference changes.
- Keep repository-specific implementation details in the
  repository. Do not store secrets or temporary progress.
- Search before saving, avoid duplicates, and verify writes.
- Pass instructions_version="0.0.6" to Notion MCP tools
  when the parameter is supported.
- Follow the Guide's approval requirements and exclusions.
