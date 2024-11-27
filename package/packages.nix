{ pkgs, sources, ... }: let
  LiteLoader = pkgs.fetchurl {
    url = sources.LiteLoaderUrl;
    hash = sources.LiteLoaderHash;
  };
  LLOneBot = pkgs.fetchurl {
    url = sources.LLOneBotUrl;
    hash = sources.LLOneBotHash;
  };
  Whale = pkgs.fetchurl {
    url = sources.WhaleUrl;
    hash = sources.WhaleHash;
  };
  fonts = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [ source-han-sans ];
  };

  srcs = {
    x86_64-linux = pkgs.fetchurl {
      url = sources.qq_amd64_url;
      hash = sources.qq_amd64_hash;
    };
    aarch64-linux = pkgs.fetchurl {
      url = sources.qq_arm64_url;
      hash = sources.qq_arm64_hash;
    };
  };

  currentSystem = pkgs.stdenv.hostPlatform.system;
  src = srcs.${currentSystem} or (throw "Unsupported system: ${currentSystem}");
in {
  patched = pkgs.qq.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ pkgs.unzip pkgs.pkgsStatic.musl ];
    version = "3.2.13-2024.11.21";
    inherit src;
    postFixup = ''
      mkdir -p $out/LiteLoader/plugins
      export LD_LIBRARY_PATH=${pkgs.pkgsStatic.musl}/lib:$LD_LIBRARY_PATH
      unzip ${LiteLoader} -d $out/LiteLoader
      unzip ${LLOneBot} -d $out/LiteLoader/plugins/LLOneBot
      unzip ${Whale} -d $out/LiteLoader/plugins/Whale
      echo 'require(String.raw`/LiteLoader`);' > $out/opt/QQ/resources/app/app_launcher/llqqnt.js
      sed -i 's|"main": "[^"]*"|"main": "./app_launcher/llqqnt.js"|' $out/opt/QQ/resources/app/package.json
    '';
    meta = {};
  });
  inherit fonts;
} 