# 记忆协议

> 所有长篇作品在章节生成前后都按本协议操作。与 `file-contract.md` 配套使用。

## 核心设计

上下文窗口再大也装不下百万/千万字作品。记忆系统不是「把更多内容塞进上下文」，而是「每次写作都能精确取到对的那一小块」。本协议由四部分组成：

1. **分层摘要 + 冻结规则**：防止覆盖式摘要导致早期细节被稀释。
2. **实体中心档案**：按人/地/物/势力/系统建档，支持定向加载。
3. **正典账本**：原子事实 + 世界规则 + 时间线，只追加不修改，支持机器级冲突检测。
4. **写前组装协议 + 写后校验**：把"该读什么、该存什么"从经验主义变成固定流程。

## 一、分层摘要与冻结

```
L0  chapter-NNNN.md              正文原文（最权威，永不修改）
L1  chapter-NNNN.brief.md        单章摘要 300-500 字（写完即冻结）
L2  chunks/chunk-NNNN.md         3-5 章 chunk 摘要 ≤800 字（写定即冻结）
L3  arcs/arc-NNN.md              10-30 章篇章摘要 ≤2000 字（篇章收尾冻结）
L4  volumes/volume-NNN.md        卷摘要 ≤3000 字（卷收尾冻结）
L5  summaries/global.md          全书浓缩摘要 ≤2000 字（卷收尾重生成）
```

### 关键规则

- **只读下层，不改下层**：L2 只读对应章节的 L1；L3 只读 arc 内的 L2；L4 只读卷内的 L3；L5 由所有 L4 聚合。
- **L1 到 L4 一经写定永不修改**。事实变更走 `entities/` 变更记录或 `canon` 追加，不回改旧摘要。
- **L5 允许在卷收尾重生成**，但每次重生成必须把上一版原文归档到 `summaries/global.md` 的「历史版本」段，审计可追。
- 冻结不意味着永远不能修订。发现事实错误时在 `continuity-issues.md` 登记，并在对应实体文件补一条变更记录——而不是回改 L1/L2。

### 生成时机

| 层级 | 触发时机 | 源文件 |
|---|---|---|
| L1 | 章节正文写完立刻生成 | 仅该章 L0 |
| L2 | chunk 内最后一章完成后 | 该 chunk 的 3-5 份 L1 |
| L3 | arc 内最后一章完成后 | 该 arc 的所有 L2 |
| L4 | 卷最后一章完成后 | 该卷的所有 L3 |
| L5 | 每次有新卷 L4 落地后 | 所有 L4 |

## 二、实体中心档案

角色、地点、道具、组织、力量体系每个都有自己的文件（见 file-contract）。档案包含四个区段：

- **正典摘要**：一句话定位，立项或首次登场写定。
- **硬约束**：绝不可违反的设定（天赋、禁忌、语言特征、地理距离等）。
- **关键节点**：追加式时间线，每次涉及该实体的章节都补一条。
- **当前状态**：可随时间更新，但状态变化必须同时在「关键节点」或「变更记录」里留痕。

### 按需加载原则

写某章时不载入所有实体档案，只载入：

- 本章 blueprint `characters_involved` / `key_items` / `scene_location` 命中的实体
- 本章 `foreshadowing` 字段涉及的伏笔对应的实体
- `story-bible.md` 中的硬约束（永远加载）

## 三、正典账本（Canon Ledger）

正典账本是对分层摘要和实体档案的补充，专门解决「叙述性文字无法机器比对」的问题。分层摘要告诉 agent"发生了什么"，实体档案告诉 agent"现在是什么状态"，正典账本告诉 agent"哪些事实绝对不能违反"。

### 三个文件

**`canon/facts.jsonl`** — 原子事实，每行一条断言，只追加不修改。新增 `known_by` 字段记录 POV 知识边界：

