# Chezmoi Migration Plan

## Goal

This document outlines a migration from the current Nix-centric dotfile ownership model to a split model:

- `nix` / `nix-darwin` / `home-manager` own packages, system settings, and `programs.*`
- `chezmoi` owns per-user dotfile contents such as `nvim`, `~/.codex`, `~/.apm`, and selected `~/.config/*`

The intent is to make file-level dotfile editing independent from Nix module edits while preserving reproducible package and system configuration.

## Principles

### Single owner per file

Each path under `$HOME` should be owned by exactly one layer.

- Nix owns package installation, activation, and `programs.*`
- chezmoi owns concrete dotfile contents
- generated or third-party managed paths should be explicitly excluded from chezmoi if needed

### Keep bootstrap explicit

The recommended bootstrap flow is:

1. `chezmoi init <repo>`
2. `chezmoi apply`
3. `darwin-rebuild switch --flake <path>#TY`
4. `chezmoi apply`

`chezmoi apply` should be treated as a normal step, not as a recovery step.

### Prefer Nix for behavior, chezmoi for content

If Home Manager has a good `programs.*` abstraction, keep the behavior there.

Examples:

- keep `programs.zsh`, `programs.git`, `programs.direnv`, `programs.fzf`, `programs.zoxide` in Nix
- move editor config, plain shell snippets, prompt helper files, Codex/APM config, and content-heavy config trees to chezmoi

## Current State

Today this repository mixes package ownership and dotfile ownership.

Examples from the current tree:

- `home-manager/nvim` is linked into `~/.config/nvim`
- `home-manager/chezmoi` is linked into `~/.config/chezmoi`
- `.gitconfig` is managed via `home.file`
- `~/.config/zsh/functions/*` is managed via `home.file`
- `zsh-abbr` content is embedded inline in Nix

This works, but it makes file-level config edits depend on Nix structure and `home.file` ownership.

## Target Ownership Model

### Keep in Nix

- `flake.nix`
- Nix overlays and custom packages
- `nix-darwin` host configuration
- `home-manager` package list
- `programs.*` declarations
- shell integration wiring such as `direnv`, completion, `zoxide`, and `starship`

### Move to chezmoi

- Neovim config tree
- `~/.codex`
- `~/.apm`
- plain `~/.config/*` trees that are content-oriented
- shell helper files
- `zsh-abbr` user abbreviations
- optionally `.gitconfig` if it stays mostly static and content-driven

### Hybrid handling for zsh

Do not fully migrate `.zshrc` to chezmoi.

Recommended split:

- Nix owns the main `programs.zsh` setup
- chezmoi owns user shell fragments such as `~/.config/zsh/local.zsh` and `~/.config/zsh/functions/*`
- Nix sources the chezmoi-managed shell fragment from `initExtra`

This avoids double ownership of `.zshrc` while still allowing fast user-level edits.

## Proposed Repository Layout

```text
.
├── flake.nix
├── flake.lock
├── .chezmoiroot
├── Taskfile.pkl
├── justfile
├── docs/
│   └── chezmoi-migration-plan.md
├── nix/
│   ├── darwin/
│   │   ├── configuration.nix
│   │   └── homebrew.nix
│   ├── home/
│   │   ├── default.nix
│   │   ├── packages.nix
│   │   ├── programs.nix
│   │   └── shell.nix
│   ├── overlays/
│   │   └── default.nix
│   └── pkgs/
│       └── cargo-compete.nix
└── chezmoi/
    ├── .chezmoi.toml.tmpl
    ├── .chezmoiignore
    ├── dot_apm/
    ├── dot_codex/
    ├── dot_config/
    │   ├── chezmoi/
    │   ├── nvim/
    │   ├── zsh/
    │   └── zsh-abbr/
    ├── dot_gitconfig
    └── dot_zshrc
```

## Why this layout

- `nix/` becomes the configuration root for system and Home Manager logic
- `chezmoi/` becomes the source root for files materialized into `$HOME`
- the top-level `flake.nix` remains stable and can import from `./nix/...`
- the split is visible from the directory tree itself

## Bootstrap Design

### Baseline flow

Recommended first-machine setup:

1. Install Nix
2. Install or invoke chezmoi
3. `chezmoi init <repo>`
4. `chezmoi apply`
5. `darwin-rebuild switch --flake <flake-path>#TY`
6. `chezmoi apply`

### Flake path options

#### Option A: use the repository source tree as the flake root

This is the safest immediate design.

