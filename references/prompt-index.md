# 提示词索引

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

## 旧分支英文提示词

文件：`references/prompts/legacy-en-prompt_definitions_en.py`

包含与中文提示词同名的英文版本，并在文件末尾对所有 prompt 注入统一风格要求：禁止 em dash、en dash 和 double dash。英文创作或英文输出任务优先读取此文件。

## 旧分支其他提示词

文件：`references/prompts/legacy-consistency_checker.py`

- `CONSISTENCY_PROMPT`：检查小说设定、角色状态、前文摘要、未解决冲突和最新章节之间的不一致。

旧项目中还有配置测试短 prompt：`Please reply 'OK'`，属于 LLM 连通性测试，不纳入创作工作流。

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

## dev 分支格式审校

文件：`references/prompts/dev-format_review_service.py`

- `review_prompt`：当 LLM 原始输出无法通过 schema 校验时，要求模型提取有效信息并严格输出合法 JSON。

