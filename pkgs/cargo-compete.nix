{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-compete";
  version = "0.10.7";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-EbseENvy8vBn97aR2LlH8eVgHtC1DKECSo6Dw0X6Vo0=";
  };

  # Run `nix build` once to get the actual hash from the error output,
  # then replace this placeholder with the real value.
  cargoHash = lib.fakeHash;

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  meta = with lib; {
    description = "A Cargo subcommand for competitive programming";
    homepage = "https://github.com/qryxip/cargo-compete";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "cargo-compete";
  };
}
