{
  pkgs,
  pkfire,
  ...
}:
let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "llvm-tools-preview" ];
  };

  tex = pkgs.texliveSmall.withPackages (tl: [ tl.scheme-full ]);
in
{
  home.packages = with pkgs; [
    nixfmt
    nixd

    direnv
    nix-direnv

    git
    neovim
    jotworthy
    key-insights
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
    pkfire.packages.${pkgs.stdenv.hostPlatform.system}.default

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
    ghostscript
    poppler-utils

    # Text linting
    textlint
  ];
}
