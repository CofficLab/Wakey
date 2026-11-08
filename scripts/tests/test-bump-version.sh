#!/bin/bash
# bump-version.sh 的回归测试：构造若干临时仓库，校验每种提交约束输出。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BUMP="$SCRIPT_DIR/.github/scripts/bump-version.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git init -q "$TMP/repo"
cd "$TMP/repo" || exit 1
git config user.email test@example.com
git config user.name test
git commit -q --allow-empty -m "chore: init"
git tag v0.0.0
cp "$BUMP" ./bump-version.sh
chmod +x ./bump-version.sh

fail=0
check() {
    local expected="$1" message="$2"
    local actual
    actual="$(./bump-version.sh)"
    if [ "$actual" != "$expected" ]; then
        echo "❌ $message: 期望 $expected，实际 $actual"
        fail=1
    else
        echo "✅ $message -> $actual"
    fi
    git reset -q --hard HEAD~1
}

git commit -q --allow-empty -m "feat(theme): x"
check minor "带 scope 的 feat"
git commit -q --allow-empty -m "feat!: x"
check major "无 scope 的破坏性 feat"
git commit -q --allow-empty -m "feat(api)!: x"
check major "带 scope 的破坏性 feat"
git commit -q --allow-empty -m "chore(x): x" -m "BREAKING CHANGE: y"
check major "BREAKING CHANGE 页脚"
git commit -q --allow-empty -m "fix(x): x"
check patch "带 scope 的 fix"
git commit -q --allow-empty -m "chore: x"
check patch "非功能提交"

exit "$fail"
