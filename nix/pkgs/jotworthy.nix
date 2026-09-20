{ buildGoModule, src }:

buildGoModule {
  pname = "jotworthy";
  version = "0.1.0";
  inherit src;

  vendorHash = null;

  postInstall = ''
    mv "$out/bin/jev-jotworthy" "$out/bin/jotworthy"
  '';

  meta = {
    description = "Judge whether a thought is worth capturing in an Obsidian daily note";
    homepage = "https://github.com/beso1225/jev-jotworthy";
    mainProgram = "jotworthy";
  };
}
