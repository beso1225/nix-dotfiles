# pstack tool mapping for DeepSeek Harness

Use this mapping when a pstack skill names Claude Code tools, models, or paths.
The tools and options exposed by the current DSH session take precedence over
examples here. Follow the user's instructions and the host's permissions.

## Tools and delegation

| pstack or Claude Code | DSH |
| --- | --- |
| `Skill` or `/skill-name` | Use the available `skill` tool or a user-invoked slash skill. |
| `Agent` or `Task` | Use the available `subagent` tool. Give the child the absolute path to `poteto-mode/SKILL.md` and ask it to read the skill when the workflow requires its style. |
| `poteto-agent` or `comment-sicko` agent type | Use an available child agent and ask it to read the relevant `poteto-mode` instructions or `references/agents/comment-sicko.md`. Do not invent an agent type. |
| Task list | Use `todo_write` when available. Each call replaces the entire list; statuses are `pending`, `in_progress`, and `completed`. Otherwise use the skill's documented file fallback. |
| `AskUserQuestion` | Use the available question tool, or ask in plain text if none is exposed. |

Start independent children together when appropriate. Follow the session's
subagent tool description for background execution, completion notifications,
and messaging: these capabilities depend on the provider and version. Do not
poll or sleep when the host says completion notices will resume the parent.
If delegation is unavailable, use the skill's documented fallback; do not claim
that a required independent review was performed.

For parallel writers, create separate worktrees when the workflow calls for
isolation. Set the child `cwd` only if the exposed tool supports it; otherwise
include the absolute worktree path in the child prompt. Review each child's
changes before integrating them.

## Models and skills

Claude model names and role-specific agent types are not automatically valid
DSH routes. Inherit the parent route by default. Select another model or effort
only when the current session exposes that option and confirms the route and
effort are available. Report when a requested diverse-model review cannot be
performed; do not present repeated runs of one model as model diversity.

Skills-only APM installations do not provide all pstack companion skills or
plugin tools. Load named skills when available. If a required companion or
driver is missing, state the limitation and follow any explicit fallback in the
workflow; do not invent plugin tools or claim a missing check succeeded.

For `create-verification-skill` and `maintain-verification-skill`, use a
project skill root recognized by the current DSH installation, such as
`.dsh/skills/`, rather than assuming Claude's `.claude/skills/` is discovered.
Keep the project's existing verification skill location when it is already
recognized by DSH.

## References

- DSH agent instructions: https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/context/agent-instructions/README.md
- DSH subagent tool: https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/subagent/tool-subagent/README.md
- DSH skill filesystem: https://github.com/deepseek-ai/deepseek-harness/blob/master/packages/skill/skill-filesystem/README.md
- DSH pstack port and historical mapping: https://github.com/aa2246740/pstack-dsh/blob/main/HARNESS.md
