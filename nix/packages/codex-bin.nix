{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  bubblewrap,
  ripgrep,
}:

let
  version = "0.152.0";
  sources = {
    aarch64-darwin = {
      codex = {
        url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
        hash = "sha256-XJrkBsb3PDXpITCMf1o/rHBSisGtXDUj56tDKiI4r8E=";
      };
      codeModeHost = {
        url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-aarch64-apple-darwin.tar.gz";
        hash = "sha256-PRG9THC4Ip7E1woxFJADxBmxhgOzJW4P3V2uFmfgp9w=";
      };
    };
    x86_64-linux = {
      codex = {
        url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-BflC09PFtazZ7a1WzieXtv5y27FGKyTlyb99zsmiihE=";
      };
      codeModeHost = {
        url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-RJzv41ufNH4/2/Eh6BYzmzeCXrC/7n3oKYoKYbZofLo=";
      };
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported Codex binary platform: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "codex";
  inherit version;

  src = fetchurl source.codex;
  codeModeHostSrc = fetchurl source.codeModeHost;
  sourceRoot = ".";
  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 codex-* "$out/bin/codex"
    mkdir code-mode-host
    tar -xzf "$codeModeHostSrc" -C code-mode-host
    install -Dm755 code-mode-host/codex-code-mode-host-* "$out/bin/codex-code-mode-host"
    wrapProgram "$out/bin/codex" --prefix PATH : ${
      lib.makeBinPath ([ ripgrep ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ bubblewrap ])
    }

    runHook postInstall
  '';

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://raw.githubusercontent.com/openai/codex/refs/tags/rust-v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = builtins.attrNames sources;
  };
}
