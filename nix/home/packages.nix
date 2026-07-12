{
  pkgs,
  pkfire,
  ...
}:
let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "llvm-tools-preview" ];
  };

  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium
      luatexja
      jsclasses
      silence
      circuitikz
      ;
  };
in
{
  home.packages = with pkgs; [
    nixfmt
    nixd

    direnv
    nix-direnv

    git
    neovim
    eza
    lazygit
    yazi
    just
    pkl
    cargo-watch
    tree-sitter
    fd
    ripgrep
    bat
    gh
    wget
    ghq
    uv
    chezmoi
    pkfire.packages.${pkgs.system}.default

    # rust tools
    rustToolchain
    cargo-binutils
    sqlx-cli
    cargo-compete
    mini-redis

    # C/C++ tools
    gccWithoutCc
    cmake
    ninja

    # TeX
    tex
    biber
    ghostscript
    poppler-utils

    # Text linting
    textlint
  ];
}