```jsonl
{"id":"FACT-0001","chapter":3,"entity":["zhang-san"],"fact":"张三天赋为火系，无法修炼水系功法","source":"测灵石发出赤红光芒"}
{"id":"FACT-0089","chapter":45,"entity":["li-si"],"fact":"李四是天魔教奸细","source":"他撕开衣领，露出天魔教的刺青","known_by":["zhang-san"]}
{"id":"FACT-0089-D","chapter":78,"type":"disclosure","fact_id":"FACT-0089","to":"wang-er","source":"张三将秘密告知了王二"}
```

`known_by` 留空表示公开信息；新角色得知时追加 `type:"disclosure"` 条目。写前加载出场角色档案时，同步过滤该角色的已知事实列表，防止角色使用尚未获得的信息。

**`canon/rules.md`** — 世界规则，追加式，每条带章节来源。发现冲突时在原条目旁加 `⚠️` 标注，不删除原规则。

**`canon/timeline.md`** — 时间线，按故事日（Day N）追加。用于检测事件顺序矛盾。

**`canon/promises.jsonl`** — 角色承诺/誓言/宣言，只追加不修改：

```jsonl
{"id":"PROMISE-0012","chapter":20,"by":"zhang-san","content":"三年内必取天魔殿殿主首级","deadline_day":1500,"status":"pending"}
{"id":"PROMISE-0012-U","chapter":180,"type":"update","promise_id":"PROMISE-0012","status":"fulfilled","source":"他终于站在了殿主的尸身旁"}
```

状态变化追加 `type:"update"` 条目。写前加载「距本章故事时间 ±200 天内到期且 status=pending 的承诺」。

**`canon/progression.jsonl`** — 能力/境界进阶轨迹，只追加不修改：

```jsonl
{"id":"PROG-0001","chapter":1,"entity":"zhang-san","system":"灵气修炼","level":"炼气一层","value":1}
{"id":"PROG-0031","chapter":120,"entity":"zhang-san","system":"灵气修炼","level":"筑基期","value":10}
```

写后校验时检查：新登记的 `value` 是否低于该实体在同一 `system` 下的历史最高值（防止境界倒退）。

### 登记原则

只登记**可能在后续章节被违反的约束性事实**：能力上限、物品归属、人物死亡、关键承诺、地理距离、时间节点。不需要登记所有细节，每条 `fact` ≤100 字，`source` 为 10-50 字原文引用。

### 加载方式

canon 账本**不进写前上下文**（体量随章节数线性增长）。只在写后校验时按 `entity` 过滤后载入，单次过滤结果通常 ≤5k token。

## 四、写前组装协议（Context Assembly Protocol）

写任何一章之前，按此顺序拼接上下文。顺序本身决定优先级：高优先级内容放上下文更靠近生成位置。

1. `metadata.md` + `story-bible.md`（永远加载）
2. 当前 `volumes/volume-NNN.md`（L4）+ 当前 `arcs/arc-NNN.md`（L3）
   - **按实际存在的最高层加载**：L5/L4/L3 生成时机不同步（L3 在每个 arc 末生成，L4 在每个 volume 末生成，L5 在每个 volume 末重生成）。`layered_summary` 槽位按下表拼接存在的段；story-bible 作为长期目标补充。

     | 状态 | 典型章号（卷 1 = 60 章为例）| layered_summary 填充 |
     |---|---|---|
     | 全缺失 | 第 1 章到首个 arc 末前 | `story-bible` 全文 |
     | 仅 L3 | 卷 1 内首个 arc 末后 | L3（最近一份已存在的 arc-NNN.md）+ `story-bible`（story-bible 补卷级以上目标）|
     | L4+L3（无 L5，不存在于本设计）| — | — |
     | L5+L4+L3 | 卷末刚完成所有聚合后的下一个写作轮 | L5 + L4 + L3 |
     | L5+L4（L3 未生成）| 新卷第 1 章到该卷首个 arc 末前 | L5 + L4（最近一份已存在的 volume-NNN.md，即上一卷）+ `story-bible`（story-bible 补 arc 级以下连续性）|
     | L5+L4+L3（新卷内）| 新卷内 arc 末后 | L5 + L4（仍为上一卷，当前卷 L4 要到本卷末才生成）+ L3（稳态）|

     **原则**：只有 L5 没 L4/L3 的情况不会发生（L5 必伴随至少一份 L4）；L4 必定比 L3 早生成（volume 末同时产出两者，L3 先生成）；L5 必定在 L4 之后生成。其他未列组合实际无法通过落盘流程产生。
