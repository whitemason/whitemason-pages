---
paths:
  - "src/**/*.astro"
  - "src/styles/**"
---

# 디자인 규칙

- 배경은 로고 종이색 `#f8f7f3` 하나. 라이트 모드 전용(`color-scheme: light`), 다크 모드는 만들지 않는다.
- 색은 검정(`--label` #1d1d1f)과 회색 단계(`--label-2`, `--label-3`, `--border` #d2d2d7)만 쓴다. 파란색을 포함한 강조색은 쓰지 않는다.
- 클릭할 수 있는 곳은 검은색. App Store는 검은 캡슐 버튼(`.pill`), 그 밖의 링크는 검은 글자 + `›`.
- 앱 카드는 배경 없이 연한 회색 테두리만 둔다. 순서는 출시된 앱 먼저(Casebook → Keystone).
- 앱 카드는 데스크톱에서 같은 높이로 가로로 나란히, 734px 이하에서는 세로로 쌓는다.
- App Store에 없고 TestFlight 공개 베타가 있는 앱은 같은 검은 캡슐 버튼(`.pill`)에 글자 "TestFlight"를 두고, 출시되면 글자와 링크를 "App Store"로 바꾼다.
- 공개 링크가 아직 없는 앱은 같은 크기의 회색 캡슐 `.pill.off`(링크 아님, 글자 "TestFlight 곧 공개")를 둔다. 링크 대상 페이지가 게시되기 전에는 "웹사이트 ›"도 넣지 않는다(깨진 링크 금지).
- 아이콘은 64px. App Store 아이콘처럼 네모난 그림은 CSS로 모서리(14px)와 얇은 테두리를 두르고, Icon Composer에서 모서리 · 테두리까지 내보낸 그림은 `.icon-shaped`로 CSS 모서리 · 테두리를 빼서 이중 테두리를 막는다.
- 글자는 SF Pro 시스템 폰트 스택만 쓴다. 워드마크 "Whitemason"은 글자가 아니라 손글씨 이미지(`public/media/wordmark.webp`, `@2x`)이고 alt는 "Whitemason"이다.
- Apple HIG를 따른다: 16px 이상 좌우 여백, 키보드 포커스 링, `prefers-reduced-motion`이면 인트로를 건너뛴다.
- 문구를 바꿀 때는 사용자 승인을 받는다. 현재 문구: Casebook 설명 "숨겨진 사건의 진실", Keystone 설명 "App Store 심사 준비를 한곳에서.", Whitebell 설명 "병실에서 간호사에게 보내는 요청을 한곳에서. 급하면 콜벨을 먼저 눌러요."
