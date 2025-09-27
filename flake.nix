{
  description = "llonebot.nix";
  # libstdc++.so.6: version `GLIBCXX_3.4.32' not found
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # 直接定义默认包
        defaultConfig = {
          vncport = 7081;
          vncpassword = "vncpassword";
          display = ":666";
          novncport = 5900;
          pmhq_host = "0.0.0.0";
          pmhq_port = 13000;
          headless = true;
          quick_login_qq = ""; # 快速登录QQ号
        };

      in
      rec {
        devShells.default = pkgs.mkShell { };

        lib.buildLLOneBot = config: pkgs.callPackage ./package/default.nix { inherit config; };

        lib.buildLLOneBotSandbox = config: pkgs.callPackage ./package/sandbox.nix { inherit config; };

        llonebot-service =
          (pkgs.callPackage ./package/llonebot-service.nix {
            config = defaultConfig;
          }).service;

        packages = rec {
          pmhq = pkgs.callPackage ./package/pmhq.nix {
            config = {
              host = defaultConfig.pmhq_host;
              port = defaultConfig.pmhq_port;
              quick_login_qq = defaultConfig.quick_login_qq;
              headless = defaultConfig.headless;
            };
          };

          default = (lib.buildLLOneBot defaultConfig).llonebot;

          sandbox =
            (pkgs.callPackage ./package/sandbox.nix {
              config = defaultConfig;
            }).sandbox;

          # 添加 Docker 镜像构建
          dockerImage = pkgs.dockerTools.buildImage {
            name = "llonebot";
            tag = "latest";
            copyToRoot = pkgs.buildEnv {
              name = "llonebot-env";
              paths = [
                llonebot-service
                pkgs.coreutils
                pkgs.bash
              ];
            };
            config = {
              Cmd = [ "/bin/llonebot-service" ]; # 根据实际可执行文件路径调整
              Env = [
                "TZDIR=${pkgs.tzdata}/share/zoneinfo"
                "TZ=Asia/Shanghai"
              ];
              Expose = [
                "3000"
                "3001"
                "5900"
                "5600"
                "3080"
                "13000"
              ]; # 曝露端口
            };
          };
        };
      }
    );
}
