# long-novel-writer 核心规则

以下是使用 long-novel-writer 技能时的**绝对规则**。完整流程见 SKILL.md。

## 铁律

```
没有通过 verification 的章节，禁止写入磁盘。没有例外。
没有完成 9 步 pre-writing assembly 的章节，禁止开始写正文。没有例外。
已冻结的 L1-L4 摘要，禁止修改。没有例外。
```

**违反信条等于违反精神。**

## HARD-GATE 阻断门

1. `story-bible.md` 未创建 → 禁止进入阶段 2
2. 卷/篇章/chunk 层级未拆分 → 禁止生成章节正文
3. 9 步 pre-writing assembly 未完成 → 禁止写正文
4. post-writing verification 未通过 → 禁止 landing
5. landing 顺序必须严格按 13 步执行

## 违规前兆 — 立即停止

- "这个章节很简单，不需要完整 assembly"
- "我已经记住上下文了，不需要加载文件"
- "verification 太慢了，先 landing 再说"
- "字数差不多就行"
- "改一下旧摘要也没关系"
- "这次情况特殊"

## 验证脚本

- `scripts/verify-pre-writing.sh` — 检查写前 assembly
- `scripts/verify-word-count.sh` — 字数门检查
- `scripts/verify-landing.sh` — 检查落盘完整性
