{
  pkgs,
  lib,
  config,
  ...
}:
rec {
  llonebot-js = pkgs.callPackage ./llonebot-js.nix { };

  pmhq = pkgs.callPackage ./pmhq.nix {
    config = {
      host = config.pmhq_host;
      port = config.pmhq_port;
      quick_login_qq = config.quick_login_qq;
      headless = config.headless;
    };
  };

  llonebot = pkgs.writeScriptBin "llonebot" ''
    #!${pkgs.runtimeShell}

    # llonebot 工作目录
    if [ ! -f "~/.config/llonebot/llonebot.js" ]; then
      mkdir -p ~/.config/llonebot
      cp -rf ${llonebot-js}/js/* ~/.config/llonebot/
    fi

    ${pmhq}/bin/pmhq &

    cd ~/.config/llonebot && \
      ${pkgs.nodejs}/bin/node llonebot.js \
      --pmhq-host=${config.pmhq_host} \
      --pmhq-port=${toString config.pmhq_port}
  '';
}
