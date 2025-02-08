#!/bin/bash

# 获取本机 IP 和归属地
IP_INFO=$(curl -s https://ipinfo.io)
IP=$(echo "$IP_INFO" | grep '"ip":' | awk -F'"' '{print $4}')
COUNTRY=$(echo "$IP_INFO" | grep '"country":' | awk -F'"' '{print $4}')
ASN=$(echo "$IP_INFO" | grep '"org":' | awk -F'"' '{print $4}')
echo "🔹 你的 IP: $IP ($ASN, $COUNTRY)"
echo "--------------------------------------"

# 定义检测函数
check_service() {
    local service_name=$1
    local test_url=$2
    local result=$(curl -L -s -o /dev/null -w "%{http_code}" "$test_url")
    
    if [[ "$result" == "200" ]]; then
        echo "✅ $service_name: 已解锁"
    elif [[ "$result" == "403" || "$result" == "451" ]]; then
        echo "❌ $service_name: 被封锁"
    else
        echo "⚠️ $service_name: 无法确定 (状态码: $result)"
    fi
}

# 逐个检测服务
echo "🎬 正在检测流媒体服务..."
check_service "Netflix" "https://www.netflix.com/title/80018499"
check_service "Disney+" "https://www.disneyplus.com"
check_service "Amazon Prime Video" "https://www.primevideo.com"

echo "📱 正在检测社交媒体..."
check_service "ChatGPT" "https://chat.openai.com"
check_service "TikTok" "https://www.tiktok.com"
check_service "Instagram" "https://www.instagram.com"
check_service "LINE" "https://line.me"
check_service "WhatsApp" "https://web.whatsapp.com"
check_service "X.com (Twitter)" "https://twitter.com"
check_service "Google" "https://www.google.com"

echo "🎵 正在检测音乐和游戏..."
check_service "Spotify" "https://www.spotify.com"
STEAM_CURRENCY=$(curl -s "https://store.steampowered.com/iplookup/" | grep -oP '(?<="currency":")[^"]+')
echo "🎮 Steam 货币区域: $STEAM_CURRENCY"

echo "✅ 检测完成！"