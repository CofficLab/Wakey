#!/bin/bash
# 遍历 Packages/ 下所有含源码的包，逐一运行 swift test 并汇总结果。
# 用法：scripts/test-all-packages.sh
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

PASS=()
FAIL=()
SKIP=()

for dir in Packages/*/; do
    pkg="$(basename "$dir")"

    # 跳过空目录（只剩 .swiftpm 残留）
    if [ ! -d "$dir/Sources" ] || [ -z "$(find "$dir/Sources" -name '*.swift' 2>/dev/null | head -1)" ]; then
        SKIP+=("$pkg")
        continue
    fi

    if [ ! -d "$dir/Tests" ]; then
        FAIL+=("$pkg (缺少 Tests 目录)")
        continue
    fi

    if output=$(cd "$dir" && swift test 2>&1); then
        line=$(echo "$output" | grep -oE "Test run with [0-9]+ tests? in [0-9]+ suites? passed" | tail -1)
        count=$(echo "$line" | grep -oE "[0-9]+" | head -1)
        PASS+=("$pkg: ${count:-?} tests")
    else
        reason=$(echo "$output" | grep -E "error:|signal code|Expectation failed" | head -1)
        FAIL+=("$pkg: ${reason:-测试失败}")
    fi
done

echo "================ 测试结果 ================"
echo "✅ 通过 (${#PASS[@]})"
for item in "${PASS[@]}"; do echo "   $item"; done

if [ ${#FAIL[@]} -gt 0 ]; then
    echo ""
    echo "❌ 失败 (${#FAIL[@]})"
    for item in "${FAIL[@]}"; do echo "   $item"; done
fi

if [ ${#SKIP[@]} -gt 0 ]; then
    echo ""
    echo "⏭️  跳过空包目录 (${#SKIP[@]}): ${SKIP[*]}"
fi

[ ${#FAIL[@]} -eq 0 ]
