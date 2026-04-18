# 디렉토리 컨벤션 — 레이어별 정리

## 개요

프로젝트 디렉토리는 **소스 리소스 → 빌드 산출물 → 배포 타겟** 3개 레이어로 구분된다.

---

## Layer 1: 소스 리소스 (개발자가 직접 편집)

| 디렉토리 | 프레임워크 | 역할 |
|----------|-----------|------|
| `wwwroot/` | ASP.NET / Blazor | 정적 파일의 **소스 원본** — HTML, CSS, JS, 이미지, `manifest.json` 등 |
| `src/` | 관행 | 프로젝트 소스 루트. 여러 프로젝트가 있을 때 격리 목적 |
| `Pages/`, `Components/` | Blazor | Razor 컴포넌트 소스 |

### wwwroot/ 의 특수성
`wwwroot/`는 .NET 프레임워크 규약으로, **이 폴더 안 파일만 웹에 노출**됩니다.
바깥 파일(`.cs`, `.csproj` 등)은 외부 접근 불가 — 보안 경계선 역할.

---

## Layer 2: 빌드 산출물 (도구가 생성)

| 디렉토리 | 생성 주체 | 역할 |
|----------|----------|------|
| `bin/` | `dotnet build` | 컴파일된 `.dll`, 실행 바이너리 |
| `obj/` | `dotnet build` | 빌드 중간 캐시 (`.pdb`, 종속성 그래프 등) |
| `publish/` | `dotnet publish` | **배포용 최종 산출물** — WASM, `_framework/`, `index.html` 등 전부 포함 |

### publish/ vs bin/ 차이
- `bin/`: 개발 환경에서 실행 가능한 빌드 결과물
- `publish/`: 런타임 없이 독립 실행 가능한 완성본. `dotnet publish`는 빌드 + 트리 쉐이킹 + 최적화까지 수행

---

## Layer 3: 배포 타겟 (Chrome이 읽는 폴더)

| 디렉토리 | 역할 |
|----------|------|
| `dist/` | `publish/` 산출물을 **Chrome Extension 구조에 맞게 정리**한 최종 폴더 |

### 왜 publish/ → dist/ 복사 단계가 필요한가?
`dotnet publish` 출력 구조와 Chrome Extension이 기대하는 구조가 다를 수 있기 때문:
- Chrome은 `manifest.json`이 루트에 있어야 함
- 불필요한 파일 제거, 경로 조정 등이 필요할 수 있음

`chrome://extensions/`에서 `dist/` 폴더를 직접 로드하거나, `.zip`으로 패키징해 Web Store에 제출.

---

## Layer 4: 자동화 스크립트

| 디렉토리 | 역할 |
|----------|------|
| `scripts/` | 빌드·복사·패키징 자동화 셸 스크립트. 위 레이어들을 연결하는 접착제 역할 |

---

## 전체 흐름

```
[개발자 편집]          [도구 생성]                    [배포 타겟]
src/
├── wwwroot/     →   dotnet publish   →   publish/   →  scripts/  →  dist/
├── Pages/                                                               ↓
└── ...                                                        Chrome에 로드
                                                               (.zip → Web Store)
```

---

## .gitignore 관점

```
bin/        ✗ 커밋 X  (빌드 캐시, 재현 가능)
obj/        ✗ 커밋 X  (빌드 캐시, 재현 가능)
publish/    ✗ 커밋 X  (재현 가능한 산출물)
dist/       ✗ 커밋 X  (재현 가능한 산출물)
wwwroot/    ✓ 커밋 O  (소스 원본)
scripts/    ✓ 커밋 O  (자동화 스크립트)
src/        ✓ 커밋 O  (소스 원본)
```

재현 가능한 산출물은 커밋하지 않는 것이 원칙 — 저장소 크기 절약 + 빌드 환경 오염 방지.

---

## 관련 문서
- [[blazor-wasm-overview]]
- [[manifest-versions]]
