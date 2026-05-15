# tools/lnw — 长篇小说写作 CLI

将"该读什么、该校验什么、ID 怎么分"这类机械操作固化为确定性脚本，避免 agent 凭记忆操作记忆系统。

## 命令一览

| 命令 | 作用 |
|---|---|
| `lnw assemble-context <N>` | 拼接第 N 章写前上下文（9 段），输出到 stdout |
| `lnw check-naming <N>` | grep 第 N 章正文，扫 `naming.md` 禁用变体 |
| `lnw check-progression <N>` | 校验第 N 章涉及的境界/能力是否单调（不允许倒退） |
| `lnw next-id <fact\|promise\|prog\|foreshadowing>` | 分配下一个 ID |
| `lnw filter-facts <slug1,slug2,...>` | 过滤相关实体的 facts.jsonl 条目 |
| `lnw last-seen <slug>` | 该角色最后出场章号 |
| `lnw stale-subplots [--threshold N]` | 超过 N 章（默认 20）未推进的副线 |
| `lnw snapshot <N> [--note "..."]` | 创建第 N 章的记忆层快照 |

`lnw help` 看完整帮助。

## 运行环境

`lnw` 是 bash 脚本。在能跑 bash 的环境里都能用，**不能在 PowerShell / cmd 里直接执行**。

| 环境 | 状态 | 备注 |
|---|---|---|
| Linux | ✅ 原生 | 装 `jq` 即可 |
| macOS | ✅ 原生 | `brew install jq` |
| Windows + Git Bash | ✅ 推荐 | 装了 Git for Windows 就自带 Git Bash |
| Windows + WSL | ✅ 推荐 | 完整 Linux 子系统，最省心 |
| Windows + Cygwin / MSYS2 | ✅ 可用 | 同 Git Bash 思路 |
| Windows PowerShell（裸） | ❌ 不支持 | bash 脚本无法直接执行 |
| Windows cmd（裸） | ❌ 不支持 | 同上 |

**没有 Git Bash 也不想装 WSL 怎么办？**  
切换到 `dev` 分支。dev 分支没有 CLI，所有"机械操作"由 agent 用读写文件、grep 等工具完成，行为一致，仅 token 成本略高、确定性略低。

## 依赖安装

### `jq`（必须）

`jq` 用于处理 `canon/*.jsonl`。**所有 `lnw` 命令都依赖它**。

| 平台 | 命令 |
|---|---|
| Debian / Ubuntu | `sudo apt install jq` |
| Fedora / RHEL | `sudo dnf install jq` |
| Arch | `sudo pacman -S jq` |
| macOS | `brew install jq` |
| Windows + scoop | `scoop install jq` |
| Windows + choco | `choco install jq` |
| Windows + winget | `winget install jqlang.jq` |

验证：`jq --version` 应输出 `jq-1.x` 及以上。

### `yq` v4+（可选）

`yq` 用于解析 YAML frontmatter（`chapter-*.index.md` 的元数据头）。当前 `lnw` 命令对 `yq` 是软依赖：缺失时仍可工作，但 `assemble-context` 等命令会跳过 frontmatter 字段。

> ⚠️ 必须用 [mikefarah/yq v4+](https://github.com/mikefarah/yq)（Go 实现），不是 Python 的 `yq`。两者命令语法不兼容。

| 平台 | 命令 |
|---|---|
| Linux / macOS | 从 GitHub Releases 下载二进制；或 `brew install yq`（macOS）/ `snap install yq`（Ubuntu） |
| Windows + scoop | `scoop install yq` |
| Windows + choco | `choco install yq` |
| Windows + winget | `winget install MikeFarah.yq` |

验证：`yq --version` 应输出 `yq (https://github.com/mikefarah/yq/) version v4.x`。如果显示 v3 或 Python 版本，需要另外装 v4。

## Windows 用户分步指南

如果你刚开始：

1. 安装 [Git for Windows](https://git-scm.com/download/win)（自带 Git Bash）
2. 安装包管理器：[Scoop](https://scoop.sh/) 或 [Chocolatey](https://chocolatey.org/) 任选其一
3. 在 PowerShell 跑一次 `scoop install jq`（或 `choco install jq`）
4. 之后所有 `lnw` 调用都在 **Git Bash 终端** 里跑，不要切回 PowerShell
5. （可选）`scoop install yq`

如果你的 agent（Kiro CLI / Claude Code 等）默认在 PowerShell 里跑命令，需要让它在调用 `lnw` 时显式走 Git Bash。两种做法：

- 让 agent 用 `bash -c "lnw <args>"`（前提是 Git Bash 的 `bash.exe` 在 PATH 里，Git for Windows 默认会加）
- 或在终端里先 `bash` 进入 Git Bash 子 shell，再调 `lnw`

## 路径约定

`lnw` 自带"向上查找 `metadata.md`"的根目录定位逻辑。在小说目录或其任意子目录里运行都能识别项目根。

将 `tools/` 整体放在小说仓库或 SKILL 安装目录下都可以，建议把 `tools/lnw` 加到 PATH（或起 alias），免得每次写绝对路径。

## 排错

**`lnw: command not found`**  
脚本没在 PATH 里，或终端不是 bash。用 `bash /path/to/tools/lnw <args>` 显式调用，或加 alias。

**`jq: command not found`**  
按上面装 `jq`，重启终端使 PATH 生效。

**Git Bash 里 `jq` 装在了 PowerShell 一侧但 Git Bash 找不到**  
这是 PATH 隔离问题。Scoop / Choco 装到的目录通常是 `~/scoop/shims` 或 `C:\ProgramData\chocolatey\bin`，确保 Git Bash 的 PATH 能看到这些目录。最简单：直接复制 `jq.exe` 到 Git Bash 的 `/usr/bin/`。

**脚本报 `bad interpreter: /usr/bin/env`**  
说明你不是在 bash 环境里跑。检查终端是 bash（`echo $SHELL` 应有 `bash`）。

**`set -euo pipefail` 在 macOS 老版 bash 报错**  
macOS 自带 bash 是 3.2，部分语法行为不同。建议 `brew install bash` 装 5.x，或用 zsh 调脚本（`bash --version` 验证）。

## 与 dev 分支的关系

dev-tools 是 dev 的超集。每次 dev 上的协议或提示词改动会同步合并进 dev-tools。两个分支在记忆系统、prompt、文件契约上完全一致；区别只在 dev-tools 多了 `tools/`。

如果你的工作机不能跑 bash，用 dev 分支不会丢任何能力，只是把 CLI 替换成 agent 操作。
