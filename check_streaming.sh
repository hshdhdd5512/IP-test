#!/bin/bash

# 颜色定义
Font_Green="\033[32m"
Font_Red="\033[31m"
Font_Yellow="\033[33m"
Font_Suffix="\033[0m"

# 生成随机 User-Agent
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

# 获取本机 IP 和 ISP
get_network_info() {
    echo -e "${Font_Yellow}正在获取网络信息...${Font_Suffix}"
    local_ipv4=$(curl -4 -s --fail --max-time 10 https://api64.ipify.org)
    local_isp=$(curl -s --fail --max-time 10 https://ipinfo.io/org)

    echo -e "IPv4 地址：${Font_Green}$local_ipv4${Font_Suffix}"
    echo -e "ISP 运营商：${Font_Green}$local_isp${Font_Suffix}"
}

# Netflix 检测
check_netflix() {
    echo -e "${Font_Yellow}正在检测 Netflix...${Font_Suffix}"
    local result=$(curl -s --fail -L --max-time 10 --user-agent "$UA_Browser" -I "https://www.netflix.com/title/81280792" | grep "HTTP/2 200")

    if [[ -n "$result" ]]; then
        echo -e "Netflix 访问状态：${Font_Green}解锁${Font_Suffix}"
    else
        echo -e "Netflix 访问状态：${Font_Red}未解锁${Font_Suffix}"
    fi
}

# Disney+ 检测
check_disney() {
    echo -e "${Font_Yellow}正在检测 Disney+...${Font_Suffix}"
    local result=$(curl -s --fail --max-time 10 --user-agent "$UA_Browser" "https://disney.api.edge.bamgrid.com/device/ip" | grep -o '"countryCode":"[A-Z]*"' | cut -d '"' -f4)

    if [[ -n "$result" ]]; then
        echo -e "Disney+ 访问状态：${Font_Green}解锁 (地区: $result)${Font_Suffix}"
    else
        echo -e "Disney+ 访问状态：${Font_Red}未解锁${Font_Suffix}"
    fi
}

# TikTok 检测
check_tiktok() {
    echo -e "${Font_Yellow}正在检测 TikTok...${Font_Suffix}"
    local result=$(curl -s --fail --max-time 10 --user-agent "$UA_Browser" "https://www.tiktok.com/" | grep -o '"region":"[A-Z]*"' | cut -d '"' -f4)

    if [[ -n "$result" ]]; then
        echo -e "TikTok 访问状态：${Font_Green}解锁 (地区: $result)${Font_Suffix}"
    else
        echo -e "TikTok 访问状态：${Font_Red}未解锁${Font_Suffix}"
    fi
}

# 运行检测
generate_random_user_agent
get_network_info
check_netflix
check_disney
check_tiktok
