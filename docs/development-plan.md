# 개발 계획 (Development Plan)

> 작성일: 2026-04-18
> 목표: .NET 10 + Blazor WASM으로 Chrome Extension 샘플 구현 및 배포 체험

---

## 최종 목표

1. Blazor WASM 앱을 Chrome Extension의 Popup 페이지로 실행
2. `chrome.tabs` API를 통해 현재 탭 정보 표시 (JS Interop 실습)
3. `chrome.storage` API로 설정값 저장/불러오기
4. Chrome 개발자 모드로 로컬 로드 성공
5. (선택) `.zip` 패키징 후 Web Store 비공개 배포

---

## 단계별 계획

### Phase 1 — 프로젝트 뼈대 구성
**목표**: 빈 Blazor WASM 앱이 Extension Popup으로 뜨는 것 확인

- [x] `dotnet new blazorwasm -o src/BlazorExtension` 실행
- [x] `wwwroot/manifest.json` 작성 (Manifest V3)
  - `action.default_popup` → `index.html`
  - CSP: `script-src 'self' 'wasm-unsafe-eval' 'unsafe-inline'` (inline import map 허용)
- [x] `dotnet publish` 후 `dist/` 복사 (`scripts/build.sh`)
- [ ] Chrome 개발자 모드로 로드 → Popup 버튼 클릭 시 Blazor UI 표시 확인
- [x] Extension 아이콘 (16, 48, 128px) 추가 (sips로 icon-192.png 리사이즈)

**완료 기준**: Blazor Counter 기본 페이지가 Chrome Extension Popup에 렌더링됨

---

### Phase 2 — Chrome API 연동 (JS Interop)
**목표**: C#에서 Chrome Extension API 호출

- [ ] `IJSRuntime`을 이용한 JS Interop 구현
- [ ] `chrome.tabs.query()` 호출 → 현재 탭 URL/Title을 Blazor UI에 표시
- [ ] `background.js` (Service Worker) 추가 — 탭 변경 이벤트 수신
- [ ] manifest.json에 `tabs` permission 추가

**완료 기준**: Popup에서 "현재 탭: [URL]" 표시

---

### Phase 3 — Storage API 연동
**목표**: 사용자 설정을 Extension 로컬 스토리지에 저장

- [ ] Options 페이지 추가 (`options.html` → Blazor 라우트 `/options`)
- [ ] `chrome.storage.sync`로 설정값 저장/불러오기
- [ ] JS Interop wrapper 서비스 클래스 작성 (`ChromeStorageService.cs`)
- [ ] manifest.json에 `storage` permission 추가

**완료 기준**: Options에서 입력한 값이 Popup을 닫고 다시 열어도 유지됨

---

### Phase 4 — 빌드 자동화 & 패키징
**목표**: 반복 가능한 빌드·배포 파이프라인

- [ ] `scripts/build.sh` 작성 (publish → dist/ 복사)
- [ ] `scripts/pack.sh` 작성 (dist/ → releases/*.zip)
- [ ] `.claude/commands/build.md`, `pack.md` 검증
- [ ] `releases/` 폴더에 버전 zip 생성

**완료 기준**: `/build` → `/pack` 커맨드로 자동화 완료

---

### Phase 5 (선택) — Web Store 비공개 배포
**목표**: 실제 배포 흐름 체험

- [ ] 스토어 등록 자료 준비 (스크린샷, 설명문)
- [ ] Chrome Web Store Developer Dashboard 업로드
- [ ] 비공개 상태로 게시 → 본인 계정에서 설치 확인

---

## 기술 결정 사항 (ADR)

| 결정 | 선택 | 이유 |
|------|------|------|
| Extension 라이브러리 | 직접 구성 (라이브러리 없이) | 학습 목적 — 내부 동작 이해 우선 |
| Blazor 렌더링 방식 | Standalone WASM | 서버 불필요, Extension 번들에 self-contained |
| CSS 프레임워크 | Bootstrap (Blazor 기본 포함) | 별도 설치 없이 즉시 사용 가능 |
| JS Interop 방식 | IJSRuntime 직접 사용 | 간단한 샘플에는 wrapper 라이브러리 불필요 |
| Background Script | Service Worker | Manifest V3 표준 |

---

## 파일 구조 (완성 시 예상)

```
BlazorChromeExtensionSample/
├── src/
│   └── BlazorExtension/
│       ├── BlazorExtension.csproj
│       ├── Program.cs
│       ├── App.razor
│       ├── Pages/
│       │   ├── Popup.razor          # 메인 팝업 UI
│       │   └── Options.razor        # 설정 페이지
│       ├── Services/
│       │   └── ChromeStorageService.cs
│       └── wwwroot/
│           ├── manifest.json
│           ├── background.js        # Service Worker
│           ├── index.html           # = popup.html
│           └── icons/
│               ├── icon16.png
│               ├── icon48.png
│               └── icon128.png
├── scripts/
│   ├── build.sh
│   └── pack.sh
├── dist/                            # gitignore
├── releases/                        # gitignore
├── docs/
│   ├── development-plan.md          # 이 파일
│   ├── agents.md
│   └── qa/
└── CLAUDE.md
```

---

## 진행 상태 추적

| Phase | 상태 | 완료일 |
|-------|------|--------|
| Phase 1 — 뼈대 구성 | 🔲 미시작 | - |
| Phase 2 — Chrome API 연동 | 🔲 미시작 | - |
| Phase 3 — Storage API | 🔲 미시작 | - |
| Phase 4 — 빌드 자동화 | 🔲 미시작 | - |
| Phase 5 — Web Store 배포 | 🔲 선택 사항 | - |

> 이 파일은 각 Phase 완료 시마다 업데이트한다.
