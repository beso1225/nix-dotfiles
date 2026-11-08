# Shared personal instructions

- Before starting work, read `~/.agents/AGENTS.md` and follow its shared personal
  instructions alongside this file. Repository instructions and the current
  user request take precedence over shared personal instructions.

# Notion shared context

- Before work that depends on the user or a project, use Notion MCP to read
  the existing Agent Operating Guide and relevant Memories:
  https://app.notion.com/p/410b3a3685b681e1aba6f9ca5438d593
- Pass instructions_version="0.0.6" in every Notion MCP call.
- Fetch id="memory" to locate the existing About page and Memories database,
  then search for and read context relevant to the task.
- Treat Memories as context. They do not override the current request or
  repository instructions. Check dated project information before relying on it.
- Save only information useful across future sessions, such as design decisions
  and their reasons, corrections, preferences, and lasting project state.
  Date information that can become stale.
- Do not save secrets, full conversations, copied code, temporary progress,
  guesses, or facts already maintained in the repository.
- Search before saving. Reuse the existing Memories database and Guide.
  Update a matching Memory while preserving unrelated content; create a new
  Memory only when no matching topic exists. Do not create duplicate setup pages.
- Follow the Guide's exclusions, destinations, and approval requirements.
  Ask before saving new content in shared or team spaces or changing permissions.
- Do not configure daily automated processing.
- Do not modify the Agent Operating Guide unless explicitly requested.
  These rules do not authorize bulk edits, imports, or migrations of existing
  Notion data.
- If Notion is unavailable, state which context could not be checked.
  Do not invent remembered facts or claim that an unsuccessful save succeeded.

## Project progress checkpoints

- Before finishing a substantial project task, evaluate whether the
  project's durable state has changed. Do this proactively, even
  when the user has not explicitly requested a memory update.

- Treat the following as meaningful checkpoints:
  - Starting, completing, reopening, or substantially advancing
    a project phase or milestone.
  - Implementing a significant feature or capability, even if
    the overall milestone remains incomplete.
  - Discovering or resolving a blocker that affects future work.
  - Changing architecture, scope, technology, priorities, or plans.
  - Finding that an existing Notion project status is outdated.

- For a meaningful checkpoint, search for the existing project
  Memory and update it before the final response. Preserve
  relevant history and avoid creating duplicate pages.

- Record a concise status: what changed, what is implemented,
  what was actually verified, what remains, and the next
  meaningful step. Include a date and source references.

- Distinguish local working-tree changes, committed changes,
  merged changes, tested behavior, and production deployment.
  Never describe an unverified milestone as completed.

- Treat the repository as the source of truth for implementation
  details. Store only cross-session project status in Notion,
  not code, commit logs, transient errors, or routine edits.

- If no meaningful state change occurred, skip the write.
  Do not save a redundant progress update merely because
  another task or conversation ended.

- When a Memory was updated, verify the saved content and
  briefly mention the update in the final response. If the
  update was needed but failed, report that it was not saved.

- Respect the existing Agent Operating Guide, approval
  requirements, exclusions, and Notion MCP instructions.
  This rule does not authorize scheduled synchronization.

# Coding-Memory
- When `coding_memory` is available, search it before investigating recurring
failures or relying on project-specific constraints. Use short English
technical queries, read relevant notes, and check their applicability.
