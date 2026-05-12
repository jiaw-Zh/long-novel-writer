# 提示词索引

## 写后校验提示词

文件：`references/prompts/consistency-check-prompt.md`

用于章节落盘前的独立一致性校验，建议由独立 subagent 或新对话窗口执行。
覆盖 8 项校验：正典冲突 / POV 知识边界 / 硬约束 / 进阶合法性 / 命名一致性 / 桥段重复+伏笔对齐 / 场景类型 + 情感打分 / 台词样本更新。

## 中文提示词主文件

文件：`references/prompts/legacy-zh-prompt_definitions.py`

### 设定类（立项用）
- `core_seed_prompt` — 核心种子
- `character_dynamics_prompt` — 角色动力学
- `world_building_prompt` — 世界观构建
- `plot_architecture_prompt` — 情节架构（三幕式）

### 实体档案类
- `create_character_state_prompt_v2` — 生成角色档案（对齐 entities/characters 结构，带体裁模式）
- `create_entity_prompt` — 生成非角色实体档案（locations/items/organizations/systems 通用）
- `Character_Import_Prompt_v2` — 从外部文本导入角色档案
- `update_character_state_prompt_v2` — 更新角色档案：当前状态 + 变更记录

### 章节目录类
- `chapter_blueprint_prompt_v2` — 整本章节目录（≤100 章，带体裁模式）
- `chunked_chapter_blueprint_prompt_v2` — 分批生成章节目录（>100 章，带体裁模式，输出 volume/arc/chunk 归属）

### 章节正文类
- `first_chapter_draft_prompt_v2` — 第一章正文（带体裁模式分支）
- `next_chapter_draft_prompt_v2` — 后续章节正文（带 POV 知识边界、前期过渡规则）
- `enrich_prompt_v2` — 扩写短章节（带一致性约束）
- `fix_chapter_prompt` — 校验失败后的局部修复

### 分层摘要类
- `chapter_brief_prompt` — L1 单章摘要（300-500 字，写完即冻结）
- `chunk_summary_prompt` — L2 chunk 摘要（3-5 章 L1 聚合）
- `arc_summary_prompt` — L3 篇章摘要（arc 内 L2 聚合）
- `volume_summary_prompt` — L4 卷摘要（卷内 L3 聚合）
- `global_summary_prompt` — L5 全书摘要（所有 L4 聚合）

### 伏笔与副线类
- `extract_foreshadowing_prompt` — 从章节正文识别伏笔埋设/强化/回收
- `update_subplots_prompt` — 从章节正文识别副线推进和新增

### 知识库类
- `knowledge_search_prompt` — 生成检索关键词
- `knowledge_filter_prompt` — 过滤检索结果

### 网文专用
- `opening_three_chapters_prompt` — 开篇三章黄金结构（觉醒/小爽点/格局确立）
- `golden_finger_design_prompt` — 金手指设计与节奏化使用规则
- `chapter_hook_prompt` — 章末钩子（10 种模式，避免重复）
- `face_slap_prompt` — 打脸循环三段式（被低估/冲突爆发/收尾）
- `progression_breakthrough_prompt` — 境界突破章四段式（蓄力/突破/确认/打脸）

### 体裁模式常量
- `GENRE_MODE_LITERARY` / `GENRE_MODE_WEBNOVEL` — 单章写作约束
- `GENRE_CONSTRAINTS_LITERARY` / `GENRE_CONSTRAINTS_WEBNOVEL` — 角色硬约束字段
- `GENRE_RHYTHM_LITERARY` / `GENRE_RHYTHM_WEBNOVEL` — 章节目录节奏规则
- `GENRE_IMPORT_CONSTRAINTS_LITERARY` / `GENRE_IMPORT_CONSTRAINTS_WEBNOVEL` — 角色导入约束

## dev 分支提示词

文件：`references/prompts/dev-prompt_default.yaml`

`create_novel_by_ai` 工作流，用于从一句创意扩展到完整 metadata.md：

- `expand_idea_to_full_novel_story_prompt_base` + schema suffix
- `extract_idea_prompt_base` + schema suffix
- `core_seed_prompt_base` + schema suffix
- `novel_meta_prompt_base` + schema suffix
