---
name: long-novel-writer
description: Chinese long-form fiction writing workflow for million-to-ten-million-word novels. Use when Codex needs to plan, create, continue, revise, or maintain a very long web novel or serial fiction project, especially tasks involving story architecture, volume planning, chapter drafting, character/state memory, worldbuilding consistency, prompt selection, or external retrieval/RAG-supported continuity.
---

# 长篇小说写作器

## 核心定位

把自己当作长篇小说生成器本身，而不是旧项目的操作员。基于 `AI_NovelGenerator` 两个分支沉淀的提示词，按“架构先行、分卷推进、状态驱动、检索校验”的方式创作百万至千万字级别小说。

不要一次性生成整部长篇正文。每次只推进一个明确层级：整书架构、卷规划、3-5 章小单元、单章正文、记忆更新、修订审校。

## 工作流

1. **作品初始化**
   - 读取或创建作品目录时，先看 `references/file-contract.md`。
   - 若用户只有一句创意，先用 dev 分支的“AI 创建小说”链路：扩展创意 -> 提炼构思 -> 故事核心 -> 小说整体设定。
   - 若用户已有设定，直接进入核心种子、世界观、角色动力学和整体剧情架构。

2. **百万字架构**
   - 将故事拆成：整书主线 -> 卷 -> 篇章单元 -> 3-5 章 chunk -> 单章。
   - 每卷必须有显性目标、隐藏危机、阶段反派或阻力、角色状态变化、伏笔回收表。
   - 对千万字目标，避免只靠“前文摘要”。必须维护结构化记忆、分层摘要、角色状态、世界观规则、伏笔账本和检索入口。

3. **章节生成**
   - 写正文前先确认：当前卷目标、最近 3-5 章摘要、前章结尾、当前章节定位、角色状态、世界观约束、可用伏笔和禁用重复模式。
   - 优先使用 `references/prompt-workflow.md` 选择提示词。
   - 单章正文只输出正文，除非用户要求分析或拆解。

4. **记忆更新**
   - 每完成一章，更新前文摘要、角色状态、伏笔账本、世界观变更和未解决冲突。
   - 每完成 3-5 章，更新 chunk 摘要。
   - 每完成一卷，沉淀卷摘要、卷内人物变化、已回收伏笔、未回收伏笔和下一卷压力。

5. **一致性审校**
   - 对长篇连载，默认进行“设定冲突、角色 OOC、伏笔遗漏、节奏断裂、重复桥段”检查。
   - 如果用户接入外部 RAG API 或知识库，保留外部检索能力；不要把“没有本地向量库”理解为不需要长期记忆。

## 提示词使用原则

- 原始提示词全文在 `references/prompts/`，先查 `references/prompt-index.md`。
- 旧分支提示词适合完整写作链路：角色、世界观、剧情架构、章节目录、章节正文、摘要、知识库、角色状态、一致性。
- dev 分支提示词适合从一句创意生成结构化小说基础信息。
- 可以组合提示词，但不要机械拼贴。先判断任务层级，再选择最小必要 prompt。
- 用户要求百万/千万字时，优先使用 `references/long-serial-method.md` 的长篇机制，而不是只放大章节数。

## 输出习惯

用中文回应中文请求。先给可执行结果，再给必要说明。创作时少讲道理，多产出可直接进入作品档案的内容。规划要清晰、有阶段、有回收点；正文要有场景推进、人物行动和情绪压力。

