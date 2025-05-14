{ config, pkgs, lib, ... }: let
  env = import ./env.nix { inherit pkgs lib config; };
in {
  inherit (env) script;
} 