3. 当前章节 blueprint + 下一章 blueprint；同时读取最近 10 章 `index.md` 的 `scene_types` 和 `emotional_tone`，检查：
   - 若同一 `scene_type` 连续出现 ≥4 章，提示本章应切换场景类型
   - 若 `tension` 连续 5 章 ≥7 或连续 5 章 ≤3，提示节奏需要调整
4. 最近 3-5 章的 **L1 brief**
5. **上一章结尾段原文**（500-1000 字，用于文风与节奏衔接，不是整章）
   - **第 1 章例外**：没有上一章，本步跳过。第 1 章使用 `first_chapter_draft_prompt_v2`，其槽位中无 `previous_chapter_excerpt`。
6. 出场实体档案（按需加载）+ 各出场角色的「已知秘密」列表（从 `canon/facts.jsonl` 按 `known_by` 过滤）+ `dialogue-samples/<slug>.md`（出场主要角色的台词样本，作为对话语气参考）
   - **前期过渡**：某角色尚未有台词样本积累（通常首次登场章）时，该角色的 `dialogue_samples` 槽位填「首次登场，无历史样本」。
7. `foreshadowing-ledger.md` 中所有 `状态=待回收` 或 `状态=强化中` 的条目
8. `continuity-issues.md` 的「禁用桥段」与「待修复」段 + `subplots.md` 中距上次推进超过 20 章的活跃副线 + `canon/promises.jsonl` 中距本章故事时间 ±200 天内到期且 status=pending 的承诺
9. 按章节 blueprint 的 keywords 在 `chapter-*.index.md` 中反查 top 3-5 相关章节，只载入其 L1 brief

以上 9 项通常能压到 50k-150k token，远低于 1M 上限，但每一项都对本章有直接价值。

> 如果作品体量小（≤30 章）或是短篇，可以退化为：story-bible + 全部 L1 + 出场角色档案。

### 运行时规则（操作细节）

- **故事日（`story_day`）推导**：第 1 章默认 Day 001；后续章节由 blueprint 的「时间压力」字段或上一章 `index.md` 的 `time` 字段推算。agent 在生成 L1 brief 时必须明确填入 `时间：Day N`。
- **arc / chunk 编号**：立项时在 `blueprints/chapters.md` 中为每章标注 `volume/arc/chunk` 归属（见 file-contract 立项 checklist 第 5 步）。写章节 `index.md` 时直接读取 blueprint 的标注，不允许写作时临时决定。
- **chunk/arc/volume 末章判断**：落盘步骤 11 需要判断当前章是否为某层级的末章。规则：读 `blueprints/chapters.md` 中**当前章**和**下一章**的编号标注，若下一章的 chunk/arc/volume 编号与当前章不同，则当前章是该层级的末章。最后一章（全书末章）必定是所有层级的末章。
- **arc 内 chunk 反查**：生成 L3 时需要拼接该 arc 内所有 L2。方法：在 `blueprints/chapters.md` 中找出所有 `arc=NNN` 的章节，提取其中出现的不重复 chunk 编号，读取对应 `chunks/chunk-NNNN.md` 文件。volume 内 arc 反查同理。
- **ID 分配（FACT / PROMISE / PROG / F / SUB）**：agent 手工分配时，先 grep 对应文件的最大 ID，在其基础上 +1。有 `lnw` 工具时使用 `lnw next-id <type>`。
- **实体档案「关键节点」追加**：由 agent 在落盘步骤 9 中根据本章正文手工添加一行 `- 第 N 章：<事件简述>`。「变更记录」段由 `update_character_state_prompt_v2` 输出负责。
- **`novel_setting` 槽位的数据源**：`story-bible.md` 全文 + `metadata.md` 的「类型/基调/目标读者/单章字数/体裁模式」字段拼接。

