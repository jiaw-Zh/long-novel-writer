---
name: long-novel-writer
description: 当用户需要写长篇小说、扩展小说创意、构建小说架构、生成正文章节或进行章节定稿更新时使用。此技能提供了一套完整的五阶段工作流，通过外部文档驱动状态机的方式，保障百万/千万级别小说的连贯性。
---

# 长篇小说写作器

## 工具路径约定

本 SKILL 的 CLI 工具位于 **`<SKILL安装目录>/tools/lnw`**。

agent 执行任何 `lnw` 命令前，先确定路径：
```bash
# SKILL 通过 git clone 安装时，路径通常为：
LNW="$HOME/.claude/skills/long-novel-writer/tools/lnw"   # Claude Code
LNW="$HOME/.codex/skills/long-novel-writer/tools/lnw"    # Codex
# 或直接用绝对路径：
LNW="/path/to/long-novel-writer/tools/lnw"
```

后续所有 `lnw <cmd>` 均等价于 `$LNW <cmd>`，在小说目录内（或任意子目录）执行，工具会自动向上查找 `metadata.md` 定位小说根目录。

无法确定安装路径时，退化为手工操作（见 `memory-protocol.md` §10）。

---



按"架构先行、分卷推进、状态驱动、检索校验"的方式创作百万至千万字级别小说。

不要一次性生成整部长篇正文。每次只推进一个明确层级：整书架构、卷规划、3-5 章小单元、单章正文、记忆更新、修订审校。

## 工作流

1. **作品初始化**
   - 读取或创建作品目录时，先看 `references/file-contract.md`（文件布局）与 `references/memory-protocol.md`（记忆协议）。
   - 若用户只有一句创意，先用 dev 分支的"AI 创建小说"链路：扩展创意 -> 提炼构思 -> 故事核心 -> 小说整体设定。
   - 若用户已有设定，直接进入核心种子、世界观、角色动力学和整体剧情架构。
   - `story-bible.md` 立项时即写定并视为冻结基线，后续修订必须追加「变更记录」。

2. **百万字架构**
   - 将故事拆成：整书主线 -> 卷 -> 篇章单元 -> 3-5 章 chunk -> 单章。
   - 每卷必须有显性目标、隐藏危机、阶段反派或阻力、角色状态变化、伏笔回收表。
   - 对千万字目标，默认启用 `memory-protocol.md` 的分层摘要（L0–L5）+ 实体档案 + 章节索引。禁止只靠"一份不断覆盖的前文摘要"撑长篇。

3. **章节生成**
   - 写正文前运行 `lnw assemble-context <N>`（需 shell 权限），输出即为完整写前上下文（9 段）。无 shell 权限时按 `memory-protocol.md` §4 手工加载。
   - 选择提示词按 `references/prompt-workflow.md`。
   - 单章正文只输出正文，除非用户要求分析或拆解。

4. **章节落盘与记忆更新**
   - 正文生成后先跑机械校验（零 LLM）：
     - `lnw check-naming <N>` — grep 禁用变体
     - `lnw check-progression <N>` — 境界单调性
   - 再跑语义校验：按 `memory-protocol.md` §5 双 agent 校验清单。
   - 通过后按固定顺序落盘：
     1. `chapter-NNNN.md`（L0 正文）
     2. `chapter-NNNN.brief.md`（L1，300-500 字，写完即冻结）
     3. `chapter-NNNN.index.md`（YAML 章节索引）
     4. `canon/facts.jsonl` 追加本章约束性事实（含 `known_by`）；ID 用 `lnw next-id fact`
     5. `canon/promises.jsonl` 追加承诺变化；ID 用 `lnw next-id promise`
     6. `canon/progression.jsonl` 追加进阶；ID 用 `lnw next-id prog`
     7. `canon/timeline.md` / `canon/rules.md` 追加更新
     8. 相关实体档案追加「关键节点」+「变更记录」，更新「最后出场」「已知秘密」
     9. `foreshadowing-ledger.md` + `subplots.md` 状态更新；新伏笔 ID 用 `lnw next-id foreshadowing`
   - 到达 chunk/arc/volume 末章时生成对应 L2/L3/L4；卷结束时重生成 L5 `summaries/global.md`。
   - 每 50 章或每卷收尾运行 `lnw snapshot <N> --note "..."` 创建记忆层快照。
   - **禁止回改已冻结的 L1/L2/L3/L4**。事实纠错走 `continuity-issues.md` + canon retraction + 实体档案变更记录。

5. **一致性审校**
   - 对长篇连载，默认进行"设定冲突、角色 OOC、伏笔遗漏、节奏断裂、重复桥段"检查。
   - 如果用户接入外部 RAG API 或知识库，保留外部检索能力；不要把"没有本地向量库"理解为不需要长期记忆。本项目的 `chapter-*.index.md` + 实体档案 + keywords 检索已足够支撑。

## 提示词使用原则

- 原始提示词全文在 `references/prompts/`，先查 `references/prompt-index.md`。
- 旧分支提示词适合完整写作链路：角色、世界观、剧情架构、章节目录、章节正文、摘要、知识库、角色状态、一致性。
- dev 分支提示词适合从一句创意生成结构化小说基础信息。
- 可以组合提示词，但不要机械拼贴。先判断任务层级，再选择最小必要 prompt。
- 用户要求百万/千万字时，优先使用 `references/long-serial-method.md` 的长篇机制，而不是只放大章节数。
- 体裁模式由 `metadata.md` 的 `体裁模式` 字段控制（网文/严肃文学/通用），决定提示词的写作约束分支。网文模式启用爽点密度、打脸循环、章末钩子等专用规则；严肃文学模式保留潜台词、心理深度等要求。
- 摘要类提示词在新协议下的用法：`chapter_brief_prompt` 生成 L1；`chunk/arc/volume/global_summary_prompt` 分别生成 L2-L5；`update_character_state_prompt_v2` 输出落入实体档案「当前状态」段 +「变更记录」追加。

## 输出习惯

用中文回应中文请求。先给可执行结果，再给必要说明。创作时少讲道理，多产出可直接进入作品档案的内容。规划要清晰、有阶段、有回收点；正文要有场景推进、人物行动和情绪压力。
