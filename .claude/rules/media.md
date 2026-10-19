---
paths:
  - "public/media/**"
  - "tools/**"
---

# 로고 영상 · 워드마크 이미지 규칙

## 로고 영상 (`public/media/mason.mp4`)
- 원본 영상(640×640, 4초)은 저장소에 없다. 다시 가공하려면 사용자에게 원본을 받는다.
- 가공본은 종이를 순백(#fff)으로 평탄화하고 오디오를 뺀 H.264다. 페이지에서 `mix-blend-mode: multiply`로 겹쳐
  흰색이 배경색과 정확히 같아진다. 배경색을 바꿔도 영상은 다시 만들 필요가 없다.
- 가공 스크립트: `tools/flatten-logo-video.swift` (macOS AVFoundation + CoreImage, ffmpeg 불필요).
  스크립트가 만드는 파일 이름은 저장소 파일 이름과 다르다. 아래 순서대로 바꿔 넣는다.

```bash
OUT=$(mktemp -d)                                  # 중간 결과 폴더
sips -s format png <원본 로고.webp> --out $OUT/logo.png   # 로고가 PNG면 생략
swiftc -O tools/flatten-logo-video.swift -o $OUT/flatten
$OUT/flatten <원본.mp4> public/media/mason.mp4 $OUT $OUT/logo.png
# → public/media/mason.mp4, $OUT/first.png, $OUT/last.png, $OUT/logo-flat.png

# 포스터: 회색조로 바꾸며 이름을 저장소 이름으로 (Pillow 필요)
python3 -c "
from PIL import Image; import sys
o=sys.argv[1]
Image.open(o+'/first.png').convert('L').save('public/media/mason-start.png', optimize=True)
Image.open(o+'/last.png').convert('L').save('public/media/mason-end.png', optimize=True)" $OUT

# 아이콘 · OG: 흰 종이를 배경색 #f8f7f3과 곱해서 만든다
python3 -c "
from PIL import Image, ImageChops; import sys
o=sys.argv[1]; bg=(248,247,243)
logo=Image.open(o+'/logo-flat.png').convert('RGB'); logo=ImageChops.multiply(logo, Image.new('RGB', logo.size, bg))
for n,s in [('favicon.png',48),('apple-touch-icon.png',180),('icon-512.png',512)]:
    logo.resize((s,s), Image.LANCZOS).save('public/'+n, optimize=True)
og=Image.new('RGB',(1200,630),bg); og.paste(logo.resize((560,560), Image.LANCZOS),(320,35)); og.save('public/og.png', optimize=True)" $OUT
```

- `mason-start.png`는 인트로 시작 전 포스터, `mason-end.png`는 인트로가 끝난 뒤와 동작 줄이기 설정에서 보이는 정지 화면이다. 영상을 바꾸면 둘 다 함께 바꾼다.
- 로고만 바뀌고 영상이 그대로면 아이콘 · OG 단계만 다시 하면 된다. 이때도 스크립트는 영상 인자가 필요하므로 지금 원본 영상을 함께 넘기고, 출력 mp4는 버린다.

## 손글씨 워드마크 (`public/media/wordmark.webp`, `wordmark@2x.webp`)
- 사용자가 준 흰 바탕 붓글씨 이미지(2000×667, 회색 먹)에서 만들었다. 원본은 저장소에 없으니 다시 만들려면 사용자에게 받는다.
- 먹색은 바꾸지 않는다. 가장 진한 먹(밝기 41) 한 색으로 고정하고, 원본 밝기를 알파로 옮긴다.
  흰 바탕에 다시 얹으면 원본과 같은 회색이 되고, 옅은 붓 결은 반투명으로 남는다. 색이 한 가지라 줄여도 테두리에 흰 띠가 생기지 않는다.
- 밝기 251 이상은 종이로 보고 투명하게 한다(글자 밖 종이 잡티가 251). 글자 영역만 잘라(여백 6px) 240px · 480px 너비의 무손실 WebP로 저장한다.
- 원본이 바뀌면 먼저 가장 진한 먹 값과 종이 잡티 값을 다시 재서 `INK` · `PAPER`를 맞춘다.

```bash
python3 -c "
from PIL import Image; import sys
INK, PAPER = 41, 251
g=Image.open(sys.argv[1]).convert('L')
a=g.point(lambda v: 0 if v>=PAPER else 255 if v<=INK else round((PAPER-v)/(PAPER-INK)*255))
b=a.getbbox(); p=6; a=a.crop((max(b[0]-p,0),max(b[1]-p,0),min(b[2]+p,g.width),min(b[3]+p,g.height)))
for w,n in [(240,'wordmark.webp'),(480,'wordmark@2x.webp')]:
    m=a.resize((w,round(w*a.height/a.width)), Image.LANCZOS)
    Image.merge('RGBA',(Image.new('L',m.size,INK),)*3+(m,)).save('public/media/'+n, lossless=True, quality=100, method=6)" <원본 워드마크 이미지>
```

- 화면 크기 기준: 워드마크 글자 범위가 로고 그림의 먹 범위와 같은 폭이 되게 하고, 가운데 정렬한다.
  (mason-end 먹 범위 517/640, 워드마크 글자 범위 474/480). `.mark` 너비가 바뀌면 `.name img` 너비와 `src/pages/index.astro`의 `width` · `height` 속성을 이 비율로 다시 계산한다.
