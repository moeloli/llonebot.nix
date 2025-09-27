{
  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable";
    llonebot.url = "github:LLOneBot/llonebot.nix";
  };

  outputs =
    { nixpkgs, llonebot, ... }:
    {
      nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { pkgs, ... }:
            let
              llonebotConfig = {
                vncport = 7081;
                vncpassword = "vncpassword";
                display = ":666";
                novncport = 5900;
                pmhq_host = "0.0.0.0";
                pmhq_port = 13000;
                headless = true;
                quick_login_qq = ""; # 快速登录QQ号
              };
              myLLOneBot = (pkgs.llonebot.buildLLOneBotSandbox llonebotConfig).sandbox;
            in
            {
              systemd.services.llonebot = {
                enable = true;
                description = "LLOneBot Service";
                after = [ "network.target" ];
                wantedBy = [ "multi-user.target" ];

                # 完全保留原服务配置
                serviceConfig = {
                  ExecStart = "${myLLOneBot}/bin/sandbox";
                  Restart = "always";
                  User = "root";
                };
              };
            }
          )
        ];
      };
    };
}
