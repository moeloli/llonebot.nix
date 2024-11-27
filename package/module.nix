{ config, lib, ... }: {
  options.programs.llonebot = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 7081;
      description = "VNC服务器端口";
    };
    
    vncpasswd = lib.mkOption {
      type = lib.types.str;
      default = "vncpasswd";
      description = "VNC服务器密码";
    };
  };
} 