## 五、写后校验与落盘顺序

章节正文生成后，**不要直接落盘**。完整处理分三阶段：

- **阶段 A（准备）**：agent 把本章所有附属产物准备好（L1 brief、新 facts、实体更新、伏笔识别、副线推进、index 草稿），**全部暂存内存不落盘**。具体 prompt 与步骤见 `prompt-workflow.md` 的「章节生成后处理」段。
- **阶段 B（校验）**：用阶段 A 的草稿作为输入，跑本节的 8 项校验清单。
- **阶段 C（落盘）**：通过后按本节末尾的 11 步顺序真正写文件。

### 双 agent 校验模式

写正文的 agent 对自己刚写的内容有惯性认同，容易把矛盾合理化。推荐用独立的干净上下文执行校验：

**环境支持 subagent 时**（Kiro、Claude Code、Codex 等）：
将校验任务委托给独立 subagent，只传入以下内容，不传入写作上下文：
- 本章正文
- 本章 `index.md`（entity 列表、plot_beats）
- 过滤后的 `canon/facts.jsonl`（按 entity 过滤）
- `canon/progression.jsonl`（按 entity 过滤）
- `canon/promises.jsonl`（status=pending 的条目）
- 出场角色的实体档案（硬约束段）
- `naming.md`
- 最近 20 章的 `plot_beats`（从各章 index.md 提取）
- `foreshadowing-ledger.md`（活跃条目）

使用提示词：`references/prompts/consistency-check-prompt.md`

**环境不支持 subagent 时**：
> ⚠️ 当前环境不支持独立 subagent。建议手动切换到新的对话窗口，粘贴以下内容后运行校验提示词（见 `references/prompts/consistency-check-prompt.md`）：
> 1. 本章正文全文
> 2. 本章 index.md
> 3. 相关 canon 条目（按 entity 过滤后的 facts/progression/promises）
> 4. 出场角色硬约束
> 5. naming.md
> 6. 最近 20 章 plot_beats 列表

### 校验清单（8 项）

1. **正典冲突检测**：提取本章 `index.md` 的 `entity` 列表，在 `canon/facts.jsonl` 里过滤相关条目，逐条比对本章内容是否违反已登记事实。
2. **POV 知识边界**：出场角色是否使用了其 `known_by` 列表中尚未获得的信息？
3. **硬约束检查**：出场实体的行为是否违背其「硬约束」段？
4. **进阶合法性**：本章涉及的境界/能力变化是否与 `canon/progression.jsonl` 中的历史最高值冲突（新值不得低于旧值）？
5. **命名一致性**：grep 本章正文，扫到 `naming.md` 「禁用变体」列中的词直接报错。
6. **桥段重复 + 伏笔对齐**：本章 `plot_beats` 是否与最近 20 章重复？埋设/回收的伏笔是否都有对应 ID？
7. **填写 `scene_types` 和 `emotional_tone`**：为本章 `index.md` 打分，供后续章节的节奏检查使用。
8. **更新 `dialogue-samples/<slug>.md`**：从本章正文中摘取出场主要角色最具代表性的 1 条台词，替换掉该文件中最旧的一条，保持滚动 5 条。

任一项不通过：改写正文，或在 `continuity-issues.md` 登记为已知问题后再落盘。

### 校验失败修复子流程

校验报告标记"需修复"时：

1. **判断问题类型**：
   - **轻微问题**（命名不一致、单句知识边界违反、单处桥段撞车）→ 走 `fix_chapter_prompt` 局部修复
   - **严重问题**（主线事件违反硬约束、进阶回退、关键伏笔遗漏）→ 重写本章（回到第 3 步 `next_chapter_draft_prompt_v2`，在 `user_guidance` 槽位追加校验报告）
   - **无法修复**（设定根本冲突、blueprint 本身有问题）→ 在 `continuity-issues.md` 登记为已知问题；若影响后续章节，调整 blueprint 后再续写

