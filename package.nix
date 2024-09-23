{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook,
  fd,
  patchelfUnstable,
  # deps
  alsa-lib,
  atk,
  cairo,
  cups,
  dbus,
  ffmpeg,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libevent,
  libffi,
  libglvnd,
  libjpeg,
  libnotify,
  libpng,
  libstartup_notification,
  libva,
  libvpx,
  libwebp,
  libxkbcommon,
  libxml2,
  mesa,
  pango,
  pciutils,
  pulseaudio,
  pipewire,
  stdenv,
  udev,
  xcb-util-cursor,
  xorg,
  zlib,
  # package-related
  sourceInfo,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zen-browser-${sourceInfo.variant}";
  inherit (sourceInfo) version;

  src = fetchurl sourceInfo.src;

  nativeBuildInputs = [
    fd
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook
    patchelfUnstable
  ];

  buildInputs = [
    alsa-lib
  ];

  # Used by autoPatchelfHook
  runtimeDependencies = lib.concatLists [
    [
      atk
      cairo
      cups
      dbus
      ffmpeg
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libevent
      libffi
      libglvnd
      libjpeg
      libnotify
      libpng
      libstartup_notification
      libva.out
      libvpx
      libwebp
      libxkbcommon
      libxml2
      mesa
      pango
      pciutils
      pulseaudio
      pipewire
      stdenv.cc.cc
      udev
      xcb-util-cursor
      zlib
    ]
    (with xorg; [
      libxcb
      libX11
      libXcursor
      libXrandr
      libXi
      libXext
      libXcomposite
      libXdamage
      libXfixes
      libXScrnSaver
    ])
  ];

  appendRunpaths = [
    "${pipewire}/lib"
  ];

  # Firefox uses "relrhack" to manually process relocations from a fixed offset
  patchelfFlags = ["--no-clobber-old-sections"];

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

  postFixup = ''
    # For some reason autoPatchelfHook can't take care of all the deps
    wrapProgram $out/bin/zen \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath finalAttrs.runtimeDependencies}"
  '';

  meta = {
    homepage = "https://zen-browser.app";
    description = "Beautiful, fast, private browser";
    license = lib.licenses.mpl20;
    mainProgram = "zen";
    platforms = ["x86_64-linux"];
  };
})
