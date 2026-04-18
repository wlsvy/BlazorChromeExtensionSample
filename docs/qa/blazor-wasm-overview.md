# Blazor와 WebAssembly — 개념 정리

> 질문: Blazor WASM의 주요 기능들? / Blazor란 WASM(WebAssembly)의 닷넷 툴인지?
> 작성일: 2026-04-18

---

## 먼저 WebAssembly(WASM)란?

브라우저에서 실행되는 **저수준 바이너리 포맷**이다.
원래 웹은 JavaScript만 실행할 수 있었는데, WASM이 등장하면서 C, C++, Rust, **C#** 같은 언어로 짠 코드도 브라우저에서 직접 실행할 수 있게 됐다.

```
기존: 소스코드 → JavaScript → 브라우저 실행
WASM: 소스코드 → 컴파일 → .wasm 바이너리 → 브라우저 실행 (훨씬 빠름)
```

---

## Blazor는 "닷넷용 WASM 프레임워크"인가?

**맞다, 정확히 그렇다.** 더 정확하게 표현하면:

> Blazor WASM = .NET 런타임 자체를 WASM으로 컴파일해서 브라우저 안에서 실행시키는 프레임워크

```
C# 코드
    ↓
.NET 런타임 (WASM으로 컴파일됨)
    ↓
브라우저 내부에서 실행 (JavaScript 없이!)
```

즉, 브라우저 안에 미니 .NET 런타임이 통째로 들어가는 구조다.

---

## Blazor의 두 가지 모드

| 모드 | 실행 위치 | 특징 |
|------|----------|------|
| **Blazor Server** | 서버 | C# 코드가 서버에서 실행, SignalR로 UI 업데이트 전송 |
| **Blazor WebAssembly (WASM)** | 브라우저 | .NET 런타임 + 앱 전체를 브라우저에 다운로드 후 실행 |

이 프로젝트는 **Blazor WASM** 사용 — 서버 없이 브라우저(Extension) 안에서 완전히 실행됨.

---

## Blazor WASM 주요 기능

### 1. C#으로 UI 작성
JavaScript 대신 C#으로 이벤트 핸들러, 상태 관리, DOM 조작 가능

```razor
<!-- Counter.razor -->
<h1>카운트: @count</h1>
<button @onclick="Increment">+1</button>

@code {
    int count = 0;
    void Increment() => count++;
}
```

### 2. Razor 컴포넌트 시스템
HTML + C# 로직을 `.razor` 파일 하나에 작성. React의 컴포넌트와 유사한 개념.

### 3. 의존성 주입 (DI)
ASP.NET Core와 동일한 DI 컨테이너 사용 가능

```csharp
builder.Services.AddSingleton<MyService>();
```

### 4. JavaScript Interop (JS Interop)
필요한 경우 C#에서 JavaScript 함수 호출 가능 (반대도 됨)

```csharp
await JS.InvokeVoidAsync("alert", "Hello from C#!");
```

### 5. HttpClient 내장
브라우저의 Fetch API를 래핑한 `HttpClient`로 REST API 호출

### 6. 라우팅
SPA 방식의 클라이언트 사이드 라우팅 지원

```razor
@page "/counter"
```

### 7. AOT (Ahead-of-Time) 컴파일 (.NET 6+)
런타임 인터프리팅 대신 미리 네이티브 코드로 컴파일 → 실행 속도 대폭 향상 (단, 번들 크기 증가)

---

## Blazor WASM의 한계

| 한계 | 설명 |
|------|------|
| 초기 로딩 시간 | .NET 런타임 + 앱 DLL 전체를 다운로드해야 함 (수 MB) |
| 메모리 | 브라우저 탭 내 .NET 힙 유지 → 메모리 사용량 높음 |
| DOM 직접 접근 | JS Interop 거쳐야 함 (C#에서 직접 불가) |
| SEO | SPA 특성상 서버사이드 렌더링 불가 (Extension에서는 무관) |

---

## Chrome Extension에서 Blazor WASM 사용 시 구조

```
popup.html          ← Extension의 진입점 (Blazor의 index.html 역할)
    └── _framework/
        ├── blazor.webassembly.js   ← Blazor 부트스트랩
        ├── dotnet.wasm             ← .NET 런타임 (WASM)
        └── *.dll / *.wasm          ← 앱 어셈블리
```

Extension 번들 안에 .NET 런타임 파일들이 모두 포함되므로,
설치 시 한 번 다운로드 후 오프라인에서도 동작한다.
