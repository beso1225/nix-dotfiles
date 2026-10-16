# User Config Ownership

Issue [#64](https://github.com/beso1225/nix-dotfiles/issues/64) adds the following
content to the `chezmoi/` source tree. Import individual files, not entire home
directories: applications often store credentials and session data beside config.

## Managed content

| Target under `$HOME` | Chezmoi-owned content | Other owner / excluded content |
| --- | --- | --- |
| `.codex` | `AGENTS.md`, selected preferences in `config.toml`, RunCat registration in `hooks.json`, `runcat-hook.py`, the customized `herdr` skill | Codex owns auth, sessions, databases, plugins, bundled `.system` skills, generated rules, runtimes, project trust, and app integration settings; herdr owns its integration script and hook registrations |
| `.apm` | `apm.yml`, `apm.lock.yaml`, `config.json` | APM owns `apm_modules` and deployed skills |
| `.agents` | None in this phase | APM deploys the twelve dependencies listed below |
| `.claude` | `settings.json`: `theme` only; `CLAUDE.md` symlink to `../.codex/AGENTS.md` | Preserve all other settings, including herdr hooks; ignore hooks, caches, and backups |
| `.copilot` | `settings.json`: `showReasoning` only | Preserve other settings; ignore auth/config state, permissions, sessions, and herdr scripts |
| `.latexmkrc` | LuaLaTeX/Biber commands and output directories | Backup files |
| `.config/btop` | `btop.conf` | Downloaded themes |
| `.config/gh` | `config.yml` | `hosts.yml`, authentication |
| `.config/git` | `ignore` | `.gitconfig` remains Home Manager-owned |
| `.config/ghostty` | `config` | Other application files |
| `.config/herdr` | `config.toml` | Sockets, logs, sessions/snapshots, integration scripts |
| `.config/hunk` | `config.toml` | `state.json` |
| `.config/karabiner` | `karabiner.json` | Automatic backups and downloaded modification assets |
| `.config/rstudio` | `rstudio-prefs.json` | Dictionaries and other app data |
| `.config/yazi` | `init.lua`, `keymap.toml`, `package.toml`, `theme.toml`, `yazi.toml` | `ya pkg` owns `plugins` and `flavors` |
| `.config/zed` | `settings.json`, `keymap.json` | Conversations, prompt databases, downloaded themes |
| `.config/zellij` | `config.kdl`, `themes/tokyonight.kdl` | Full default-config dump and other themes |

Previously migrated Neovim, AeroSpace, zsh functions, and zsh-abbr content stay
chezmoi-owned. There are no Home Manager `home.file` declarations for the new
targets, so this phase requires no ownership removal from Nix.

### Files shared with applications

Codex stores user defaults in `~/.codex/config.toml`
([OpenAI configuration documentation](https://learn.chatgpt.com/docs/config-file/config-basic)).
The installed desktop app also writes machine-specific integration entries there.
`dot_codex/modify_config.toml` updates only these user preferences:

- `model`, `model_reasoning_effort`, `personality`, `service_tier`
- `features.hooks`, `features.js_repl`, `features.reasoning_effort_override`
- `features.context_management.experimental_mode`

Every other TOML value is preserved, including `notify`, MCP servers,
marketplaces, plugins, and trusted projects. Fresh homes receive just the managed
preferences, without paths to uninstalled desktop runtimes. Edit the modify
template to change these preferences; do not recursively re-add `.codex`.

The JSON modify templates preserve unrelated settings and herdr registrations.
Codex's RunCat hook uses `$HOME` at execution time and replaces existing RunCat
commands without adding duplicates. The other AI clients do not receive hooks
pointing to herdr scripts that might not be installed yet.

`~/.claude/CLAUDE.md` is a chezmoi-managed symlink to `~/.codex/AGENTS.md`, so
Claude Code reuses the same personal instructions as Codex. It is declared with
the `symlink_` source attribute and a relative target
(`chezmoi/dot_claude/symlink_CLAUDE.md`); edit `dot_codex/AGENTS.md` to change the
content. The `.chezmoiignore` exception `!.claude/CLAUDE.md` keeps only this link
managed while the rest of `.claude` stays local.

These templates use chezmoi's documented
[partial-file management](https://www.chezmoi.io/user-guide/manage-different-types-of-file/).
TOML/JSON serialization can change formatting and remove comments; values outside
the selected keys remain local. Invalid existing TOML/JSON fails the apply instead
of discarding it.

### Skill dependencies and local changes

Store install inputs for external skills instead of copying their bodies into
dotfiles. OpenAI skills use the latest official versions verified during this
migration, including their instructions and supporting resources. Customizations
to those six skills, `grilling`, and `domain-modeling` are superseded by upstream;
back them up before migrating an existing installation. The customized `herdr`
skill remains locally maintained.

| Skills | Source / restore method | Content stored in this repository |
| --- | --- | --- |
| `apm-usage`, `pkfire` | Existing pinned APM dependencies | Manifest and lockfile only |
| `typesafe-ai` | `typesafe-ai/skills/skills/typesafe-ai`, pinned in APM | Manifest and lockfile only; installed contents matched the pinned source |
| `tenbin-astra-diff-review` | Private `beso1225/agent-skills/skills/tenbin-astra-diff-review`, pinned in APM | Manifest and lockfile only; installed contents matched the existing source repo |
| `define-goal`, `gh-address-comments`, `gh-fix-ci`, `hatch-pet`, `playwright`, `yeet` | Official `openai/skills/skills/.curated/<name>#main`; exact commits recorded in the APM lockfile | Manifest and lockfile only; complete official skills, without local overrides |
| `herdr` | Local customized instructions and command reference | Only `SKILL.md`, `references/commands.md`, and the installed `LICENSE`; no full upstream checkout |
| `grilling` | `mattpocock/skills/skills/productivity/grilling#main`; exact commit recorded in the APM lockfile | Manifest and lockfile only; upstream instructions and agent metadata replace the local copy |
| `domain-modeling` | `mattpocock/skills/skills/engineering/domain-modeling#main`; exact commit recorded in the APM lockfile | Manifest and lockfile only; complete upstream instructions, glossary/ADR formats, and agent metadata |

Upstream `domain-modeling` uses `GLOSSARY.md` and `GLOSSARY-MAP.md`, with
`GLOSSARY-FORMAT.md` replacing the old local `CONTEXT-FORMAT.md`. Adopt this
convention when using the updated skill; migration of existing project documents
is separate from installing the skill.

The initial 78-file skill snapshot is reduced to three files in the customized
`herdr` skill. The eight upstream skills above track `main` in `apm.yml`, while
`apm.lock.yaml` records the exact commits to restore. Updating resolves the latest
upstream revisions; installing from the lockfile reproduces the recorded versions.
The other four APM dependencies retain their explicit commit refs.

APM's lockfile was generated by APM 0.32 in an isolated directory and records all
twelve dependencies, pinned commits, deployed paths, and file hashes. The six OpenAI
skills were restored and compared against the official source archive. The
`grilling` and `domain-modeling` contents were compared against their pinned
upstream source. Fresh installations with `--frozen` verify reproducibility. `.chezmoiignore` excludes
module caches, `.agents`, and all ten relocated legacy `.codex/skills/<name>`
paths. Bundled `.system` skills and plugin caches remain installed by Codex.

## Paths intentionally left outside this phase

| Category | Paths / reason |
| --- | --- |
| Application config excluded by user preference | `.arduinoIDE`, `.keras`, `.docker`; all Arduino IDE, Keras, and Docker settings, including CLI auth, context selection, and runtime state, remain local |
| Nix-generated configuration | `.gitconfig`, `.zshenv`, `.zprofile`, `.zshrc`, `.config/starship.toml`, `.config/sheldon`, `.config/tmux`; keep shell wiring and prompt/plugin behavior in `programs.*` |
| Inactive shell config and backups | `.p10k.zsh`, `.profile` (Docker/rustup-generated PATH setup), `.tmux.conf.back`, `.latexmkrc.back`, `*.backup`, `*.hm-backup`, `chezmoi.back`, `nvim.back`, `zshenv.before-nix-darwin` |
| Credentials and app databases | `.ssh`, `.claude.json`, `.dsh`, `.pgadmin`, `.plastic4`, `.config/github-copilot`, `.config/jotworthy/env`, `.config/configstore`, `.config/containers`, `.config/raycast`, `.config/iterm2` |
| Mixed preferences and local state | `.psychopy3`, `.config/fontforge/prefs` (includes recent private document paths), `.config/gtk-2.0/gtkfilechooser.ini`, `.gtk-bookmarks`, `.vscode/argv.json`; need a separate selection/partial-file decision |
| Installed tools, dependencies, and caches | `.cargo`, `.rustup`, `.npm`, `.pyenv`, `.moon`, `.ollama`, `.pkl`, `.swiftpm`, `.texlive2025`, `.nix-defexpr`, `.nix-profile`, `.local`, `.cache`, `.ServiceHub`, `.Library`, `.vscode*/extensions`, `.tmux/plugins`, `Applications`, `bin`, `etc`, `go`, `ghq`, `LizzieYzy-2.5.4-non_RTX` |
| Generated histories and metadata | Shell/Python/R/Node histories, `.bash_sessions`, `.zsh_sessions`, `.zcompdump*`, `.viminfo`, `.vim/.netrwhist`, `.chpwd-recent-dirs`, `.wget-hsts`, `.DS_Store`, `.CFUserTextEncoding`, `.cups`, `.Trash`, `.obsidian-cli.sock`, `.matplotlib/fontlist-*`, `.ipython` runtime files, `.vscode-R`, `.vscode-server`, `.vscode-shared`, `.config/cagent`, `.config/ghc` |
| Personal data and ad hoc scripts | `Desktop`, `Documents`, `Downloads`, `Library`, `Movies`, `Music`, `Pictures`, `Public`, `vault-curator-backups`, `file.txt`, `watch-file.sh`; not application dotfiles |

The `.gitconfig` decision is to keep it in Nix: it is already generated from
`home-manager/git/.gitconfig` and configures behavior (identity, initial branch,
pager). Moving it brings no file-editing benefit in this phase. The separate XDG
ignore file can be owned by chezmoi without overlapping it.

## Restore and update

After the bootstrap in [the migration plan](chezmoi-migration-plan.md), restore
external content explicitly:

```sh
cd <repo-path>
pkf run chezmoi-diff
pkf run chezmoi-apply
GITHUB_APM_PAT="$(gh auth token)" apm install --global --frozen
ya pkg install
```

The chezmoi tasks run from the repository root and use its `chezmoi/` source,
independently of the default source configured on the machine. Both run every
time without caching. Review the diff before applying.

The APM install needs GitHub access to the private `beso1225/agent-skills` repo.
Authenticate with `gh auth login` first; the command above passes the existing
token through the process environment, not a checked-in file. `--frozen` is the
flag exposed by the installed APM 0.32 CLI. Keep dependency updates intentional.
After an APM update, copy the revised manifest and lockfile
into `chezmoi/dot_apm/`; do not add `apm_modules` or deployment directories.
To update the six OpenAI skills, `grilling`, and `domain-modeling`, run a
targeted update:

```sh
GITHUB_APM_PAT="$(gh auth token)" apm update --global \
  openai/skills/skills/.curated/define-goal \
  openai/skills/skills/.curated/gh-address-comments \
  openai/skills/skills/.curated/gh-fix-ci \
  openai/skills/skills/.curated/hatch-pet \
  openai/skills/skills/.curated/playwright \
  openai/skills/skills/.curated/yeet \
  mattpocock/skills/skills/productivity/grilling \
  mattpocock/skills/skills/engineering/domain-modeling
```

Keep the manifest refs as `#main`; review and commit the regenerated lockfile
after verifying a frozen installation. The targeted update leaves the other four
dependencies at their declared commits. Ordinary and frozen installs reuse the
locked revisions; they do not automatically advance to the latest upstream head.
See the [APM lockfile specification](https://microsoft.github.io/apm/reference/lockfile-spec/).
Do not recursively re-add restored skill trees.
Yazi's checked-in `package.toml` records plugin/flavor revisions and hashes.
Chezmoi apply needs no skill downloads; APM and Yazi installation remain explicit.
Reinstall herdr integrations
using herdr on a machine that needs them; their generated files remain local.

On an existing machine, APM's relocated skills will appear in `.agents/skills`.
After verifying those copies, move the old six OpenAI skill directories plus
`typesafe-ai`, `tenbin-astra-diff-review`, `grilling`, and `domain-modeling` from
`.codex/skills` to a backup outside both skill search directories, such as
`.local/state/skill-migration-backup`.
Chezmoi deliberately does not delete the legacy copies. Do not leave both
locations installed: that would create duplicate skill names. Preserve any local
changes in the backup, including the earlier customized `hatch-pet` version.

Review local changes with `chezmoi --source <repo-path>/chezmoi diff`. For ordinary
files, use `chezmoi add <specific-file>` after editing; for partial files, edit
the corresponding `modify_` template instead. Avoid recursive `chezmoi add ~`.

Run `pkf run test-chezmoi` to check both migration phases. Phase 4 restores fresh
and populated temporary homes, verifies preserved app values and hook state,
tests excluded files even when accidentally imported into source, and checks
that repeated apply is idempotent. Manifest and lockfile checks enforce the
complete official OpenAI dependencies, the eight `main` refs, and consistent
lockfile commit pins. Tests do not modify the real home directory or need
network/private repository access.
