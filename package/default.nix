{
  pkgs,
  lib,
  pmhq,
  ...
}:
rec {
  llonebot-js = pkgs.callPackage ./llonebot-js.nix { };

  llonebot = pkgs.writeScriptBin "llonebot" ''
    #!${pkgs.runtimeShell}

    # llonebot 工作目录
    if [ ! -f "~/.config/llonebot/llonebot.js" ]; then
      mkdir -p ~/.config/llonebot
      cp -rf ${llonebot-js}/js/* ~/.config/llonebot/
    fi

    ${pmhq}/bin/pmhq &

    cd ~/.config/llonebot && ${pkgs.nodejs}/bin/node llonebot.js --pmhq-host=127.0.0.1 --pmhq-port=13000
  '';
}
