{
  description = "llonebot.nix";
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
        };

      in
      rec {
        devShells.default = pkgs.mkShell { };

        lib.buildLLOneBot = config: pkgs.callPackage ./package/default.nix { inherit config; };

        llonebot-service =
          (pkgs.callPackage ./package/llonebot-service.nix {
            config = defaultConfig;
          }).service;

        packages = rec {
          pmhq = pkgs.callPackage ./package/pmhq.nix {
            config = {
              host = defaultConfig.pmhq_host;
              port = defaultConfig.pmhq_port;
            };
          };

          default = (lib.buildLLOneBot defaultConfig).llonebot;

          sandbox =
            (pkgs.callPackage ./package/sandbox.nix {
              config = defaultConfig;
              inherit llonebot-service;
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
              Expose = [
                "3000"
                "3001"
                "5900"
                "5600"
                "7081"
                "13000"
              ]; # 曝露端口
            };
          };
        };
      }
    );
}
