# gina-devkit

개인용 Claude Code 플러그인. 서브에이전트 3개, 커맨드 1개, 스킬 3개로 구성 — 새 프로젝트마다 같은 규칙을 다시 설명할 필요 없이 설치 한 번으로 재사용한다.

## 설치

```
/plugin marketplace add ginaseo/gina-devkit
/plugin install gina-devkit
```

## 들어있는 것

### 서브에이전트 (`agents/`)

작업 난이도별로 모델을 고정해둔 3개. `Agent` 도구로 `subagent_type`에 이름을 지정해 위임한다.

| 이름 | 모델 | 역할 |
|---|---|---|
| `explorer` | haiku | 읽기 전용 탐색 — 파일 위치, 함수 정의, 호출부 찾기. 코드 수정 안 함 |
| `implementer` | sonnet | 기능 구현·버그 수정. 테스트도 같이 작성 |
| `architect` | opus | 설계·아키텍처 결정, 복잡한 버그의 근본원인 분석. 성급하게 고치지 않고 먼저 분석·계획 제시 |

### 커맨드 (`commands/`)

| 커맨드 | 설명 |
|---|---|
| `/review` | 코드 리뷰. codex MCP(`/codex:review`)를 우선 쓰고, rate limit이나 codex 미설치로 실패하면 opus가 직접 리뷰로 전환. 결과가 나오면 그대로 끝내지 않고 파일:라인 직접 확인 + 호출부 유무로 실사용버그/잠복결함 판정까지 자동으로 이어감 |

### 스킬 (`skills/`)

플러그인 설치 시 세션에 자동으로 노출되는 정책 문서 3개.

| 스킬 | 담당 |
|---|---|
| `model-and-review-policy` | 모델 선택 사다리(기계적=haiku / 일반구현=sonnet / 설계·최종리뷰=opus) + `/review` 결과 타당성검토 절차 |
| `plugin-routing` | 작업 요청이 들어오면 성격을 파악해 아래 "플러그인별 사용 시점" 표에 맞는 플러그인을 기본 동작보다 먼저 검토·사용 |
| `plugin-check` | `plugin-routing`이 지목한 플러그인이 세션에 없을 때, 실제 미설치인지 확인하고 설치 명령을 제시(자동 설치는 안 함 — 훅으로 임의 코드 실행 가능해 항상 사용자 확인) |

## 플러그인별 사용 시점 (`plugin-routing`이 참조하는 표)

같은 역할을 하는 플러그인이 여러 개일 때 뭘 먼저 쓸지 정리한 것.

| 플러그인 | 이 업무일 때 쓴다 |
|---|---|
| **superpowers** | 기능구현·버그수정 방법론 전체(TDD, 계획수립, subagent 실행, 체계적 디버깅) 필요할 때 |
| **codex** | 코드 리뷰 1순위(`/codex:review`, 이 킷의 `/review`가 이걸 감쌈), 또는 막혔을 때 2차 의견 |
| **karpathy-skills** | 코드 짜거나 리팩터할 때 과설계 방지, 인접 코드 안 건드리기, 숨은 가정 표면화, 완료기준 명확히 |
| **ponytail** | 의도적으로 단순화한 부분을 나중에 추적 가능하게 남겨야 할 때(`ponytail:` 주석 + 부채 원장) |
| **humanizer** | 영어로 쓴 글의 AI 티 제거 |
| **humanize-korean** | 한글로 쓴 글의 AI 티 제거 |
| **figma** | Figma 디자인 읽기/쓰기, 코드↔디자인 변환 |

`caveman`(대화 톤)·`claude-dashboard`(사용량 관측)는 작업 성공/효율과 무관해 라우팅 대상이 아니다 — 필요하면 개별 설치.

## 함께 쓰는 플러그인 — 설치 명령

Claude Code 플러그인은 다른 플러그인을 의존성으로 선언해 자동 설치하는 기능이 없다(직접 확인함 — 설치된 모든 플러그인 매니페스트에 그런 필드 없음). 그래서 코드로 묶어 넣는 대신, 정확한 설치 명령을 여기 남겨둔다. 로컬 캐시 경로가 아니라 각자의 GitHub 소스라 어느 기기에서든 그대로 동작한다.

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install superpowers@claude-plugins-official
/plugin install figma@claude-plugins-official

/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex

/plugin marketplace add forrestchang/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills

/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail

/plugin marketplace add blader/humanizer
/plugin install humanizer@humanizer

/plugin marketplace add epoko77-ai/im-not-ai
/plugin install humanize-korean@im-not-ai

/plugin marketplace add JuliusBrussee/caveman
/plugin install caveman@caveman

/plugin marketplace add uppinote20/claude-dashboard
/plugin install claude-dashboard@claude-dashboard
```

`claude-plugins-official` 마켓플레이스 하나에 `superpowers`와 `figma`가 같이 들어있어서 그 둘은 `marketplace add`를 한 번만 하면 된다.

`superpowers`·`codex`는 없으면 `/review`·서브에이전트 실행이 대체 경로(opus 직접 리뷰, 방법론 없이 진행)로 동작하고, `karpathy-skills`·`ponytail`·`humanizer`·`humanize-korean`·`figma`는 없으면 `plugin-check`가 감지해서 설치 명령을 제시한다. `caveman`·`claude-dashboard`는 순수 선택 사항.

## 왜 CLAUDE.md가 아니라 스킬인가

CLAUDE.md는 프로젝트 루트 파일이라 플러그인이 자동으로 심어줄 수 없다. 대신 스킬로 만들면 플러그인 설치만으로 모든 프로젝트에서 같은 내용이 세션에 노출된다 — 프로젝트마다 CLAUDE.md에 이 내용을 복붙할 필요가 없다.

## 배경

[PassFlow](https://github.com/ginaseo/passflow) 프로젝트에서 처음 만들어 쓰다가, 다른 프로젝트에도 재사용하려고 플러그인으로 분리했다.
