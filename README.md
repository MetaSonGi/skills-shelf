# Claude Code 스킬 선반

효기요의 웹 디자인·코딩·보안 검토에 사용할 6개 GitHub 프로젝트를 정리했습니다. 설치 대상은 **Claude Code 사용자 스킬**이며 Codex 설정은 변경하지 않습니다. 2026-11-03에 확인한 Git 커밋은 `skills-lock.json`에 고정되어 있습니다. SNS 주간 순위·별 증가량을 재현한 목록은 아닙니다.

| 프로젝트 | 기능 | 이 PC의 호출 이름 |
|---|---|---|
| [Hallmark](https://github.com/Nutlope/hallmark) | 새 사이트의 디자인 방향·디테일 개선 | `/hallmark` |
| [Impeccable](https://github.com/pbakaus/impeccable) | 기존 화면 UX·접근성·디자인 검토와 마무리 | `/impeccable` |
| [Cloudflare security-audit](https://github.com/cloudflare/security-audit-skill) | 코드·API 보안 검토 | `/security-audit` |
| [Superpowers](https://github.com/obra/superpowers) | 기획·계획·디버깅·테스트·검증 등 15개 스킬 | `/brainstorming`, `/systematic-debugging` 등 |
| [Uncle Bob ub-mode](https://github.com/unclebob/ub-mode) | 작은 변경·테스트·설계 규율 | `/ub-mode` |
| [Taste Skill](https://github.com/Leonxlnx/taste-skill) | 웹·앱 화면의 디자인 방향과 브라우저 검토 | `/design-taste-frontend` |

합계 **20개 SKILL.md**. 디자인 스킬은 처음에는 Impeccable 하나를 명시해서 쓰고, 다른 방향이 필요할 때 Hallmark 또는 Taste를 지정하는 식으로 시작하세요.

## Windows 설치

Git과 Claude Code가 필요합니다. Claude Code 설치·로그인은 [공식 설치 안내](https://code.claude.com/docs/en/setup)를 참고하세요. PowerShell에서:

```powershell
git clone https://github.com/MetaSonGi/skills-shelf.git
cd skills-shelf
.\install-skills.ps1
```

실행 정책 때문에 스크립트가 차단되면 현재 실행에만 적용해 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-skills.ps1
```

스크립트는 `~/.claude/skill-repos/`에 원본 저장소를 내려받고 고정 커밋을 체크아웃합니다. 각 스킬 디렉터리를 `~/.claude/skills/`에 Windows 디렉터리 정션으로 연결하므로 참조 문서와 스크립트가 함께 유지됩니다. 기존 같은 이름의 다른 스킬은 건너뛰고, 수정된 원본 체크아웃은 덮어쓰지 않고 중단합니다. `installed.local.json`은 로컬 설치 결과이며 Git에 올리지 않습니다.

설치 후 Claude Code를 다시 열고 `/skills`에서 확인하세요. [공식 스킬 안내](https://code.claude.com/docs/en/skills)의 사용자 스킬 위치를 따릅니다. Claude 앱의 일반 웹 채팅·클라우드 세션으로 자동 복사되는 설정은 아닙니다.

## 바로 쓰기

Claude Code에서 작업할 프로젝트 폴더를 연 다음:

```text
/impeccable critique 사진전시관의 액자 편집 패널을 검토해 줘
/hallmark 전시 프로젝트 소개 페이지를 만들어 줘
/security-audit 로봇랩의 인증과 WebSocket 접근 제어를 검토해 줘
/brainstorming 로봇랩에 추가할 음성 제어 기능을 설계해 줘
/systematic-debugging 로봇 전환 중 멈추는 문제를 조사해 줘
/ub-mode 이 변경을 작은 단위로 구현하고 검증해 줘
/design-taste-frontend 전시 소개 페이지의 디자인을 개선해 줘
```

## 업데이트·연결 해제

```powershell
git pull --ff-only
.\install-skills.ps1
```

위 명령은 이 저장소의 고정 버전을 적용합니다. 원본 프로젝트의 최신 커밋을 새로 선택하려면 `./refresh-lock.ps1`을 실행하고 GitHub의 변경 내용을 검토한 뒤 `./install-skills.ps1`을 실행하세요. 스킬 디렉터리 구조가 바뀌었다면 lock 파일의 경로도 갱신해야 합니다. 새 lock 파일을 커밋하면 선택한 버전이 GitHub에 기록됩니다.

```powershell
.\unlink-skills.ps1
```

연결 해제는 이 설치기가 지정한 정션만 제거합니다. 원본 저장소나 다른 스킬은 지우지 않습니다.

## 포함 범위

- SKILL.md와 각 스킬 디렉터리의 참조 자료·보조 스크립트 연결입니다. 원본 스킬 내용은 수정하지 않았습니다.
- Impeccable·Superpowers 플러그인의 자동 실행 훅·별도 에이전트는 이 방식으로 등록되지 않습니다. 명시적 스킬 호출로 사용하세요.
- 일부 보조 기능은 Node.js, 브라우저, 추가 모델·API를 실행 시 요구할 수 있습니다. 이 설치는 해당 런타임·API 키를 일괄 구성하지 않습니다.
- Impeccable live의 Apply 동작은 별도 에이전트를 실행할 수 있습니다. 사용 전에 [원본 live 설명](https://github.com/pbakaus/impeccable#live-mode)을 읽으세요. 이 설치기는 live 서버나 권한 우회 옵션을 실행하지 않습니다.
- 원본 라이선스는 각 저장소에 유지됩니다. 이 저장소는 설치 관리 파일만 담습니다.
