# 长篇小说生成 SKILL

> 原始项目：[AI_NovelGenerator](https://github.com/YILING0013/AI_NovelGenerator)

一个面向百万/千万字长篇的 AI 写作 SKILL，解决长篇小说后期走形的核心问题。

## 特色

**分层摘要冻结**
将作品摘要拆为 L0（正文）→ L1（单章）→ L2（chunk）→ L3（篇章）→ L4（卷）→ L5（全书）六层，每层写定后冻结，不再被后续章节覆盖。彻底消除"电话传话"式的早期细节稀释。

**实体中心档案**
角色、地点、道具、势力、力量体系各自独立建档，包含硬约束、追加式时间线和变更记录。写作时只按需加载本章出场实体，精准且省 token。

**正典账本（Canon Ledger）**
`canon/facts.jsonl` 以原子断言形式记录约束性事实（能力上限、物品归属、人物死亡等），只追加不修改，带原文引用。写后校验时按实体过滤账本，数值漂移、能力越界、死而复生等硬冲突在落盘前即被拦截。

**写前组装协议**
9 步固定流程决定每章写作前载入哪些文件，典型上下文用量 25k–40k token，1M 窗口极度宽裕，且每一项都对当前章节有直接价值。

**写后校验闭环**
4 项校验（正典冲突 / 硬约束 / 桥段重复 / 伏笔对齐）+ 10 步固定落盘顺序，确保每章完成后记忆状态一致。

## 使用方法

安装后直接给 agent 发送指令：

```text
"我想写一本小说"
"我想写一本300万字的穿越修真逆袭小说"
```

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
