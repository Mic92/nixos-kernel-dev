{
  description = "Development environment for this project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;
      perSystem = { pkgs, ... }: {
        # TODO
        #packages = {
        #  nixos-image = pkgs.callPackage ./nix/nixos-image.nix { };
        #};
        devShells.default = pkgs.linuxPackages.kernel.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
            pkgs.bashInteractive
            pkgs.mkuimage
            pkgs.just
            pkgs.u-root
            pkgs.qemu_kvm
          ];
        });
      };
    });
}
