# 作品文件契约

> 本契约服务于百万/千万字长篇。核心原则：**实体中心存档 + 分层摘要冻结 + 章节索引 + 正典账本**。
> 分层摘要与写前组装协议见 `references/memory-protocol.md`，本契约只规定文件位置与字段。

## 目录结构

```text
novel-title/
  metadata.md                       # 元信息（固定）
  story-bible.md                    # 设定正典（核心种子/终局/世界观/视角，冻结）
  continuity-issues.md              # 冲突与禁用项

  settings/
    core-seed.md                    # 核心种子（core_seed_prompt 输出）
    character-dynamics.md           # 角色动力学（character_dynamics_prompt 输出）
    world-building.md               # 世界观（world_building_prompt 输出）
    plot-architecture.md            # 情节架构（plot_architecture_prompt 输出）
    golden-finger.md                # 网文模式金手指设计（golden_finger_design_prompt 输出）

  blueprints/
    chapters.md                     # 分章节 blueprint（chapter_blueprint_prompt_v2 输出）
    opening-three.md                # 网文模式开篇三章大纲（opening_three_chapters_prompt 输出）

  summaries/
    global.md                       # L5 全书摘要（卷结束时重生成）

  volumes/
    volume-001.md                   # L4 卷摘要（卷结束时冻结）
  arcs/
    arc-001.md                      # L3 篇章摘要（10-30 章，冻结）
  chunks/
    chunk-0001.md                   # L2 chunk 摘要（3-5 章，冻结）

  chapters/
    volume-001/
      chapter-0001.md               # L0 正文
      chapter-0001.brief.md         # L1 单章摘要（300-500 字，冻结）
      chapter-0001.index.md         # 章节索引（YAML frontmatter）

  entities/
    characters/*.md                 # 每个主要/常驻角色一份
    locations/*.md                  # 关键地点
    items/*.md                      # 关键道具/宝物
    organizations/*.md              # 势力/门派/组织
    systems/*.md                    # 力量体系/科技体系

  dialogue-samples/
    <slug>.md                       # 每个主要角色一份，滚动保留最近5条台词样本

  snapshots/
    ch-0050/                        # 第50章落盘后的记忆层快照
      entities/
      canon/
      summaries/
      dialogue-samples/
      foreshadowing-ledger.md
      subplots.md
      naming.md
      snapshot-meta.md              # 快照元信息

  canon/
    facts.jsonl                     # 原子事实账本（只追加）
    rules.md                        # 世界规则（追加式，冲突高亮）
    timeline.md                     # 时间线事件（按 Day 编号追加）
    promises.jsonl                  # 承诺/誓言/宣言账本（只追加）
    progression.jsonl               # 能力/境界进阶轨迹（只追加）

  naming.md                         # 标准名称表（规范写法 + 禁用变体）

  foreshadowing-ledger.md           # 伏笔账本（含原文引用）
```

## Agent 操作规则

- 作品状态以文件为准，不以对话记忆为准。
- 写作前按 `memory-protocol.md` 的「写前组装协议」选择性加载文件，不做全量读取。
- 缺失文件按本契约最小结构自动创建，不等用户手动建目录。
- **分层摘要一经写入即冻结**：L1 不因后续章节被重写，L2 只读 L1 生成，依此类推。
- **实体档案按时间线追加**，不覆盖既有事实；人物/设定修订必须在文件内显式标注前后差异。
- **正典账本只追加不修改**：发现事实错误时在 `continuity-issues.md` 登记，并追加一条 `retraction` 条目，不删除原条目。
- 章节文件只放正文，分析与元数据放 `.brief.md` / `.index.md`。

## 命名与编号规则（硬约束）

### 实体 slug
- 中文名：全拼音 kebab-case，如"陆无涯"→`lu-wu-ya`、"青云剑宗"→`qing-yun-jian-zong`
- 英文名：全小写 kebab-case，如"Vincent Lee"→`vincent-lee`
- 标点、空格、特殊符号一律转为 `-`，连续 `-` 合并为单个
- 同音字手工加数字区分：`li-ming-1` / `li-ming-2`
- slug 一经写入 `naming.md` 即冻结，不允许更名。需要改名时在 `naming.md` 标注 `旧 slug → 新 slug`，但旧 slug 的文件保留且硬链接到新位置。

