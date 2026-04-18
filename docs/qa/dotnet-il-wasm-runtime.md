# .NET IL, WASM, 브라우저 런타임 관계

> 질문1: .NET은 IL로 컴파일되는 언어 아닌지? 브라우저가 IL을 컴파일해서 실행하는 역할인지?
> 질문2: 브라우저의 JS 런타임과 WASM은 별개의 런타임인지?
> 작성일: 2026-04-18

---

## 1. .NET의 컴파일 파이프라인 (전통적인 데스크톱 .NET)

먼저 일반 .NET부터 이해하고 넘어가자.

```
C# 소스코드
    ↓ [Roslyn 컴파일러]
IL (Intermediate Language) — .dll 파일 안에 저장
    ↓ [CLR의 JIT 컴파일러 — 실행 시점]
네이티브 머신코드 (x64, ARM 등)
    ↓
CPU 실행
```

- **IL**은 CPU 종속 없는 중간 언어다. 자바의 JVM 바이트코드와 개념이 같다.
- **CLR(Common Language Runtime)**이 IL을 받아 해당 OS/CPU에 맞는 네이티브 코드로 JIT 컴파일해서 실행한다.
- 브라우저는 이 파이프라인과 무관하다.

---

## 2. Blazor WASM에서의 파이프라인 — 핵심

브라우저는 IL을 직접 이해하지 못한다. 그래서 Blazor WASM의 접근 방식은 이렇다:

```
C# 소스코드
    ↓ [Roslyn]
IL (.dll 파일들) ──────────────────────────┐
                                            │
.NET 런타임(Mono/CoreCLR) ──[WASM으로 컴파일]── dotnet.wasm
                                            │
                                            ↓
                              브라우저의 WASM 엔진이 실행
                                            │
                                            ↓
                              .NET WASM 런타임이 IL(.dll)을 해석/JIT
                                            │
                                            ↓
                              C# 코드 실행됨
```

**핵심 포인트:**
- 브라우저가 IL을 직접 컴파일하는 게 아니다
- **.NET 런타임 자체**가 WASM 바이너리(`dotnet.wasm`)로 컴파일되어 브라우저에 전달된다
- 브라우저는 이 `dotnet.wasm`을 실행하고, 그 안의 .NET 런타임이 IL `.dll` 파일들을 해석한다
- 즉, 브라우저 위에서 **미니 .NET VM**이 돌아가는 구조

### 비유

```
브라우저 = PC
WASM     = 가상머신(VM) 소프트웨어 (예: VirtualBox)
dotnet.wasm = VM 위에서 돌아가는 .NET 런타임
.dll 파일들  = .NET 런타임이 실행할 IL 프로그램
```

---

## 3. AOT (Ahead-of-Time) 컴파일 시 파이프라인

.NET 6+에서 AOT 활성화 시:

```
C# 소스코드
    ↓ [Roslyn]
IL
    ↓ [AOT 컴파일러 — 빌드 시점]
WASM 바이트코드 (.wasm 파일들)
    ↓
브라우저 WASM 엔진이 직접 실행 (런타임 없이)
```

- AOT는 IL 단계를 거치지만, 브라우저에 배포될 때는 이미 WASM으로 변환된 상태
- 런타임 인터프리팅이 없으므로 **실행 속도 빠름**, 대신 번들 크기가 큼

| 방식 | 번들 크기 | 실행 속도 | IL .dll 필요 |
|------|---------|---------|------------|
| 기본 (Interpreter) | 작음 | 보통 | O (브라우저에 포함) |
| AOT | 큼 | 빠름 | X (이미 WASM으로 변환) |

---

## 4. JS 런타임과 WASM 런타임은 별개인가?

**결론: 같은 브라우저 엔진(V8) 안에 공존하지만, 실행 파이프라인은 완전히 분리되어 있다.**

```
브라우저 프로세스
└── V8 엔진 (Chrome 기준)
    ├── JavaScript 실행 파이프라인
    │   └── JS 힙, JS 스택, Event Loop
    └── WASM 실행 파이프라인
        └── WASM 선형 메모리, WASM 실행 컨텍스트
```

- 같은 V8 엔진 안에 두 파이프라인이 모두 내장되어 있다
- **메모리 공간은 분리**: JS 힙 ≠ WASM 선형 메모리 (직접 메모리 공유 불가)
- **통신은 가능**: WebAssembly JavaScript API로 JS ↔ WASM 함수 호출 가능
- WASM은 DOM에 직접 접근할 수 없다 — **반드시 JS를 거쳐야 한다**

### Blazor에서 DOM 접근이 JS Interop을 거치는 이유

```
Blazor C# 코드 (WASM 메모리 공간)
    ↓ [IJSRuntime.InvokeAsync]
blazor.webassembly.js (JS 공간의 브릿지)
    ↓
DOM API / Chrome Extension API
```

이게 바로 Blazor에서 `await JS.InvokeVoidAsync("chrome.tabs.query", ...)`처럼
JS Interop을 써야 하는 근본적인 이유다.

---

## 5. 전체 그림 요약

```
┌─────────────────────────────────────────────────────┐
│                    Chrome 브라우저                    │
│                                                     │
│  ┌─────────────────┐    ┌─────────────────────────┐ │
│  │  JS 실행 공간    │    │    WASM 실행 공간        │ │
│  │                 │◄──►│                         │ │
│  │ - DOM API       │    │ dotnet.wasm             │ │
│  │ - Chrome Ext API│    │   └── .NET 런타임        │ │
│  │ - blazor.js     │    │         └── IL (.dll들)  │ │
│  │   (브릿지)       │    │               └── C# 코드│ │
│  └─────────────────┘    └─────────────────────────┘ │
│         ↑ JS Interop (IJSRuntime)으로 연결            │
└─────────────────────────────────────────────────────┘
```

---

## 정리

| 질문 | 답변 |
|------|------|
| 브라우저가 IL을 컴파일해서 실행하나? | 아니다. .NET 런타임이 WASM으로 변환되어 브라우저에서 실행되고, 그 런타임이 IL을 해석한다. |
| JS 런타임과 WASM 런타임은 별개인가? | 같은 엔진(V8) 안에 공존하지만 실행 파이프라인과 메모리 공간은 분리되어 있다. 통신은 JS Interop API로 한다. |
| WASM이 DOM에 직접 접근 가능한가? | 불가. 반드시 JS를 거쳐야 한다. Blazor의 IJSRuntime이 이 브릿지 역할을 한다. |
