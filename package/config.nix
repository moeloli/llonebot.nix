{
  lib,
  ...
}:
let
  # 默认配置
  defaultConfig = {
    vncport = 7081;
    vncpassword = "vncpassword";
    display = ":666";
    novncport = 5900;
    pmhq_host = "0.0.0.0";
    pmhq_port = 13000;
    headless = true;
    quick_login_qq = ""; # 快速登录QQ号
    sandbox_root_dir = "/root/bot/llonebot"; # 沙盒数据持久化目录
  };

  # 合并用户配置和默认配置
  mergeConfig = userConfig: defaultConfig // userConfig;

in
{
  inherit defaultConfig mergeConfig;
}
