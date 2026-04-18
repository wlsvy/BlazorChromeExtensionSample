# Claude Code Harness 구성 파일 설명

> 질문: Claude의 harness를 구성하는 파일들(rules, skills 등)은 무엇인가?
> 작성일: 2026-04-18

---

## "Harness"란?

Claude Code가 프로젝트를 인식하고 일관되게 동작하도록 잡아주는 **설정 파일 묶음**이다.
사람으로 치면 "업무 매뉴얼 + 권한 위임서 + 도구 목록" 역할.

---

## 파일별 역할 요약

```
프로젝트 루트/
├── CLAUDE.md                    ← (1) 핵심 컨텍스트 & 규칙
└── .claude/
    ├── settings.json            ← (2) 권한 & 훅(Hooks) 설정
    └── commands/
        ├── build.md             ← (3) 커스텀 슬래시 커맨드
        └── pack.md

사용자 홈/
└── ~/.claude/
    ├── CLAUDE.md                ← (4) 전역 규칙 (모든 프로젝트에 적용)
    └── projects/
        └── [project-hash]/
            └── memory/          ← (5) 프로젝트 메모리
                ├── MEMORY.md
                └── *.md
```

---

## (1) CLAUDE.md — 가장 중요한 파일

**자동 로드**: Claude Code 세션 시작 시 항상 읽힘
**역할**: 프로젝트 컨텍스트, 코딩 규칙, 작업 방식 등 Claude가 알아야 할 모든 것

```markdown
# 포함할 내용
- 프로젝트 개요 & 기술 스택
- 코딩 규칙 (Rules)
- 디렉토리 구조
- 주요 커맨드
- 주의사항
```

> **팁**: CLAUDE.md가 너무 길어지면 Claude의 컨텍스트 창을 낭비한다.
> 핵심 규칙만 남기고 상세 내용은 `docs/` 폴더로 분리할 것.

---

## (2) .claude/settings.json — 권한 & 자동화

**역할**: Claude가 실행할 수 있는 명령어 허용/차단, 훅(Hooks) 설정

```json
{
  "permissions": {
    "allow": ["Bash(dotnet:*)", "Bash(npm:*)", "Bash(zip:*)"],
    "deny": ["Bash(git push:*)"]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{ "type": "command", "command": "dotnet build" }]
    }]
  }
}
```

> 훅(Hooks)이 진짜 강력함: 파일 편집 후 자동 빌드, 커밋 전 lint 실행 등 자동화 가능

---

## (3) .claude/commands/*.md — 커스텀 슬래시 커맨드

**역할**: `/build`, `/pack` 같은 프로젝트 전용 명령어 정의
**사용법**: 파일명이 곧 커맨드 이름 (`build.md` → `/build`)

```markdown
<!-- .claude/commands/build.md 예시 -->
Build the Blazor WASM project and copy output to dist/.

Steps:
1. Run dotnet publish ...
2. Copy to dist/
3. Verify manifest.json exists
```

> `$ARGUMENTS` 플레이스홀더로 인자도 받을 수 있음: `/deploy production`

---

## (4) ~/.claude/CLAUDE.md — 전역 규칙

**역할**: 모든 프로젝트에 공통 적용되는 개인 규칙
**예**: 말투, 이모지 사용 여부, 기본 코딩 스타일

이 프로젝트에서는 이미 `/Users/jinpyo/.claude/CLAUDE.md`에 한국어 응답 규칙 등이 설정되어 있음.

---

## (5) Memory 파일 — 세션 간 기억

**역할**: 대화가 끝나도 유지되어야 할 프로젝트 맥락 저장
**위치**: `~/.claude/projects/[project-path-hash]/memory/`
**이 프로젝트 기준**: `~/.claude/projects/-Volumes-TOSHIBA-EXT-LargeWorkspace/memory/`

```
memory/
├── MEMORY.md                             ← 인덱스 (자동 로드됨)
└── project_blazor_chrome_extension.md    ← 실제 내용
```

> `MEMORY.md`는 매 세션마다 자동으로 Claude 컨텍스트에 주입됨.
> 세션이 끊겨도 프로젝트 진행 상황, 결정 사항들이 보존된다.

---

## "rules.md", "skills.md" 파일은 별도로 존재하는가?

**공식 Claude Code에서는 이런 파일명이 특별 취급되지 않는다.**

| 개념 | 실제 구현 방법 |
|------|--------------|
| Rules (규칙) | `CLAUDE.md`의 `## Rules` 섹션에 작성 |
| Skills (재사용 프로시저) | `.claude/commands/*.md`로 구현 |
| Agent 정의 | `docs/agents.md`에 설명 작성 후 Claude에게 참조 지시 |

즉, Claude Code의 harness는 파일 이름 규약보다 **CLAUDE.md + settings.json + commands/** 삼각 구조가 핵심이다.
