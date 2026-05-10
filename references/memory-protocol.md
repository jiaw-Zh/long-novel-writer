# 记忆协议

> 所有长篇作品在章节生成前后都按本协议操作。与 `file-contract.md` 配套使用。

## 核心设计

上下文窗口再大也装不下百万/千万字作品。记忆系统不是「把更多内容塞进上下文」，而是「每次写作都能精确取到对的那一小块」。本协议由三部分组成：

1. **分层摘要 + 冻结规则**：防止覆盖式摘要导致早期细节被稀释。
2. **实体中心档案**：按人/地/物/势力/系统建档，支持定向加载。
3. **写前组装协议 + 写后校验**：把"该读什么"从经验主义变成固定流程。

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

## 三、写前组装协议（Context Assembly Protocol）

写任何一章之前，按此顺序拼接上下文。顺序本身决定优先级：高优先级内容放上下文更靠近生成位置。

1. `metadata.md` + `story-bible.md`（永远加载）
2. 当前 `volumes/volume-NNN.md`（L4）+ 当前 `arcs/arc-NNN.md`（L3）
3. 当前章节 blueprint + 下一章 blueprint
4. 最近 3-5 章的 **L1 brief**
5. **上一章结尾段原文**（500-1000 字，用于文风与节奏衔接，不是整章）
6. 出场实体档案（见上节「按需加载」）
7. `foreshadowing-ledger.md` 中所有 `状态=待回收` 或 `状态=强化中` 的条目
8. `continuity-issues.md` 的「禁用桥段」与「待修复」段
9. 按章节 blueprint 的 keywords 在 `chapter-*.index.md` 中反查 top 3-5 相关章节，只载入其 L1 brief

以上 9 项通常能压到 50k-150k token，远低于 1M 上限，但每一项都对本章有直接价值。

> 如果作品体量小（≤30 章）或是短篇，可以退化为：story-bible + 全部 L1 + 出场角色档案。

## 四、写后校验闭环

章节正文生成后，**不要直接落盘**，先跑一轮自检：

1. 本章是否引入与 `story-bible.md` / 硬约束 / 已登记事实冲突的内容？
2. 出场角色的行为是否违背其「硬约束」？
3. 本章桥段是否与最近 20 章的 `chapter-*.index.md`→`plot_beats` 重复？
4. 本章埋设/回收的伏笔是否都能在 `foreshadowing-ledger.md` 找到对应 ID？

任一项不通过：改写正文，或在 `continuity-issues.md` 登记为已知问题后再落盘。

通过后按以下顺序落盘（避免中途崩溃导致不一致）：

1. 写 `chapter-NNNN.md`（L0 正文）
2. 写 `chapter-NNNN.brief.md`（L1，冻结）
3. 写 `chapter-NNNN.index.md`（索引）
4. 追加实体档案的「关键节点」与「变更记录」
5. 追加 `foreshadowing-ledger.md` 的状态变化
6. 若当前章节是 chunk/arc/volume 的末章，生成对应 L2/L3/L4

## 五、Token 预算参考

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

## 六、与原提示词的对接

- `summarize_recent_chapters_prompt` → 用来生成 **L1 brief**，输出落入 `chapter-NNNN.brief.md`，落盘后冻结。
- `summary_prompt` → **不再** 用于逐章覆盖式更新，改为 **L3/L4 生成**（arc/volume 收尾时）以及 **L5 重生成**（卷收尾聚合）。输入改为对应下层摘要的拼接。
- `update_character_state_prompt` → 输出落入对应 `entities/characters/<slug>.md` 的「当前状态」段，同时要求模型另行输出一段「变更记录」追加到文件末尾。
- `create_character_state_prompt` → 首次为某角色建档时使用，直接生成 `entities/characters/<slug>.md` 骨架。
- `knowledge_search_prompt` / `knowledge_filter_prompt` → 在写前组装协议第 9 步使用，检索目标是 `chapter-*.index.md` 与实体档案。
- `CONSISTENCY_PROMPT` → 用于写后校验闭环第 1-3 项（若原始 prompt 库未提供，则按 memory-protocol §4 的自检清单内联到校验任务提示里）。

## 七、迁移与退化

- 已有作品若按旧扁平结构写了一部分：保留旧文件不动，从下一个 chunk 起按本协议建 `entities/` / `chapters/*/brief` / `*.index.md`，L5 在下次卷收尾时统一重生成。
- 作品不到 30 章时可以简化：L2/L3/L4 合并为单一「阶段摘要」，实体档案合并为一份 `characters.md`，但 **L1 冻结与章节索引仍要维护**。
