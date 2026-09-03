{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
  bubblewrap,
  ripgrep,
  versionCheckHook,
  zstd,
  installShellCompletions ? stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform,
  manifest ? lib.importJSON ./manifest.json,
}:
let
  platform = manifest.platforms.${stdenvNoCC.hostPlatform.system};
  baseUrl = "https://github.com/openai/codex/releases/download/rust-v${manifest.version}";

  codex = fetchurl {
    url = "${baseUrl}/codex-${platform.target}.zst";
    sha256 = platform.codexChecksum;
  };

  codeModeHost = fetchurl {
    url = "${baseUrl}/codex-code-mode-host-${platform.target}.zst";
    sha256 = platform.codeModeHostChecksum;
  };
in
stdenvNoCC.mkDerivation {
  pname = "codex";
  inherit (manifest) version;

  dontUnpack = true;
  dontBuild = true;
  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    zstd
  ]
  ++ lib.optionals installShellCompletions [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    unzstd -q ${codex} -o $out/bin/codex
    unzstd -q ${codeModeHost} -o $out/bin/codex-code-mode-host
    chmod 755 $out/bin/codex $out/bin/codex-code-mode-host

    ${lib.optionalString installShellCompletions ''
      installShellCompletion --cmd codex \
        --bash <($out/bin/codex completion bash) \
        --fish <($out/bin/codex completion fish) \
        --zsh <($out/bin/codex completion zsh)
    ''}

    wrapProgram $out/bin/codex \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]} \
      ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
      ''}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://github.com/openai/codex/releases/tag/rust-v${manifest.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "codex";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
