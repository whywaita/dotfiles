# Third Party Notices

このリポジトリには、外部プロジェクトから取り込んだ（vendoring した）ファイルが含まれる。
取り込み元のライセンスと帰属をここに記録する。

更新するときは、取り込み元のコミット SHA も併せて更新すること。

---

## mattpocock/skills

- 取り込み元: <https://github.com/mattpocock/skills>
- コミット: `ed37663cc5fbef691ddfecd080dff42f7e7e350d` (2026-07-21)
- ライセンス: MIT

### 取り込んだファイル

上流のパス（`skills/` 以下）から、このリポジトリの `dot_claude/skills/` 以下へ内容を変更せずにコピーしている。
`dot_codex/skills/` 以下のコピーは `scripts/sync-skills.sh` が生成したもので、frontmatter から Codex が解釈しないキーを除いた以外は同一。

| 上流 | このリポジトリ |
|------|---------------|
| `skills/productivity/grilling/SKILL.md` | `dot_claude/skills/grilling/SKILL.md` |
| `skills/engineering/grill-with-docs/SKILL.md` | `dot_claude/skills/grill-with-docs/SKILL.md` |
| `skills/engineering/domain-modeling/SKILL.md` | `dot_claude/skills/domain-modeling/SKILL.md` |
| `skills/engineering/domain-modeling/ADR-FORMAT.md` | `dot_claude/skills/domain-modeling/ADR-FORMAT.md` |
| `skills/engineering/domain-modeling/CONTEXT-FORMAT.md` | `dot_claude/skills/domain-modeling/CONTEXT-FORMAT.md` |

`grill-with-docs` は本文が 1 行で、`grilling` と `domain-modeling` の両方を呼び出す。
3 つ揃っていないと動作しないため、まとめて取り込んでいる。

### ライセンス全文

```
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
