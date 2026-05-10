# 提示词工作流

## 从一句创意开始

使用 dev 分支 `dev-prompt_default.yaml`：

1. `expand_idea_to_full_novel_story_prompt_base` + schema suffix
2. `extract_idea_prompt_base` + schema suffix
3. `core_seed_prompt_base` + schema suffix
4. `novel_meta_prompt_base` + schema suffix

适用场景：用户只有点子，想先得到完整故事雏形、类型、基调、核心种子和小说基础设定。

## 从已有设定开始

使用旧分支中文提示词 `legacy-zh-prompt_definitions.py`：

1. `core_seed_prompt`
2. `character_dynamics_prompt`
3. `world_building_prompt`
4. `plot_architecture_prompt`
5. `create_character_state_prompt`
6. `chapter_blueprint_prompt` 或 `chunked_chapter_blueprint_prompt`

适用场景：用户已有题材、主角、世界观或大纲，需要搭建百万字主链路。

## 写章节正文

第一章使用 `first_chapter_draft_prompt`。后续章节使用 `next_chapter_draft_prompt`。

写前严格按 `references/memory-protocol.md` 第三节「写前组装协议」加载上下文。对应到提示词槽位：

- `global_summary` ← `summaries/global.md`（L5）+ 当前 `volumes/volume-NNN.md`（L4）+ 当前 `arcs/arc-NNN.md`（L3）
- `previous_chapter_excerpt` ← 上一章结尾 500-1000 字原文
- `user_guidance` ← 用户本轮指导
- `character_state` ← 出场角色 `entities/characters/<slug>.md` 的「当前状态」段聚合
- `short_summary` ← 最近 3-5 章 `chapter-*.brief.md`（L1）
- 当前章节信息 ← 当前章 blueprint
- `next_chapter_*` ← 下一章 blueprint
- `filtered_context` ← `chapter-*.index.md` 关键词反查到的相关章节 L1 + 活跃伏笔 + `continuity-issues.md` 禁用桥段

## 更新记忆

**章节完成后**（单章级，每章都做，按此顺序）：

1. `summarize_recent_chapters_prompt` → 生成 L1 brief，落盘到 `chapter-NNNN.brief.md` 后**冻结**。
2. 追加 `canon/facts.jsonl`：本章新增约束性事实（含 `known_by` 字段）。
3. 追加 `canon/promises.jsonl`：本章新增或状态变化的承诺/誓言。
4. 追加 `canon/progression.jsonl`：本章发生的境界/能力进阶。
5. 追加 `canon/timeline.md` 与 `canon/rules.md`。
6. `update_character_state_prompt` → 更新实体档案「当前状态」（含「最后出场」「已知秘密」字段），追加「变更记录」引用 FACT ID。
7. 维护 `chapter-NNNN.index.md`、`foreshadowing-ledger.md`、`subplots.md`。
8. 写后校验：按 `memory-protocol.md` §5 的 6 项清单检查（正典冲突 / POV 知识边界 / 硬约束 / 进阶合法性 / 命名一致性 / 桥段重复+伏笔对齐）。

**chunk/arc/volume 末章额外执行**：

- `summary_prompt` 的输入从"章节正文 + 旧摘要"改为"该 chunk/arc/volume 下层摘要的拼接"，输出分别落盘到 `chunks/chunk-NNNN.md` / `arcs/arc-NNN.md` / `volumes/volume-NNN.md`，落盘后冻结。
- 卷末额外运行一次聚合，把所有 L4 拼成新的 `summaries/global.md`（L5），旧版归档到文件「历史版本」段。

**禁止用 `summary_prompt` 做逐章覆盖式的全局摘要更新**——这是旧协议下的主要漂移源。

## 知识库和检索

使用：

- `knowledge_search_prompt` 生成检索词。
- `knowledge_filter_prompt` 过滤检索结果。

输出时把材料分为：情节燃料、人物维度、世界碎片、叙事技法、冲突预警。



