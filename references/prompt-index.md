# 提示词索引

## 写后校验提示词

文件：`references/prompts/consistency-check-prompt.md`

用于章节落盘前的独立一致性校验，建议由独立 subagent 或新对话窗口执行。
覆盖 6 项校验：正典冲突 / POV 知识边界 / 硬约束 / 进阶合法性 / 命名一致性 / 桥段重复+伏笔对齐。

## 旧分支中文提示词

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


