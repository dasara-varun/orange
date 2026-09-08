---
name: git-github-manager
description: Manage git and GitHub workflows — branching, staging, committing, pushing, resolving conflicts, rebasing/history cleanup, opening and reviewing pull requests, managing issues, and cutting releases/tags. Follows a commit-often/push-often, branch-liberally workflow where main/master always stays deployable, and watches for common gotchas (uncommitted work lost on branch switch, detached HEAD, stale/diverged branches, secrets in history, force-push risk, submodule drift, silent CI failures). Use this skill whenever the user asks to commit, branch, push, open a PR, review a diff, resolve a merge conflict, rebase, squash commits, tag a release, or manage GitHub issues/PRs — even if they just say "commit this," "push my changes," "make a PR," or "clean up my branch," without naming git or GitHub explicitly. Also use for repo hygiene tasks like writing a .gitignore, undoing a commit, recovering lost commits, or investigating history with git log/blame.
---

# Git & GitHub Manager

Handles the full lifecycle of working in a git repo and on GitHub: local changes → commits → branches → PRs → issues → releases.

## Setup check (do this first)

Before doing anything, confirm the environment:

```bash
git rev-parse --is-inside-work-tree 2>&1   # confirms we're in a repo
git status --short                          # see what's changed
git branch --show-current                   # current branch
```

For anything touching GitHub itself (PRs, issues, releases, forks), check whether the `gh` CLI is available and authenticated:

```bash
gh auth status 2>&1
```

- If `gh` is available and authenticated, use it for all GitHub-side operations (PRs, issues, releases) — it's more reliable than scraping web UI conventions and handles auth automatically.
- If `gh` is not installed or not authenticated, fall back to plain `git` for everything local (commits, branches, pushes), and tell the user what's missing for the GitHub-side parts (e.g. "I don't see `gh` authenticated — I can push the branch, but you'll need to open the PR yourself, or authenticate `gh` first with `gh auth login`").
- Never invent a GitHub URL or PR number — only report links/numbers that a command actually returned.

## Core principles

