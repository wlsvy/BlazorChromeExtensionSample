# Chrome Extension Manifest 버전별 패러다임

> 질문: manifest v3 이란? 과거 버전 별로 어떤 패러다임인지?
> 작성일: 2026-04-18

---

## Manifest 파일이란?

Chrome Extension의 **신분증 + 설정서**라고 보면 된다.
`manifest.json` 하나로 이 확장이 어떤 권한을 요청하고, 어떤 파일이 popup인지, background에서 뭘 실행하는지를 브라우저에 알려준다.

---

## 버전별 패러다임 비교

### Manifest V1 (2010~2012, 지원 종료)
- 초창기 Extension 형식
- 보안 개념이 거의 없었음 — 무제한 권한, eval() 자유롭게 사용 가능
- 현재 완전히 폐기됨

---

### Manifest V2 (2012~2023, 단계적 폐기 중)

**핵심 패러다임: "Persistent Background Page"**

```json
{
  "manifest_version": 2,
  "background": {
    "scripts": ["background.js"],
    "persistent": true   // 브라우저 켜있는 동안 항상 살아있음
  }
}
```

- Background Script가 **항상 메모리에 상주** → 이벤트 즉시 처리 가능
- `XMLHttpRequest`, `eval()`, 인라인 스크립트 허용 (보안 구멍 多)
- `webRequestBlocking` API로 네트워크 요청을 실시간 차단 가능 (광고 차단기가 이걸 씀)
- 2024년부터 Chrome Web Store 신규 등록 불가, 2025년 6월부터 Chrome에서 실행 불가

---

### Manifest V3 (2020~ , 현재 표준) ✅

**핵심 패러다임: "Service Worker + Declarative"**

```json
{
  "manifest_version": 3,
  "background": {
    "service_worker": "background.js"   // 상주 X, 이벤트 있을 때만 깨어남
  },
  "permissions": ["storage", "tabs"],
  "host_permissions": ["https://example.com/*"]
}
```

#### V3의 주요 변화 3가지

| 항목 | V2 | V3 |
|------|----|----|
| Background 방식 | Persistent Page (항상 살아있음) | Service Worker (필요할 때만 깨어남) |
| 네트워크 요청 차단 | `webRequestBlocking` (동적) | `declarativeNetRequest` (규칙 기반) |
| 코드 실행 | 원격 스크립트 로드 가능 | 번들에 포함된 코드만 실행 가능 |

#### V3의 의도
- **보안 강화**: 런타임에 원격 코드를 받아 실행하는 방식 금지
- **성능 향상**: Service Worker는 유휴 상태에서 메모리 해제됨
- **프라이버시**: 네트워크 요청 차단을 선언적(규칙 파일)으로만 허용

#### V3의 주요 제약 (개발 시 주의)
- Service Worker는 DOM에 접근 불가
- Service Worker는 일정 시간 후 자동으로 종료됨 → 장기 상태 보존 불가 (Storage API 활용 필요)
- `eval()`, `new Function()` 금지
- CSP(Content Security Policy) 강화 → 인라인 스크립트 금지

---

## 이 프로젝트와의 관계

Blazor WASM을 사용하므로 V3 기준으로만 작성한다.
Blazor의 `_framework/blazor.webassembly.js`는 번들에 포함되는 로컬 파일이므로 V3 제약에 위배되지 않는다.

---

> 참고: [Chrome Extension Manifest V3 공식 문서](https://developer.chrome.com/docs/extensions/develop/migrate/what-is-mv3)
