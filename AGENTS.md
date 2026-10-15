# whitemason-pages

Whitemason 스튜디오 웹사이트 https://whitemason.club 의 저장소. Astro 정적 사이트를 GitHub Pages에 배포한다.

## 이 저장소가 다루는 것 / 다루지 않는 것

- 다룬다: `whitemason.club` 메인 페이지 한 장과 404 페이지, 로고 애니메이션, 폰트, 아이콘.
- **다루지 않는다: `casebook.whitemason.club`.** Casebook 문서 사이트는 별도 저장소 `whitemason/casebook-pages`에 있다.
  App Store Connect의 처리방침 · 지원 · 마케팅 URL이 그 주소를 가리키므로 이 저장소 작업 중에 그 사이트나 DNS 레코드를 바꾸지 않는다.
- 조직 사이트 저장소 `whitemason/whitemason.github.io`는 없다. 만들면 casebook CNAME 대상(`whitemason.github.io`)에 영향이 갈 수 있으니 사용자 결정을 받은 뒤에만 만든다.

## 명령

```bash
npm install        # 의존성 설치 (package-lock.json 기준)
npm run dev        # 개발 서버 http://localhost:4321
npm run build      # dist/ 로 정적 빌드
npm run preview    # dist/ 미리보기
```

테스트 코드는 없다. 바꾼 뒤에는 `npm run build`가 통과하는지와 브라우저에서 인트로 → 전환 → 본문이 보이는지 확인한다.

## 폴더 구조

```
src/pages/index.astro     메인 페이지 (인트로 스크립트, 페이지 스타일)
src/pages/404.astro       404 페이지
src/layouts/Base.astro    <head> 공통 (title, description, OG, 아이콘)
src/styles/global.css     색 · 폰트 토큰, @font-face
public/media/             로고 영상(mason.mp4), 포스터, Casebook 아이콘
public/fonts/             워드마크 폰트 subset + OFL.txt
public/CNAME              whitemason.club (Actions 배포에서는 쓰이지 않음, 기록용)
.github/workflows/deploy.yml   main push → GitHub Pages 배포
tools/flatten-logo-video.swift 로고 영상 종이 평탄화 스크립트 (사용법: .claude/rules/media.md)
.claude/rules/            경로별 규칙: design.md(화면 코드), media.md(영상 · 폰트 파일)
.claude/skills/           점검 절차: dns-change-check, pages-cert-check
```

## 배포

- `main`에 push하면 `.github/workflows/deploy.yml`이 빌드해 GitHub Pages로 배포한다(1~2분).
  사용하는 action: `actions/checkout@v7`, `withastro/action@v6`, `actions/deploy-pages@v5`.
- Pages 설정: Source = GitHub Actions, Custom domain = `whitemason.club`, Enforce HTTPS 켬.
  Actions 배포는 `public/CNAME`을 읽지 않는다. 도메인은 저장소 Settings › Pages에서만 바뀐다.
- 인증서 SAN은 `whitemason.club`, `www.whitemason.club` 두 개다. `www`는 apex로 301 이동한다.
- 배포 뒤 확인: Actions run이 success인지, `https://whitemason.club/`에 바뀐 내용이 나오는지.

## DNS (GoDaddy, ns67/ns68.domaincontrol.com)

DNS는 사용자가 GoDaddy 화면에서 직접 바꾼다. 에이전트는 값을 조회하고 확인만 한다.

**규칙: 어떤 레코드든 저장한 직후 ns67과 ns68 두 곳에 직접 조회해 아래 값이 그대로인지 확인한다.**
2026-10-12에 다른 레코드를 편집하다가 casebook CNAME이 두 번 망가졌다(한 번은 사라지고, 한 번은 값이 `github-pages-challenge-whitemason.`으로 바뀜).

| Type | Name | 값 |
|---|---|---|
| A | `@` | `185.199.108.153` · `185.199.109.153` · `185.199.110.153` · `185.199.111.153` |
| AAAA | `@` | `2606:50c0:8000::153` · `2606:50c0:8001::153` · `2606:50c0:8002::153` · `2606:50c0:8003::153` |
| CNAME | `www` | `whitemason.github.io` |
| CNAME | `casebook` | `whitemason.github.io` |
| TXT | `_github-pages-challenge-whitemason` | GitHub 조직 Pages 도메인 인증 값. 지우지 않는다 |
| MX | `@` | `mx01.mail.icloud.com` · `mx02.mail.icloud.com` (iCloud+ 메일) |
| TXT | `@` | SPF `v=spf1 include:icloud.com ~all`, `apple-domain=…` |

- GoDaddy의 "Parked" A 레코드나 Forwarding이 다시 생기면 GitHub 인증서 발급이 막힌다. 보이면 사용자에게 삭제를 요청한다.
- 조회 절차와 보고 형식은 skill `dns-change-check`를 따른다.

## 결정 권한

- 문구, 디자인, 그 밖에 불확실한 부분은 사용자에게 승인 · 거절 · 수정 답을 받은 뒤 진행한다.
- 도메인 · DNS · 공개 시점 · 다른 저장소에 영향을 주는 변경은 사용자 결정이 있어야 한다.
  선택지와 추천안을 정리해 결정을 요청하고, casebook 주소에 이상이 보이면 가장 먼저 알린다.
- 커밋과 push는 사용자가 요청했을 때만 한다.

## 함께 작업할 때

- 작업 전에 `git pull --ff-only`로 최신 상태를 받는다.
- force push 금지. 충돌이 나면 혼자 해결하지 말고 사용자에게 알린다.
- 브랜치는 `main` 하나를 쓴다(push가 곧 배포).
- 커밋 메시지는 한국어. 첫 줄은 무엇을 바꿨는지, 본문은 `-` 목록으로 이유와 세부.
- 사용자에게 쓰는 글은 한국어로 쓰고, API 같은 전문 용어와 고유명사는 원어로 쓴다.

## 의존성

- 버전은 정확히 고정한다(`"astro": "7.3.5"`처럼 `^` 없이).
- 새 버전은 배포된 지 2주가 지난 것만 쓴다.

## 공개 금지 정보

- 토큰, API key, 비밀 값, 개인 이메일 주소를 코드 · 커밋 · 문서에 쓰지 않는다.
- 사이트에 공개하는 연락처는 `engineering@whitemason.club` 하나다.
