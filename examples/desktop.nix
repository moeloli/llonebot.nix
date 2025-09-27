{
  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-23.11";
    llonebot = {
      url = "github:LLOneBot/llonebot.nix"; # nix flake lock --update-input llonebot
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    };
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
              myLLOneBot = (pkgs.llonebot.buildLLOneBot llonebotConfig).llonebot;
            in
            {
              environment.systemPackages = [ myLLOneBot ];
            }
          )
        ];
      };
    };
}
