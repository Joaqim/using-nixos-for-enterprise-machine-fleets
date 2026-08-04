# Overlay composition using list concatenation
#
# This module composes all overlays from the auto-discovered flake.nixpkgsOverlays list
# into a single flake.overlays.default for use in machine configurations.
#
# Architecture:
# - overlays/*.nix each append to flake.nixpkgsOverlays list (NixOS module system feature)
#
# Machine configs reference: nixpkgs.overlays = [ inputs.self.overlays.default ];
#
{
  config,
  lib,
  ...
}:
{
  # Compose all overlays into flake.overlays.default
  flake.overlays.default = lib.composeManyExtensions config.flake.nixpkgsOverlays;
}
