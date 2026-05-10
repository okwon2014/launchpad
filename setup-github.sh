#!/bin/bash
# launchpad_files를 GitHub private repo로 만들고 GitHub Pages로 배포
set -e

REPO_NAME="launchpad"
cd "$(dirname "$0")"

echo "==> 1. git 상태 확인"
if [ ! -d .git ]; then
  git init -b main
fi
# 마운트 잔여물이 있을 수 있으므로 안전하게 정리
rm -f .git/index.lock 2>/dev/null || true

# 사용자 정보 미설정 시 기본값
git config user.email >/dev/null 2>&1 || git config user.email "kwon.ohkyung@gmail.com"
git config user.name  >/dev/null 2>&1 || git config user.name  "okwon2014"

echo "==> 2. 변경사항 커밋"
git add -A
if git diff --cached --quiet; then
  echo "    (커밋할 변경사항 없음)"
else
  git commit -m "Initial commit: launchpad files"
fi

echo "==> 3. gh CLI 확인"
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh가 설치돼 있지 않습니다."
  echo "다음 명령으로 설치 후 다시 실행하세요:"
  echo "  brew install gh"
  echo "그리고 인증:"
  echo "  gh auth login"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh 인증이 필요합니다. 다음을 실행하세요:"
  echo "  gh auth login"
  exit 1
fi

echo "==> 4. private repo 생성 + push"
# 이미 remote가 있으면 push만
if git remote get-url origin >/dev/null 2>&1; then
  echo "    (origin remote 이미 존재 — push만 시도)"
  git push -u origin main
else
  gh repo create "$REPO_NAME" --private --source=. --remote=origin --push
fi

OWNER=$(gh api user -q .login)
echo "    repo: $OWNER/$REPO_NAME"

echo "==> 5. GitHub Pages 활성화 (main / root)"
gh api -X POST "repos/$OWNER/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" 2>&1 || \
gh api -X PUT "repos/$OWNER/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/"

echo ""
echo "==> 완료!"
echo "Pages URL: https://$OWNER.github.io/$REPO_NAME/"
echo "(빌드에 1~2분 정도 걸릴 수 있습니다)"
