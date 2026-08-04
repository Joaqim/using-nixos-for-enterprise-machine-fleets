{ config, inputs, ... }: {
  flake.nixosConfigurations = {
    workstation = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        config.flake.modules.nixos."machines/nixos/workstation"
      ];
    };
  };
}
