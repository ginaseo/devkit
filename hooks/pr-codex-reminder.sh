#!/usr/bin/env bash
# PR 생성(gh pr create) 직전에 codex 리뷰 돌렸는지 상기시키는 훅.
# devkit의 model-and-review-policy 정책("코드 리뷰는 codex MCP 우선")을
# SDD 최종리뷰(opus)로 착각해서 빼먹는 패턴이 반복돼서 추가함.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"REMINDER: gh pr create 실행 직전이다 — 이 브랜치에 codex 리뷰(/codex:review 또는 codex-companion.mjs review --base origin/main --scope branch)를 이미 돌렸는지 확인해라. 아직 안 돌렸으면 PR 생성 전에 먼저 돌려라."}}
JSON
