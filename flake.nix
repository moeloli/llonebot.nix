{
  description = "llonebot.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      
      # 默认配置
      defaultConfig = {
        vncport = 7081;
        vncpassword = "vncpassword";
      };

      # 跨系统构建函数
      buildForTarget = targetSystem: let
        pkgsCross = import nixpkgs {
          system = "x86_64-linux";  # 构建主机系统
          crossSystem.system = targetSystem;  # 目标系统（aarch64-linux）
        };
      in rec {
        llonebot = pkgsCross.callPackage ./package { config = defaultConfig; };
        
        dockerImage = pkgsCross.dockerTools.buildImage {
          name = "llonebot";
          tag = "latest";
          copyToRoot = pkgsCross.buildEnv {
            name = "llonebot-env";
            paths = [ llonebot.script pkgsCross.coreutils pkgsCross.bash ];
          };
          config = {
            Cmd = [ "/bin/LLOneBot" ];  # 根据实际路径调整
            ExposedPorts = { "${toString defaultConfig.vncport}/tcp" = {}; };
          };
        };
      };

    in rec {
      devShells.default = pkgs.mkShell {};

      lib.buildLLOneBot = config: pkgs.callPackage ./package { inherit config; };

      packages.default = (lib.buildLLOneBot defaultConfig).script;

      packages.dockerImage = (buildForTarget system).dockerImage;

      packages.dockerImageAarch64 = (buildForTarget "aarch64-linux").dockerImage;
    });
}