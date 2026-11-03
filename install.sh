#!/bin/bash
# cli ztl（Claude Code 中文状态栏）一键安装
# 用法：bash install.sh   （或用 README 里的 curl 一行命令）
set -e

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TARGET="$CLAUDE_DIR/ztl.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
SRC_URL="${STATUSLINE_SRC_URL:-https://raw.githubusercontent.com/7675300-svg/cli-ztl/main/statusline.sh}"

command -v python3 >/dev/null || { echo "❌ 需要 python3（Mac 自带；Linux 请先安装）"; exit 1; }
mkdir -p "$CLAUDE_DIR"

# 1. 放脚本：本地有就用本地的，否则从 GitHub 下载
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo .)"
if [ -f "$HERE/statusline.sh" ]; then
  cp "$HERE/statusline.sh" "$TARGET"
else
  curl -fsSL "$SRC_URL" -o "$TARGET"
fi
chmod +x "$TARGET"

# 2. 改 settings.json（先备份）
if [ -f "$SETTINGS" ]; then
  BAK="$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
  cp "$SETTINGS" "$BAK"
  echo "📦 已备份原设置：$BAK"
fi
python3 - "$SETTINGS" "$TARGET" <<'PY'
import json, os, sys
path, target = sys.argv[1], sys.argv[2]
d = {}
if os.path.exists(path) and open(path).read().strip():
    d = json.load(open(path))
old = d.get("statusLine")
if old:
    print("ℹ️  原状态栏配置：", json.dumps(old, ensure_ascii=False))
d["statusLine"] = {"type": "command", "command": target, "padding": 0}
json.dump(d, open(path, "w"), ensure_ascii=False, indent=2)
PY

echo "✅ 安装完成。新开一个 Claude Code 窗口（或等下一次刷新）就能看到。"
echo "   想换回原来的：把上面的备份文件改回 settings.json 即可。"
