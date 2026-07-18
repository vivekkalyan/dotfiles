{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  stdenv,
}:

let
  version = "0.27.0";
  sources = {
    aarch64-darwin = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-darwin-arm64";
      sha256 = "550bca0ba6e474f4e0faeadfae03a9294c7c25688670f38ff488ab8cf176d817";
    };
    x86_64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-x64";
      sha256 = "eecbab45bc1b992b648c46387a0972c340fac7d8b2549616f1eacec90e595a31";
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
