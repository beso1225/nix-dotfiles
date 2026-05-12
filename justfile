set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

switch host="TY":
    sudo nix run nix-darwin -- switch --flake .#{{host}}

update-nixpkgs:
    nix flake update nixpkgs

update-all:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "WARNING: This runs 'nix flake update' and may update all flake inputs (including home-manager and nix-darwin)."
    read -r -p "Continue? [y/N] " reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
    nix flake update
