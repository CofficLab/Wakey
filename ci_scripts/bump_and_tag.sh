#!/bin/bash
# ============================================================
# bump_and_tag.sh — Wakey 版本 bump + tag 脚本
# ============================================================
# 用法:
#   ./ci_scripts/bump_and_tag.sh                # bump + commit + push + tag
#   ./ci_scripts/bump_and_tag.sh --dry-run      # 只打印计划，不改动
#   ./ci_scripts/bump_and_tag.sh --no-push      # 本地 commit + tag，不推送
#
# 依赖: bash 3.2+ (macOS 自带), git
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${WORKSPACE_ROOT}"

PROJECT_FILE="Wakey.xcodeproj/project.xcproj"
TAG_PREFIX="v"

# ------------------------------------------------------------
# 参数解析
# ------------------------------------------------------------
DRY_RUN=false
DO_PUSH=true

for arg in "$@"; do
  case "${arg}" in
    --dry-run) DRY_RUN=true ;;
    --no-push) DO_PUSH=false ;;
    -h|--help)
      echo "用法: bump_and_tag.sh [--dry-run] [--no-push]"
      exit 0
      ;;
    *) echo "未知选项: ${arg}" >&2; exit 2 ;;
  esac
done

# ------------------------------------------------------------
# 前置检查
# ------------------------------------------------------------
if [[ ! -f "${PROJECT_FILE}" ]]; then
  echo "ERROR: 找不到 ${PROJECT_FILE}" >&2
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: 当前目录不是 git 仓库" >&2
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "ERROR: 工作区有未提交改动，请先 commit 或 stash：" >&2
  git status --short >&2
  exit 1
fi

# ------------------------------------------------------------
# 读取当前版本
# ------------------------------------------------------------
current_version="$(grep -E '"MARKETING_VERSION"' "${PROJECT_FILE}" | head -n 1 | sed 's/.*"MARKETING_VERSION"[[:space:]]*:[[:space:]]*"//' | sed 's/".*//')"

IFS='.' read -r major minor patch <<< "${current_version}"
if [[ -z "${major:-}" || -z "${minor:-}" || -z "${patch:-}" ]]; then
  echo "ERROR: 期望 MARKETING_VERSION 为 x.y.z 格式，得到: '${current_version}'" >&2
  exit 1
fi

new_version="${major}.${minor}.$((patch + 1))"
tag="${TAG_PREFIX}${new_version}"

echo "==> [bump_and_tag] 当前版本 : ${current_version}"
echo "==> [bump_and_tag] 新版本   : ${new_version}"
echo "==> [bump_and_tag] 新 tag   : ${tag}"
echo "==> [bump_and_tag] 当前分支 : ${CURRENT_BRANCH}"

# ------------------------------------------------------------
# tag 已存在则跳过
# ------------------------------------------------------------
git fetch --tags --force 2>/dev/null
if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
  echo "==> [bump_and_tag] tag ${tag} 已存在，跳过 bump。"
  exit 0
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  echo ""
  echo "==> [bump_and_tag] --dry-run：以下为计划，不会实际执行。"
  echo "    1. 改写 ${PROJECT_FILE} 中 MARKETING_VERSION = ${new_version}"
  echo "    2. git commit -m \"ci: bump to ${new_version}\""
  echo "    3. git push origin HEAD:${CURRENT_BRANCH}"
  echo "    4. git tag -a ${tag} -m \"Release ${tag}\" && git push origin ${tag}"
  exit 0
fi

# ------------------------------------------------------------
# 改写版本号并提交
# ------------------------------------------------------------
sed -i '' "s/\"MARKETING_VERSION\": \"${current_version}\"/\"MARKETING_VERSION\": \"${new_version}\"/" "${PROJECT_FILE}"

if ! grep -q "\"MARKETING_VERSION\": \"${new_version}\"" "${PROJECT_FILE}"; then
  echo "ERROR: MARKETING_VERSION 未成功写入 ${PROJECT_FILE}" >&2
  exit 1
fi

git add "${PROJECT_FILE}"
git commit -m "ci: bump to ${new_version}"
echo "==> [bump_and_tag] 已提交版本 bump: ${new_version}"

if [[ "${DO_PUSH}" == "false" ]]; then
  git tag -a "${tag}" -m "Release ${tag}"
  echo "==> [bump_and_tag] --no-push：跳过推送。"
  echo "    手动推送: git push origin HEAD:${CURRENT_BRANCH} && git push origin ${tag}"
  exit 0
fi

# ------------------------------------------------------------
# 推送分支（带重试）
# ------------------------------------------------------------
max_retries=5
push_branch_ok=false
for attempt in $(seq 1 "${max_retries}"); do
  echo "==> [bump_and_tag] 分支推送 第 ${attempt}/${max_retries} 次"
  if git pull --rebase origin "${CURRENT_BRANCH}" \
    && git push origin "HEAD:${CURRENT_BRANCH}"; then
    push_branch_ok=true
    break
  fi
  echo "    推送失败，等待后重试..."
  sleep $((attempt * 3))
  git fetch origin "${CURRENT_BRANCH}"
done

if [[ "${push_branch_ok}" != "true" ]]; then
  echo "ERROR: 分支推送重试 ${max_retries} 次后仍失败。" >&2
  echo "      手动恢复: git push origin HEAD:${CURRENT_BRANCH}" >&2
  exit 1
fi

# ------------------------------------------------------------
# 打 tag 并推送（带重试）
# ------------------------------------------------------------
git tag -a "${tag}" -m "Release ${tag}"
push_tag_ok=false
for attempt in $(seq 1 "${max_retries}"); do
  echo "==> [bump_and_tag] tag 推送 第 ${attempt}/${max_retries} 次"
  if git push origin "${tag}"; then
    push_tag_ok=true
    break
  fi
  sleep $((attempt * 3))
done

if [[ "${push_tag_ok}" != "true" ]]; then
  echo "ERROR: tag 推送重试 ${max_retries} 次后仍失败。" >&2
  echo "      手动推送: git push origin ${tag}" >&2
  exit 1
fi

echo ""
echo "==> [bump_and_tag] ✅ 完成！版本 ${new_version}，tag ${tag} 已推送。"
