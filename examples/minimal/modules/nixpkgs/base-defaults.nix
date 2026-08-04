# Shared nixpkgs defaults applied to every NixOS machine
#
# Contributes to flake.modules.nixos.base, which every machine
# imports via the `base` flakeModule in its
# modules/machines/<class>/<host>/default.nix.
{ inputs, ... }:
let
  defaults = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
in
{
  flake.modules.nixos.base = defaults;
}
