{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  asar,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gtk3,
  libGL,
  libgbm,
  libdrm,
  libnotify,
  libpulseaudio,
  libusb1,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  xorg,
  xdg-utils,
}:

stdenv.mkDerivation {
  pname = "chatgpt";
  version = "26.901.41600";

  # Official Linux preview. The hash pins the download even if latest changes.
  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    hash = "sha256-Fc9CKnfo8op1U9MYC4xyeEqZRDihQXhMgtcs3pPvync=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
    asar
  ];
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gtk3
    libGL
    libgbm
    libdrm
    libnotify
    libpulseaudio
    libusb1
    libxkbcommon
    nspr
    nss
    pango
    systemd
    stdenv.cc.cc
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];
  runtimeDependencies = [
    libGL
    libnotify
    libpulseaudio
    systemd
  ];

  unpackPhase = ''
    dpkg-deb --fsys-tarfile "$src" | tar -x
  '';
  dontBuild = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -a usr/lib usr/share "$out/"
    # detect-libc's diagnostic-report fallback trips a CFI trap in this
    # Electron build's call to gnu_get_libc_version. The libc is known here.
    asar extract "$out/lib/chatgpt/resources/app.asar" app-unpacked
    substituteInPlace app-unpacked/node_modules/@parcel/watcher/node_modules/detect-libc/lib/process.js \
      --replace-fail 'process.report.getReport()' \
      '({ header: { glibcVersionRuntime: "${lib.getVersion stdenv.cc.libc}" } })'
    asar pack app-unpacked "$out/lib/chatgpt/resources/app.asar" --unpack-dir node_modules
    # Optional Chromium Qt integrations; GTK is used on this system.
    rm "$out/lib/chatgpt/libqt5_shim.so" "$out/lib/chatgpt/libqt6_shim.so"
    # NixOS uses glibc; retain the matching prebuilds and remove musl variants.
    find "$out/lib/chatgpt/resources" -type f -path '*musl*' -name '*.node' -delete
    mkdir -p "$out/bin"
    makeWrapper "$out/lib/chatgpt/ChatGPT" "$out/bin/chatgpt" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail 'Exec=chatgpt' "Exec=$out/bin/chatgpt"
    runHook postInstall
  '';

  meta = {
    description = "Official ChatGPT desktop app (Linux preview)";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
}