### 编号位数（全项目统一）
| 项 | 位数 | 示例 |
|---|---|---|
| volume | 3 位 | `volume=001`、`volumes/volume-001.md` |
| arc | 3 位 | `arc=001`、`arcs/arc-001.md` |
| chunk | 4 位 | `chunk=0001`、`chunks/chunk-0001.md` |
| chapter | 4 位 | `chapter-0001.md` |
| FACT ID | 4 位 | `FACT-0001` |
| PROMISE ID | 4 位 | `PROMISE-0001` |
| PROG ID | 4 位 | `PROG-0001` |
| F（伏笔）ID | 3 位 | `F-001` |
| SUB（副线）ID | 3 位 | `SUB-001` |

blueprint 标注章节归属时使用同样位数：`所属单元：volume=001 arc=001 chunk=0001`。

### 边界对齐规则（blueprint 阶段强制）
- chunk 每 3-5 章，**不允许跨 arc**
- arc 每 10-30 章，**不允许跨 volume**
- volume 末必定同时是 arc 末 + chunk 末
- arc 末必定是 chunk 末
- 生成 blueprint 时若某 arc 末 chunk 不足 3 章，将该 chunk 归并到前一 chunk（前一 chunk 可扩至 6 章，超出则重新分块）

## 立项 checklist（新作品初始化顺序）

按此顺序生成文件，后一步可能依赖前一步的输出：

**1. 元信息与创意扩展**
- 用户只给一句话时：`dev-prompt_default.yaml` 的 4 个 prompt 链路（expand → extract → core_seed → novel_meta），输出汇总到 `metadata.md`。
- 用户已有设定时：直接让用户/agent 填 `metadata.md`。

**2. 设定正典**
| 产出 | Prompt | 输入 |
|---|---|---|
| `settings/core-seed.md` | `core_seed_prompt` | metadata |
| `settings/character-dynamics.md` | `character_dynamics_prompt` | core_seed |
| `settings/world-building.md` | `world_building_prompt` | core_seed |
| `settings/plot-architecture.md` | `plot_architecture_prompt` | core_seed + character_dynamics + world_building |
| `story-bible.md` | `compile_story_bible_prompt` | 上述四份 + metadata |

**3. 实体档案**
| 产出 | Prompt | 槽位填充 |
|---|---|---|
| `entities/characters/*.md` | `create_character_state_prompt_v2` | `genre_constraints` 按体裁填 `GENRE_CONSTRAINTS_*` |
| `entities/locations/*.md` | `create_entity_prompt` | `entity_type=locations`, `entity_type_constraints=ENTITY_CONSTRAINTS_LOCATIONS`, `entity_type_state_fields=ENTITY_STATE_LOCATIONS` |
| `entities/items/*.md` | `create_entity_prompt` | `entity_type=items`, 对应 `ENTITY_CONSTRAINTS_ITEMS` / `ENTITY_STATE_ITEMS` |
| `entities/organizations/*.md` | `create_entity_prompt` | `entity_type=organizations`, 对应 `ENTITY_CONSTRAINTS_ORGANIZATIONS` / `ENTITY_STATE_ORGANIZATIONS` |
| `entities/systems/*.md` | `create_entity_prompt` | `entity_type=systems`, 对应 `ENTITY_CONSTRAINTS_SYSTEMS` / `ENTITY_STATE_SYSTEMS` |

**4. 网文模式额外项**（体裁模式=网文 时）
| 产出 | Prompt |
|---|---|
| `settings/golden-finger.md` | `golden_finger_design_prompt` |
| `blueprints/opening-three.md` | `opening_three_chapters_prompt` |

