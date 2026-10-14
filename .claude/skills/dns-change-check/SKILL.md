---
name: dns-change-check
description: whitemason.club DNS를 GoDaddy에서 바꾼 뒤, 또는 바꾸기 전에 레코드를 점검한다. 사용자가 "DNS 저장했어", "레코드 바꿨어", "도메인 확인해줘"라고 하면 쓴다.
---

# DNS 변경 점검

DNS는 사용자가 GoDaddy에서 직접 바꾼다. 이 skill은 조회와 보고만 한다. 레코드를 고치는 일은 하지 않는다.

## 1. 권한 있는 네임서버 두 곳에 직접 조회

공개 resolver는 캐시가 있으니 판단에는 ns67/ns68 결과를 쓴다. zsh에서는 변수 단어가 나뉘지 않으니 이름과 타입을 따로 넘긴다.

```bash
for ns in ns67.domaincontrol.com ns68.domaincontrol.com; do
  echo "== $ns"
  for q in whitemason.club:A whitemason.club:AAAA www.whitemason.club:CNAME \
           casebook.whitemason.club:CNAME _github-pages-challenge-whitemason.whitemason.club:TXT \
           whitemason.club:MX whitemason.club:TXT whitemason.club:CAA; do
    n=${q%%:*}; t=${q##*:}
    echo "-- $n $t: $(dig +short +time=3 +tries=2 @$ns $n $t | tr '\n' ' ')"
  done
done
```

## 2. 기대값과 비교

AGENTS.md의 DNS 표와 비교한다. 특히:
- casebook CNAME이 `whitemason.github.io.`인지 (가장 중요. 운영 중인 Casebook 문서 사이트)
- `_github-pages-challenge-whitemason` TXT가 있는지
- MX 2개, SPF, `apple-domain` TXT가 있는지
- apex A에 GoDaddy 파킹 IP(`3.33.130.190`, `15.197.148.33`)가 섞여 있지 않은지. GoDaddy 화면에서는 "Parked"로 보인다
- CAA가 비어 있거나 Let's Encrypt를 허용하는지

## 3. 서비스 응답 확인

```bash
for u in http://whitemason.club/ https://whitemason.club/ https://www.whitemason.club/ https://casebook.whitemason.club/; do
  printf "%-36s " $u; curl -s -o /dev/null -m 10 -w "%{http_code} -> %{redirect_url} %{errormsg}\n" $u
done
```

## 4. 보고

- 사용자에게: 레코드별 표(레코드 · 지금 값 · 판정)와 고칠 것. 고칠 것은 GoDaddy 화면 기준으로 Name과 Value를 정확히 적는다.
- casebook 레코드에 이상이 있으면 보고의 맨 앞에 쓴다.
- 고친 뒤 다시 1~3을 돌려 확인한다.
