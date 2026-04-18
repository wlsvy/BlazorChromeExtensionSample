# 공부용 Chrome Extension 프로젝트 사례

> 질문: 나처럼 공부용으로 진행하는 프로젝트 사례 간단하게?
> 작성일: 2026-04-18

---

## 공부용 Extension 프로젝트의 전형적인 패턴

처음 Chrome Extension을 배울 때 대부분의 개발자들이 거치는 단계가 있다.
각 단계마다 배우는 핵심 개념이 다르다.

---

## 단계별 학습 사례

### 1단계 — "Hello World" 수준

**목표**: manifest.json 구조와 popup UI 이해

```
- popup.html에 버튼 하나 렌더링
- 클릭하면 "Hello Extension!" alert
- 배우는 것: manifest 구조, popup 연동
```

---

### 2단계 — 현재 탭 정보 읽기

**목표**: Tabs API와 content script 이해

```
- 현재 탭의 URL, 제목을 popup에 표시
- 배우는 것: chrome.tabs API, permissions
```

---

### 3단계 — 페이지 조작 (Content Script)

**목표**: 웹페이지 DOM에 개입하는 방법 이해

**사례: 다크모드 토글 Extension**
```
- popup에서 토글 버튼 클릭
- content script가 현재 페이지에 dark.css 삽입
- 배우는 것: content_scripts, message passing
```

**사례: 단어 하이라이터**
```
- popup에서 단어 입력
- 현재 페이지에서 해당 단어 모두 노란 배경으로 하이라이트
- 배우는 것: DOM 조작, chrome.scripting API
```

---

### 4단계 — 데이터 저장 (Storage API)

**목표**: Extension의 설정 영속성 이해

**사례: 방문 횟수 카운터**
```
- 특정 도메인 방문할 때마다 카운트 증가
- popup에 "오늘 GitHub 방문: 5회" 표시
- 배우는 것: chrome.storage.local, service worker 이벤트
```

---

### 5단계 — 외부 API 연동

**목표**: fetch + CORS + 인증 처리

**사례: GitHub Notification 뱃지**
```
- GitHub API로 미읽음 알림 수 조회
- Extension 아이콘에 뱃지 숫자 표시
- 배우는 것: chrome.notifications, chrome.action.setBadgeText
```

---

### 6단계 — 프레임워크 연동 (이 프로젝트의 위치)

**목표**: Blazor/React/Vue 같은 프레임워크를 Extension에 통합

**사례 (React 버전, 유명 오픈소스들)**
- [chrome-extension-boilerplate-react](https://github.com/lxieyang/chrome-extension-boilerplate-react)
  - React로 popup/options 페이지 작성
  - Webpack 빌드 파이프라인 포함

**사례 (이 프로젝트와 유사한 Blazor 사례)**
- [BlazorBrowserExtension](https://github.com/mingyaulee/Blazor.BrowserExtension) — 가장 잘 알려진 Blazor Extension 라이브러리
  - Blazor WASM을 Chrome/Firefox Extension으로 빌드하는 헬퍼
  - popup, options, content script 페이지 모두 Blazor로 작성 가능

---

## 이 프로젝트의 학습 로드맵 제안

```
현재 위치
    ↓
[1] Blazor WASM 프로젝트 생성 + manifest.json 작성
    ↓
[2] 로컬 빌드 후 Chrome 개발자 모드 로드 성공
    ↓
[3] Popup 페이지에서 현재 탭 URL 표시 (Tabs API + JS Interop)
    ↓
[4] Storage API로 설정값 저장/불러오기
    ↓
[5] (선택) Web Store 비공개 배포 체험
```

각 단계마다 이 `docs/qa/` 폴더에 배운 내용을 기록해두면 나중에 레퍼런스로 유용하다.