**5. 章节目录**
- 产出：`blueprints/chapters.md`
- Prompt：`chapter_blueprint_prompt_v2`（≤100 章）或分批用 `chunked_chapter_blueprint_prompt_v2`（>100 章，每批 50 章）
- blueprint 中每章必须标注 `volume=N arc=N chunk=N`（chunk 每3-5章，arc 每10-30章，volume 按 metadata 的「单卷章数」）

**6. 空壳文件与 naming 初始化**
- `canon/facts.jsonl` / `promises.jsonl` / `progression.jsonl`：空文件
- `canon/rules.md` / `timeline.md`：仅标题
- **`naming.md`**：用 `compile_naming_prompt` 从 character-dynamics + world-building + golden-finger 提取所有已命名实体，生成规范写法 + slug + 初始禁用变体
- `foreshadowing-ledger.md`：仅表头
- `subplots.md`：仅表头
- `continuity-issues.md`：仅三个子标题（「禁用桥段」/「待修复」/「已登记的已知问题」）
- `dialogue-samples/`：目录存在但无文件（首次登场章节生成时才建）

立项完成后即可开始写第 1 章。

## 导入既有作品 checklist

用户已有正文（通常几万到几十万字）但没有本 SKILL 的记忆结构时，走这条路径，而非"新作品立项"。目标：把现有作品接入记忆系统，使后续章节能享受全部校验与长程记忆能力。

**前置条件**
- 用户提供所有现有正文（章节边界清晰，或能按用户/agent 商定的规则切分）
- 用户能口述或填写基础元信息（类型/基调/体裁模式/目标字数）

**执行顺序**

**1. 切分章节文件**
- 若用户已按章分文件：移动到 `chapters/volume-001/chapter-NNNN.md`（若目前还没分卷，先假设全部在 volume=001，等第 7 步再重新划卷）
- 若是一整份文本：与用户确认分章规则，或让 agent 按章节标题/分隔符自动切

**2. 粗填 metadata.md**
- 用户直接填：`类型 / 基调 / 目标读者 / 单章字数 / 体裁模式`
- `目标字数` 可先填「已有 + 计划新增」估值
- `单卷章数` 先留空，第 7 步确定

**3. 生成全部 L1 brief（必须全量）**
- 对每章跑 `chapter_brief_prompt`，输入：章节正文 + 章号 + 标题（无则由 agent 起）
- 产出：`chapter-NNNN.brief.md`
- 所有 L1 即时冻结，作为后续反推的唯一真实源

**4. 反推 story-bible.md**
- 用 `reverse_story_bible_prompt`，输入：metadata 粗稿 + 全部 L1 briefs 拼接 + 代表性原文段（开篇 + 每 arc 末高潮章 + 最新章）
- 直接产出 `story-bible.md`（跳过 settings/ 下四份文件，导入场景不需要）
- 若用户后续要修订 story-bible，按常规"追加变更记录"规则

**5. 提取实体清单**
- 用 `extract_entities_prompt`，输入：全部 L1 briefs 拼接
- 产出：分类（角色/地点/道具/组织/体系）的实体表，含推荐 slug + 重要度
- 用户审核并勾选「必建 + 建议建」的条目；「可选」按需

**6. 生成实体档案**
- 角色：对每个角色跑 `Character_Import_Prompt_v2`，`{content}` 填该角色出场章节的原文合集
- 其他实体：对每个跑 `import_entity_prompt`，`{source_text}` 填相关章节原文合集，按类型填 `entity_type` + `entity_type_constraints` + `entity_type_state_fields`
- 产出：`entities/characters/*.md` / `entities/locations/*.md` / 等

**7. 回填 volume/arc/chunk 边界**
- agent 根据全部 L1 briefs 识别情节节奏，按 `chunk 3-5 章 / arc 10-30 章 / volume 按 metadata 的「单卷章数」` 重新划分
- 在 `blueprints/chapters.md` 中为每一章标注 `volume/arc/chunk`（已写的 N 章产出"回溯型 blueprint"，每章仅保留章号 + 标题 + 一句话定位 + 归属标注）
- 若章节分卷结果与第 1 步不一致，移动 `chapter-NNNN.md` 到对应 `chapters/volume-NNN/`

