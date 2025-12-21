package=$1
version=$2

if [ "$package" = "pmhq" ]; then
    amd64_url="https://github.com/linyuchen/PMHQ/releases/download/v${version}/pmhq-linux-x64.zip"
    arm64_url="https://github.com/linyuchen/PMHQ/releases/download/v${version}/pmhq-linux-arm64.zip"

    # use friendlier hashes
    amd64_hash=$(nix-prefetch-url $amd64_url)
    arm64_hash=$(nix-prefetch-url $arm64_url)
    amd64_hash=$(nix hash convert --hash-algo sha256 "$amd64_hash")
    arm64_hash=$(nix hash convert --hash-algo sha256 "$arm64_hash")
    
    sed -i "s|# Last updated: .*\.|# Last updated: $(date +%F)\.|g" ./package/sources.nix
    sed -i "s|pmhq_version = \".*\";|pmhq_version = \"$version\";|g" ./package/sources.nix
    sed -i "s|pmhq_amd64_url = \".*\";|pmhq_amd64_url = \"$amd64_url\";|g" ./package/sources.nix
    sed -i "s|pmhq_amd64_hash = \".*\";|pmhq_amd64_hash = \"$amd64_hash\";|g" ./package/sources.nix
    sed -i "s|pmhq_arm64_url = \".*\";|pmhq_arm64_url = \"$arm64_url\";|g" ./package/sources.nix
    sed -i "s|pmhq_arm64_hash = \".*\";|pmhq_arm64_hash = \"$arm64_hash\";|g" ./package/sources.nix
fi

if [ "$package" = "llonebot" ]; then
    url="https://github.com/LLOneBot/LLOneBot/releases/download/v$version/LLBot.zip"
    hash=$(nix-prefetch-url $url)
    hash=$(nix hash convert --hash-algo sha256 "$hash")
    sed -i "s|# Last updated: .*\.|# Last updated: $(date +%F)\.|g" ./package/sources.nix
    sed -i "s|llonebot_version = \".*\";|llonebot_version = \"$version\";|g" ./package/sources.nix
    sed -i "s|llonebot_url = \".*\";|llonebot_url = \"$url\";|g" ./package/sources.nix
    sed -i "s|llonebot_hash = \".*\";|llonebot_hash = \"$hash\";|g" ./package/sources.nix
fi

# example: ./update.sh qq https://dldir1v6.qq.com/qqfile/qq/QQNT/9afaaf9b/linuxqq_3.2.18-35951_amd64.deb
if [ "$package" = "qq" ]; then
    cd package/qq && ./update.sh $version
fi