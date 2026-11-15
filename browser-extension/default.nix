# Unpacked MV3 build of the web-palette extension.
# Loaded by Helium through --load-extension (see modules/web-palette.nix).
{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "web-palette-extension";
  version = "0.1.0";
  src = ./.;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp manifest.json background.js content.js mapping.js $out/
    runHook postInstall
  '';
}