**8. 生成 naming.md**
- 用 `compile_naming_prompt`，输入：story-bible + character-dynamics（本步无，可用 story-bible §五 主要角色锚点代替）+ world-building（同上，用 story-bible §三 替代）+ golden-finger（网文模式才有）
- 扫正文补充口语化变体到「禁用变体」列

**9. 反向填充 canon（必须全量）**
- 用 `canon_backfill_prompt`，输入：全部 L1 briefs + 关键原文段 + naming.md 的 slug 列表
- 产出四份：`canon/facts.jsonl` / `promises.jsonl` / `progression.jsonl` / `timeline.md`
- 按 chapter 字段升序排列；FACT/PROMISE/PROG 的 ID 从 0001 顺序分配
- `canon/rules.md` 由 agent 从 story-bible §三 世界观规则复制 + 扫正文补充

**10. 生成伏笔账本与副线账本**
- 对每章依次跑 `extract_foreshadowing_prompt`（已有，单章版），`{active_foreshadowing}` 槽位使用前序已提取的条目累积
- 按章推进填充 `foreshadowing-ledger.md`；对"埋设了但从未回收"的条目，status 设为「待回收」
- `subplots.md` 同理：agent 通读 L1 briefs 识别贯穿多章的副线，按副线最后推进章填「最后推进」列

**11. 生成 L2/L3/L4/L5（至少覆盖最近 1 卷）**
- 优先级：当前卷（最新 chunk 的 L2 + 最新 arc 的 L3）> 当前卷全部 L2/L3 > 过往卷 L4 > 过往卷 L2/L3
- 若 token 受限，只回填最近 1 卷的 L2/L3 + 最新一份 L4 + 当前 L5 即可；早期章节依靠 L1 + 关键词反查
- L5 用 `global_summary_prompt`，`{volume_summaries}` 填已生成的所有 L4（至少最近一份）

**12. 为 N+1 章起生成 blueprint**
- 用 `chunked_chapter_blueprint_prompt_v2`
- `{chapter_list}` 填前 N 章的回溯型 blueprint（第 7 步产出）
- `{n}`=N+1, `{m}`=N+50
- `{novel_architecture}` 填 story-bible 全文（本场景无独立 plot-architecture.md）
- 产出的 blueprint 追加到 `blueprints/chapters.md`

**13. 首次快照**
- 在导入完成后立即执行一次快照（见 `memory-protocol.md §九`），目录名 `snapshots/ch-NNNN-imported/`
- `snapshot-meta.md` 标注「来源：从既有作品导入」

完成上述 13 步后，从第 N+1 章起走正常「写前组装 → 写后校验 → 落盘」流程。

**退化路径**：若用户的作品 ≤10 章，可跳过第 7/11 步的 L2/L3/L4 回填，`layered_summary` 直接用 story-bible 全文 + 全部 L1；第 12 步的 blueprint 用 `chapter_blueprint_prompt_v2` 单批生成。

**已有 SKILL 结构但旧版**（如早期扁平结构）：按 `memory-protocol.md §七` 兼容处理——保留旧文件，从下一个 chunk 起按本协议建新结构，L5 在下次卷收尾统一重生成。

## 文件内容规范

### `metadata.md`

```markdown
# 元信息
- 标题：
- 类型：
- 基调：
- 目标读者：
- 目标字数：
- 单章字数：
- 字数容差：0.15            # 单章允许浮动比例，缺省 0.15（即 ±15%）
- 单卷章数：
- 体裁模式：网文 / 严肃文学 / 通用
- 禁用风格/桥段：
```

**字数三参数语义**

- `单章字数`（target）：单章目标字符数（中文 1 字 = 1 字符）。
- `字数容差`（tol）：单章允许的浮动比例，建议网文 0.10–0.15、严肃文学 0.15–0.20。
- 实际允许区间：`[target × (1 − tol), target × (1 + tol)]`，写后校验和扩写/缩写均按此区间判定。
- 未填 `字数容差` 时按 0.15 处理，向 agent 说明「使用默认容差」。

