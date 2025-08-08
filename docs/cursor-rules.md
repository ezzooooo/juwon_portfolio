## 프로젝트 개요

이 문서는 본 포트폴리오 사이트(Flutter Web)의 작업 원칙(커서 룰)을 정의합니다. 목표는 웹 우선(Responsive, SEO 고려)으로 이력서와 프로젝트, 위젯 데모를 깔끔하고 빠르게 탐색할 수 있는 사이트를 구축하는 것입니다.

- **대상 플랫폼**: Flutter Web (추가적으로 Android/iOS/Desktop 빌드 가능하나 웹 중심)
- **핵심 카테고리**: 홈, 이력서, 프로젝트, 위젯 모음
- **핵심 가치**: 반응형·접근성·성능·검색 친화(SEO)·재사용성·간결한 유지보수


## 페이지 구성과 요구사항

### 홈(Home)
- 개인 소개(한 줄 소개, 핵심 역량, 간단한 키워드)와 주요 링크(GitHub, LinkedIn 등)
- 최신 혹은 대표 프로젝트 일부를 카드로 하이라이트
- 이력서/프로젝트/위젯 모음 섹션으로 이동 가능한 CTA 제공

### 이력서(Resume)
- 경력 요약, 기술 스택, 경력 타임라인, 학력, 자격/수상, 연락처/다운로드 링크(PDF)
- 구조화된 데이터(JSON-LD)를 통한 SEO 강화

### 프로젝트(Projects)
- 카드 그리드(반응형)로 프로젝트 목록 표시: 썸네일, 태그, 요약, 역할, 링크(GitHub/배포)
- 태그/카테고리 필터 및 검색(선택 사항)
- 상세 페이지(선택 사항): 문제-접근-결과, 기술 스택, 데모/스크린샷, 회고

### 위젯 모음(Widget Gallery)
- 포트폴리오에 사용된 재사용 컴포넌트/패턴 라이브 데모
- 각 위젯별 스펙(Props), 반응형 동작, 사용 예시 스니펫 제공


## 기술 스택 및 주요 라이브러리

- **Flutter stable** / Dart 최신 stable 범위 유지
- **Routing**: go_router
- **상태관리**: Riverpod (flutter_riverpod)
- **불변/모델**: freezed, json_serializable (선택)
- **로깅**: dart:developer + 간단 래퍼 (필요 시)
- **국제화(i18n)**: 기본 `ko`, 선택적으로 `en` 확장 (Flutter gen-l10n)
- **의존성 주입**: Riverpod Provider로 단순화
- **테마**: 라이트/다크 지원, 디자인 토큰 기반 스케일
- **아이콘/폰트**: Material Symbols/Google Fonts (웹 폰트 최적화)
- **애널리틱스(선택)**: Google Analytics(GTAG) - 빌드 시 `--dart-define`로 key 주입


## 디렉터리 구조 원칙

`lib/src` 기준으로 기능 단위 구조를 사용합니다.

```
lib/
  main.dart
  src/
    core/
      config/            # 환경/상수/실험(Feature flags)
      router/            # go_router 설정 및 라우트 정의
      theme/             # 색상, 타이포, 간격 토큰 및 라이트/다크 테마
      utils/             # 공통 유틸(세마틱, URL, Launcher 등)
      widgets/           # 앱 전역 공용 위젯(Section, AppScaffold 등)
    features/
      home/
        view/
        widgets/
      resume/
        data/            # 이력서 데이터 포맷, 리포지토리
        view/
        widgets/
      projects/
        data/
        view/
        widgets/
      gallery/
        view/
        widgets/
```

- `assets/data/`에 정적 데이터(JSON/Markdown) 저장. 예: `assets/data/resume_ko.json`, `assets/data/projects.json`
- 이미지/썸네일은 `assets/images/` 또는 `web/`에 위치(웹 퍼포먼스 고려)
- 파일/클래스 명명: `snake_case.dart`, 타입/클래스는 `PascalCase`, 변수/함수는 `camelCase`


## 반응형 설계 규칙

- **브레이크포인트(권장)**: `xs < 600`, `sm < 1024`, `md < 1440`, `lg < 1920`, `xl ≥ 1920`
- **레이아웃**: `LayoutBuilder` + 토큰화된 spacing/columns. 그리드 컬럼 수는 브레이크포인트에 따라 변화
- **타이포 스케일**: heading/body 캡쳐한 스케일을 브레이크포인트 별 미세 조정
- **터치 타겟**: 최소 40x40dp, 키보드 포커스 아웃라인 유지


## 접근성(A11y)

