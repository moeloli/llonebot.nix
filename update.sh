package=$1
version=$2

if [ "$package" = "liteloader" ]; then
    amd64_url="https://github.com/LiteLoaderQQNT/LiteLoaderQQNT/releases/download/$version/LiteLoaderQQNT.zip"
    amd64_hash=$(nix-prefetch-url $amd64_url)

    # use friendlier hashes
    amd64_hash=$(nix hash to-sri --type sha256 "$amd64_hash")
    sed -i "s|# Last updated: .*\.|# Last updated: $(date +%F)\.|g" ./package/sources.nix
    sed -i "s|LiteLoaderUrl = \".*\";|LiteLoaderUrl = \"$amd64_url\";|g" ./package/sources.nix
    sed -i "s|LiteLoaderHash = \".*\";|LiteLoaderHash = \"$amd64_hash\";|g" ./package/sources.nix
fi

if [ "$package" = "qq" ]; then
    amd64_url="https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_${version}_amd64_01.deb"
    arm64_url="https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_${version}_arm64_01.deb"

    # use friendlier hashes
    amd64_hash=$(nix-prefetch-url $amd64_url)
    arm64_hash=$(nix-prefetch-url $arm64_url)
    amd64_hash=$(nix hash to-sri --type sha256 "$amd64_hash")
    arm64_hash=$(nix hash to-sri --type sha256 "$arm64_hash")
    
    sed -i "s|# Last updated: .*\.|# Last updated: $(date +%F)\.|g" ./package/sources.nix
    sed -i "s|qq_version = \".*\";|qq_version = \"$version\";|g" ./package/sources.nix
    sed -i "s|qq_amd64_url = \".*\";|qq_amd64_url = \"$amd64_url\";|g" ./package/sources.nix
    sed -i "s|qq_amd64_hash = \".*\";|qq_amd64_hash = \"$amd64_hash\";|g" ./package/sources.nix
    sed -i "s|qq_arm64_url = \".*\";|qq_arm64_url = \"$arm64_url\";|g" ./package/sources.nix
    sed -i "s|qq_arm64_hash = \".*\";|qq_arm64_hash = \"$arm64_hash\";|g" ./package/sources.nix
fi

if [ "$package" = "llonebot" ]; then
    url="https://github.com/LLOneBot/LLOneBot/releases/download/v$version/LLOneBot.zip"
    hash=$(nix-prefetch-url $url)
    hash=$(nix hash to-sri --type sha256 "$hash")
    sed -i "s|# Last updated: .*\.|# Last updated: $(date +%F)\.|g" ./package/sources.nix
    sed -i "s|LLOneBotVersion = \".*\";|LLOneBotVersion = \"$version\";|g" ./package/sources.nix
    sed -i "s|LLOneBotUrl = \".*\";|LLOneBotUrl = \"$url\";|g" ./package/sources.nix
    sed -i "s|LLOneBotHash = \".*\";|LLOneBotHash = \"$hash\";|g" ./package/sources.nix
fi

if [ "$package" = "whale" ]; then
    url="https://github.com/initialencounter/whale/releases/download/v$version/whale.zip"
    hash=$(nix-prefetch-url $url)
    hash=$(nix hash to-sri --type sha256 "$hash")
    sed -i "s|# Last updated: .*\.|# Last updated: $(date +%F)\.|g" ./package/sources.nix
    sed -i "s|WhaleUrl = \".*\";|WhaleUrl = \"$url\";|g" ./package/sources.nix
    sed -i "s|WhaleHash = \".*\";|WhaleHash = \"$hash\";|g" ./package/sources.nix
fi