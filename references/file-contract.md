# 作品文件契约

> 本契约服务于百万/千万字长篇。核心原则：**实体中心存档 + 分层摘要冻结 + 章节索引 + 正典账本**。
> 分层摘要与写前组装协议见 `references/memory-protocol.md`，本契约只规定文件位置与字段。

## 目录结构

```text
novel-title/
  metadata.md                       # 元信息（固定）
  story-bible.md                    # 设定正典（核心种子/终局/世界观/视角，冻结）
  continuity-issues.md              # 冲突与禁用项

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

  canon/
    facts.jsonl                     # 原子事实账本（只追加）
    rules.md                        # 世界规则（追加式，冲突高亮）
    timeline.md                     # 时间线事件（按 Day 编号追加）

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
- 单卷章数：
- 禁用风格/桥段：
```

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
foreshadowing_set: [F045]
foreshadowing_paid: [F012]
new_facts: [FACT-0891, FACT-0892]
keywords: [寒铁剑, 血祭, 西市刺杀]
---
```

用于按实体/伏笔/关键词反查章节。写完正文即生成，后续不改。

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
