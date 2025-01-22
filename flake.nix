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
        packages = {
          nixos-image = pkgs.callPackage ./nixos-image.nix { };
        };
        devShells.default = pkgs.linuxPackages.kernel.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
            pkgs.bashInteractive
            pkgs.mkuimage
            pkgs.just
            pkgs.u-root
            pkgs.qemu_kvm
            (pkgs.runCommand "busybox" {} ''
              mkdir -p $out/bin
              ln -s ${pkgs.busybox}/bin/busybox $out/bin/busybox
            '')
          ];
        });
      };
    });
}
