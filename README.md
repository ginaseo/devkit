# devkit

개인용 Claude Code 플러그인. 서브에이전트 6개, 커맨드 1개, 스킬 10개, 상시 압축 출력 모드(caveman, 벤더링)로 구성 — 새 프로젝트마다 같은 규칙을 다시 설명할 필요 없이 설치 한 번으로 재사용한다.

## 설치

```
/plugin marketplace add ginaseo/devkit
/plugin install devkit@devkit
```

이 한 줄이면 끝난다. caveman(상시 압축 출력 모드)은 별도 플러그인이 아니라 devkit 안에 코드로 가져와(vendored) 포함해뒀다 — 출처·라이선스는 `NOTICE.md` 참고.

## 들어있는 것

### 서브에이전트 (`agents/`)

| 이름 | 모델 | 역할 |
|---|---|---|
| `explorer` | haiku | 읽기 전용 탐색 — 파일 위치, 함수 정의, 호출부 찾기. 코드 수정 안 함 |
| `implementer` | sonnet | 기능 구현·버그 수정. 테스트도 같이 작성 |
| `architect` | opus | 설계·아키텍처 결정, 복잡한 버그의 근본원인 분석. 성급하게 고치지 않고 먼저 분석·계획 제시 |
| `cavecrew-investigator` | — | 읽기 전용 코드 위치 탐색. 출력이 caveman 압축 포맷이라 메인 컨텍스트 소모가 적음(caveman 벤더링) |
| `cavecrew-builder` | — | 1~2개 파일 범위의 수술적 수정(오탈자, 단일 함수 재작성, 기계적 리네임). 3개 파일 이상 범위는 거부(caveman 벤더링) |
| `cavecrew-reviewer` | — | diff/branch/file 리뷰. 발견당 한 줄, 심각도 태그(caveman 벤더링) |

`explorer`/`implementer`/`architect`는 난이도별 모델을 고정해뒀고, `cavecrew-*`는 caveman 쪽에서 가져온 것으로 출력 압축이 목적이다. `Agent` 도구로 `subagent_type`에 이름을 지정해 위임한다.

### 커맨드 (`commands/`)

| 커맨드 | 설명 |
|---|---|
| `/review` | 코드 리뷰. codex MCP(`/codex:review`)를 우선 쓰고, rate limit이나 codex 미설치로 실패하면 opus가 직접 리뷰로 전환. 결과가 나오면 그대로 끝내지 않고 파일:라인 직접 확인 + 호출부 유무로 실사용버그/잠복결함 판정까지 자동으로 이어감 |

caveman 쪽 슬래시 명령(`/caveman`, `/caveman-commit`, `/caveman-review`, `/caveman-help`)은 별도 커맨드 파일이 아니라 같은 이름의 스킬로 등록돼 있다 — 아래 스킬 표 참고.

### 스킬 (`skills/`)

플러그인 설치 시 세션에 자동으로 노출된다. devkit 자체 정책 스킬 3개 + caveman 벤더링 스킬 7개.

| 스킬 | 담당 |
|---|---|
| `model-and-review-policy` | 모델 선택 사다리(기계적=haiku / 일반구현=sonnet / 설계·최종리뷰=opus) + `/review` 결과 타당성검토 절차 |
| `plugin-routing` | 작업 요청이 들어오면 성격을 파악해 아래 "플러그인별 사용 시점" 표에 맞는 플러그인을 기본 동작보다 먼저 검토·사용 |
| `plugin-check` | `plugin-routing`이 지목한 플러그인이 세션에 없을 때, 실제 미설치인지 확인하고 설치 명령을 제시(자동 설치는 안 함 — 훅으로 임의 코드 실행 가능해 항상 사용자 확인) |
| `caveman` (벤더링) | 상시 압축 출력 모드 본체. 강도 전환은 `/caveman lite`, `full`, `ultra` |
| `caveman-commit` (벤더링) | 압축된 커밋 메시지 생성 |
| `caveman-review` (벤더링) | 압축된 리뷰 코멘트 생성 |
| `caveman-help` (벤더링) | caveman 관련 명령/스킬 요약표 |
| `caveman-compress` (벤더링) | 메모리 파일(CLAUDE.md 등)을 caveman 포맷으로 압축, 원본은 `.original.md`로 백업 |
| `caveman-stats` (벤더링) | 세션 로그 기반 실제 토큰 절약량 표시 |
| `cavecrew` (벤더링) | `cavecrew-investigator`/`builder`/`reviewer` 중 언제 뭘 위임할지 판단 가이드 |

### 훅 (`hooks/`)

| 훅 | 시점 | 역할 |
|---|---|---|
| `pr-codex-reminder.sh` | `gh pr create` 직전(PreToolUse) | codex 리뷰 돌렸는지 리마인드 |
| `caveman-activate.js` (벤더링) | SessionStart | caveman 모드를 세션 시작 시 자동으로 켬 |
| `caveman-mode-tracker.js` (벤더링) | UserPromptSubmit | 매 프롬프트마다 현재 caveman 강도를 컨텍스트에 주입 |

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

`caveman`은 이제 devkit에 벤더링돼 있어 "고를 대상"이 아니다(항상 켜져 있음). `claude-dashboard`(사용량 관측)도 작업 성공/효율과 무관해 표에 없다 — 필요하면 개별 설치.

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

/plugin marketplace add uppinote20/claude-dashboard
/plugin install claude-dashboard@claude-dashboard
```

`claude-plugins-official` 마켓플레이스 하나에 `superpowers`와 `figma`가 같이 들어있어서 그 둘은 `marketplace add`를 한 번만 하면 된다.

`superpowers`·`codex`는 없으면 `/review`·서브에이전트 실행이 대체 경로(opus 직접 리뷰, 방법론 없이 진행)로 동작하고, `karpathy-skills`·`ponytail`·`humanizer`·`humanize-korean`·`figma`는 없으면 `plugin-check`가 감지해서 설치 명령을 제시한다. `caveman`은 devkit에 포함돼 있으니 따로 설치할 필요 없고, `claude-dashboard`(사용량 관측)만 순수 선택 사항이다.

## 왜 CLAUDE.md가 아니라 스킬인가

CLAUDE.md는 프로젝트 루트 파일이라 플러그인이 자동으로 심어줄 수 없다. 대신 스킬로 만들면 플러그인 설치만으로 모든 프로젝트에서 같은 내용이 세션에 노출된다 — 프로젝트마다 CLAUDE.md에 이 내용을 복붙할 필요가 없다.

## 서드파티 코드

`caveman` 관련 서브에이전트·스킬·훅은 [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)(MIT)에서 가져온 것이다. 원본이 업데이트돼도 자동 반영되지 않으므로, 최신화가 필요하면 수동으로 다시 복사한다. 파일 목록·라이선스 전문 위치는 `NOTICE.md` 참고.

## 배경

[PassFlow](https://github.com/ginaseo/passflow) 프로젝트에서 처음 만들어 쓰다가, 다른 프로젝트에도 재사용하려고 플러그인으로 분리했다.
