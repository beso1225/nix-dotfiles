# Chezmoi Bootstrap

This repository is both the nix-darwin flake and the chezmoi source repository.
Chezmoi clones the whole repository, while `.chezmoiroot` limits its source
state to the `chezmoi/` subdirectory. The repository root therefore remains the
flake root without exposing Nix or documentation files as home-directory
targets.

## First bootstrap

After installing Nix and making `chezmoi` available, run:

```sh
chezmoi init beso1225/nix-dotfiles
chezmoi apply
source_dir=$(git -C "$(chezmoi source-path)" rev-parse --show-toplevel)
darwin-rebuild switch --flake "$source_dir"#TY
chezmoi apply
```

The two `chezmoi apply` steps are intentional. The first materializes files
needed by Nix activation once such files are introduced. The second reconciles
the home directory after nix-darwin and Home Manager activation.

No bootstrap shell script is provided. Add one only when a concrete dependency
must exist before the first `darwin-rebuild switch`.

## Ownership boundary

Every path under `$HOME` must have a single owner. Nix and Home Manager own
packages, activation, `programs.*`, and all current `home.file` targets. Chezmoi
will own a target only after its corresponding `home.file` entry is removed in
the same change.

Phase 2 deliberately adds no managed home-directory paths. The chezmoi config
itself is generated from `chezmoi/.chezmoi.toml.tmpl`; Home Manager no longer
owns `~/.config/chezmoi`, which avoids a directory/symlink conflict during
bootstrap.
