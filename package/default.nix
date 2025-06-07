{
  config,
  pkgs,
  lib,
  stdenv,
  ...
}:
let
  env = import ./env.nix { inherit pkgs lib config; };
in
{
  inherit (env) script;
}
