# 作品文件契约

## 目录结构

推荐每部作品一个目录：

```text
novel-title/
  metadata.md
  story-bible.md
  volumes.md
  characters.md
  worldbook.md
  foreshadowing-ledger.md
  summaries.md
  continuity-issues.md
  chapters/
    volume-001/
      chapter-0001.md
      chapter-0002.md
```

## Agent 操作规则

- 作品状态以文件为准，不以当前对话记忆为准。
- 写作前先读取相关文件：当前卷、最近摘要、角色状态、世界观、伏笔账本。
- 若文件不存在，按最小可用结构创建，不要等待用户手动建目录。
- 不需要脚本来管理这些文件；Codex 可以按本契约直接读写。
- 章节文件只放正文和必要的简短元信息，不把长篇分析塞进正文文件。

## 文件内容建议

`metadata.md`：

```markdown
# 元信息
- 标题：
- 类型：
- 基调：
- 目标读者：
- 目标字数：
- 单章字数：
- 禁用风格/桥段：
```

`foreshadowing-ledger.md`：

```markdown
# 伏笔账本
| ID | 伏笔 | 首次出现 | 强化节点 | 回收计划 | 状态 |
| --- | --- | --- | --- | --- | --- |
```

`summaries.md`：

```markdown
# 摘要
## 全局摘要

## 当前卷摘要

## 最近 3-5 章摘要
```

