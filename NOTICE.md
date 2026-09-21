# 서드파티 코드 표기

이 플러그인은 아래 오픈소스 프로젝트의 코드를 가져와(vendored) 포함한다 — `devkit` 하나만 설치해도 같이 동작하도록 묶은 것이지, devkit이 직접 작성한 코드가 아니다.

## caveman

- 출처: https://github.com/JuliusBrussee/caveman
- 저작권: Copyright (c) 2026 Julius Brussee
- 라이선스: MIT (전문은 `hooks/caveman/LICENSE-caveman.txt`)
- 포함된 파일:
  - `agents/cavecrew-builder.md`, `agents/cavecrew-investigator.md`, `agents/cavecrew-reviewer.md`
  - `skills/caveman/`, `skills/caveman-commit/`, `skills/caveman-compress/`, `skills/caveman-help/`, `skills/caveman-review/`, `skills/caveman-stats/`, `skills/cavecrew/`
  - `hooks/caveman/caveman-activate.js`, `caveman-mode-tracker.js`, `caveman-config.js`, `caveman-stats.js`, `caveman-statusline.ps1`, `caveman-statusline.sh`
  - `hooks/hooks.json`의 `SessionStart`·`UserPromptSubmit` 항목

원본이 업데이트돼도 여기 파일은 자동으로 따라가지 않는다. 최신화하려면 위 파일들을 원본 저장소에서 다시 복사해온다.
