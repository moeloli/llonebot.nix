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
  pmhq = pkgs.callPackage ./pmhq.nix {
    inherit pkgs lib config;
  };
  llonebot-js = pkgs.callPackage ./llonebot-js.nix { inherit pkgs lib; };
  fonts = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [ source-han-sans ];
  };
  nixpkgs24_05 = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz";
    sha256 = "sha256:0zydsqiaz8qi4zd63zsb2gij2p614cgkcaisnk11wjy3nmiq0x1s";
  }) { system = pkgs.system; };
  # 基础环境设置脚本
  setupEnvironment = ''
    export PATH=${
      lib.makeBinPath (
        with pkgs;
        [
          nixpkgs24_05.nodejs_22
          busybox
          xorg.xorgserver
          dbus
          dunst
          ffmpeg
          jq
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

    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export SSL_CERT_DIR=/etc/ssl/certs
    export REQUESTS_CA_BUNDLE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export CURL_CA_BUNDLE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

    : ''${QUICK_LOGIN_QQ:="${toString cfg.quick_login_qq}"}
    export ENV_QUICK_LOGIN_QQ=$QUICK_LOGIN_QQ
  '';

  # 创建必要的目录和文件
  setupDirectories = ''
    mkdir -p /root/{.local/share,.config} /etc/{ssl/certs,fonts,dbus} /run/dbus
    mkdir -p /tmp /usr/bin /bin

    # 基础系统文件
    echo "root:x:0:0::/root:${pkgs.runtimeShell}" > /etc/passwd
    echo "root:x:0:" > /etc/group
    echo "nameserver 114.114.114.114" > /etc/resolv.conf
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "172.17.0.1 host.docker.internal" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts

    # SSL证书目录设置
    mkdir -p /etc/ssl/certs /etc/pki/tls/certs
    # 符号链接
    ln -sf ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt
    ln -sf ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
    ln -sf ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt
    # 为Python设置默认证书位置
    ln -sf ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/cert.pem
    ln -s ${fonts} /etc/fonts/fonts.conf
    ln -s $(which env) /usr/bin/env
    ln -s $(which sh) /bin/sh

    # llonebot 工作目录
    mkdir -p /root/llonebot
    cp -rf ${llonebot-js}/js/* /root/llonebot/
    sed -i "s|\"ffmpeg\":\s*\"\"|\"ffmpeg\": \"${pkgs.ffmpeg}/bin/ffmpeg\"|g" "/root/llonebot/default_config.json"
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

    export WLR_BACKENDS=headless
    export WLR_LIBINPUT_NO_DEVICES=1
    export XDG_RUNTIME_DIR=/tmp/runtime
    export NIXOS_OZONE_WL=1
    
    mkdir -p $XDG_RUNTIME_DIR
    chmod 700 $XDG_RUNTIME_DIR
    
    rm -rf /tmp/.X11-unix
    mkdir -p /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix
    
    createService cage "${pkgs.cage}/bin/cage -d -s -- ${pmhq}/bin/pmhq --qq-path=\"\$(jq -r '.qq_path' ${pmhq}/bin/config.json)\" --headless --qq=\$ENV_QUICK_LOGIN_QQ"

    createService llonebot "cd /root/llonebot && node --enable-source-maps llbot.js --pmhq-host=${cfg.pmhq_host} --pmhq-port=${toString cfg.pmhq_port}"
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
