#!/bin/bash
# RegionRestrictionCheck - Safe Modified Version
# -----------------------------------------------
# 这是一个经过修改的版本，用于检测你的 IP 在主要流媒体平台（Netflix、Disney+、TikTok）的解锁状态。
# 协议：AGPL-3.0（原项目：lmc999/RegionRestrictionCheck）
# 注意：本版本已删除所有涉及敏感 Cookie、Token 等危险内容，仅保留公开检测功能。
#
# 使用示例:
#   bash <(curl -sL https://your_server_or_repo_url/check.sh)
#
# 可选参数（原版支持更多选项，此版本为简化示例）：
#   -M 4      仅检测 IPv4（默认检测 IPv4）
#   -M 6      仅检测 IPv6（本示例仅检测 IPv4）
#   -E en     指定脚本语言（仅作输出提示，本版本默认英文输出）
#
# -----------------------------------------------

set -euo pipefail

# -------------------------
# 生成随机 User-Agent
# -------------------------
generate_random_user_agent() {
    local browsers=("Chrome" "Firefox" "Edge")
    local versions=("87.0" "88.0" "89.0")
    local browser=${browsers[$RANDOM % ${#browsers[@]}]}
    local version=${versions[$RANDOM % ${#versions[@]}]}
    case $browser in
        Chrome)
            UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$version Safari/537.36"
            ;;
        Firefox)
            UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:${version%%.*}) Gecko/20100101 Firefox/$version"
            ;;
        Edge)
            UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${version%.*}.0.0 Safari/537.36 Edg/$version"
            ;;
    esac
}

# -------------------------
# 获取公共 IPv4 地址
# -------------------------
get_public_ipv4() {
    IPV4=$(curl -s --fail --max-time 10 https://api64.ipify.org)
}

# -------------------------
# 检查 Netflix 解锁状态
# -------------------------
check_netflix() {
    echo "Checking Netflix..."
    # 向 Netflix 发送请求，检查返回的 HTTP 状态码
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 10 --user-agent "$UA_Browser" "https://www.netflix.com/title/81280792")
    if [[ "$status" == "200" ]]; then
        echo "Netflix: ${GREEN}Unlocked${NC}"
    else
        echo "Netflix: ${RED}Locked or Network Issue (HTTP $status)${NC}"
    fi
}

# -------------------------
# 检查 Disney+ 解锁状态
# -------------------------
check_disney() {
    echo "Checking Disney+..."
    # 调用公开接口，获取国家代码（危险的 Cookie/Token 部分已移除）
    local response country
    response=$(curl -s --fail --max-time 10 --user-agent "$UA_Browser" "https://disney.api.edge.bamgrid.com/device/ip")
    country=$(echo "$response" | grep -oP '"countryCode":"\K[A-Z]+')
    if [[ -n "$country" ]]; then
        echo "Disney+: Unlocked (Country: $country)"
    else
        echo "Disney+: Locked or Network Issue"
    fi
}

# -------------------------
# 检查 TikTok 解锁状态
# -------------------------
check_tiktok() {
    echo "Checking TikTok..."
    local response region
    response=$(curl -s --fail --max-time 10 --user-agent "$UA_Browser" "https://www.tiktok.com/")
    region=$(echo "$response" | grep -oP '"region":"\K[A-Z]+')
    if [[ -n "$region" ]]; then
        echo "TikTok: Unlocked (Region: $region)"
    else
        echo "TikTok: Locked or Network Issue"
    fi
}

# -------------------------
# 主程序
# -------------------------
# 定义颜色（仅在终端支持颜色时有效）
GREEN="\033[32m"
RED="\033[31m"
NC="\033[0m"

# 解析参数（此示例仅简单处理 -M 参数）
MODE="4"
while getopts "M:E:" opt; do
    case "$opt" in
        M)
            MODE="$OPTARG"
            ;;
        E)
            LANG="$OPTARG"
            ;;
    esac
done

# 目前仅支持 IPv4 检测
if [[ "$MODE" != "4" ]]; then
    echo "Warning: This safe version only supports IPv4 detection. Defaulting to IPv4."
fi

# 执行检测流程
generate_random_user_agent
get_public_ipv4

echo "Public IPv4: $IPV4"
echo "User-Agent: $UA_Browser"
echo ""

check_netflix
check_disney
check_tiktok

echo ""
echo "RegionRestrictionCheck - Safe Modified Version Completed."
