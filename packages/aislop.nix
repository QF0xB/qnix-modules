{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aislop";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "scanaislop";
    repo = "aislop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-41op9Np4pXAMzb92MoOc/g5vNEHfgeTqcmp5dTziwyQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-9O8OP62jZSU3FlRVzjB/bai6CNos9GxXr02agRQ65h8=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm_10
    pnpmConfigHook
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm prune --prod --ignore-scripts
    mkdir -p $out/lib/aislop $out/bin
    cp -r dist node_modules package.json $out/lib/aislop/

    # Agent hooks run aislop on every edit, so keep it quiet and offline by
    # default. Both variables can still be overridden by the caller.
    for entry in aislop:cli aislop-mcp:mcp; do
      makeWrapper ${lib.getExe nodejs} $out/bin/''${entry%%:*} \
        --add-flags $out/lib/aislop/dist/''${entry#*:}.js \
        --set-default AISLOP_NO_TELEMETRY 1 \
        --set-default AISLOP_NO_UPDATE_NOTIFIER 1
    done

    runHook postInstall
  '';

  meta = {
    description = "Deterministic scanner for the code patterns AI coding agents leave behind";
    homepage = "https://github.com/scanaislop/aislop";
    license = lib.licenses.mit;
    mainProgram = "aislop";
  };
})
