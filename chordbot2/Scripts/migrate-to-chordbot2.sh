#!/usr/bin/env bash
# Migrates the chordbot2/ subtree from spacehaze/encryption (this repo)
# into a dedicated GitHub repo as that repo's main branch, preserving the
# git history of just the Chordbot2 work.
#
# Run this from a clone of spacehaze/encryption, on the
# claude/recreate-iphone-app-MS2mj branch (or any branch that contains
# chordbot2/). Does not modify your current branch.
#
# By default this targets spacehaze/chordmate (the original GitHub repo
# even though the project was renamed to Chordbot2). Override with:
#     DEST_REMOTE=https://github.com/spacehaze/chordbot2.git ./migrate-to-chordbot2.sh

set -euo pipefail

DEST_REMOTE="${DEST_REMOTE:-https://github.com/spacehaze/chordmate.git}"
DEST_BRANCH="${DEST_BRANCH:-main}"
SUBTREE="${SUBTREE:-chordbot2}"
WORK_BRANCH="chordbot2-only"
REMOTE_NAME="chordbot2-dest"

if [[ ! -d "$SUBTREE" ]]; then
    echo "error: '$SUBTREE/' not found. Run from the encryption repo root, on a branch that contains it." >&2
    exit 1
fi

echo "==> Extracting $SUBTREE/ as $WORK_BRANCH (rewriting paths to root)..."
if git show-ref --verify --quiet "refs/heads/$WORK_BRANCH"; then
    git branch -D "$WORK_BRANCH"
fi
git subtree split --prefix="$SUBTREE" -b "$WORK_BRANCH"

echo "==> Configuring remote $REMOTE_NAME -> $DEST_REMOTE ..."
if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
    git remote set-url "$REMOTE_NAME" "$DEST_REMOTE"
else
    git remote add "$REMOTE_NAME" "$DEST_REMOTE"
fi

echo "==> Pushing $WORK_BRANCH -> $REMOTE_NAME/$DEST_BRANCH ..."
if git push "$REMOTE_NAME" "$WORK_BRANCH:$DEST_BRANCH"; then
    echo "Done. $DEST_REMOTE"
    exit 0
fi

echo
echo "Push rejected — the destination repo probably has an auto-generated"
echo "initial commit (README/license)."
echo "Re-run with FORCE=1 to overwrite, or rebase first:"
echo "    FORCE=1 $0"
echo "    # — or —"
echo "    git fetch $REMOTE_NAME"
echo "    git rebase $REMOTE_NAME/$DEST_BRANCH $WORK_BRANCH"
echo "    git push $REMOTE_NAME $WORK_BRANCH:$DEST_BRANCH"

if [[ "${FORCE:-0}" == "1" ]]; then
    echo "==> FORCE=1 set; force-pushing..."
    git push --force "$REMOTE_NAME" "$WORK_BRANCH:$DEST_BRANCH"
    echo "Done. $DEST_REMOTE"
fi