- Semantics 위젯으로 의미 전달, 이미지 대체 텍스트 제공
- 키보드 내비게이션(포커스 순서), 명확한 포커스 인디케이터
- 색 대비 WCAG 권장 준수(텍스트 대비 4.5:1 이상)
- 애니메이션/모션 과도 사용 지양, `MediaQuery.of(context).disableAnimations` 고려


## SEO 및 공유 메타

- `web/index.html`에 다음 반영
  - Title/Description/Keywords 메타 태그
  - OpenGraph/Twitter 카드 메타
  - Favicon/Manifest 적절 설정
- 라우팅은 Path URL 전략 사용(`setPathUrlStrategy`)하여 `/#/` 제거
- 정적 sitemap.xml, robots.txt 제공(배포 루트)
- 이력서/프로젝트 상세는 JSON-LD 구조화 데이터 삽입(가능 범위 내)


## 성능 원칙

- 이미지/썸네일은 크기별 준비 또는 `webp/avif` 고려
- 라우트 레이지 로딩(가능 범위), 위젯 트리 단순화, Rebuild 최소화
- 프로파일 빌드로 TTI(Time to Interactive) 확인 후 최적화 포인트 반영
- 웹 렌더러는 기본 auto 사용, 필요 시 canvaskit 옵션 비교


## 빌드/배포

- 개발: `flutter run -d chrome`
- 린트/포맷: `dart fix --apply`, `dart format .`, `flutter analyze`, `flutter test`
- 웹 빌드: `flutter build web --release`
- 배포: GitHub Pages/Netlify/Vercel 중 택1
  - GitHub Pages 사용 시 `web/`의 base href 확인, 커스텀 도메인 CNAME 설정
  - CI는 GitHub Actions로 빌드-배포 자동화(yaml 분리)


## 코드 스타일 & 품질

- Effective Dart 및 `analysis_options.yaml` 준수
- 네이밍은 의미 기반, 축약 피하고 명확성 우선
- 상태 최소화: Riverpod Provider 계층으로 데이터 흐름 단순화
- 예외 처리: 사용자 메시지와 로깅 분리, 실패 복구 UX 제공
- 테스트: 핵심 위젯 Golden 테스트, 라우팅/상태 위젯 테스트, 유틸 단위 테스트
- 커밋 규칙: Conventional Commits(`feat:`, `fix:`, `refactor:`, `docs:`, `chore:` 등)


## 구성/비밀값 처리

- 런타임 설정은 `--dart-define` 사용: 예) `--dart-define=GA_MEASUREMENT_ID=G-XXXX`
- 코드 내 비밀/토큰 하드코딩 금지, 공개 저장소 노출 금지


## 데이터 스키마(초안)

### 이력서(JSON 예시 키)
- `name`, `title`, `summary`, `contacts`(email, github, linkedin, blog)
- `skills`(categories: frontend, backend, mobile, devops, tools)
- `experiences`(company, role, period, summary, achievements[])
- `education`(school, degree, period)
- `certificates`(name, issuer, date)

### 프로젝트(JSON 예시 키)
- `title`, `description`, `role`, `highlights[]`, `techStack[]`, `period`, `links`(repo, demo), `thumbnail`
- `tags[]`(ex: flutter, web, state-management, performance)


## 위젯 모음 규칙

- 재사용 가능한 컴포넌트만 등재(카드, 섹션 헤더, 태그, 배지, 리치 링크, 반응형 그리드 등)
- 각 위젯 페이지에 Props/예제/반응형 스냅샷 제공
- 생산에 투입된 실제 UI/UX 패턴 우선 수록


## 작업 단계(로드맵)

1. 커서 룰 수립(본 문서) 및 기본 의존성 결정
2. 라우팅/테마/레이아웃 스켈레톤 생성, 홈/이력서/프로젝트/위젯 모음 라우트 뼈대
3. 데이터 모델/샘플 JSON/렌더링 바인딩
4. 반응형/접근성 마감, SEO 메타/JSON-LD 반영
5. 배포 파이프라인 구성 및 공개


## 수용 기준(Acceptance Criteria)

- 브라우저 너비 변화에 따라 각 페이지 레이아웃이 자연스럽게 적응한다
- 라우팅이 해시 없이 동작하며 브라우저 히스토리 연동이 정상이다
- Lighthouse 성능/접근성/베스트프랙티스/SEO 90+ 달성(이미지/폰트 최적화 포함)
- 이력서/프로젝트 데이터가 구조화되어 손쉽게 갱신 가능하다
- 기본 위젯 갤러리가 사용법과 함께 정상 동작한다


## 유지보수 원칙

- TODO 주석 대신 이슈 등록 및 링크(작업 추적)
- 기능 추가 시 스키마/도메인 용어/디자인 토큰 먼저 정렬 후 구현
- PR 단위는 작게, 테스트/스크린샷/데모 포함


