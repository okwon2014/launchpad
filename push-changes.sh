#!/bin/bash
# 파일 재배치 + 코드 패치 commit/push
set -e
cd "$(dirname "$0")"

echo "==> 옛 파일 정리"
rm -fv manifest.json pack.json
rm -rfv mnt

echo "==> git add + commit"
git add -A
if git diff --cached --quiet; then
  echo "    (변경사항 없음)"
else
  git commit -m "Restructure sound packs into sounds/; defer AudioContext, harden lib XSS"
fi

echo "==> push"
git push

echo ""
echo "==> 완료. Pages가 새 빌드를 만드는 데 1~2분 걸립니다."
echo "URL: https://okwon2014.github.io/launchpad/"
