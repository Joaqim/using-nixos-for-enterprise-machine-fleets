{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules # Enable flake.modules merging
  ];
}