**字符数计数口径**

正文总字符数 = 不含空白和换行的 `chapter-NNNN.md` 正文长度，**包含中文标点**。Shell 一行命令：`tr -d '[:space:]' < chapter-NNNN.md | wc -m`。

### `story-bible.md`

设定正典，长度控制在 3000 字以内。包括：核心种子、主题、终局预设、世界观规则、叙事视角、禁忌与硬约束。立项时写定，后续**只修订不扩写**，修订需在文件尾追加「变更记录」。

### `summaries/global.md`（L5）

全书浓缩摘要，≤2000 字。仅在卷收尾时由 `volumes/volume-XXX.md` 聚合重生成，生成前把上一版归档到同文件「历史版本」段，便于审计。

### `volumes/volume-NNN.md`（L4）

卷结束时写定并冻结，约 2000-3000 字，字段：

- 卷目标与冲突升级
- 本卷主要事件链
- 卷内角色变化（指向 `entities/characters/` 内对应条目）
- 已回收伏笔 / 遗留伏笔
- 卷结局状态与下一卷压力

### `arcs/arc-NNN.md`（L3）

10-30 章形成的篇章，约 1500-2000 字。结构同 L4，但粒度到「篇章目标」。

### `chunks/chunk-NNNN.md`（L2）

3-5 章的悬念小闭环，≤800 字。只读对应的 L1 brief 生成，一次写定。

### `chapters/volume-NNN/chapter-NNNN.brief.md`（L1）

```markdown
# 第 NNNN 章 摘要
- 时间：故事日 Day X
- 地点：
- POV：
- 出场：
- 主要事件：1. ... 2. ... 3. ...
- 推进主线：
- 埋/回收伏笔：
- 新增事实 ID：FACT-xxxx, FACT-xxxx
- 章末钩子：
```

300-500 字，章节完成后立刻生成，**此后永不修改**。

### `chapters/volume-NNN/chapter-NNNN.index.md`

```yaml
---
chapter: 123
title: "..."
volume: 3
arc: 7
chunk: 28
time: "Day 412"
location: "柳溪镇·西市"
pov: "zhang-san"
characters: [zhang-san, li-si, wang-er]
entities: [hantie-sword, yunxiao-sect]
plot_beats: [主线-A3, 副线-B1]
scene_types: [action, dialogue]
emotional_tone: {tension: 8, despair: 2, hope: 3}
foreshadowing_set: [F045]
foreshadowing_paid: [F012]
new_facts: [FACT-0891, FACT-0892]
keywords: [寒铁剑, 血祭, 西市刺杀]
---
```

用于按实体/伏笔/关键词反查章节。写完正文即生成，后续不改。

`scene_types` 可选值：`action`（打斗/追逐）、`dialogue`（对话/谈判）、`introspection`（内心独白/回忆）、`exposition`（世界观/信息交代）、`transition`（过场/行路）。一章可多个。

`emotional_tone` 三个维度各 1-10 打分：`tension`（紧张度）、`despair`（绝望/压抑）、`hope`（希望/上扬）。用于写前检查最近 10 章的情感曲线，避免连续同类场景或情感单调。

### `entities/characters/<slug>.md`

```markdown
# 张三（zhang-san）
## 正典摘要
一句话定位 + 身份 + 核心立场。立项或首次登场时写定，修订需走变更记录。

## 首次登场
第 3 章

## 硬约束（不可违反）
- 天赋：火系
- 禁忌：不能触碰寒铁
- 语言特征：自称「某」，句短

## 关键节点（追加式时间线）
- 第 12 章：获得寒铁剑
- 第 45 章：与李四决裂
- 第 78 章：突破炼气六层

## 当前状态
- 物品：青衫、寒铁长剑
- 能力：精神感知、无形攻击
- 身体状态：
- 心理状态：
- 关系网：
  - 李四：竞争对手
- 最后出场：第 78 章
- 已知秘密：FACT-0089（李四是天魔教奸细）
  - 王二：旧怨

## 变更记录
- 第 45 章：关系「李四」由盟友→竞争对手（原文引用：...）
```

