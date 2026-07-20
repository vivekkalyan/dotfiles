{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
  python3,
  removeReferencesTo,
  srcOnly,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "obsidian-headless";
  version = "0.0.13";

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    tag = finalAttrs.version;
    hash = "sha256-gPFIGxB4jf2+JbgUpIf6ENiYKp2bmHKKRKrb2sXSDHY=";
  };

  # The 0.0.13 tag updated package.json without refreshing pnpm-lock.yaml.
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"better-sqlite3": "12.11.1"' '"better-sqlite3": "12.6.2"'
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-9XbLTX0ZM7GzRkNQ0IIKjuU7dIzzz3WvqfbBOFdIdmY=";
    inherit (finalAttrs) postPatch;
  };

  nativeBuildInputs = [
    nodejs_24
    pnpm_10
    pnpmConfigHook
    python3
  ];

  buildPhase = ''
    runHook preBuild

    pushd node_modules/better-sqlite3
    npm run build-release --offline --nodedir="${srcOnly nodejs_24}"
    find build -type f -exec \
      ${lib.getExe removeReferencesTo} -t "${srcOnly nodejs_24}" {} \;
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/lib/node_modules/obsidian-headless" "$out/bin"
    cp -r cli.js package.json node_modules \
      "$out/lib/node_modules/obsidian-headless/"
    ln -s "$out/lib/node_modules/obsidian-headless/cli.js" "$out/bin/ob"
    chmod +x "$out/lib/node_modules/obsidian-headless/cli.js"
    patchShebangs "$out/lib/node_modules/obsidian-headless/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Headless client for Obsidian Sync and Obsidian Publish";
    homepage = "https://github.com/obsidianmd/obsidian-headless";
    license = lib.licenses.unfree;
    mainProgram = "ob";
    platforms = lib.platforms.linux;
  };
})
