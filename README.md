# Claude Code 中文状态栏

给 Claude Code 底部加一个两行的中文状态栏，用量、花费、时长一眼看清。

```
Opus 5.5 │ 🧠 █░░░░░ 10% │ 5h █░░░░░ 12%(2时53分) │ 7d ░░░░░░ 2%(2天10时)
🔢 入63k 出28k 缓存4.7M │ 💰 $2.34 │ ⏳ 1时28分
```

| 图标 | 含义 |
|---|---|
| 🧠 | 上下文窗口用了多少 |
| 5h / 7d | 5 小时、7 天额度用了多少，括号里是离重置还有多久（订阅用户才有） |
| 🔢 | 本会话累计 Token：输入 / 输出 / 缓存读取 |
| 💰 | 本会话花费（按 API 价格估算，订阅用户不代表实际扣费） |
| ⏳ | 会话时长 |

进度条颜色：绿色 < 50%，黄色 50–80%，红色 > 80%。

## 安装

在终端里运行：

```bash
curl -fsSL https://raw.githubusercontent.com/7675300-svg/claude-statusline-zh/main/install.sh | bash
```

然后新开一个 Claude Code 窗口即可。

- 会把脚本放到 `~/.claude/statusline-zh.sh`，并修改 `~/.claude/settings.json` 里的 `statusLine`。
- 修改前会自动备份原设置（`settings.json.bak.时间`），其他设置不动。
- 需要 `python3`（Mac 自带）。

## 卸载 / 换回原来的

把备份文件改回 `settings.json`，或者删掉 `settings.json` 里的 `statusLine` 那一项。

## 要求

- Claude Code 2.1 以上（5h / 7d 用量需要较新版本，旧版本不显示这两项）
- macOS 或 Linux
