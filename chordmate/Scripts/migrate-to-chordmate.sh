#!/usr/bin/env bash
# Migrates the chordmate/ subtree from spacehaze/encryption (this repo)
# into spacehaze/chordmate as that repo's main branch, preserving the
# git history of just the chordmate/ work.
#
# Run this from a clone of spacehaze/encryption, on the
# claude/recreate-iphone-app-MS2mj branch (or any branch that contains
# chordmate/). Does not modify your current branch.

set -euo pipefail

DEST_REMOTE="${DEST_REMOTE:-https://github.com/spacehaze/chordmate.git}"
DEST_BRANCH="${DEST_BRANCH:-main}"
SUBTREE="${SUBTREE:-chordmate}"
WORK_BRANCH="chordmate-only"

if [[ ! -d "$SUBTREE" ]]; then
    echo "error: '$SUBTREE/' not found. Run from the encryption repo root, on a branch that contains it." >&2
    exit 1
fi

echo "==> Extracting $SUBTREE/ as $WORK_BRANCH (rewriting paths to root)..."
if git show-ref --verify --quiet "refs/heads/$WORK_BRANCH"; then
    git branch -D "$WORK_BRANCH"
fi
git subtree split --prefix="$SUBTREE" -b "$WORK_BRANCH"

echo "==> Adding chordmate remote (if missing)..."
if ! git remote get-url chordmate >/dev/null 2>&1; then
    git remote add chordmate "$DEST_REMOTE"
fi

echo "==> Pushing $WORK_BRANCH -> chordmate/$DEST_BRANCH ..."
if git push chordmate "$WORK_BRANCH:$DEST_BRANCH"; then
    echo "Done. https://github.com/spacehaze/chordmate"
    exit 0
fi

echo
echo "Push rejected — the chordmate repo probably has an auto-generated"
echo "initial commit (README/license)."
echo "Re-run with FORCE=1 to overwrite, or rebase first:"
echo "    FORCE=1 $0"
echo "    # — or —"
echo "    git fetch chordmate"
echo "    git rebase chordmate/$DEST_BRANCH $WORK_BRANCH"
echo "    git push chordmate $WORK_BRANCH:$DEST_BRANCH"

if [[ "${FORCE:-0}" == "1" ]]; then
    echo "==> FORCE=1 set; force-pushing..."
    git push --force chordmate "$WORK_BRANCH:$DEST_BRANCH"
    echo "Done. https://github.com/spacehaze/chordmate"
fi
