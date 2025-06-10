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
        };

      in
      rec {
        devShells.default = pkgs.mkShell { };

        lib.buildLLOneBot = config: pkgs.callPackage ./package { inherit config; };

        packages = {
          llonebot = pkgs.callPackage ./package/llonebot.nix { };
          qq = pkgs.callPackage ./package/qq/package.nix {
            libgbm = pkgs.mesa.drivers; # 显式传递 libgbm
            inherit (pkgs)
              alsa-lib
              libuuid
              cups
              dpkg
              fetchurl
              glib
              libssh2
              gtk3
              libayatana-appindicator
              libdrm
              libgcrypt
              libkrb5
              libnotify
              libpulseaudio
              libGL
              nss
              xorg
              systemd
              vips
              at-spi2-core
              autoPatchelfHook
              makeShellWrapper
              wrapGAppsHook3
              ;
            commandLineArgs = ""; # 可选参数
          };
          pmhq = pkgs.callPackage ./package/pmhq.nix { };
          # 默认包使用默认配置
          default = pkgs.writeScriptBin "bwrap-env" ''
            #!${pkgs.runtimeShell}
            mkdir -p /tmp ./data
            if [ -z "$VNC_PASSWD" ]; then
              VNC_PASSWD=${defaultConfig.vncpassword}
            fi
            ${pkgs.bubblewrap}/bin/bwrap \
              --unshare-all \
              --share-net \
              --as-pid-1 \
              --uid 0 --gid 0 \
              --setenv VNC_PASSWD $VNC_PASSWD \
              --ro-bind /nix/store /nix/store \
              --ro-bind ${pkgs.tzdata}/share/zoneinfo/Asia/Shanghai /etc/localtime \
              --bind ./data /root/ \
              --proc /proc \
              --dev /dev \
              --tmpfs /tmp \
              ${(lib.buildLLOneBot defaultConfig).script}/bin/llonebot-env
          '';

          # 添加 Docker 镜像构建
          dockerImage = pkgs.dockerTools.buildImage {
            name = "llonebot";
            tag = "latest";
            copyToRoot = pkgs.buildEnv {
              name = "llonebot-env";
              paths = [
                (lib.buildLLOneBot defaultConfig).script
                pkgs.coreutils
                pkgs.bash
              ];
            };
            config = {
              Cmd = [ "/bin/llonebot-env" ]; # 根据实际可执行文件路径调整
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
