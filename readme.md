# 参考

[chronocat.nix](https://github.com/Anillc/chronocat.nix) 若有侵权，请联系我删除


# 使用方法

## docker

### docker compose

```yaml
version: "3"
services:
    llonebot:
        volumes:
            - ./QQ:/root/.config/QQ # 挂载 QQ 配置目录
            - ./llonebot:/root/llonebot # 挂载 llonebot 数据目录
        ports:
            - 3000:3000 # OneBot HTTP 端口
            - 3001:3001 # OneBot WebSocket 端口
            - 5600:5600 # Satori 端口
            - 13000:13000 # pmhq
        container_name: llonebot
        network_mode: bridge
        restart: always
        image: initialencounter/llonebot:latest
```

### docker cli

```bash
docker run -d \
  --name llonebot \
  -p 3000:3000 \
  -p 3001:3001 \
  -p 5600:5600 \
  -v ./QQ:/root/.config/QQ \
  -v ./llonebot:/root/llonebot \
  --restart unless-stopped \
  initialencounter/llonebot:latest
```

## 快速体验

```bash
# 沙盒运行
nix run github:LLOneBot/llonebot.nix#sandbox

# 直接在桌面运行（需要桌面环境）
nix run github:LLOneBot/llonebot.nix

# 仅运行 pmhq
nix run github:LLOneBot/llonebot.nix#pmhq
```

## NixOS 配置

无需桌面环境
[sandbox](./examples/sandbox.nix)

需要桌面环境版
[desktop](./examples/sandbox.nix)

## 登录

### VNC

使用 VNC客户端连接 localhost:7081 或者 docker 宿主机 ip:7081 登录，**注意：不是用浏览器打开localhost:7081**！

默认密码是 `vncpassword`


### noVNC

浏览器打开 http://<宿主机IP>:5900/vnc.html

默认密码是 `vncpassword`
