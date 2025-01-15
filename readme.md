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
    llonebot.url = "github:LLOneBot/llonebot.nix";
  };

  outputs = { self, llonebot, ... }: {
    packages.default = llonebot.lib.buildLLOneBot ./configuration.nix;
  };
}
```

```nix
# configuration.nix
{ config, lib, pkgs, ... }:

{
  programs.llonebot = {
    port = 8080;                            # 设置 VNC 端口
    vncpasswd = "your-secure-password";     # 设置 VNC 密码
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
