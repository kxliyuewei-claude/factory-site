#!/bin/zsh
set -euo pipefail

REPO="kxliyuewei-claude/factory-site"
BRANCH="main"

cd "$(dirname "$0")"

if [[ ! -d .git ]]; then
  git init
  git checkout -b "$BRANCH"
fi

git add index.html privacy support deploy.sh deploy-github-pages.md deploy-cloudflare-pages.md 2>/dev/null || git add .
git commit -m "Deploy app support pages" || true

if ! gh repo view "$REPO" >/dev/null 2>&1; then
  gh repo create "$REPO" --public --source=. --remote=origin --push
else
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "https://github.com/$REPO.git"
  fi
  git push -u origin "$BRANCH"
fi

gh api -X POST "repos/$REPO/pages" -f source.branch="$BRANCH" -f source.path="/" >/dev/null 2>&1 || true
gh api -X PUT "repos/$REPO/pages" -f source.branch="$BRANCH" -f source.path="/" >/dev/null 2>&1 || true

echo "Factory site deployed:"
echo "https://kxliyuewei-claude.github.io/factory-site/privacy/fretmeasure-log.html"
echo "https://kxliyuewei-claude.github.io/factory-site/support/fretmeasure-log.html"
