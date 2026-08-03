{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        myTypst = pkgs.typst.withPackages (
          ps: with ps; [
            conch
            gentle-clues
            glossy
            charged-ieee
            ilm
            zebraw
            tdtr
            tidymind
            cetz_0_3_4
            oxifmt
          ]
        );
      in
      {
        devShells.default = pkgs.mkShell {
          env = {
            TYPST_FONT_PATHS = pkgs.lib.concatStringsSep ";" [
              "${pkgs.inter}/share/fonts"
              "${pkgs.iosevka}/share/fonts"
            ];
          };
          packages = with pkgs; [
            myTypst

            # Font
            inter

            # Typos checker
            typos
          ];
        };
      }
    );
}
