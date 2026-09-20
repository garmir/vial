{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  libsForQt5,
  makeDesktopItem,
  copyDesktopItems,
}:

let
  # the gui is built from a fork that adds encoder rotation to the matrix
  # tester, see https://github.com/vial-kb/vial-gui/pull/400
  rev = "231c22f7e596a212bc89e1d0eed202c8f87e8f0d";

  python = python3.withPackages (
    ps: with ps; [
      pyqt5
      hidapi
      keyboard
      simpleeval
      certifi
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vial";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "garmir";
    repo = "vial-gui";
    inherit rev;
    hash = "sha256-PqydB56pmZYsj63++Tzca4boVLzfRrtE0Lg/TYkj+C4=";
  };

  nativeBuildInputs = [
    libsForQt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtwayland
  ];

  # the launcher is a shell script, which the qt hook does not wrap on its own
  dontWrapQtApps = true;
  preFixup = "wrapQtApp $out/bin/vial";

  desktopItems = [
    (makeDesktopItem {
      name = "vial";
      exec = "vial";
      icon = "vial";
      desktopName = "Vial";
      comment = "Keyboard configurator";
      categories = [ "Utility" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    share=$out/share/vial
    mkdir -p $share $out/bin
    cp -r src/main/python/. $share
    cp -r src/main/resources/base $share/resources
    cp src/build/settings/base.json $share/build_settings.json
    # upstream runs under the fbs runtime, which nix does not have
    cp -r ${./fbs-runtime}/fbs_runtime $share/fbs_runtime

    cat > $out/bin/vial <<SCRIPT
    #!${stdenv.shell}
    export VIAL_SHARE_DIR=$share
    exec ${python}/bin/python3 $share/main.py "\$@"
    SCRIPT
    chmod +x $out/bin/vial

    for icon in src/main/icons/base/*.png src/main/icons/linux/*.png; do
      size=$(basename "$icon" .png)
      install -Dm644 "$icon" $out/share/icons/hicolor/''${size}x''${size}/apps/vial.png
    done

    # hidraw access for the logged in user. on nixos enable it with
    # services.udev.packages = [ vial ];
    # the file must sort before systemd's 73-seat-late.rules, which is
    # where the uaccess tag turns into an acl.
    mkdir -p $out/lib/udev/rules.d
    echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", TAG+="uaccess"' > $out/lib/udev/rules.d/70-vial.rules

    runHook postInstall
  '';

  meta = {
    description = "Keyboard configurator for vial enabled keyboards";
    homepage = "https://get.vial.today";
    license = lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "vial";
  };
})
