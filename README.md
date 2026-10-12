# whitemason.club

Whitemason 스튜디오 웹사이트. Astro로 만든 정적 사이트를 GitHub Pages에 배포한다.

## 개발

```bash
npm install
npm run dev
```

## 로고 애니메이션

- `public/media/mason.mp4`: 원본 영상의 종이 배경을 순백으로 평탄화하고 오디오를 뺀 버전.
  페이지에서 `mix-blend-mode: multiply`로 겹치므로 흰색이 배경색(`#f8f7f3`)과 정확히 같아진다.
- `mason-start.png` / `mason-end.png`: 첫 프레임과 마지막 프레임 포스터.
- 인트로는 페이지를 열거나 새로고침할 때마다 재생하고, 동작 줄이기 설정에서는 마지막 프레임만 보여 준다.

## 배포

`main`에 push하면 `.github/workflows/deploy.yml`이 빌드해 GitHub Pages로 배포한다.

1. 저장소 Settings › Pages › Source를 **GitHub Actions**로 설정
2. DNS에서 `whitemason.club` apex A 레코드를 GitHub Pages 주소로 변경
   `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
3. Settings › Pages › Custom domain에 `whitemason.club` 입력 후 **Enforce HTTPS** 켜기
