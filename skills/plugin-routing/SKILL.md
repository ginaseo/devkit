---
name: plugin-routing
description: 새 작업 요청을 받으면 그 작업 성격을 파악해 아래 표에 맞는 플러그인/스킬을 먼저 검토하고 쓴다. 기본 동작으로 바로 들어가기 전에 이 표부터 훑는다 — 방법론/리뷰/과설계방지/부채추적/윤문/디자인 작업일 가능성이 1%라도 있으면 확인한다.
---

# 플러그인 라우팅

작업 요청이 들어오면, 실행 방식을 정하기 전에 이 표에서 일치하는 행이 있는지 먼저 본다. 있으면 기본 동작(맨손으로 처리) 대신 해당 플러그인 기능을 쓴다. `caveman`·`claude-dashboard`는 작업 성공/효율과 무관해 라우팅 대상이 아니다(관측·톤 전용).

| 작업 성격(트리거) | 플러그인 | 실제로 쓰는 것 |
|---|---|---|
| 여러 단계짜리 기능구현/버그수정, 계획 세우고 실행해야 함, TDD 필요, subagent로 나눠 진행 | **superpowers** | `superpowers:brainstorming`(설계 전), `superpowers:writing-plans`(계획서), `superpowers:subagent-driven-development`(다태스크 실행), `superpowers:systematic-debugging`(버그) 등 상황에 맞는 하위 스킬 |
| 코드 리뷰 요청, PR/diff/브랜치 점검 | **codex** | `/codex:review` 우선 호출 (이 킷의 `/review` 커맨드가 이 흐름 + 실패시 opus fallback + 타당성검토까지 자동 처리하니 `/review`를 기본으로 쓴다) |
| 코드 작성/리팩터 중 — 과설계 방지, 인접 코드 안 건드리기, 숨은 가정 표면화, 완료기준 정의 | **karpathy-skills** | `andrej-karpathy-skills:karpathy-guidelines` |
| 의도적으로 단순화한 부분을 나중에 추적 가능하게 남겨야 함(임시방편, TODO성 코드) | **ponytail** | `ponytail:ponytail` — 코드에 `ponytail:` 주석으로 천장·업그레이드 경로 명시 |
| 영어 텍스트에서 AI가 쓴 티 제거 요청 | **humanizer** | `humanizer:humanizer` |
| 한글 텍스트에서 AI가 쓴 티 제거 요청 | **humanize-korean** | `humanize-korean:humanize-korean` |
| Figma 디자인 읽기/쓰기, 코드↔디자인 변환, 목업 생성 | **figma** | 상황별 figma 스킬(`figma-use`, `figma-design-to-code`, `figma-generate-design` 등) — 대상이 `use_figma`/`get_design_context` 도구 호출 전이면 반드시 대응 스킬부터 로드 |

## 미설치 플러그인을 만났을 때

표의 플러그인이 필요한데 세션에 없으면(스킬 목록에 안 뜨면) 조용히 기본 동작으로 넘어가지 않는다 — `plugin-check` 스킬로 감지하고, 설치 명령을 사용자에게 제시한다(자동 설치는 안 한다 — 플러그인은 훅으로 임의 코드를 실행할 수 있어 설치는 항상 사용자 확인을 거친다).

## 모델 선택은 별개

이 표는 "어떤 플러그인을 쓸지"만 정한다. 그 작업에 어떤 모델을 쓸지는 `model-and-review-policy` 스킬을 따로 따른다 — 플러그인 선택과 모델 선택은 독립적으로 결정한다.
