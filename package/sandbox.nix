{
  pkgs,
  lib,
  config,
  ...
}:
let
  llonebot-service =
    (pkgs.callPackage ./llonebot-service.nix {
      inherit config;
    }).service;
in
rec {
  sandbox = pkgs.writeScriptBin "sandbox" ''
    #!${pkgs.runtimeShell}
    if [ -z "$VNC_PASSWD" ]; then
      VNC_PASSWD=${config.vncpassword}
    fi
    ${pkgs.bubblewrap}/bin/bwrap \
      --unshare-all \
      --share-net \
      --as-pid-1 \
      --uid 0 --gid 0 \
      --setenv VNC_PASSWD $VNC_PASSWD \
      --ro-bind /nix/store /nix/store \
      --ro-bind ${pkgs.tzdata}/share/zoneinfo/Asia/Shanghai /etc/localtime \
      --bind ${config.sandbox_root_dir} /root/ \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      ${llonebot-service}/bin/llonebot-service
  '';
}
