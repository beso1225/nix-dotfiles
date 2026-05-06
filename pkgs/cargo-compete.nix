{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  openssl,
  zlib,
  libiconv,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-compete";
  version = "0.10.7";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-EbseENvy8vBn97aR2LlH8eVgHtC1DKECSo6Dw0X6Vo0=";
  };

  cargoHash = "sha256-lid1tyR8Y6lvjpeGJ4vGzqDTY6V2y/5rL9fGyjyF3yw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ zlib ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

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
