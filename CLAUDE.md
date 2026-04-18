# BlazorChromeExtensionSample

## 프로젝트 개요
.NET 10 + Blazor WebAssembly를 사용한 Chrome Browser Extension 샘플 프로젝트.
Blazor WASM을 Chrome Extension의 Popup/Options 페이지로 빌드하고 배포하는 흐름을 실습한다.

## 기술 스택
- **Runtime**: .NET 10
- **UI Framework**: Blazor WebAssembly (Standalone)
- **Target**: Chrome Extension (Manifest V3)
- **Node/npm**: 빌드 보조 도구 (필요 시)

## 프로젝트 구조 (예정)
```
BlazorChromeExtensionSample/
├── src/
│   └── BlazorExtension/        # Blazor WASM 프로젝트
│       ├── wwwroot/
│       │   └── manifest.json   # Chrome Extension Manifest V3
│       └── Pages/
├── scripts/                    # 빌드·패키징 스크립트
├── dist/                       # 빌드 산출물 (gitignore)
└── CLAUDE.md
```

## 개발 원칙
- Manifest V3 기준으로 작성 (V2 사용 금지)
- `service_worker` 방식의 background script 사용
- Content Security Policy(CSP) 준수 — inline script 금지
- `publish` 산출물을 `dist/` 에 복사 후 Chrome에 로드

## 주요 커맨드
```bash
# Blazor WASM 빌드
dotnet publish src/BlazorExtension/BlazorExtension.csproj -c Release -o publish/

# dist 폴더로 복사 (빌드 스크립트 참조)
./scripts/pack.sh
```

## Chrome Extension 로드 방법
1. Chrome → `chrome://extensions/` 접속
2. **개발자 모드** 활성화
3. **압축해제된 확장 프로그램 로드** → `dist/` 폴더 선택

## Rules (코딩 규칙)

### .NET 코딩 컨벤션
- 네이밍: `PascalCase` (클래스·메서드·프로퍼티), `camelCase` (로컬 변수·파라미터), `_camelCase` (private 필드)
- 인터페이스 접두사 `I` 필수: `IChromStorageService`
- `async` 메서드명 `Async` 접미사 필수: `GetTabInfoAsync()`
- `var` 사용: 타입이 우변에서 명확히 보일 때만 허용
- 파일 1개 = 클래스(타입) 1개, 파일명 = 클래스명
- `using` 정렬: System → Microsoft → Third-party → 내부 네임스페이스 순
- nullable 활성화 (`<Nullable>enable</Nullable>`), `!` 단언 남용 금지
- XML 문서 주석(`///`)은 public API에만 작성, 내부 구현에는 생략

### Single Responsibility Principle (SRP) — 강력 준수
- 하나의 클래스/컴포넌트는 **하나의 이유로만** 변경되어야 한다
- Razor 컴포넌트: UI 렌더링 로직만 — 비즈니스 로직은 Service 클래스로 분리
- Service 클래스: 하나의 도메인(예: Storage, Tabs)만 담당
- 하나의 메서드가 20줄을 넘으면 분리를 검토한다
  - 코드 depth 가 오히려 가독성을 해칠 것 같다면 분리하지 않아도 된다.
- `God class` 금지 — 여러 책임이 섞이면 즉시 분리

### NuGet 패키지 우선 원칙
- 이미 검증된 패키지로 해결 가능한 기능은 직접 구현하지 않는다
- 직접 구현 전에 반드시 NuGet에서 관련 패키지 존재 여부 확인
- 단, 학습 목적상 "이해를 위해" 직접 구현하는 경우는 주석으로 명시
- 패키지 버전은 최신 stable 버전 사용, `.csproj`에 명시적 버전 고정

### 추가 규칙
- **YAGNI (You Aren't Gonna Need It)**: 지금 필요하지 않은 기능은 만들지 않는다
- **Magic string 금지**: 문자열 상수는 `static class Constants`나 `enum`으로 추출
- **async/await 일관성**: `Task`를 반환하는 메서드는 끝까지 `await`, `.Result` 또는 `.Wait()` 금지
- **JS Interop 집중화**: Chrome API 호출은 반드시 `Services/` 폴더의 전용 서비스 클래스를 통해서만
- **에러 처리**: 외부 경계(Chrome API, fetch)에서만 try/catch, 내부 로직에서 남용 금지

---

## 학습 Q&A 정책
이 프로젝트는 **공부 목적**으로 진행한다.
- 사용자가 중간에 던지는 개념 질문들은 `docs/qa/` 폴더 아래 `.md` 파일로 저장한다.
- 파일명은 주제를 명확히 반영 (예: `manifest-versions.md`, `blazor-wasm-overview.md`)
- 작성 스타일: 친절하고 읽기 쉬운 해설 위주, 필요 시 표·예시 코드 포함
- 새 질문이 들어오면 관련 파일을 업데이트하거나 신규 파일 생성
- **문서 간 연관 링크 필수**: 서로 관련된 문서는 Obsidian 링크 포맷(`[[파일명]]`)으로 상호 참조한다
  - 예: `[[dotnet-il-wasm-runtime]]`, `[[manifest-versions]]`
  - 문서 하단에 `## 관련 문서` 섹션을 두고 연관 링크를 모아둔다

## 보안 규칙 (철저 준수)
이 프로젝트는 **GitHub Public Repository**입니다.

- **민감성 데이터 작성 금지**: API 키, 토큰, 비밀번호, 개인정보 등은 코드·문서에 직접 작성하지 않는다
- **작성 전 보고 의무**: 민감할 수 있는 정보를 파일에 쓰기 전에 반드시 사용자에게 먼저 확인을 받는다
- **환경변수 분리**: 비밀값은 `.env` 또는 사용자 secrets 저장소를 사용하고, `.gitignore`에 등록한다
- **gitignore 확인**: 민감 파일(`*.env`, `appsettings.*.json`, `secrets/` 등)이 `.gitignore`에 포함되어 있는지 주기적으로 확인한다
- **CSP 준수**: inline script, eval() 등 XSS 위험 패턴 사용 금지 (Manifest V3 정책과도 일치)

## 주의사항
- Blazor WASM은 `index.html` 기반 SPA이므로 popup.html이 이를 래핑하는 구조
- `_framework/` 경로의 WASM 파일은 Extension 번들에 포함되어야 함
- Chrome Web Store 배포 시 `.zip` 패키징 필요
