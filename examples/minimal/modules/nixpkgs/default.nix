# nixpkgs integration + overlay export
#
# - Integration (this file) imports submodules
# - Configuration (per-system.nix) configures perSystem pkgs
# - Overlays (overlays/*.nix) append to flake.nixpkgsOverlays list
# - Option declaration (overlays-option.nix) enables list concatenation
#
# Machine configs reference: nixpkgs.overlays = [ inputs.self.overlays.default ];
{ ... }:
{
  imports = [
    ./overlays-option.nix
    ./per-system.nix
    ./compose.nix
  ];
}
