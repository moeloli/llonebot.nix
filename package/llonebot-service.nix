# This configuration file is derived from someone else's work. Thanks to the original author for their contribution.
# Original Author: Anillc
# Link: https://github.com/Anillc/chronocat.nix/blob/master/modules/chronocat.nix

{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config;
  pmhq = pkgs.callPackage ./pmhq.nix { inherit pkgs lib; };
  llonebot-js = pkgs.callPackage ./llonebot-js.nix { inherit pkgs lib; };
  fonts = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [ source-han-sans ];
  };
  # 基础环境设置脚本
  setupEnvironment = ''
    export PATH=${
      lib.makeBinPath (
        with pkgs;
        [
          nodejs
          busybox
          xorg.xorgserver
          x11vnc
          dbus
          dunst
        ]
      )
    }
    export FFMPEG_PATH=${pkgs.ffmpeg}/bin/ffmpeg
    export HOME=/root
    export XDG_DATA_HOME=/root/.local/share
    export XDG_CONFIG_HOME=/root/.config
    export TERM=xterm
    export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/dbus/system_bus_socket'
    export DISPLAY='${toString cfg.display}'
    export LIBGL_ALWAYS_SOFTWARE=1

    # 从环境变量设置 VNC 密码
    : ''${VNC_PASSWD:="${toString cfg.vncpassword}"}
    export ENV_VNC_PASSWD=$VNC_PASSWD
  '';

  # 创建必要的目录和文件
  setupDirectories = ''
    mkdir -p /root/{.local/share,.config} /etc/{ssl/certs,fonts,dbus} /run/dbus
    mkdir -p /tmp /usr/bin /bin

    # 基础系统文件
    echo "root:x:0:0::/root:${pkgs.runtimeShell}" > /etc/passwd
    echo "root:x:0:" > /etc/group
    echo "nameserver 114.114.114.114" > /etc/resolv.conf

    # 符号链接
    ln -s ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt
    ln -s ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
    ln -s ${fonts} /etc/fonts/fonts.conf
    ln -s $(which env) /usr/bin/env
    ln -s $(which sh) /bin/sh

    # llonebot 工作目录
    mkdir -p /root/llonebot
    cp -rf ${llonebot-js}/js/* /root/llonebot/
  '';

  # 配置 DBUS
  setupDbus = ''
    cp ${pkgs.dbus}/share/dbus-1/system.conf /etc/dbus/system.conf
    sed -i 's/<user>messagebus<\/user>/<user>root<\/user>/' /etc/dbus/system.conf
    sed -i 's/<deny/<allow/' /etc/dbus/system.conf
    rm -rf /run/dbus/pid
  '';

  # 创建服务函数
  servicesScript = ''
    createService() {
      mkdir -p /services/$1
      echo -e "#!${pkgs.runtimeShell}\n$2" > /services/$1/run
      chmod +x /services/$1/run
    }

    # 创建各个服务
    createService xvfb 'Xvfb ${toString cfg.display}'
    createService x11vnc 'x11vnc ${
      lib.concatStringsSep " " [
        "-forever"
        "-display ${toString cfg.display}"
        "-rfbport ${toString cfg.vncport}"
        "-passwd \"$ENV_VNC_PASSWD\""
        "-shared"
      ]
    }'
    createService novnc '${pkgs.novnc}/bin/novnc --listen ${toString cfg.novncport} --vnc 127.0.0.1:${toString cfg.vncport}'
    createService dbus 'dbus-daemon --nofork --config-file=/etc/dbus/system.conf'
    # 通知守护进程
    createService dunst 'dunst'
    createService pmhq "${pmhq}/bin/pmhq"
    createService llonebot "cd /root/llonebot && node llonebot.js --pmhq-host=127.0.0.1 --pmhq-port=13000"
  '';

in
{
  service = pkgs.writeScriptBin "llonebot-service" ''
    #!${pkgs.runtimeShell}

    ${setupEnvironment}
    ${setupDirectories}
    ${setupDbus}
    ${servicesScript}

    # 启动所有服务
    runsvdir /services
  '';
}
