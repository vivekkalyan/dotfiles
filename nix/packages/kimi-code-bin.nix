{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  stdenv,
}:

let
  version = "2.1.1";
  sources = {
    aarch64-darwin = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-darwin-arm64";
      sha256 = "4bab6f96c2c289368b7f05a04f66737c53a59ce740f932d8f149240584758efb";
    };
    x86_64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-x64";
      sha256 = "66f47536e40b02bb1d577cdd324768f73d39b8b9472e0ca140e73d8e225cd7de";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported Kimi Code binary platform: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "kimi-code";
  inherit version;

  src = fetchurl source;
  sourceRoot = ".";
  dontUnpack = true;
  # Stripping the binary corrupts its embedded Bun runtime on Linux.
  dontStrip = true;
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/kimi"

    runHook postInstall
  '';

  meta = {
    description = "Kimi Code command-line coding agent";
    homepage = "https://www.kimi.com/code/";
    license = lib.licenses.unfree;
    mainProgram = "kimi";
    platforms = builtins.attrNames sources;
  };
}
