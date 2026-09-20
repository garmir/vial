{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "vial";
  version = "0.7.5";

  # upstream builds the gui with pyinstaller and ships it as an appimage
  src = fetchurl {
    url = "https://github.com/vial-kb/vial-gui/releases/download/v${version}/Vial-v${version}-x86_64.AppImage";
    hash = "sha256-sN8i/MOPhaLZ4iJNKz/MdpRIGTZVV/G5qD7o+ID8dAM=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/Vial.desktop $out/share/applications/vial.desktop
    substituteInPlace $out/share/applications/vial.desktop \
      --replace-fail 'Exec=Vial' 'Exec=vial %U' \
      --replace-fail 'Icon=Vial' 'Icon=vial'
    sed -i '/^X-AppImage-Version/d' $out/share/applications/vial.desktop

    for icon in ${contents}/usr/share/icons/hicolor/*/apps/Vial.png; do
      size=$(basename "$(dirname "$(dirname "$icon")")")
      install -Dm644 "$icon" $out/share/icons/hicolor/$size/apps/vial.png
    done

    # hidraw access for the logged in user. on nixos enable it with
    # services.udev.packages = [ vial ];
    # the file must sort before systemd's 73-seat-late.rules, which is
    # where the uaccess tag turns into an acl.
    mkdir -p $out/lib/udev/rules.d
    echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", TAG+="uaccess"' > $out/lib/udev/rules.d/70-vial.rules
  '';

  meta = {
    description = "Keyboard configurator for vial enabled keyboards";
    homepage = "https://get.vial.today";
    license = lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "vial";
  };
}
