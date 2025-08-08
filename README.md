# Juwon Portfolio (Flutter Web)

개인 이력서/프로젝트/위젯 갤러리를 담은 Flutter Web 포트폴리오입니다.

## 개발 실행

```bash
flutter run -d chrome
```

CanvasKit로 확인하려면:

```bash
flutter run -d chrome --web-renderer canvaskit
```

## 빌드

```bash
flutter build web --release
```

## GitHub Pages 배포

이 저장소는 GitHub Actions를 통해 자동으로 GitHub Pages에 배포됩니다.

### 기본(유저/오거나이제이션 페이지 제외, 커스텀 도메인 없음)
- main 브랜치에 push하면 워크플로우가 실행되어 `build/web` 산출물을 Pages로 배포합니다.
- `base href`는 `/${REPO_NAME}/`로 설정됩니다.

### 커스텀 도메인 사용
1. `web/CNAME` 파일의 내용을 원하는 도메인으로 변경합니다. 예: `portfolio.yourdomain.com`
2. DNS에서 해당 도메인을 `username.github.io`로 CNAME 설정합니다.
3. 워크플로우가 `web/CNAME` 존재를 감지해 `base href`를 `/`로 설정하여 빌드합니다.

### 유저/오거나이제이션 페이지(`username.github.io`)
- `base href`가 `/`이어야 하므로 `web/CNAME`을 유지하거나, 워크플로우를 적절히 수정하세요.

## 자산/데이터
- 이력서: `assets/data/resume_ko.json`
- 프로젝트: `assets/data/projects.json`

## 라우트
- `/` 홈
- `/resume` 이력서
- `/projects` 프로젝트 목록
- `/projects/:id` 프로젝트 상세
- `/gallery` 위젯 갤러리

## 라이선스
MIT
