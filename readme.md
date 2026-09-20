# vial

nix flake for [vial](https://get.vial.today), the keyboard configurator.

upstream ships the gui as an appimage. this flake wraps it for nix and
ships the udev rule the app needs to talk to the keyboard.

## use

add the input

    inputs.vial.url = "github:garmir/vial";

install the package and its udev rule

    environment.systemPackages = [ inputs.vial.packages.${pkgs.system}.default ];
    services.udev.packages = [ inputs.vial.packages.${pkgs.system}.default ];

or use the overlay

    nixpkgs.overlays = [ inputs.vial.overlays.default ];
    environment.systemPackages = [ pkgs.vial ];
    services.udev.packages = [ pkgs.vial ];

the udev rule gives the logged in user access to hidraw devices. without
it the app cannot see the keyboard.

## run without installing

    nix run github:garmir/vial

x86_64-linux only.
