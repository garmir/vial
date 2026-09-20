# vial

nix flake for [vial](https://get.vial.today), the keyboard configurator.

the gui is built from source out of [garmir/vial-gui](https://github.com/garmir/vial-gui),
branch `encoder-matrix-tester`, which makes encoder rotation show on the
matrix tester. that change is proposed upstream in
[vial-kb/vial-gui#400](https://github.com/vial-kb/vial-gui/pull/400) with the
firmware side in
[vial-kb/vial-qmk#1042](https://github.com/vial-kb/vial-qmk/pull/1042).
the flake also ships the udev rule the app needs to talk to the keyboard.

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

## how it is built

upstream runs vial under the fbs runtime, which nix does not package.
`fbs-runtime/` is a small stand in that only provides what vial uses:
build settings, resource paths and the qt application.

x86_64-linux only.
