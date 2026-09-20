{
  description = "vial, the keyboard configurator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        vial = pkgs.callPackage ./package.nix { };
        default = self.packages.${system}.vial;
      };

      overlays.default = final: prev: {
        vial = final.callPackage ./package.nix { };
      };

      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system}.vial = self.packages.${system}.vial;
    };
}
