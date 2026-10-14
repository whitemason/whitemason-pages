---
paths:
  - "src/**/*.astro"
  - "src/styles/**"
---

# 디자인 규칙

- 배경은 로고 종이색 `#f8f7f3` 하나. 라이트 모드 전용(`color-scheme: light`), 다크 모드는 만들지 않는다.
- 색은 검정(`--label` #1d1d1f)과 회색 단계(`--label-2`, `--label-3`, `--border` #d2d2d7)만 쓴다. 파란색을 포함한 강조색은 쓰지 않는다.
- 클릭할 수 있는 곳은 검은색. App Store는 검은 캡슐 버튼(`.pill`), 그 밖의 링크는 검은 글자 + `›`.
- Casebook 카드는 배경 없이 연한 회색 테두리만 둔다.
- 본문 폰트는 SF Pro 시스템 폰트 스택. 워드마크 "Whitemason"만 Manufacturing Consent(400)를 쓴다.
- Apple HIG를 따른다: 16px 이상 좌우 여백, 키보드 포커스 링, `prefers-reduced-motion`이면 인트로를 건너뛴다.
- 문구를 바꿀 때는 사용자 승인을 받는다. 현재 문구: Casebook 설명 "숨겨진 사건의 진실".
