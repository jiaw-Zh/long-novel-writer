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

写前补齐输入：

- 前文摘要
- 前章结尾段
- 用户指导
- 角色状态
- 当前章节摘要
- 当前章节信息
- 下一章目录
- 检索或知识库参考

## 更新记忆

章节完成后使用：

- `summary_prompt` 更新前文摘要。
- `update_character_state_prompt` 更新角色状态。
- `summarize_recent_chapters_prompt` 生成当前章节摘要。
- `CONSISTENCY_PROMPT` 做冲突检查。

## 知识库和检索

使用：

- `knowledge_search_prompt` 生成检索词。
- `knowledge_filter_prompt` 过滤检索结果。

输出时把材料分为：情节燃料、人物维度、世界碎片、叙事技法、冲突预警。



