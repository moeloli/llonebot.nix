# 参考
- [chronocat.nix](https://github.com/Anillc/chronocat.nix) 若有侵权，请联系我删除

```nix
# flake.nix
{
  inputs = {
    llonebot.url = "github:initialencounter/llonebot.nix";
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

# 使用方法
```bash
nix run
```