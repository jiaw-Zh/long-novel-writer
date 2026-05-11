# 提示词索引

## 写后校验提示词

文件：`references/prompts/consistency-check-prompt.md`

用于章节落盘前的独立一致性校验，建议由独立 subagent 或新对话窗口执行。
覆盖 6 项校验：正典冲突 / POV 知识边界 / 硬约束 / 进阶合法性 / 命名一致性 / 桥段重复+伏笔对齐。

## 旧分支中文提示词（v1，部分已废弃）

文件：`references/prompts/legacy-zh-prompt_definitions.py`

**v2 升级版（推荐使用）：**
- `next_chapter_draft_prompt_v2` — 对齐新记忆系统，拆分 global_summary/character_state 槽位
- `first_chapter_draft_prompt_v2` — 对齐新记忆系统，加体裁模式分支
- `chapter_brief_prompt` — 生成 L1 单章摘要（替代 summarize_recent_chapters_prompt）
- `chunk_summary_prompt` — 生成 L2 chunk 摘要（3-5 章 L1 聚合）
- `arc_summary_prompt` — 生成 L3 篇章摘要（arc 内 L2 聚合）
- `volume_summary_prompt` — 生成 L4 卷摘要（卷内 L3 聚合）
- `global_summary_prompt` — 生成 L5 全书摘要（所有 L4 聚合）
- `update_character_state_prompt_v2` — 输出拆为「当前状态」更新 + 独立「变更记录」
- `create_character_state_prompt_v2` — 输出对齐 entities/characters/<slug>.md 结构，加体裁模式
- `chapter_blueprint_prompt_v2` — 加体裁模式，输出格式加 scene_types/emotional_tone 字段
- `Character_Import_Prompt_v2` — 输出对齐实体档案结构，加体裁模式
- `enrich_prompt_v2` — 扩写时加入一致性约束

**网文专用提示词：**
- `chapter_hook_prompt` — 章末钩子生成，内置10种模式，避免重复
- `face_slap_prompt` — 打脸循环三段式（被低估/冲突爆发/收尾）
- `opening_three_chapters_prompt` — 开篇三章黄金结构（觉醒/小爽点/格局确立）
- `progression_breakthrough_prompt` — 境界突破章四段式（蓄力/突破/确认/打脸）
- `golden_finger_design_prompt` — 金手指设计与节奏化使用规则

**体裁模式常量（填入 genre_mode_instructions 等槽位）：**
- `GENRE_MODE_LITERARY` / `GENRE_MODE_WEBNOVEL`
- `GENRE_CONSTRAINTS_LITERARY` / `GENRE_CONSTRAINTS_WEBNOVEL`
- `GENRE_RHYTHM_LITERARY` / `GENRE_RHYTHM_WEBNOVEL`
- `GENRE_IMPORT_CONSTRAINTS_LITERARY` / `GENRE_IMPORT_CONSTRAINTS_WEBNOVEL`

**v1 原版（保留兼容，部分已废弃）：**

文件：`references/prompts/legacy-zh-prompt_definitions.py`

- `summarize_recent_chapters_prompt`
- `knowledge_search_prompt`
- `knowledge_filter_prompt`
- `core_seed_prompt`
- `character_dynamics_prompt`
- `world_building_prompt`
- `plot_architecture_prompt`
- `chapter_blueprint_prompt`
- `chunked_chapter_blueprint_prompt`
- `summary_prompt`
- `create_character_state_prompt`
- `update_character_state_prompt`
- `first_chapter_draft_prompt`
- `next_chapter_draft_prompt`
- `Character_Import_Prompt`
- `enrich_prompt`





## dev 分支提示词

文件：`references/prompts/dev-prompt_default.yaml`

`create_novel_by_ai` 工作流：

- `expand_idea_to_full_novel_story_prompt_base`
- `expand_idea_to_full_novel_story_prompt_with_schema_suffix`
- `expand_idea_to_full_novel_story_prompt_without_schema_suffix`
- `extract_idea_prompt_base`
- `extract_idea_prompt_with_schema_suffix`
- `extract_idea_prompt_without_schema_suffix`
- `core_seed_prompt_base`
- `core_seed_prompt_with_schema_suffix`
- `core_seed_prompt_without_schema_suffix`
- `novel_meta_prompt_base`
- `novel_meta_prompt_with_schema_suffix`
- `novel_meta_prompt_without_schema_suffix`


