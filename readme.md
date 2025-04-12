# 参考

[chronocat.nix](https://github.com/Anillc/chronocat.nix) 若有侵权，请联系我删除


# 使用方法

## docker

```bash
# VNC 端口 7081
# OneBot HTTP 端口 3000
docker run -p 3000:3000 -p 7081:7081 -e VNC_PASSWD=vncpassword --privileged initialencounter/llonebot:latest
```

## 快速体验

```bash
# 使用nix run
nix run github:LLOneBot/llonebot.nix
```

## Nix

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable";
    llonebot.url = "github:LLOneBot/llonebot.nix";
  };

  outputs = { nixpkgs, llonebot, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, config, ... }: let
          llonebotConfig = {
            vncport = 7081;
            vncpassword = "mysecurepassword";  # 保留原密码
          };
          llonebotLib = llonebot.lib.${config.nixpkgs.system};
          myLLOneBot = (llonebotLib.buildLLOneBot llonebotConfig).script;
        in {
          systemd.services.llonebot = {
            enable = true;
            description = "LLOneBot Service";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            # 完全保留原服务配置
            serviceConfig = {
              ExecStart = "${myLLOneBot}/bin/LLOneBot";
              Restart = "always";
              User = "root";
            };
          };
        })
      ];
    };
  };
}
```

## 登录
### 终端扫码

```bash
# 使用终端扫码登录
docker logs llonebot
```

### VNC

使用 VNC客户端连接 localhost:7081 或者 docker 宿主机 ip:7081 登录，**注意：不是用浏览器打开localhost:7081**！

默认密码是 `vncpassword`