1. **Commit frequently.** Don't let work pile up uncommitted. Commit at natural checkpoints — a working function, a passing test, a logical chunk of a larger change — rather than one giant commit at the end. Small, frequent commits are easier to review, bisect, and revert. If the user has been working for a while with no commits, proactively suggest committing what's stable so far.
2. **Push often.** Once something is committed and the branch is in a reasonable state, push it. Local-only commits aren't backed up and aren't visible to collaborators or CI. Don't stockpile many local commits before pushing — push after every commit or every few, unless the user says otherwise.
3. **Use branches liberally; `main` (or `master`) is always the source of truth for final, working code.** Any nontrivial change — a feature, a fix, an experiment — gets its own branch. Never commit directly to `main` for anything beyond trivial fixes (typos, docs) without checking with the user first. Multiple branches can exist in parallel; that's expected and fine. See "Branch strategy" below for the full policy.
4. **Never force-push or rewrite shared history without explicit confirmation.** `push --force`, `rebase` on a branch others may have pulled, `reset --hard`, and deleting branches are all destructive. Show the user what will happen (e.g. `git log` of what's about to be lost) and get a clear go-ahead first, unless they already gave a blanket instruction in this conversation. This applies doubly to `main`.
5. **Always show a diff or status before committing.** Run `git status` and `git diff` (or `git diff --staged` once staged) and briefly summarize what's changing before writing a commit. Don't stage/commit blind.
6. **Never commit secrets.** If a diff includes what looks like an API key, token, password, or `.env` contents, flag it and ask before committing, even if the user didn't ask you to check.
7. **Write commit messages from the actual diff, not the request.** Base the message on what the code changes actually do, in imperative mood ("Add", "Fix", "Refactor"), not a restatement of the user's instruction. No strong style mandate — Conventional Commits (`feat:`, `fix:`) is fine if the repo already uses that convention (check `git log --oneline -15`); otherwise plain descriptive messages are fine. Stay consistent with whatever the repo already does.
8. **Keep commits focused.** Frequent commits and focused commits go together — if unrelated changes are mixed together and the user hasn't said otherwise, ask whether they want them split into separate commits rather than bundling silently.
9. **Before merging anything into `main`, verify it actually works.** Run the project's test/build/lint commands if they exist (check `package.json` scripts, `Makefile`, CI config in `.github/workflows/`) before merging or right after, and don't report a merge as done if checks are failing. `main` should never be left in a known-broken state.
10. **One clarifying question max, and only if truly ambiguous** (e.g. "push my changes" with no upstream configured yet, or multiple remotes). Otherwise proceed and state the assumption inline (e.g. "pushing to origin/main since that's the current upstream").

## Common workflows

### Committing changes

```bash
git status --short
git diff                      # unstaged
git add <files>                # prefer explicit paths over `git add .` unless the user wants everything
git diff --staged             # confirm what's about to be committed
git commit -m "<message>"
```

For multi-line commit messages, use a heredoc so quoting doesn't break:
```bash
git commit -m "$(cat <<'EOF'
Short summary line

Longer explanation if needed.
EOF
)"
```

### Branching

```bash
git branch --show-current
git checkout -b <branch-name>        # or: git switch -c <branch-name>
```

Branch naming: if the repo has an existing convention (check `git branch -a` / recent branch names), follow it. Otherwise default to `<type>/<short-description>` (e.g. `fix/login-redirect`, `feat/csv-export`).

## Branch strategy: `main` is always deployable

Treat `main`/`master` as sacred — it should always reflect final, working code that could be deployed or handed to someone else at any moment. Everything else happens on branches.

- **Before starting any nontrivial work**, check the current branch (`git branch --show-current`). If it's `main`, create a new branch first rather than working directly on it: `git checkout -b <type>/<description>`.
- **It's normal and expected to have several branches alive at once** — one per feature, fix, or experiment. Don't try to force everything into a single branch. Name them clearly so it's obvious what each is for.
- **Only merge into `main` when the branch is verified working** — tests pass, it builds, and (if using PRs) it's been reviewed/approved. Prefer merging via `gh pr merge` (or a PR merge on GitHub) over merging locally and pushing directly to `main`, so there's a review record and CI gets a chance to run.
- **Keep branches in sync with `main`** to avoid painful conflicts later — periodically merge or rebase `main` into a long-lived feature branch (`git merge main` or `git rebase main` while on the feature branch), especially before opening a PR.
- **Clean up after merging.** Once a branch is merged into `main`, delete it (locally and on the remote) so the branch list doesn't accumulate stale clutter:
  ```bash
  git branch -d <branch-name>                 # local, only if merged
  git push origin --delete <branch-name>       # remote
  gh pr merge <number> --delete-branch          # does both in one step, via gh
  ```
- **If asked to "fix something quickly on main"**, still push back gently: suggest a short-lived branch even for small fixes, unless the user explicitly overrides.

### Pushing

```bash
git push -u origin <branch-name>     # first push of a new branch
git push                              # subsequent pushes
```

If the push is rejected (non-fast-forward), do NOT force-push automatically — explain that the remote has commits the local branch doesn't, and offer `git pull --rebase` (rewrites local commits on top of remote) vs `git merge` (creates a merge commit) as options, unless the user has a standing preference.

### Opening a pull request (via `gh`)

```bash
gh pr create --title "<title>" --body "<description>" --base <base-branch>
```

- Derive the title/body from the actual commits on the branch (`git log <base>..HEAD --oneline`), not just the user's one-line request.
- If the repo has a PR template (`.github/PULL_REQUEST_TEMPLATE.md`), read it and fill it in rather than ignoring it.
- Push the branch first if it isn't already on the remote.
- Report back the PR URL that `gh` returns — don't construct one manually.

Reviewing/checking PRs:
```bash
gh pr list
gh pr view <number> --comments
gh pr diff <number>
gh pr checks <number>
```

### Resolving merge conflicts

```bash
git status                     # shows conflicted files
```
For each conflicted file: read the `<<<<<<<` / `=======` / `>>>>>>>` markers, understand both sides' intent (check `git log` on both branches if unclear), and produce a merged version that preserves both changes' intent rather than blindly picking one side. Show the user the resolution for anything non-trivial before finalizing. Then:
```bash
git add <resolved-file>
git commit            # for a merge; or `git rebase --continue` mid-rebase
```

### Rebasing / cleaning up history

Only do this on branches the user confirms are theirs alone (not shared/already-reviewed), or with explicit confirmation:

```bash
git rebase -i <base-branch>          # interactive: reorder, squash, reword
git rebase <base-branch>             # replay commits on top of latest base
```

After a rebase that's already been pushed once, the follow-up push needs:
```bash
git push --force-with-lease          # safer than --force: fails if remote has new commits you haven't seen
```
Always prefer `--force-with-lease` over `--force`, and always confirm with the user before force-pushing at all.

### Undoing things

- Uncommitted changes to a file: `git restore <file>` (or `git checkout -- <file>` on older git)
- Unstage but keep changes: `git restore --staged <file>`
- Last commit, keep changes staged: `git reset --soft HEAD~1`
- Last commit, discard changes: `git reset --hard HEAD~1` — **confirm first**, this is destructive
- Already pushed and shared: prefer `git revert <commit>` (adds a new commit undoing the change) over rewriting history

### Issues (via `gh`)

```bash
gh issue create --title "<title>" --body "<description>"
gh issue list
gh issue view <number>
gh issue close <number>
```

### Releases and tags

```bash
git tag -a v1.2.0 -m "<release notes summary>"
git push origin v1.2.0
gh release create v1.2.0 --title "v1.2.0" --notes "<notes>"
```

For release notes, prefer generating from merged PRs/commits since the last tag (`git log <last-tag>..HEAD --oneline`, or `gh release create --generate-notes`) over inventing a summary.

### Investigating history

```bash
git log --oneline --graph -20        # recent history, visual
git log -p -- <file>                  # history of a specific file
git blame <file>                      # who changed each line, when
git log --all --grep="<term>"         # search commit messages
```

## .gitignore / repo hygiene

When asked to add a `.gitignore` or clean up tracked files that shouldn't be tracked:
```bash
git rm --cached <file>       # untrack without deleting locally
```
Check for an existing `.gitignore` and add to it rather than overwriting, and match the project's language/tooling (check for `package.json`, `requirements.txt`, etc.) to pick sensible default ignores rather than guessing generically.

## Safety nets — common gaps to watch for

These are easy to miss and cause real damage or lost work. Check for them proactively, not just when something breaks.

- **Uncommitted work before switching branches.** `git checkout`/`switch` can carry uncommitted changes onto the new branch or, worse, refuse and block you confusingly. Always check `git status` before switching; if there are changes that aren't ready to commit, `git stash push -m "<description>"` first, and remind the user it's stashed (`git stash list` / `git stash pop` to bring it back). Don't let a stash silently disappear — mention it.
- **Working on `main` by accident.** Always check the current branch before making changes described above; redirect to a branch first for anything nontrivial.
- **Detached HEAD state.** If `git status` reports "HEAD detached at ...", any new commits will be orphaned and lost once you switch away. Flag this immediately and create a branch to hold the work (`git switch -c <branch-name>`) before committing further.
- **Stale local `main`.** Before branching off `main` or merging into it, `git fetch` and check whether local `main` is behind `origin/main`; pull first so new branches start from current code and merges don't fight stale history.
- **Force-pushing to `main` or a shared branch.** Treat this as effectively forbidden — refuse by default and require explicit, unambiguous confirmation, since it can destroy others' work.
- **Losing commits after a reset/rebase gone wrong.** They're usually still recoverable via `git reflog` (shows every HEAD movement, including "lost" commits) — know this exists and use it before telling the user something is unrecoverable.
- **Secrets or large files committed by mistake.** If a secret was committed (even if since removed in a later commit), it's still in history and needs `git filter-repo` or GitHub's secret-scanning remediation — plus rotating the leaked credential. A later commit that just deletes the line does NOT remove it from history; say so explicitly. For accidentally-tracked large files/binaries, `git rm --cached` and add to `.gitignore` going forward.
- **`.gitignore` added too late.** If files that should've been ignored are already tracked, adding them to `.gitignore` alone won't untrack them — needs `git rm --cached <file>` too.
- **Diverged/behind branches.** Before pushing, `git fetch` and check if the remote has moved (`git status` will show "ahead/behind" info after a fetch) so pushes don't get surprise-rejected mid-task.
- **Multiple remotes or forks.** If `git remote -v` shows more than one remote (e.g. `origin` + `upstream` for a fork), confirm which one to push to / open the PR against rather than assuming `origin`.
- **Line-ending / cross-platform diffs.** If diffs show whole files as changed when only line endings differ, check for a missing or inconsistent `.gitattributes` (`* text=auto`) rather than treating it as a real content change.
- **Submodules silently out of sync.** If the repo has a `.gitmodules` file, `git status` may not show submodule changes by default — run `git submodule status` when working near submodule paths.
- **Empty or no-op commits from failed staging.** If `git commit` says "nothing to commit," the `git add` likely didn't match anything (bad path, or the file is gitignored) — check rather than assuming the commit went through.
- **CI failing silently.** After pushing or opening a PR, check `gh pr checks <number>` (or `gh run list` for Actions) rather than assuming green; report actual failures back with the failing job name, not just "checks may be running."

## Reporting back

After any git/GitHub operation, summarize concretely: what was committed/pushed/opened, the branch name, and any real URL or PR/issue number returned by the tool — not a paraphrase of the request. If something failed (push rejected, conflict, auth error), say exactly what failed and what the fix options are, rather than a generic "something went wrong."
