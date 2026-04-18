# JavaScript 실행 원리와 V8 엔진

## 브라우저는 JS를 어떻게 실행하는가?

JavaScript는 원래 인터프리터 언어로 설계됐지만, 현대 엔진은 **JIT 컴파일(Just-In-Time)** 방식으로 실행합니다.

---

## V8 엔진이란?

Google이 만든 **오픈소스 JavaScript/WebAssembly 엔진**입니다.

- **사용처**: Chrome, Edge, Node.js, Deno
- **언어**: C++로 작성
- **특징**: JavaScript 실행 + WebAssembly 실행을 모두 담당

---

## V8의 실행 파이프라인

```
JS 소스코드
    ↓
[Parser] → AST (Abstract Syntax Tree) 생성
    ↓
[Ignition] → 바이트코드(Bytecode) 생성 및 인터프리터 실행
    ↓ (자주 실행되는 "Hot" 함수 감지 시)
[TurboFan] → 최적화된 기계어(Machine Code)로 JIT 컴파일
```

| 단계 | 역할 |
|------|------|
| **Parser** | 소스를 AST로 변환 |
| **Ignition** | AST → 바이트코드, 빠른 초기 실행 |
| **TurboFan** | Hot path → 기계어 최적화 컴파일 |
| **Deoptimization** | 타입 가정이 틀리면 다시 Ignition으로 내려옴 |


---

## 다른 브라우저 엔진

| 엔진 | 브라우저 |
|------|---------|
| **V8** | Chrome, Edge |
| **SpiderMonkey** | Firefox |
| **JavaScriptCore (Nitro)** | Safari |

기본 원리(JIT, AST, 바이트코드)는 동일하고 구현 세부만 다릅니다.

---

## Blazor WASM과의 연관성

Blazor WASM도 결국 V8(또는 각 브라우저 엔진)의 **WebAssembly 런타임** 위에서 동작합니다.

- JS → JIT 컴파일로 실행
- WASM(Blazor) → 별도 WASM 런타임으로 실행 (더 낮은 레벨의 바이트코드)
- 둘 다 같은 엔진(V8)이 처리하지만 실행 경로가 다름

## 관련 문서
- [[dotnet-il-wasm-runtime]]
