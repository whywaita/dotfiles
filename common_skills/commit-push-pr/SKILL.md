---
name: commit-push-pr
description: Create a git commit, push a branch, and open a Pull Request with gh. Use when asked to commit changes, push to origin, or create PRs, especially when conventional commits and PR templates are required.
---

# Commit, Push, and PR Workflow

## Workflow

1. Detect PR language by reading `README` / `README.md`.
   - If the README contains Japanese text, use Japanese for PR title/body; otherwise use English.
2. Ensure a feature branch.
   - Run `git branch --show-current`.
   - If on `main` or `master`, infer branch naming from `git branch -r --list 'origin/*' | grep -v 'HEAD\|main\|master'`, propose a name, then run `git switch -c <branch-name>`.
3. Try signed commit first, fallback if it fails.
   - Attempt a signed commit with `git commit -S`.
   - If the signed commit fails, retry without signing using `git -c commit.gpgsign=false commit` and note the fallback in the response.
4. Create a Conventional Commit.
   - Format:
     - `<type>[optional scope]: <description>`
     - Optional body
     - Conversation log:
       - `prompt: <user prompt>`
       - `----`
       - `<assistant response>`
       - Repeat for each exchange
     - Optional footer(s)
   - Use `feat|fix|docs|style|refactor|test|chore|ci|build|perf` as needed.
   - Keep description present tense, lowercase, under 50 chars, no period.
5. Rebase onto the base branch to detect and resolve conflicts.
   - Determine the base branch via `git symbolic-ref refs/remotes/origin/HEAD`.
   - `git fetch origin <base-branch>`.
   - `git rebase origin/<base-branch>`.
     - If clean: proceed.
     - If conflicts: resolve them, `git add <files>`, `git rebase --continue`. Repeat for each conflicting commit.
     - Report which files had conflicts and how they were resolved.
6. Push the branch.
   - If no upstream: `git push -u origin <branch-name>`.
   - Otherwise: `git push` (use `git push --force-with-lease` if rebase was performed).
7. Create a PR with `gh pr create`.
   - Look for PR templates in `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/`, or `docs/PULL_REQUEST_TEMPLATE.md`.
   - If no template, use a language-appropriate default template.
   - Use a HEREDOC body:
     ```bash
     gh pr create --title "<title>" --body "$(cat <<'EOF'
     <body>
     EOF
     )"
     ```
8. Output the PR URL.
9. Verify CI status.
   - `gh pr checks <pr-number> --watch` (timeout 10 minutes), or `gh run list --branch <branch> --limit 5` + `gh run view <run-id>`.
   - If all checks pass: report success.
   - If any check fails:
     a. `gh run view <run-id> --log-failed` to get detailed logs.
     b. Analyze and fix the failure (build errors, test failures, lint errors, etc.).
     c. Create a new commit (`fix(ci): <description>`), push.
     d. Re-check CI. Repeat up to 3 times.
     e. If still failing after 3 attempts, report remaining failures to the user.

## Default PR templates

**English**
```
## Summary
- <1-3 bullets>

## Changes
- <specific changes>

## Test Plan
- <how to test>

## Notes
- <extra context>
```

**Japanese**
```
## 概要
- <1〜3点>

## 変更点
- <具体的な変更>

## テスト方法
- <テスト手順>

## 備考
- <補足>
```