The repository is the chezmoi clone/source directory, while `.chezmoiroot`
selects `chezmoi/` as its source state. Resolve the flake root from the clone so
the bootstrap also works with a non-default source directory:

```sh
source_dir=$(git -C "$(chezmoi source-path)" rev-parse --show-toplevel)
darwin-rebuild switch --flake "$source_dir"#TY
```

Advantages:

- no need to wait for target files to exist before the first switch
- minimal bootstrap ambiguity

#### Option B: use a target path such as `~/.config/home-manager`

This is possible, but then `chezmoi apply` before the first switch becomes mandatory because the target tree does not exist until chezmoi writes it.

For the initial migration, Option A is simpler and lower-risk.

## Do We Need a Bootstrap Shell Script?

Probably not with the current repository.

The reference repository `mizchi/chezmoi-dotfiles` includes `run_once_before_install-brew.sh` because its `nix-darwin` Homebrew setup depends on a custom `~/brew` prefix existing before the first switch.

This repository currently:

- uses `nix-homebrew`
- does not define a custom `~/brew` prefix in the checked-in Nix config
- still expects the standard `/opt/homebrew/bin/brew` in shell initialization

So the exact bootstrap dependency from the reference repository does not exist here.

Recommendation:

- do not add a bootstrap shell script yet
- add one only if a real pre-switch dependency appears

Examples of valid reasons to add a script:

- a custom Homebrew prefix must exist before activation
- a required file must be generated before `darwin-rebuild switch`
- a non-Nix prerequisite must be prepared before the first activation

## Migration Plan

### Phase 1: separate Nix layout from dotfile content

1. Create `nix/` and move current Nix-owned directories under it
2. Update `flake.nix` imports to point at `./nix/...`
3. Split the current `home-manager/home.nix` into smaller modules

Suggested split:

- `nix/home/default.nix`
- `nix/home/packages.nix`
- `nix/home/programs.nix`
- `nix/home/shell.nix`

### Phase 2: introduce chezmoi source layout

1. Create `chezmoi/`
2. Add `.chezmoi.toml.tmpl`
3. Add `.chezmoiignore`
4. Use this repository as the chezmoi source repository and select `chezmoi/`
   as its source state with `.chezmoiroot`

### Phase 3: move file-owned config trees

Recommended order:

1. Move `home-manager/nvim` to `chezmoi/dot_config/nvim`
2. Move `home-manager/zsh/functions/*` to `chezmoi/dot_config/zsh/functions/*`
3. Move `zsh-abbr` content from inline Nix text to `chezmoi/dot_config/zsh-abbr/user-abbreviations`
4. Move `~/.codex`
5. Move `~/.apm`
6. Move other selected `~/.config/*` trees

### Phase 4: reduce `home.file` ownership

As each path moves to chezmoi, delete the corresponding `home.file` entry from Nix.

Important rule:

- never let the same target path be owned by both `home.file` and chezmoi

### Phase 5: settle zsh ownership

Keep `programs.zsh` in Nix, but source a chezmoi-managed fragment from Nix.

Example direction:

```nix
programs.zsh.initExtra = ''
  if [ -f "$HOME/.config/zsh/local.zsh" ]; then
    source "$HOME/.config/zsh/local.zsh"
  fi
'';
```

This preserves Nix-controlled shell behavior while allowing direct edits to user shell content.

### Phase 6: document steady-state operations

Add a short operations guide for:

- first bootstrap
- updating Nix only
- updating dotfiles only
- updating both

Suggested steady-state rules:

- dotfile-only changes: `chezmoi apply`
- Nix-only changes: `darwin-rebuild switch --flake <path>#TY`
- mixed changes: `chezmoi apply && darwin-rebuild switch --flake <path>#TY && chezmoi apply`

## Resolved Decisions

- This repository is the chezmoi source repository.
- `.chezmoiroot` limits the source state to `chezmoi/`.
- The flake stays at the repository root and is invoked from the chezmoi clone.
- No bootstrap shell script is needed until a real pre-switch dependency exists.

## Open Decisions

The migration still needs explicit choices on these points:

1. Should `.gitconfig` remain in Nix or move to chezmoi?
2. Which `~/.config/*` trees are content-owned enough to move immediately?
3. Should APM-managed or generated paths be excluded from chezmoi from day one?

## Recommended Next Step

Start with the least risky migration path:

1. keep the flake at repository root
2. create `nix/` and `chezmoi/` as ownership boundaries
3. migrate `nvim` first
4. then migrate shell helper files and `zsh-abbr`
5. leave `.zshrc` main ownership in Nix

This yields the structural benefits of chezmoi without destabilizing system activation.
