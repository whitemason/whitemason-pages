---
name: pages-cert-check
description: whitemason.club의 GitHub Pages HTTPS 인증서 상태를 확인하고, www가 빠졌거나 Enforce HTTPS를 켤 수 없을 때 해결 순서를 안내한다.
---

# Pages 인증서 점검

## 1. 지금 나가는 인증서 확인

```bash
for h in whitemason.club www.whitemason.club; do
  echo "== $h"
  echo | openssl s_client -connect 185.199.108.153:443 -servername $h 2>/dev/null \
    | openssl x509 -noout -text | grep -E "Subject:|Not Before|DNS:" | head -3
done
```

정상: 두 이름 모두 `CN=whitemason.club`, SAN에 `whitemason.club`과 `www.whitemason.club`이 있다.
`CN=*.github.io`가 나오면 그 이름의 인증서가 아직 없다는 뜻이다.
macOS에는 `timeout` 명령이 없으니 쓰지 않는다. Let's Encrypt는 Not Before를 1시간쯤 앞당겨 적는다.

## 2. 증상별 조치 (사용자가 Settings › Pages에서 한다)

| Pages 화면 문구 | 원인 | 조치 |
|---|---|---|
| domain is not properly configured | DNS에 GitHub이 아닌 IP가 섞임 (주로 GoDaddy "Parked") | skill `dns-change-check`로 확인 → 레코드 정리 → Check again |
| certificate has not yet been issued | 발급 대기 | 1번으로 실제 인증서를 확인한다. 이미 나왔으면 새로고침만 하면 된다 |
| apex 인증서에 www가 없음 | 발급 시점에 www DNS가 틀렸거나 캐시가 남아 있었음 | www의 예전 TTL(1시간)이 지난 뒤 Custom domain을 비우고 Save → 다시 입력하고 Save → Enforce HTTPS 다시 켜기 |

Custom domain을 다시 저장하면 몇 분에서 1시간 정도 apex에 인증서 경고가 날 수 있다. 진행 전에 사용자 결정을 받는다.

## 3. 끝난 뒤

SAN, `http`→`https` 301, `www`→apex 301, casebook 200을 확인해 사용자에게 알린다.
