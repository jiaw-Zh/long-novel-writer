---
name: long-novel-writer
description: 当用户需要写长篇小说、扩展小说创意、构建小说架构、生成正文章节或进行章节定稿更新时使用。此技能提供了一套完整的五阶段工作流，通过外部文档驱动状态机的方式，保障百万/千万级别小说的连贯性。
---

# 长篇小说写作器

## 核心定位

按"架构先行、分卷推进、状态驱动、检索校验"的方式创作百万至千万字级别小说。

**禁止**一次性生成整部长篇正文。每次只推进一个明确层级：整书架构、卷规划、3-5 章小单元、单章正文、记忆更新、修订审校。

## 铁律

```
没有通过 verification 的章节，禁止写入磁盘。没有例外。
没有完成 9 步 pre-writing assembly 的章节，禁止开始写正文。没有例外。
已冻结的 L1-L4 摘要，禁止修改。没有例外。
```

**违反信条等于违反精神。** 不要想"我虽然跳了第 3 步但结果是对的"。流程存在的原因是：你无法在写的时候知道跳过会导致什么后果。99 次侥幸 = 1 次灾难性连贯性崩塌。

---

## 违规前兆 — 立即停止

当你发现自己有以下任何想法时，**立即停止当前操作**，回到正确流程：

- "这个章节很简单，不需要完整 assembly"
- "我已经记住上下文了，不需要加载文件"
- "verification 太慢了，先 landing 再说"
- "字数差不多就行"
- "这个 foreshadowing 以后再回收"
- "用户催得急，跳过步骤赶进度"
- "这次情况特殊"
- "改一下旧摘要也没关系"
- "先写正文再补 blueprint"
- "不需要独立 subagent 验证，我自己检查就行"

---

## 常见违规借口

| 借口 | 现实 |
|------|------|
| "这个章节很简单，不需要完整 assembly" | 简单章节也会产生连贯性错误。Assembly 是机械流程，不是可选项。 |
| "我已经记住上下文了，不需要加载文件" | 文件状态才是真相，对话记忆不可靠。**加载文件。** |
| "verification 太慢了，先 landing 再说" | Landing 后发现错误 = 回滚成本 ×10。**先验证。** |
| "字数差不多就行" | 字数门是硬指标。差 1% 也要修正。 |
| "这个 foreshadowing 以后再回收" | 20 章不回收 = 遗忘。**现在就更新 ledger。** |
| "用户催得急，跳过步骤赶进度" | 跳过步骤 = 后续返工 = 更慢。**按流程走。** |
| "这次情况特殊" | 没有特殊情况。流程没有例外。 |
| "改一下旧摘要也没关系" | 冻结层是架构基石。改摘要 = 全链路信任崩塌。 |
| "不需要独立验证" | 自己验证自己的作品 = 无效验证。 |
| "先写正文再补 blueprint" | 没有 blueprint 的正文 = 失控的叙事。先规划。 |

---

## 工作流

### 阶段 1：作品初始化

<HARD-GATE>
在 `story-bible.md` 创建并确认之前，禁止进入阶段 2（百万字架构）。
</HARD-GATE>

**重要：使用 TodoWrite 为以下每个步骤创建 todo 项。**

- 读取或创建作品目录时，先看 `references/file-contract.md`（文件布局 + 立项 checklist + 导入 checklist）与 `references/memory-protocol.md`（记忆协议）。
- **场景分支**：
  - 用户只有一句创意 → 走 dev 分支的"AI 创建小说"链路：扩展创意 → 提炼构思 → 故事核心 → 小说整体设定；然后走「立项 checklist」。
  - 用户已有设定（无正文）→ 直接走「立项 checklist」：metadata → 设定正典 → 实体档案 → 网文额外项 → 章节目录 → 空壳文件。
  - **用户已有正文但无记忆结构 → 走「导入既有作品 checklist」（13 步）**，用 `reverse_story_bible_prompt` / `extract_entities_prompt` / `canon_backfill_prompt` 等反推记忆层，然后从 N+1 章继续写。
