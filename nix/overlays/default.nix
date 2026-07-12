final: prev: {
  cargo-compete = prev.callPackage ../pkgs/cargo-compete.nix { };
  gccWithoutCc = prev.callPackage ../pkgs/gcc-without-cc.nix { };
}
