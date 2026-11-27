# Upstream sync playbook for the no-Gemini fork

This file is the quick-start guide for the next OpenCode session asked to update this fork from the original source at `../Vivaldi-Tree-Style-Tabs`.

## What this fork is

This repository is a **source-only**, no-Gemini fork of `R0STEFAN/Vivaldi-Tree-Style-Tabs`. It is a Vivaldi `custom.js` UI modification, not a browser extension. It publishes no releases: users build `dist/custom.js` themselves with `npm run build`.

The fork tracks upstream releases but preserves a small set of deliberate differences. The whole point of a sync is to take upstream's bug fixes without losing those differences or bringing Gemini back.

## Baseline at the last sync

As of 2026-11-27:

- Upstream `main` was at **v2.3.9**, commit `b40174d`.
- The fork merged it in commit `a9c1901`; the fork's version is `2.3.9-nogemini`.
- A local git remote named `upstream` points at `../Vivaldi-Tree-Style-Tabs`.
- The full test suite was **144/144** passing.
- Upstream had an unrelated uncommitted mode-only change to `patch-linux.sh`. Do not touch changes in the upstream working tree.

Treat these as a starting point, not as invariants. Always inspect both repos again.

## Non-negotiable fork deltas

These must survive every upstream sync:

1. **Gemini excluded.** No `src/services/gemini-api.js`, no `aiGroupTabs` store action, no AI header button, no AI settings block, no toast system, and no `fetch` call to an AI service.
2. **Legacy-key cleanup stays.** `src/store/settings-store.js` deletes `geminiApiKey`, `geminiModel`, and `geminiFolderLanguage` from stored settings on load. Historical mentions in `CHANGELOG.md`, `README.md`, and `.agents/` are acceptable.
3. **Debian/Ubuntu install.** `install-linux.sh` installs `/etc/apt/apt.conf.d/99vivaldi-patch` and symlinks `dist/custom.js` and `dist/svb-folder.html` into `~/.local/share/vivaldi-patch/`, so `npm run build` is picked up without reinstalling. `patch-linux.sh` is executable and Linux-oriented. No pacman hook.
4. **Tab title font size selector.** `tabTitleFontSize` exists in `src/store/settings-store.js`, the Settings `<select>` and live CSS-variable update are in `src/ui/render.js`, and the CSS rules are in `src/ui/styles.js`.
5. **Fork-scoped updater.** `updater/github.go` and `updater/README.md` point at `proapocalyptic/Vivaldi-Tree-Style-Tabs-no-gemini`, never at upstream releases.

`GEMINI.md` is architecture background only; it is not an OpenCode instruction file and should not be used as a sync guide.

## Recommended sync procedure

1. **Inspect both repositories before editing.**
   - Fork: `git status --short --branch` — never overwrite uncommitted user work.
   - Upstream: `git -C ../Vivaldi-Tree-Style-Tabs status --short --branch` — leave upstream's own changes alone.
   - Inspect the new work: `git log --oneline <merge-base>..upstream/main` after fetching.

2. **Bring in upstream tests first (red/green).**
   - Copy the new or changed upstream test files into the fork and run only those tests. They should fail for the expected missing behavior.
   - Commit that test-only checkpoint if git will not otherwise let you merge over staged test changes. The last sync used commit `11205e7` for this.
   - Do not weaken or skip upstream tests to make a merge easier.

3. **Merge, do not rebase or cherry-pick.**
   - If the `upstream` remote is missing: `git remote add upstream ../Vivaldi-Tree-Style-Tabs`.
   - Then: `git fetch upstream main` and `git merge --no-commit --no-ff upstream/main`.
   - Merge preserves upstream commit ancestry and gives one clear fork merge commit.

4. **Resolve conflicts deliberately.** Likely conflict areas:
   - `src/entry.js` — take upstream's mount/window checks, but keep the fork's missing `onAiGroupTabs` callback.
   - `src/store/tab-store.js` — take upstream's event filtering, but keep the fork's removed Gemini action and removed `gemini-api.js` import.
   - `CHANGELOG.md` and `RELEASE_NOTES.md` — combine upstream's release notes with the fork's removal/change notes.
   - `dist/custom.js` — do not hand-merge. Take either side temporarily, then regenerate it from source with `npm run build`.
   - Fork-owned files (`install-linux.sh`, `patch-linux.sh`, `src/ui/render.js`, `src/ui/styles.js`, `src/store/settings-store.js`, `updater/*`) should normally stay as they are; verify after the merge anyway.

5. **Regenerate the bundle and test.**
   - `npm run build`
   - `node --test tests/*.test.js`
   - The build should be deterministic: a second `npm run build` should not change `dist/custom.js`.

6. **Update version and docs.**
   - Set `package.json` to the upstream version with a `-nogemini` suffix, for example `2.3.9-nogemini`.
   - Update `README.md`, `CHANGELOG.md`, and `RELEASE_NOTES.md` to say which upstream version is tracked, list upstream's new fixes, and retain the fork-difference sections.
   - Update the test count in `RELEASE_NOTES.md` to the actual number from the final test run.

7. **Verify the fork deltas explicitly.**
   - Functional Gemini markers should be absent:

     ```sh
     grep -rn -e 'onAiGroupTabs' -e 'aiGroupTabs' -e 'groupTabsWithGemini' \
       -e 'fetchAvailableModels' -e 'aistudio.google.com' -e 'gemini-api.js' \
       src dist
     ```

     Expected: no output. The legacy setting name `geminiApiKey` is expected only in the cleanup logic and generated bundle.
   - Preserved-feature checks:

     ```sh
     grep -n '99vivaldi-patch' install-linux.sh
     grep -n 'tabTitleFontSize' src/store/settings-store.js src/ui/render.js src/ui/styles.js
     grep -n 'proapocalyptic/Vivaldi-Tree-Style-Tabs-no-gemini' updater/github.go
     ```

8. **Check the tree and commit.**
   - `git diff --check`
   - Confirm no conflict markers remain: `grep -rn '^<<<<<<<\|^=======$\|^>>>>>>>' --exclude-dir=.git .`
   - `git status --short` should show only intended changes.
   - Commit locally. Do not push unless explicitly asked.

## What to do if tests fail after the merge

Treat a failing upstream test as an integration mistake, not as a reason to edit the test. Re-read the conflict resolution in the relevant source file, then fix the source. If the cause is unclear, use the systematic-debugging workflow and write a minimal failing reproduction before changing code.

## Future maintenance note

Whenever this playbook's facts change — a new upstream version, a new fork-only behavior, or a changed verification command — update this file in the same commit as the change that caused it. That keeps the next sync cheap.
