# 参考

[chronocat.nix](https://github.com/Anillc/chronocat.nix) 若有侵权，请联系我删除


# 使用方法

## docker

### docker compose

```yaml
version: "3"
services:
    llonebot:
        environment:
            - VNC_PASSWD=yourpassword # 设置 VNC 密码
        volumes:
            - ./QQ:/root/.config/QQ # 挂载 QQ 配置目录
            - ./llonebot:/root/llonebot # 挂载 llonebot 数据目录
        ports:
            - 3000:3000 # OneBot HTTP 端口
            - 3001:3001 # OneBot WebSocket 端口
            - 5600:5600 # Satori 端口
            - 5900:5600 # novnc
            - 7081:7081 # vnc
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
  -p 7081:7081 \
  -p 5900:5900 \
  -e VNC_PASSWD=yourpassword \
  -v ./QQ:/root/.config/QQ \
  -v ./llonebot:/root/llonebot \
  --restart unless-stopped \
  initialencounter/llonebot:latest
```

## 快速体验

```bash
# 使用nix run
nix run github:LLOneBot/llonebot.nix
```

## Nix

此方法需要安装桌面环境，使用命令 `llonebot` 启动
[example.nix](./example.nix)

## 登录

### VNC

使用 VNC客户端连接 localhost:7081 或者 docker 宿主机 ip:7081 登录，**注意：不是用浏览器打开localhost:7081**！

默认密码是 `vncpassword`


### noVNC

浏览器打开 http://<宿主机IP>:5900/vnc.html

默认密码是 `vncpassword`
