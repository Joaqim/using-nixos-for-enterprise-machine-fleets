# Overlay composition using list concatenation
#
# This module composes all overlays from the auto-discovered flake.nixpkgsOverlays list
# into a single flake.overlays.default for use in machine configurations.
#
# Architecture:
# - overlays/*.nix each append to flake.nixpkgsOverlays list (NixOS module system feature)
# - This module composes that list with lib.composeManyExtensions
# - External overlays and custom packages merged in composition order
#
# Machine configs reference: nixpkgs.overlays = [ inputs.self.overlays.default ];
{
  config,
  lib,
  withSystem,
  ...
}:
{
  # Compose all overlays into flake.overlays.default
  flake.overlays.default =
    final: prev:
    let
      # Internal overlays auto-collected via list concatenation
      # overlays/*.nix modules append to this list automatically
      internalOverlays = lib.composeManyExtensions config.flake.nixpkgsOverlays;

      # Custom packages from pkgs-by-name
      # Provides: Project-specific packages
      # Use withSystem to access perSystem packages for the target system
      customPackages = withSystem prev.stdenv.hostPlatform.system (
        { config, ... }: config.packages or { }
      );
    in
    # Compose all (order matters!)
    # 1. Custom packages from pkgs-by-name are merged into `prev` before
    #    internal overlays compose, so overlays can `prev.<pkg>.override`
    #    pkgs-by-name derivations.
    # 2. Internal overlays (channels, stable-fallbacks, overrides,
    #    nvim-treesitter, nuenv, ...) run with the augmented
    #    prev, and their output is merged on top of customPackages so
    #    overrides win on key collisions.
    customPackages // (internalOverlays final (prev // customPackages));
}
