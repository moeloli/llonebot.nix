{ pkgs, lib, ... }:
let
  sources = import ./sources.nix { };
  src = pkgs.fetchurl {
    url = sources.llonebot_url;
    hash = sources.llonebot_hash;
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "llonebot";
  version = "${sources.llonebot_version}";
  buildInputs = [
    pkgs.unzip
  ];

  inherit src;
  unpackPhase = ''
    unzip $src -d js
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv js $out/js
    echo "node $out/js/llonebot.js --pmhq-host=127.0.0.1 --pmhq-port=13000" > $out/bin/llonebot
    chmod +x $out/bin/llonebot
  '';

  meta = with lib; {
    description = "Pure memory hook QQNT";
    homepage = "https://github.com/linyuchen/PMHQ";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
