set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

switch host="TY":
    sudo darwin-rebuild switch --flake .#{{host}}

update-nixpkgs:
    nix flake update nixpkgs
    echo "Updated nixpkgs. Run 'just switch' to apply changes."

update-homebrew:
    brew update
    echo "Updated Homebrew. Run 'just switch' to apply changes."

update-all:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "WARNING: This runs 'nix flake update' and may update all flake inputs (including home-manager and nix-darwin)."
    echo -n "Continue? [y/N] "
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
    nix flake update
    echo "Updated flake inputs. Run 'just switch' to apply changes."
