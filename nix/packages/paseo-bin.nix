{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

# Paseo Desktop for the Mac, including the daemon and CLI it bundles. The dev
# pod runs the npm CLI at the same version through bin/dev-pod-paseo.
let
  version = "0.17.1";
  sources = {
    aarch64-darwin = {
      url = "https://github.com/getpaseo/paseo/releases/download/v${version}/Paseo-${version}-arm64.zip";
      hash = "sha256-VPkNDrV/JA/AWgXBSK9YaNnB3fX3nGC88Zv2emtRL3A=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported Paseo binary platform: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "paseo";
  inherit version;

  src = fetchurl source;
  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];
  # The bundle is signed and notarized; any fixup edit would break its signature.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R Paseo.app "$out/Applications/"
    # The launcher follows symlinks back into the bundle to find Electron.
    ln -s "$out/Applications/Paseo.app/Contents/Resources/bin/paseo" "$out/bin/paseo"

    runHook postInstall
  '';

  meta = {
    description = "Desktop app, daemon, and CLI for running AI coding agents";
    homepage = "https://paseo.sh/";
    changelog = "https://github.com/getpaseo/paseo/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "paseo";
    platforms = builtins.attrNames sources;
  };
}
