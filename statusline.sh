#!/bin/bash
# 状态栏（两行）
# 第1行：模型 │ 上下文 │ 5小时用量 │ 7天用量
# 第2行：本会话累计 Token │ 花费 │ 会话时长
input=$(cat)
[ -n "$CLAUDE_STATUSLINE_DEBUG" ] && echo "$input" > /tmp/claude-statusline-last.json

echo "$input" | python3 -c '
import json, sys, time
try:
    d = json.load(sys.stdin)
except Exception:
    print("状态栏读取失败"); sys.exit()

R = "\033[0m"
def bar(p, n=6):
    p = max(0, min(100, p)); f = round(p / 100 * n)
    return "█" * f + "░" * (n - f)
def color(p):
    return "\033[32m" if p < 50 else ("\033[33m" if p < 80 else "\033[31m")
def k(n):
    n = n or 0
    return f"{n/1e6:.1f}M" if n >= 1e6 else (f"{n/1e3:.0f}k" if n >= 1e3 else str(n))
def left(ts):
    try:
        s = ts - time.time()
        if s <= 0: return ""
        h = int(s // 3600)
        return f"({h//24}天{h%24}时)" if h >= 24 else f"({h}时{int(s%3600//60)}分)"
    except Exception:
        return ""

l1, l2 = [], []

model = (d.get("model") or {}).get("display_name")
if model:
    l1.append(f"\033[36m{model}{R}")

cw = d.get("context_window") or {}
cp = cw.get("used_percentage")
if cp is not None:
    l1.append(f"🧠 {color(cp)}{bar(cp)} {cp:.0f}%{R}")

rl = d.get("rate_limits") or {}
for key, label in (("five_hour", "5h"), ("seven_day", "7d")):
    w = rl.get(key) or {}
    p = w.get("used_percentage")
    if p is not None:
        rs = left(w.get("resets_at"))
        l1.append(f"{label} {color(p)}{bar(p)} {p:.0f}%{R}{rs}")

# 本会话累计 Token：从会话记录逐条加总（按消息 id 去重）
tp = d.get("transcript_path")
if tp:
    seen = {}
    try:
        with open(tp, encoding="utf-8") as fh:
            for ln in fh:
                if "\"usage\"" not in ln:
                    continue
                try:
                    m = json.loads(ln).get("message") or {}
                except Exception:
                    continue
                u = m.get("usage")
                if isinstance(u, dict):
                    seen[m.get("id") or len(seen)] = u
    except Exception:
        pass
    if seen:
        s_in = sum((u.get("input_tokens") or 0) + (u.get("cache_creation_input_tokens") or 0) for u in seen.values())
        s_cache = sum(u.get("cache_read_input_tokens") or 0 for u in seen.values())
        s_out = sum(u.get("output_tokens") or 0 for u in seen.values())
        a, b, c = k(s_in), k(s_out), k(s_cache)
        l2.append(f"\033[33m🔢 入{a} 出{b} 缓存{c}{R}")

cost = d.get("cost") or {}
usd = cost.get("total_cost_usd")
if usd is not None:
    l2.append(f"\033[35m💰 ${usd:.2f}{R}")

ms = cost.get("total_duration_ms")
if ms is not None:
    sec = int(ms // 1000); h, m = sec // 3600, sec % 3600 // 60
    dur = f"{h}时{m}分" if h else (f"{m}分" if m else f"{sec}秒")
    l2.append(f"\033[34m⏳ {dur}{R}")

out = [" │ ".join(x) for x in (l1, l2) if x]
print("\n".join(out) if out else "等待数据…")
'