- `story-bible.md` 立项/导入时即写定并视为冻结基线，后续修订必须追加「变更记录」。

### 阶段 2：百万字架构

<HARD-GATE>
在卷/篇章/chunk/单章的层级拆分完成之前，禁止生成任何章节正文。
</HARD-GATE>

- 将故事拆成：整书主线 -> 卷 -> 篇章单元 -> 3-5 章 chunk -> 单章。
- 每卷必须有显性目标、隐藏危机、阶段反派或阻力、角色状态变化、伏笔回收表。
- 对千万字目标，**必须**启用 `memory-protocol.md` 的分层摘要（L0–L5）+ 实体档案 + 章节索引。**禁止**只靠"一份不断覆盖的前文摘要"撑长篇。

### 阶段 3：章节生成

<HARD-GATE>
在 9 步 pre-writing assembly 全部完成之前，禁止开始写章节正文。
在 post-writing verification 通过之前，禁止执行 landing 步骤。
</HARD-GATE>

#### 写前门函数

在开始写任何章节正文之前，**必须**执行以下结构化检查：

```
BEFORE 写章节正文:
  1. 读取 chapter-NNNN.blueprint.md → 是否存在？
     - NO → STOP，先生成 blueprint
  2. 执行 pre-writing assembly 9 步 → 全部完成？
     - NO → STOP，完成缺失步骤
  3. 检查上一章结尾段落 → 已加载？
     - NO → STOP，加载 chapter-(N-1).md 最后 500-1000 字
  4. 检查 foreshadowing ledger → 有 pending recovery 项？
     - YES → 标记本章需回收的项
  5. 检查最近 10 章 scene_types 和 emotional_tone → 有节奏问题？
     - YES → 调整本章 blueprint
  6. ONLY THEN → 开始写正文
```

#### 写前组装（9 步）

**重要：使用 TodoWrite 为以下每个步骤创建 todo 项。**

1. 加载 `metadata.md` + `story-bible.md`（始终加载）
2. 加载当前 volume (L4) + 当前 arc (L3)（缺失时按 `memory-protocol.md` 降级表处理）
3. 加载当前 + 下一章 blueprint；检查最近 10 章的 `scene_types` 和 `emotional_tone` 发现节奏问题
4. 加载最近 3-5 章 L1 briefs
5. 加载上一章结尾段落（500-1000 字原文）
6. 加载出场实体档案 + 每个出场角色的「已知秘密」列表 + 对话样本
7. 加载 foreshadowing ledger：所有 status 为 "pending recovery" 或 "strengthening" 的条目
8. 加载 `continuity-issues.md` 禁用桥段 + 20+ 章未推进 subplot + 故事日内到期承诺
9. 关键词反查 `chapter-*.index.md`，加载 top 3-5 相关章节的 L1 briefs

- 典型总量：50k-150k tokens，远低于 1M 限制。

#### 正文生成

- 选择提示词按 `references/prompt-workflow.md`。第一章用 `first_chapter_draft_prompt_v2`，后续章节用 `next_chapter_draft_prompt_v2`。
- 单章正文只输出正文，除非用户要求分析或拆解。

### 阶段 4：章节落盘与记忆更新

<HARD-GATE>
在 verification 完成并通过之前，禁止执行任何 landing 文件写入操作。
</HARD-GATE>

#### 写后门函数

在执行任何 landing 操作之前，**必须**执行以下结构化检查：

```
BEFORE landing 任何文件:
  1. 字数门检查 → 在 [word_min, word_max] 区间内？
     - NO, 偏短 → 执行 enrich_prompt_v2（最多 2 次）
     - NO, 偏长 → 执行 condense_prompt_v2（最多 2 次）
     - NO, 偏离 >30% → 重写
  2. 正典冲突检测 → 通过？
     - NO → 修复或注册到 continuity-issues.md
  3. POV 知识边界 → 通过？
     - NO → 修正角色知识
  4. 硬约束检查 → 通过？
     - NO → 修正违规内容
  5. 进阶单调度 → 通过？
     - NO → 修正进阶数据
  6. 命名一致性 → 通过？
     - NO → 修正命名
  7. 桥段重复 + 伏笔对齐 → 通过？
     - NO → 修正
  8. ALL PASS → 执行 landing
```

