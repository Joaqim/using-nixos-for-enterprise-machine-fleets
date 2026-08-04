{ ... }:
{
  flake.modules.nixos.hello =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.hello;
    in
    {
      options.hello = {
        enable = lib.mkEnableOption "hello";
        package = lib.mkPackageOption pkgs "hello" { };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          cfg.package
        ];
      };
    };
}
