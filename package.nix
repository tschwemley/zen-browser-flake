{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook,
  fd,
  # deps
  alsa-lib,
  dbus-glib,
  ffmpeg,
  gtk3,
  libglvnd,
  libva,
  mesa,
  pciutils,
  pipewire,
  pulseaudio,
  xorg,
  # package-related
  sourceInfo,
}:
stdenvNoCC.mkDerivation {
  pname = "zen-browser";
  inherit (sourceInfo) version;

  src = fetchurl {inherit (sourceInfo) hash url;};

  nativeBuildInputs = [
    fd
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    alsa-lib
    dbus-glib
    xorg.libXtst
  ];

  installPhase = ''
    runHook preInstall

    # mimic Firefox's dir structure
    mkdir -p $out/bin
    mkdir -p $out/lib/zen && cp -r * $out/lib/zen

    fd --type x --exclude '*.so' --exec ln -s $out/lib/zen/{} $out/bin/{}

    install -D ${./.}/zen.desktop $out/share/applications/zen.desktop

    # link icons to the appropriate places
    pushd $out/lib/zen/browser/chrome/icons/default
    for icon in *; do
      num=$(sed 's/[^0-9]//g' <<<$icon)
      dir=$out/share/icons/hicolor/"$num"x"$num"/apps

      mkdir -p $dir
      ln -s $PWD/$icon $dir/zen.png
    done
    popd

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
      pciutils
      pipewire
      pulseaudio
      libva
      libglvnd
      mesa
      ffmpeg
    ]}"
    )
    gappsWrapperArgs+=(--set MOZ_LEGACY_PROFILES 1)
    wrapGApp $out/bin/zen
  '';

  meta = {
    homepage = "https://zen-browser.app";
    description = "Beautiful, fast, private browser";
    license = lib.licenses.mpl20;
    mainProgram = "zen";
    platforms = ["x86_64-linux"];
  };
}
