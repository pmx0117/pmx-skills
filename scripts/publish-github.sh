#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd -- "$repo_dir"

for tool in git gh; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '缺少命令：%s。请安装后重试。\n' "$tool" >&2
    exit 1
  fi
done

if [[ -e .git ]]; then
  printf '本目录已有 Git 元数据，请先人工核对；脚本不会覆盖。\n' >&2
  exit 1
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web
fi

account="$(gh api --hostname github.com user --jq '.login')"
account_id="$(gh api --hostname github.com user --jq '.id')"
remote_repo="${account}/pmx-skills"

# 成功读取仓库列表后检查同名仓库，避免把网络或认证错误当成不存在。
repo_names="$(gh api --hostname github.com --paginate 'user/repos?affiliation=owner&per_page=100' --jq '.[].full_name')"
while IFS= read -r existing_repo; do
  if [[ "${existing_repo,,}" == "${remote_repo,,}" ]]; then
    printf 'GitHub 仓库 %s 已存在，请先人工核对。\n' "$remote_repo" >&2
    exit 1
  fi
done <<< "$repo_names"

git init -b main
if ! git config user.name >/dev/null; then
  git config --local user.name "$account"
fi
if ! git config user.email >/dev/null; then
  git config --local user.email "${account_id}+${account}@users.noreply.github.com"
fi

git add -- README.md AGENTS.md .gitignore scripts/publish-github.sh skills/install-app
git diff --cached --stat
git commit -m 'Add install-app skill and distribution documentation'
gh auth setup-git --hostname github.com
gh repo create "$remote_repo" --private --source=. --remote=origin --push
printf '已创建并推送私有仓库：https://github.com/%s\n' "$remote_repo"
