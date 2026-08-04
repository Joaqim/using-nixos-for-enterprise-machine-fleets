{ config, inputs, ... }:
let
  flakeModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos."machines/nixos/workstation" =
    {
      lib,
      ...
    }:
    {
      imports = with flakeModules; [
        base
        hello
      ];

      # Optionally, make flake available to all modules,
      _module.args.flake = inputs.self;

      # System platform
      nixpkgs.hostPlatform = "x86_64-linux";

      # Minimally required for successful build - don't use
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
      };

      # Bootloader
      boot.loader.systemd-boot.enable = true;

      system.stateVersion = "26.11";
    };
}
