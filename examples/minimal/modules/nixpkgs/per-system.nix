# perSystem nixpkgs configuration
#
# configures pkgs for flake-parts perSystem (checks, packages, devShells, etc.)
#
# Use config.flake.nixpkgsOverlays for overlay composition
# overlays/*.nix modules append to this list automatically via import-tree
{
  inputs,
  config,
  lib,
  ...
}:
{
  perSystem =
    { system, ... }:
    let
      # Configure nixpkgs with overlays
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # Overlay composition from flake.nixpkgsOverlays list
        # Auto-populated by overlays/*.nix modules
        overlays = config.flake.nixpkgsOverlays;
      };
    in
    {
      # Provide pkgs to perSystem context
      _module.args.pkgs = pkgs;

      legacyPackages = lib.mkForce pkgs;
    };
}
