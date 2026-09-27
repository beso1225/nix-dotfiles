{
  lib,
  rustPlatform,
  pkg-config,
  cairo,
  texlive,
  src,
}:

rustPlatform.buildRustPackage {
  pname = "tdf";
  version = "0.5.0-synctex";
  inherit src;

  cargoHash = "sha256-Rj4vW0gN3NafjiVDMENc7JYqsyCkJfer4nmlCY3xHqA=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    rustPlatform.bindgenHook
    cairo
    texlive.bin.core.dev
  ];
  buildFeatures = [ "synctex" ];

  doCheck = false;

  postInstall = ''
    rm "$out/bin/for_profiling"
  '';

  meta = {
    description = "Terminal PDF viewer with SyncTeX support";
    homepage = "https://github.com/yebo-liu/tdf";
    license = lib.licenses.agpl3Only;
    mainProgram = "tdf";
    platforms = lib.platforms.unix;
  };
}
