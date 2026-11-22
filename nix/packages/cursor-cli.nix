{
  cursor-cli,
  fetchurl,
  stdenv,
}:

let
  # Use a newer Cursor release than the flake's nixpkgs pin while retaining its packaging.
  version = "2026.11.22-e9042b2";
  sources = {
    aarch64-darwin = {
      platform = "darwin/arm64";
      sha256 = "92f39e448218897538bd801cdb01d69106ab37a86aaf3dc0e6b55159c79b75e2";
    };
    x86_64-linux = {
      platform = "linux/x64";
      sha256 = "7663b1c5d1b56e095ef8e23bef38d66df6cfd665c4873470214e0e411f0f97b3";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
cursor-cli.overrideAttrs (old: {
  inherit version;

  src = fetchurl {
    url = "https://downloads.cursor.com/lab/${version}/${source.platform}/agent-cli-package.tar.gz";
    inherit (source) sha256;
  };

  # Preserve Cursor's embedded Node.js applications.
  dontStrip = true;

  postInstall = (old.postInstall or "") + ''
    ln -s "$out/share/cursor-agent/cursor-agent" "$out/bin/agent"
  '';

  meta = old.meta // {
    platforms = builtins.attrNames sources;
  };
})
