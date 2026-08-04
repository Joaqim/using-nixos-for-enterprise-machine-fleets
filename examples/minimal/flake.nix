{
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    # NixOS nixpkgs
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz";
    systems.url = "github:nix-systems/default/future-26.11";

    # import-tree
    import-tree.url = "github:vic/import-tree";
  };
}
