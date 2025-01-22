{ pkgs }:

import (pkgs.path + "/nixos/lib/make-disk-image.nix") {
  config = (import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit (pkgs) system;
    modules = [{
      imports = [ ./configuration.nix ];
    }];
  }).config;
  inherit pkgs;
  inherit (pkgs) lib;
  diskSize = 4096;
  copyChannel = false;
  partitionTableType = "none";
}
