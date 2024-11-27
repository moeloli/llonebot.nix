{
  description = "llonebot.nix";
  outputs = {
    self, nixpkgs, flake-utils,
  }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
    
    defaultConfig = {
      programs.llonebot = {
        port = 7081;
        vncpasswd = "vncpassword";
      };
    };
    
    # 使用默认配置创建 common
    common = pkgs.callPackage ./package {
      config = defaultConfig;
    };
    
  in rec {
    devShells.default = pkgs.mkShell {};
    # 构建自定义配置的函数
    lib.buildLLOneBot = module: pkgs.callPackage ./package {
      config = module;
    };
    # 默认包使用默认配置
    packages.default = common.llonebot;

    # 添加 Docker 镜像构建
    packages.dockerImage = pkgs.dockerTools.buildImage {
      name = "llonebot";
      tag = "latest";
      copyToRoot = pkgs.buildEnv {
        name = "llonebot-env";
        paths = [ common.llonebot pkgs.coreutils];
      };
      config = {
        Cmd = [ "/bin/LLOneBot" ]; # 根据实际可执行文件路径调整
        Expose = [ "7081" ]; # 曝露端口
      };
    };
  });
}