2. **`fix_chapter_prompt` 输入**：原正文 + 校验报告 + 相关实体硬约束 + 相关 canon 条目 + naming.md。

3. **修复后**：重新跑完整校验清单。最多尝试 2 次局部修复，仍不通过则走重写或登记已知问题。

4. **正典错误**：若校验发现的是"正典本身错误"（旧 FACT 错了），走 `canon retraction` 流程——追加 `FACT-XXXX-R` 条目，不修改原条目，同时在 `continuity-issues.md` 登记。

### 落盘顺序（阶段 C，通过校验后）

1. 写 `chapter-NNNN.md`（L0 正文）
2. 写 `chapter-NNNN.brief.md`(L1，冻结）
3. 写 `chapter-NNNN.index.md`（索引）
4. **追加 `canon/facts.jsonl`**：本章新增的约束性事实（含 `known_by` 字段）
5. **追加 `canon/promises.jsonl`**：本章新增或状态变化的承诺
6. **追加 `canon/progression.jsonl`**：本章发生的境界/能力进阶
7. **追加 `canon/timeline.md` + 追加/更新 `canon/rules.md`**：本章时间线事件 + 确立或违反的世界规则
8. 追加实体档案的「关键节点」与「变更记录」（引用 FACT ID）；更新「当前状态」中的「最后出场」与「已知秘密」
9. 更新 `foreshadowing-ledger.md` 状态；更新 `subplots.md` 中本章推进的副线
10. **更新 `dialogue-samples/<slug>.md`**：从本章正文中摘取出场主要角色最具代表性的 1 条台词，替换掉该文件中最旧的一条，保持滚动 5 条；首次登场角色建新文件
11. 若当前章节是 chunk/arc/volume 的末章：按顺序 chunk → arc → volume → global 生成对应 L2/L3/L4/L5
12. **快照触发检查**：若当前章是 50 的整数倍或 volume 末，执行快照（见 §九）
13. **全书末章额外检查**（仅最后一章）：扫描 `foreshadowing-ledger.md` 中所有 `状态=待回收` 或 `状态=强化中` 的条目，输出「未回收伏笔清单」。agent 需逐条判断：(a) 有意留白（标注为「开放式结局」）；(b) 遗漏（需在本章或前几章补回收）；(c) 续作伏笔（标注为「续作预留」）。判断结果追加到 `foreshadowing-ledger.md` 末尾的「完结审计」段。

## 六、Token 预算参考

| 项目 | 典型占用 | 备注 |
|---|---|---|
| story-bible.md | 3k-5k | 固定 |
| 当前 volume + arc 摘要 | 3k-5k | 固定 |
| 当前章 + 下章 blueprint | 1k | 固定 |
| 最近 5 章 L1 | 3k | 5 × 500 字 |
| 上一章结尾段原文 | 1k-2k | |
| 出场实体档案（5 个） | 5k-10k | |
| 活跃伏笔 | 2k-5k | |
| 检索回的相关 L1 (top 5) | 3k | |
| 写作指令与提示词 | 2k | |
| **合计** | **~25k-40k** | 单章正文另计 |

1M 上下文对这种用量是极度宽裕的。预算用不满，就把更多 L2 / 变更记录拉进来；接近 80% 预算时，先砍检索命中的 L1、再砍非出场实体，不砍 story-bible / 活跃伏笔 / 出场实体。

canon 账本不进写前上下文，只在写后校验时按 entity 过滤后载入，单次过滤结果通常 ≤5k token。

## 七、与原提示词的对接

- `summarize_recent_chapters_prompt` → 用来生成 **L1 brief**，输出落入 `chapter-NNNN.brief.md`，落盘后冻结。
- `summary_prompt` → **不再** 用于逐章覆盖式更新，改为 **L3/L4 生成**（arc/volume 收尾时）以及 **L5 重生成**（卷收尾聚合）。输入改为对应下层摘要的拼接。
- `update_character_state_prompt` → 输出落入对应 `entities/characters/<slug>.md` 的「当前状态」段，同时要求模型另行输出一段「变更记录」追加到文件末尾。
- `create_character_state_prompt` → 首次为某角色建档时使用，直接生成 `entities/characters/<slug>.md` 骨架。
- `knowledge_search_prompt` / `knowledge_filter_prompt` → 在写前组装协议第 9 步使用，检索目标是 `chapter-*.index.md` 与实体档案。
- 写后校验 → 按本协议 §5 的 4 项清单内联到校验任务提示里（若 prompt 库中存在 `CONSISTENCY_PROMPT` 则直接调用）。

## 八、迁移与退化

- **用户已有作品但完全无记忆结构**（最常见的接入场景）：走 `references/file-contract.md` 的「导入既有作品 checklist」（13 步），使用 `reverse_story_bible_prompt` / `extract_entities_prompt` / `import_entity_prompt` / `canon_backfill_prompt` 等导入专用 prompt。
- 已有作品若按**旧扁平结构**写了一部分（本 SKILL 早期版本的产物）：保留旧文件不动，从下一个 chunk 起按本协议建 `entities/` / `chapters/*/brief` / `*.index.md` / `canon/`，L5 在下次卷收尾时统一重生成。
- 作品不到 30 章时可以简化：L2/L3/L4 合并为单一「阶段摘要」，实体档案合并为一份 `characters.md`，但 **L1 冻结、章节索引、canon 账本仍要维护**。


## 九、记忆快照与分叉写作

### 快照触发时机

每 50 章落盘后，或每个卷收尾后（取先到者），对记忆层做一次快照。触发检查在 §5 落盘顺序第 12 步执行。

### 快照内容（手工操作，dev 分支）

只复制记忆层，不复制正文（正文体量大，git 历史可追溯）：

```bash
# 在作品根目录执行
CHAPTER=50  # 当前章号
SNAP=snapshots/ch-$(printf "%04d" $CHAPTER)
mkdir -p $SNAP

# 复制目录（使用 -r，保持结构）
cp -r entities canon summaries blueprints settings $SNAP/
[ -d dialogue-samples ] && cp -r dialogue-samples $SNAP/
[ -d volumes ] && cp -r volumes $SNAP/
[ -d arcs ] && cp -r arcs $SNAP/
[ -d chunks ] && cp -r chunks $SNAP/

# 复制单文件
cp foreshadowing-ledger.md subplots.md naming.md continuity-issues.md $SNAP/
cp story-bible.md metadata.md $SNAP/

# 写 snapshot-meta
cat > $SNAP/snapshot-meta.md <<EOF
# Snapshot $SNAP

- 触发章节：第 $CHAPTER 章
- 触发时间（实际）：$(date -Iseconds)
- 当前卷：（从 blueprints 查）
- 当前故事日：（从 timeline.md 末尾读）
- 备注：（可选）
EOF
```

### 快照内容（dev-tools 分支有 CLI）

```bash
lnw snapshot 50 --note "卷一收尾"
```

### 回滚

出现严重设定冲突需要回退时：

1. 选定目标快照 `snapshots/ch-NNNN/`
2. 把快照内的各目录/文件覆盖回作品根目录：`cp -r snapshots/ch-NNNN/* ./`（注意会覆盖现有文件）
3. 正文回退走 git：`git checkout ch-NNNN -- chapters/`（需提前打 git tag 或记录 commit hash）
4. 从被回滚的章节重新续写

### 分叉写作

想探索"如果当时选了另一条路"：

1. 新建目录 `novel-title-branch-A/`
2. 把目标快照复制进去作为记忆层起点
3. 把分叉点之前的正文章节也复制过去
4. 在新目录里独立续写，两条线互不干扰

分叉目录是完全独立的作品目录，本协议的所有规则同样适用。
