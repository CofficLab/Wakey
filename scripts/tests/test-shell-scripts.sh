#!/bin/bash
# 回归测试：确保打包脚本在 bash 3.2 下的失败汇总与签名脚本的关键不变量。
set -uo pipefail

ROOT="${ROOT_OVERRIDE:-$(cd "$(dirname "$0")/../.." && pwd)}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0

# 1) 没有 Packages 目录时，脚本应该正常跳过并退出 0。
bash "$ROOT/scripts/test-all-packages.sh" > "$TMP/no-pkg.log" 2>&1
code=$?
if [ "$code" -ne 0 ]; then
    echo "❌ 无 Packages 目录时应以 0 退出，实际 ${code}"
    fail=1
fi
if ! grep -q "跳过" "$TMP/no-pkg.log"; then
    echo "❌ 没有输出跳过提示"
    fail=1
fi

# 2) 签名脚本必须追加而非替换 keychain 搜索列表，且不泄漏 errexit。
SIGNING="$ROOT/.github/scripts/setup-macos-signing.sh"
if ! grep -q 'security list-keychain -d user -s "$KEYCHAIN_PATH" $(security list-keychain -d user' "$SIGNING"; then
    echo "❌ keychain 搜索列表不是追加写法"
    fail=1
fi
if grep -q "PP_PATH" "$SIGNING"; then
    echo "❌ 仍在输出未定义的 PP_PATH"
    fail=1
fi
if ! grep -q "had_errexit" "$SIGNING"; then
    echo "❌ 没有恢复调用方的 errexit 状态"
    fail=1
fi
if ! grep -Fq "sed -n 's/.*(" "$SIGNING"; then
    echo "❌ TEAM_ID 仍未锚定括号"
    fail=1
fi

if [ "$fail" -eq 0 ]; then
    echo "✅ 脚本不变量测试通过"
fi
exit "$fail"
