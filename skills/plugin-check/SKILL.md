---
name: plugin-check
description: plugin-routing 스킬이 특정 플러그인을 쓰라고 지목했는데 그 스킬/에이전트/커맨드가 지금 세션에 안 보일 때, 실제로 미설치인지 확인하고 설치 명령을 사용자에게 제시한다. 자동 설치는 하지 않는다.
---

# 플러그인 설치 여부 확인

`plugin-routing`에서 특정 플러그인을 쓰라고 나왔는데 해당 스킬/에이전트/커맨드가 현재 세션에 노출되지 않으면, 조용히 기본 동작으로 넘어가지 말고 이 절차를 따른다.

## 1. 실제 설치 여부 확인

```bash
grep -A20 '"enabledPlugins"' ~/.claude/settings.json
```

`"<plugin>@<marketplace>": true` 형태로 있으면 설치된 것 — 이 경우 스킬이 안 보이는 건 다른 이유(세션 캐시, 이름 오타 등)이니 미설치로 단정하지 않는다.

## 2. 없으면 설치 명령 제시 (자동 설치 금지)

플러그인은 훅으로 임의 코드를 실행할 수 있어 설치는 항상 사용자 확인을 거친다. 아래 표에서 해당 플러그인의 정확한 설치 명령을 찾아 그대로 제시하고, 사용자가 직접 실행하게 한다.

| 플러그인 | 설치 명령 |
|---|---|
| superpowers | `/plugin marketplace add anthropics/claude-plugins-official` → `/plugin install superpowers@claude-plugins-official` |
| codex | `/plugin marketplace add openai/codex-plugin-cc` → `/plugin install codex@openai-codex` |
| karpathy-skills | `/plugin marketplace add forrestchang/andrej-karpathy-skills` → `/plugin install andrej-karpathy-skills@karpathy-skills` |
| ponytail | `/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail@ponytail` |
| humanizer | `/plugin marketplace add blader/humanizer` → `/plugin install humanizer@humanizer` |
| humanize-korean | `/plugin marketplace add epoko77-ai/im-not-ai` → `/plugin install humanize-korean@im-not-ai` |
| figma | `/plugin marketplace add anthropics/claude-plugins-official` → `/plugin install figma@claude-plugins-official` |

## 3. 사용자가 설치할 때까지

설치 명령만 제시하고, 지금 작업은 해당 플러그인 없이 처리 가능한 범위까지만 진행하거나(예: karpathy-skills 없으면 그냥 스스로 과설계 주의하며 구현), 플러그인이 꼭 필요한 작업이면(예: `/codex:review` 자체가 없는 코드리뷰) 설치부터 하고 다시 요청해달라고 안내한다.