**关键节点与变更记录只追加不删除**。其它实体类型（`locations`、`items`、`organizations`、`systems`）结构相同，调整字段含义即可。

### `foreshadowing-ledger.md`

```markdown
# 伏笔账本
| ID | 伏笔 | 首次出现(章) | 原文引用 | 强化节点 | 回收计划 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| F007 | 神秘符文 | 12 | "石碑上刻着一行古老的符文…" | 34, 58 | 卷二揭示来源 | 待回收 |
```

`原文引用` 字段强制写入，用以在回收时防止模型合理化杜撰。

### `canon/facts.jsonl`

每行一个 JSON 对象，**只追加不修改不删除**：

```jsonl
{"id":"FACT-0001","chapter":3,"entity":["zhang-san"],"fact":"张三天赋为火系，无法修炼水系功法","source":"测灵石发出赤红光芒"}
{"id":"FACT-0012","chapter":12,"entity":["zhang-san","hantie-sword"],"fact":"寒铁剑由张三在柳溪镇西市以三百灵石购得","source":"他将三百灵石推过柜台"}
{"id":"FACT-0044-R","chapter":200,"type":"retraction","retracts":"FACT-0044","reason":"第200章明确说明该事件未发生，见 CI-017"}
```

字段说明：
- `id`：全局唯一，格式 `FACT-NNNN`；撤销条目加 `-R` 后缀
- `chapter`：首次确立该事实的章节号
- `entity`：涉及的实体 slug 列表，用于过滤检索
- `fact`：一句话断言，≤100 字
- `source`：原文引用片段（10-50 字），防止回收时模型合理化杜撰
- `type`：默认省略；撤销条目填 `"retraction"`
- `known_by`：知道这条事实的角色 slug 列表（留空表示公开信息）；新角色得知时追加一条 `type:"disclosure"` 条目

```jsonl
{"id":"FACT-0089","chapter":45,"entity":["li-si"],"fact":"李四是天魔教奸细","source":"他撕开衣领，露出天魔教的刺青","known_by":["zhang-san"]}
{"id":"FACT-0089-D","chapter":78,"type":"disclosure","fact_id":"FACT-0089","to":"wang-er","chapter":78,"source":"张三将秘密告知了王二"}
```

只登记**可能在后续章节被违反的约束性事实**：能力上限、物品归属、人物死亡、关键承诺、地理距离、时间节点。不需要登记所有细节。

### `canon/rules.md`

世界规则追加式记录，每条带章节来源。发现冲突时在原条目旁加 `⚠️` 标注，不删除原规则：

```markdown
# 世界规则
- [第3章] 灵根分五系：金木水火土，天赋在测灵时确定，终身不变
- [第18章] 渡劫期以上修士不得擅入凡人城市，违者天道惩戒
- ⚠️ [第67章 vs 第3章] 张三使用了水系技能——与 FACT-0001 冲突，已登记 CI-023
```

### `canon/timeline.md`

时间线事件按故事日追加：

```markdown
# 时间线
- Day 001：张三出生于柳溪镇（第1章）
- Day 412：西市刺杀事件，张三获得寒铁剑（第12章）
- Day 890：云霄峰决裂，李四离队（第45章）
```

### `canon/promises.jsonl`

角色亲口说出的承诺、誓言、宣言，只追加不修改：

```jsonl
{"id":"PROMISE-0012","chapter":20,"by":"zhang-san","to":"li-si","content":"三年内必取天魔殿殿主首级","deadline_day":1500,"status":"pending"}
{"id":"PROMISE-0012-U","chapter":180,"type":"update","promise_id":"PROMISE-0012","status":"fulfilled","source":"他终于站在了殿主的尸身旁"}
```

