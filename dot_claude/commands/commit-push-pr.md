---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git branch:*), Bash(git checkout:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [message]
description: Create a git commit
---

Create a commit, push to remote, and create a Pull Request following these steps:

## Step 0: Detect Repository Language
Before starting, determine the language for the PR:

1. Read the README.md (or README) file in the repository root
2. Analyze the content to determine if it's primarily in Japanese or English:
   - If the README contains significant Japanese text (hiragana, katakana, kanji), use **Japanese** for the PR
   - Otherwise, use **English** for the PR
3. Apply this language setting to the PR title, description, and all PR-related text

## Step 1: Check and Create Feature Branch
Before committing, ensure you are on a feature branch (not main/master):

1. Check the current branch with `git branch --show-current`
2. If on `main` or `master`:
   - **Auto-detect branch naming pattern** by analyzing existing branches:
     - Run `git branch -r --list 'origin/*' | grep -v 'HEAD\|main\|master'` to list remote branches
     - Identify the common prefix pattern (e.g., `feature/`, `fix/`, `username/`, `feat/`, etc.)
     - Examples of patterns to detect:
       - `feature/<description>` or `feat/<description>`
       - `fix/<description>` or `bugfix/<description>`
       - `<username>/<description>` (e.g., `whywaita/add-feature`)
       - `<type>/<ticket-id>-<description>` (e.g., `feature/PROJ-123-add-login`)
     - If no clear pattern exists, default to `feature/<description>` or `fix/<description>`
   - Suggest a branch name following the detected pattern based on the changes
   - Create and switch to the new branch with `git checkout -b <branch-name>`
3. If already on a feature branch, proceed to the next step

## Step 2: Create Commit
Create a commit following Conventional Commits format:

```
<type>[optional scope]: <description>

[optional body]

prompt: <user's input prompt>
----
<your response>
----
prompt: <user's input prompt>
----
<your response>

[optional footer(s)]
```

- Breaking changes: Use ! after type/scope or add BREAKING CHANGE: footer
- Common types: feat, fix, docs, style, refactor, test, chore, ci, build, perf
- Scope examples: (api), (ui), (auth), (parser)
- Description: Present tense, lowercase, under 50 chars, no period
- Separate conversation exchanges with ----

## Step 3: Push to Remote
After committing, push the branch to the remote repository:
- If the branch doesn't have an upstream, use `git push -u origin <branch-name>`
- If the branch already has an upstream, use `git push`

## Step 4: Create Pull Request
Create a Pull Request using `gh pr create`:

1. First, check if a PULL_REQUEST_TEMPLATE exists in the repository:
   - Look for `.github/PULL_REQUEST_TEMPLATE.md`
   - Look for `.github/PULL_REQUEST_TEMPLATE/` directory
   - Look for `docs/PULL_REQUEST_TEMPLATE.md`

2. If a template exists, use it and fill in the sections appropriately based on the changes made.

3. If no template exists, use the appropriate language template based on Step 0:

**English Template (default):**
```
## Summary
<1-3 bullet points describing the changes>

## Changes
<List of specific changes made>

## Test Plan
<How to test these changes>

## Notes
<Any additional context or notes for reviewers>
```

**Japanese Template (日本語):**
```
## 概要
<変更内容を1〜3点で説明>

## 変更点
<具体的な変更内容のリスト>

## テスト方法
<この変更をテストする方法>

## 備考
<レビュアーへの補足情報>
```

4. Use HEREDOC for the PR body to ensure correct formatting:
```bash
gh pr create --title "<PR title>" --body "$(cat <<'EOF'
<PR body content>
EOF
)"
```

5. After creating the PR, output the PR URL so the user can access it.
