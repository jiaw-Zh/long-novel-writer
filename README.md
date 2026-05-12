# 长篇小说生成 SKILL

> 原始项目：[AI_NovelGenerator](https://github.com/YILING0013/AI_NovelGenerator)

一个面向百万/千万字长篇的 AI 写作 SKILL，解决长篇小说后期走形的核心问题。

## 为什么需要这个

AI 写长篇小说有一个根本性问题：**上下文窗口装不下整部作品**。即使是 1M token 的窗口，对 300 万字的小说也远远不够。结果是：

- 早期设定被后期章节覆盖稀释，角色性格漂移
- 数值、能力、物品归属前后矛盾
- 伏笔埋了忘了回收，或回收时对不上原文
- 配角消失几十章后再出场，agent 只能现编
- 同类桥段反复出现，读者审美疲劳

这个 SKILL 用结构化记忆系统解决上述问题，而不是靠"更大的上下文窗口"。

## 核心特色

### 分层摘要冻结
将作品摘要拆为六层：L0（正文）→ L1（单章）→ L2（chunk）→ L3（篇章）→ L4（卷）→ L5（全书）。每层写定后冻结，不再被后续章节覆盖。彻底消除"电话传话"式的早期细节稀释。

### 实体中心档案
角色、地点、道具、势力、力量体系各自独立建档，包含硬约束、追加式时间线和变更记录。写作时只按需加载本章出场实体，精准且省 token。典型写前上下文用量 25k–40k token，1M 窗口极度宽裕。

### 正典账本（Canon Ledger）
五个只追加不修改的结构化文件：
- `canon/facts.jsonl` — 原子事实断言，带原文引用和 `known_by` 字段
- `canon/promises.jsonl` — 角色承诺/誓言，带截止日期
- `canon/progression.jsonl` — 境界/能力进阶轨迹，校验单调性
- `canon/rules.md` — 世界规则
- `canon/timeline.md` — 时间线

写后校验时按实体过滤账本，数值漂移、能力越界、死而复生等硬冲突在落盘前即被拦截。

### POV 知识边界
`facts.jsonl` 的 `known_by` 字段追踪每条秘密"谁知道"。写前加载出场角色的已知信息列表，防止角色使用尚未获得的信息——这是长篇后期最常见的 OOC 类型。

### 写前组装协议
9 步固定流程决定每章写作前载入哪些文件，包括：活跃伏笔、到期承诺、失踪副线提醒、关键词反查相关章节。有 shell 权限时一行命令完成：`lnw assemble-context <N>`。

### 写后双 agent 校验
8 项校验（正典冲突 / POV 知识边界 / 硬约束 / 进阶合法性 / 命名一致性 / 桥段重复 / 伏笔对齐 / 场景打分）+ 固定落盘顺序。支持独立 subagent 执行校验，避免写作 agent 自我合理化。

### 命名一致性
`naming.md` 标准名称表记录每个实体的规范写法和禁用变体。有工具时用 `lnw check-naming <N>` 自动 grep 正文，零 LLM 拦截"青云宗/青云派"这类漂移。

### 副线与配角追踪
`subplots.md` 追踪所有副线的最后推进章节。超过 20 章未推进的副线会在写前自动提示。

### 记忆快照与分叉写作
每 50 章或每卷收尾快照记忆层（不含正文，正文走 git）。出问题可回滚，想探索"如果当时选了另一条路"可以从快照建分支独立续写。

### 体裁模式（网文 / 严肃文学）
`metadata.md` 的 `体裁模式` 字段控制提示词的写作约束分支：
- **网文模式**：爽点密度、打脸循环、章末钩子、具体数值、金手指节奏
- **严肃文学模式**：潜台词冲突、心理深度、隐喻系统、认知颠覆

### 网文专用提示词
5 个专为网络小说设计的提示词：
- 章末钩子（10 种模式交替）
- 打脸三段式
- 开篇三章黄金结构
- 境界突破章四段式
- 金手指设计与升级路线

### CLI 工具（dev-tools 分支）
`tools/lnw` 提供 8 个核心命令，将机械操作固化为确定性脚本：

```bash
lnw assemble-context 123    # 拼接写前上下文
lnw check-naming 123        # 命名一致性检查
lnw check-progression 123   # 境界单调性检查
lnw next-id fact            # 分配下一个 FACT ID
lnw filter-facts zhang-san  # 过滤角色相关事实
lnw last-seen zhang-san     # 角色最后出场章节
lnw stale-subplots          # 失踪副线列表
lnw snapshot 50 --note "卷一收尾"
```

依赖：`jq`（必须）、`yq`（可选）。有 shell 权限的环境（Kiro、Claude Code、Codex）可直接使用，无 shell 权限时退化为手工操作。

## 与向量数据库的对比

| 能力 | 本系统 | 向量数据库 |
|---|---|---|
| 数值/能力冲突检测 | ✅ 结构化比对 | ❌ 不擅长数字 |
| POV 知识边界 | ✅ known_by 字段 | ❌ 语义相似度无法表达"谁知道" |
| 命名漂移检测 | ✅ grep 精确匹配 | ❌ 语义相近会误召回 |
| 承诺到期提醒 | ✅ deadline_day 字段 | ❌ 无时间感 |
| 模糊语义关联 | ⚠️ keywords 覆盖 | ✅ 强项 |

结论：防走形靠结构化，本系统专攻这一点。向量数据库可作为第 9 步检索的外挂补充，不是替代。

## 使用方法

安装后直接给 agent 发送指令：

```text
"我想写一本小说"
"我想写一本300万字的穿越修真逆袭小说"
```

agent 会引导完成：创意扩展 → 世界观/角色设定 → 分卷架构 → 逐章生成 → 记忆更新。

## 安装

**OpenClaw / 支持 OpenClaw Skills 的 agent：**
```text
Install this skill: https://github.com/jiaw-Zh/long-novel-writer
```

**Claude Code：**
```text
Install this Agent Skill from GitHub as a personal Claude Code skill: https://github.com/jiaw-Zh/long-novel-writer
```

**Codex：**
```text
Use $skill-installer to install this skill from GitHub: https://github.com/jiaw-Zh/long-novel-writer
```

## 分支说明

| 分支 | 说明 |
|---|---|
| `dev` | 主开发分支，记忆系统 + 提示词，无 CLI 工具依赖 |
| `dev-tools` | 包含 `tools/lnw` CLI 工具（需 shell 权限 + jq），适合 Claude Code / Codex 环境 |
| `main` | 稳定版（待 dev 验证后合入）|

## 项目结构

```
SKILL.md                          # Agent 工作流主文件
references/
  memory-protocol.md              # 记忆协议（分层摘要、正典账本、写前/写后流程）
  file-contract.md                # 作品文件目录契约
  long-serial-method.md           # 百万字长篇机制
  prompt-workflow.md              # 提示词选择与使用流程
  prompt-index.md                 # 提示词索引
  prompts/
    prompt-templates.md               # 完整写作链路提示词模板
    dev-prompt_default.yaml           # 从创意生成小说基础信息
    consistency-check-prompt.md       # 写后一致性校验提示词
tools/                            # dev-tools 分支专有
  lnw                             # CLI 入口
  lib/                            # 各子命令实现
```
