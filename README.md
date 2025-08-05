# 📱 Findation iOS App (SwiftUI Frontend)

애플 파인데이션 프로그램 팀 **Findation**의 SwiftUI 기반 iOS 프로젝트입니다.  

---

## 📁 프로젝트 디렉토리 구조

SwiftUI 앱 프로젝트에서 사용할 디렉토리 구조입니다. (변경 사항이 있다면 추가해주세요.)

<pre lang="markdown"><code>
```
Findation/
├── Constants/
├── Core/
│   ├── Root/
│   ├── Auth/
│   ├── Home/
│   └── MyPage/
├── Models/
├── Resources/
│   └── Assets/
├── Managers/
├── Helper/
├── Utils/
└── FindationApp.swift
```
</code></pre>



| 디렉토리/파일             | 설명                                                        |
|---------------------------|-------------------------------------------------------------|
| `Constants/`              | 앱 전역에서 사용하는 상수 정의 (예: 색상, 문자열, 레이아웃 값 등) |
| `Core/`                   | 핵심 기능을 담는 디렉토리 (기초 화면 구조, 네비게이션 등)          |
| `Core/Root/`              | 앱의 루트 뷰 구성 (`ContentView` 등 메인 엔트리 포인트)           |
| `Core/Auth/`              | 앱의 로그인과 관련된 뷰 구성          |
| `Core/Home/`              | 앱의 홈과 관련된 뷰 구성         |
| `Core/MyPage/`            | 앱의 마이페이지와 관련된 뷰 구성          |
| `Models/`                 | 데이터 모델 정의 (예: `User`, `Routines` 등)             |
| `Resources/`              | 리소스 관리 디렉토리 (Assets, 폰트, 로컬 JSON 등)               |
| `Resources/Assets/`       | 이미지, 색상셋 등 Xcode Asset Catalog                         |
| `Managers/`               | 특정 도메인, 기능에 대한 비지니스 로직 관리                              |
| `Helper/`                 | 잡다한 기능들을 수행하는 유틸리티 함수                              |
| `Utils/`                  | 공용 헬퍼 클래스, 모디파이어 등                              |


## 📦 사용된 서드파티 패키지

| 패키지명     | 설명                                            | 설치 방식         |
|--------------|-------------------------------------------------|-------------------|
| [Alamofire](https://github.com/Alamofire/Alamofire) | HTTP 네트워킹을 간편하게 도와주는 Swift 라이브러리 | Swift Package Manager (SPM) |


## 💬 커밋 메시지 규칙

커밋 메시지는 다음의 규칙에 따라 작성합니다.
커밋 예약어는 모두 대문자로 작성하며, 메시지의 앞에 붙입니다.

### ✅ 커밋 메시지 예시

| 커밋 태그  | 설명                                                  |
| ---------- | ----------------------------------------------------- |
| `FEAT`     | 새로운 기능에 대한 커밋                               |
| `FIX`      | 버그 수정에 대한 커밋                                 |
| `BUILD`    | 빌드 관련 파일 수정 / 모듈 설치 또는 삭제에 대한 커밋 |
| `CHORE`    | 그 외 자잘한 수정에 대한 커밋                         |
| `DOCS`     | 문서 수정에 대한 커밋                                 |
| `STYLE`    | 코드 스타일 혹은 포맷 등에 관한 커밋                  |
| `REFACTOR` | 코드 리팩토링에 대한 커밋                             |
| `TEST`     | 테스트 코드 수정에 대한 커밋                          |
| `PERF`     | 성능 개선에 대한 커밋                                 |

```bash
FEAT: add dark mode support using ColorScheme
FIX: fix navigation bug when tapping back from detail view
STYLE: apply consistent spacing and padding in HomeView
DOCS: update README with environment setup guide
CHORE: rename `LoginView.swift` to `AuthView.swift` for clarity
```