字段说明：
- `deadline_day`：承诺的故事日截止点（可选），用于写前提示「即将到期」
- `status`：`pending` / `fulfilled` / `broken` / `abandoned`
- 状态变化追加 `type:"update"` 条目，不修改原条目

写前组装协议加载「距本章故事时间 ±200 天内到期、且 status=pending 的承诺」。

### `canon/progression.jsonl`

能力/境界/等级的进阶轨迹，只追加不修改：

```jsonl
{"id":"PROG-0001","chapter":1,"entity":"zhang-san","system":"灵气修炼","level":"炼气一层","value":1}
{"id":"PROG-0012","chapter":45,"entity":"zhang-san","system":"灵气修炼","level":"炼气六层","value":6}
{"id":"PROG-0031","chapter":120,"entity":"zhang-san","system":"灵气修炼","level":"筑基期","value":10}
```

字段说明：
- `system`：所属进阶体系（同一作品可有多套体系）
- `value`：数值化的等级（用于校验单调性：新值必须 ≥ 旧值）
- 写后校验时检查：新登记的 `value` 是否低于该实体在同一 `system` 下的历史最高值

### `naming.md`

标准名称表，防止同一实体前后写法不一致：

```markdown
# 标准名称表
| 实体 slug | 规范写法 | 禁用变体 |
| --- | --- | --- |
| zhang-san | 张三 | 张三儿、张小三 |
| hantie-sword | 寒铁剑 | 玄铁剑、黑铁剑、寒铁长剑 |
| yunxiao-sect | 云霄宗 | 云霄派、云霄门 |
```

写后校验新增一步：grep 本章正文，扫到「禁用变体」列中的词直接报错。立项时建表，每次新实体首次登场时补充。

### `continuity-issues.md`

```markdown
# 一致性追踪
## 待修复
- [ ] 第 17 章与 worldbook 的时空规则冲突：...

## 禁用桥段（最近 20 章）
- 已用：身份互换（第 52 章）
- 已用：假死复活（第 61 章）

## 已修复
- [x] ...
```

### `subplots.md`

追踪所有副线与次要角色线，防止配角失踪：

```markdown
# 副线追踪
| ID | 副线 | 涉及角色 | 当前状态 | 最后推进章节 | 预计回收 |
| --- | --- | --- | --- | --- | --- |
| SUB-001 | 李四卧底线 | li-si | 身份尚未暴露 | 第45章 | 卷二中段 |
| SUB-002 | 王二复仇线 | wang-er | 已找到仇人线索 | 第62章 | 卷三 |
```

写前组装协议加载「距上次推进超过 20 章的活跃副线」，提示 agent 是否需要在本章推进。

### `dialogue-samples/<slug>.md`

每个主要角色一份，滚动保留最近 5 条台词样本，**不冻结**——随角色成长自然演化：

```markdown
# 张三 台词样本
<!-- 滚动更新，每章写完后替换最旧的一条，始终保留最近5条 -->

## [第 78 章]
> "某既已应承，便无反悔之理。"
> （背景：与李四立约，语气平静但带压迫感）

## [第 62 章]
> "滚。"
> （背景：拒绝门派招募，一字作答）

## [第 45 章]
> "你我之间，到此为止。"
> （背景：与李四决裂，声音发抖）
```

写对话前加载本章出场角色的台词样本，作为语气/节奏参考，不作为硬约束。

### `snapshots/ch-NNNN/snapshot-meta.md`

```markdown
# 快照元信息
- 触发章节：第 50 章
- 快照时间：2026-05-10
- 故事日：Day 890
- 当前卷：卷一
- 备注：卷一收尾，李四决裂后
```

快照只复制记忆层，不复制正文（正文体量大且有 git 历史可追溯）：

```
snapshots/ch-0050/
  entities/           ← cp -r entities/
  canon/              ← cp -r canon/
  summaries/          ← cp -r summaries/
  dialogue-samples/   ← cp -r dialogue-samples/
  foreshadowing-ledger.md
  subplots.md
  naming.md
  snapshot-meta.md
```
