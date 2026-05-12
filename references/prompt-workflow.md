# 提示词工作流

## 体裁模式

`metadata.md` 的 `体裁模式` 字段决定提示词的写作约束分支：

| 体裁模式 | 适用场景 | 写作约束常量 |
|---|---|---|
| `网文` | 爽文/修真/都市/系统流 | `GENRE_MODE_WEBNOVEL`、`GENRE_RHYTHM_WEBNOVEL` 等 |
| `严肃文学` | 纯文学/深度叙事 | `GENRE_MODE_LITERARY`、`GENRE_RHYTHM_LITERARY` 等 |
| `通用` | 不确定时默认 | 两套规则各取一半 |

所有 v2 提示词的 `{genre_mode_instructions}` / `{genre_rhythm_rules}` / `{genre_constraints}` 槽位，根据 `metadata.md` 的体裁模式填入对应常量。

## 网文专用提示词使用时机

| 提示词 | 使用时机 |
|---|---|
| `opening_three_chapters_prompt` | 立项后，写第1-3章之前，生成开局大纲 |
| `golden_finger_design_prompt` | 立项时，与角色/世界观设定同步完成 |
| `chapter_hook_prompt` | 每章正文写完后，检查/优化章末钩子 |
| `face_slap_prompt` | blueprint 中标注「打脸章」时，正文生成前调用 |
| `progression_breakthrough_prompt` | blueprint 中标注「突破章」时，正文生成前调用 |



使用 dev 分支 `dev-prompt_default.yaml`：

1. `expand_idea_to_full_novel_story_prompt_base` + schema suffix
2. `extract_idea_prompt_base` + schema suffix
3. `core_seed_prompt_base` + schema suffix
4. `novel_meta_prompt_base` + schema suffix

适用场景：用户只有点子，想先得到完整故事雏形、类型、基调、核心种子和小说基础设定。产出汇总到 `metadata.md`。

## 从已有设定开始

使用旧分支中文提示词 `legacy-zh-prompt_definitions.py`：

1. `core_seed_prompt` → `settings/core-seed.md`
2. `character_dynamics_prompt` → `settings/character-dynamics.md`
3. `world_building_prompt` → `settings/world-building.md`
4. `plot_architecture_prompt` → `settings/plot-architecture.md`
5. `create_character_state_prompt_v2` → `entities/characters/*.md`
6. `create_entity_prompt`（分 4 次，`entity_type` 分别为 locations/items/organizations/systems）→ `entities/{type}/*.md`
7. 网文模式：`golden_finger_design_prompt` → `settings/golden-finger.md`
8. 网文模式：`opening_three_chapters_prompt` → `blueprints/opening-three.md`
9. `chapter_blueprint_prompt_v2`（≤100 章）或 `chunked_chapter_blueprint_prompt_v2`（>100 章分批）→ `blueprints/chapters.md`
10. 手工从 1-4 的产出中提炼 `story-bible.md`（≤3000 字）

适用场景：用户已有题材、主角、世界观或大纲，需要搭建百万字主链路。

## 写章节正文

第一章使用 **`first_chapter_draft_prompt_v2`**。后续章节使用 **`next_chapter_draft_prompt_v2`**。v1 已从 prompt 文件中移除。

`next_chapter_draft_prompt_v2` 的槽位填充方式：

| 槽位 | 来源 |
|---|---|
| `layered_summary` | `summaries/global.md`（L5）+ 当前 `volumes/volume-NNN.md`（L4）+ 当前 `arcs/arc-NNN.md`（L3）三段拼接。**前期过渡**：L5/L4/L3 全部缺失时填入 `story-bible.md` 全文代替 |
| `previous_chapter_excerpt` | 上一章结尾 500-1000 字原文 |
| `user_guidance` | 用户本轮指导 |
| `entity_states` | 出场角色 `entities/characters/<slug>.md` 的「当前状态」段聚合 |
| `known_facts` | `canon/facts.jsonl` 按出场角色 slug 过滤 `known_by` 字段的结果（`lnw filter-facts <slugs>`）|
| `dialogue_samples` | 出场角色 `dialogue-samples/<slug>.md` 内容聚合。角色首次登场且无历史样本时填「首次登场，无历史样本」 |
| `short_summary` | 最近 3-5 章 `chapter-*.brief.md`（L1）|
| 当前/下章章节信息 | 章节 blueprint |
| `filtered_context` | `chapter-*.index.md` 关键词反查命中的 L1 + 活跃伏笔 + `continuity-issues.md` 禁用桥段 |

`first_chapter_draft_prompt_v2` 的 `novel_setting` 槽位 = `story-bible.md` 全文 + `metadata.md` 的「类型/基调/目标读者/单章字数/体裁模式」字段拼接。`entity_states` 同上。

有 shell 权限时，`lnw assemble-context <N>` 自动完成上述所有槽位的文件读取和拼接。

## 更新记忆

**章节完成后**（单章级，每章都做，按此顺序）：

1. **`chapter_brief_prompt`** → 生成 L1 brief，落盘到 `chapter-NNNN.brief.md` 后**冻结**。（替代旧版 `summarize_recent_chapters_prompt`）
2. 追加 `canon/facts.jsonl`：本章新增约束性事实（含 `known_by` 字段）。
3. 追加 `canon/promises.jsonl`：本章新增或状态变化的承诺/誓言。
4. 追加 `canon/progression.jsonl`：本章发生的境界/能力进阶。
5. 追加 `canon/timeline.md` 与 `canon/rules.md`。
6. **`update_character_state_prompt_v2`** → 输出「当前状态」更新段 + 独立「变更记录」条目（引用 FACT ID），分别写入实体档案对应位置。
7. 维护 `chapter-NNNN.index.md`；用 **`extract_foreshadowing_prompt`** 更新 `foreshadowing-ledger.md`；用 **`update_subplots_prompt`** 更新 `subplots.md`。
8. 写后校验：按 `memory-protocol.md` §5 的 8 项清单检查，使用 `consistency-check-prompt.md`。校验失败时走 **`fix_chapter_prompt`** 做局部修复（最多 2 次），严重问题回到 step 3 重写，无法修复则登记 `continuity-issues.md`。

**chunk/arc/volume 末章额外执行**：

| 层级 | 使用提示词 | 输入 | 输出 |
|---|---|---|---|
| L2 chunk | `chunk_summary_prompt` | 该 chunk 的所有 L1 brief | `chunks/chunk-NNNN.md`，冻结 |
| L3 arc | `arc_summary_prompt` | 该 arc 的所有 L2 | `arcs/arc-NNN.md`，冻结 |
| L4 volume | `volume_summary_prompt` | 该卷的所有 L3 | `volumes/volume-NNN.md`，冻结 |
| L5 global | `global_summary_prompt` | 所有 L4 | `summaries/global.md`，旧版归档 |

**禁止用任何提示词做逐章覆盖式的全局摘要更新**——这是旧协议下的主要漂移源。

## 扩写

使用 **`enrich_prompt_v2`**（v1 `enrich_prompt` 已废弃）。

v2 新增 `entity_constraints` 槽位，填入出场实体的硬约束段，防止扩写时引入新设定冲突。

## 知识库和检索

使用：

- `knowledge_search_prompt` 生成检索词。
- `knowledge_filter_prompt` 过滤检索结果。

输出时把材料分为：情节燃料、人物维度、世界碎片、叙事技法、冲突预警。
