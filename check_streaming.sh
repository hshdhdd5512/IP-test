#!/bin/bash
# 文件名：run_remote.sh
# 描述：从远程服务器下载脚本并执行，功能与
#       bash <(curl -L -s media.ispvps.com)
#       相同。
#
# 警告：直接执行远程代码存在风险，请务必先确认该远程脚本的安全性！

set -euo pipefail

# 远程脚本 URL（建议使用 https 协议，如果服务器支持的话）
REMOTE_URL="https://media.ispvps.com"

# 创建一个临时文件用于存放下载的脚本
TEMP_FILE=$(mktemp /tmp/remote_script.XXXXXX)

echo "正在从 ${REMOTE_URL} 下载远程脚本..."
if ! curl -L -s -o "$TEMP_FILE" "$REMOTE_URL"; then
  echo "错误：下载远程脚本失败！"
  exit 1
fi

echo "下载成功。"
echo "----------------------"
echo "下载的脚本内容如下（请确认其安全性）："
echo "----------------------"
cat "$TEMP_FILE"
echo "----------------------"

# 暂停，等待用户确认是否继续执行
read -p "确认无误后按 Enter 键继续执行该脚本，或 Ctrl+C 中断..."

echo "正在执行下载的远程脚本..."
bash "$TEMP_FILE"

# 执行完毕后删除临时文件
rm -f "$TEMP_FILE"
echo "执行完毕，临时文件已删除。"