#### 写后校验流程

**必须**使用独立 subagent 或新对话窗口进行验证。自己验证自己的作品 = 无效验证。

正文生成后先跑 `memory-protocol.md` §5「写后校验闭环」：
- **Gate 0：字数门**（机械检查 `[word_min, word_max]`，偏短调 `enrich_prompt_v2`、偏长调 `condense_prompt_v2`、偏离 >30% 直接重写，最多 2 次扩缩写）
- **Gate 1-6：语义检查**：正典冲突检测、POV 知识边界、硬约束违背、进阶单调度、命名一致性、桥段重复 + 伏笔账本对齐

#### 落盘顺序（13 步）

**重要：使用 TodoWrite 为以下每个步骤创建 todo 项。必须严格按顺序执行。**

1. `chapter-NNNN.md`（L0 正文）
2. `chapter-NNNN.brief.md`（L1，300-500 字，写完即冻结）
3. `chapter-NNNN.index.md`（YAML 章节索引）
4. `canon/facts.jsonl` 追加本章约束性事实（含 `known_by`）
5. `canon/promises.jsonl` 追加本章承诺/誓言变化
6. `canon/progression.jsonl` 追加本章境界/能力进阶
7. `canon/timeline.md` / `canon/rules.md` 追加更新
8. 相关实体档案追加「关键节点」+「变更记录」，更新「最后出场」「已知秘密」
9. `foreshadowing-ledger.md` + `subplots.md` 状态更新
10. `dialogue-samples/<slug>.md` 更新（滚动保留 5 条）
11. 到达 chunk/arc/volume 末章时，生成对应 L2/L3/L4/L5 摘要
12. 快照触发检查（每 50 章或卷末）
13. 全书末章：扫描所有未回收伏笔，输出「未回收伏笔清单」

**禁止回改已冻结的 L1/L2/L3/L4。** 事实纠错走 `continuity-issues.md` + canon retraction 条目（`FACT-XXXX-R`）+ 实体档案变更记录。

### 阶段 5：一致性审校

- 对长篇连载，**必须**进行"设定冲突、角色 OOC、伏笔遗漏、节奏断裂、重复桥段"检查。
- 如果用户接入外部 RAG API 或知识库，保留外部检索能力；不要把"没有本地向量库"理解为不需要长期记忆。本项目的 `chapter-*.index.md` + 实体档案 + keywords 检索已足够支撑。

---

## 提示词使用原则

- 原始提示词全文在 `references/prompts/`，先查 `references/prompt-index.md`。
- 旧分支提示词适合完整写作链路：角色、世界观、剧情架构、章节目录、章节正文、摘要、知识库、角色状态、一致性。
- dev 分支提示词适合从一句创意生成结构化小说基础信息。
- 可以组合提示词，但不要机械拼贴。先判断任务层级，再选择最小必要 prompt。
- 用户要求百万/千万字时，优先使用 `references/long-serial-method.md` 的长篇机制，而不是只放大章节数。
- 本技能默认且固定使用网文创作规范，启用爽点密度、打脸循环、章末钩子等专用规则，不支持严肃文学或通用等其他体裁。
- 摘要类提示词在新协议下的用法：`chapter_brief_prompt` 生成 L1；`chunk/arc/volume/global_summary_prompt` 分别生成 L2-L5；`update_character_state_prompt_v2` 输出落入实体档案「当前状态」段 +「变更记录」追加。

## 输出习惯

用中文回应中文请求。先给可执行结果，再给必要说明。创作时少讲道理，多产出可直接进入作品档案的内容。规划要清晰、有阶段、有回收点；正文要有场景推进、人物行动和情绪压力。
