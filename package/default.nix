{ config, pkgs, lib, ... }: let
  # 导入模块系统
  module = import ./module.nix { inherit config lib; };
  # 导入沙箱配置
  sandbox = import ./sandbox.nix { inherit pkgs lib config; };
in {
  # 导出 llonebot
  inherit (sandbox) llonebot;
} 