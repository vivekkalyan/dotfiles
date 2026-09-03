{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  stdenv,
}:

let
  version = "0.40.1";
  sources = {
    aarch64-darwin = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-darwin-arm64";
      sha256 = "cdee8d0c3a1a994a7eb30a7ad95e93bf27e0f0ab3d126121518c68f6b2fe05e7";
    };
    x86_64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-x64";
      sha256 = "e1d5003ae182200ecc3c0631aba7e7eaeba1601a0cf690770aa0184b59227bb7";
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
