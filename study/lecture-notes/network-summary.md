# ⚡ 네트워크 압축 요약 (훑어보기용)

> 상세 설명·명령어는 「네트워크_핵심정리.md」에서 찾아보기. 복습용

## 챕터별 한입 요약

| Ch | 이것만 기억 |
|----|-------------|
| 1 | OSI 7계층: 물(비트)-데(프레임)-네(패킷)-전(세그먼트)-세-표-응. 충돌영역=L2로 분리, 브로드캐스트영역=L3로 분리 |
| 2 | 서브넷 수=2^s, 호스트 수=2^h−2. 사설IP: 10/8, 172.16/12, 192.168/16 |
| 3 | 같은 장비끼리=크로스, 다른 장비=스트레이트, 장비설정=롤오버(콘솔) |
| 4 | Flash=IOS, NVRAM=startup-config, RAM=running-config, ROM=POST·부트스트랩 |
| 5 | 모드: `>`사용자 → `#`관리자(enable) → `(config)#`전역(conf t) → 세부. secret > password |
| 6 | ping: `!`성공 `.`초과 `U`도달불가. SSH 설정 4요소: hostname+domain+rsa키+로컬계정 |
| 7 | 스위칭 속도: Cut through > Fragment free > Store&Forward (오류검사는 반대). STP=루프 방지, 30초(15+15) |
| 8 | 0x2102=정상부팅, 0x2142=설정 무시(패스워드 복구). 라우터=Ctrl+Break, 스위치=MODE 버튼 |
| 9 | AD: Connected 0 < Static 1 < OSPF 110 < RIP 120. Stub 네트워크=디폴트 라우팅 |
| 10 | RIP: 이웃에게/전부/30초마다, 최대 홉 15. OSPF: 전체에게/변화분만/즉시 |
| 11 | RIPv2 = 클래스리스 + 멀티캐스트 224.0.0.9 + 인증 가능. `version 2` + `no auto-summary` |
| 12 | OSPF 비용=10⁸/BW (FE=1, T1=64). Router ID: 수동 > 루프백 > 최대IP. Hello 10/Dead 40 |
| 13 | 모든 영역은 Area 0에 연결. O IA=다른 영역(ABR), O E=외부(ASBR) |
| 14 | 표준 ACL 1~99(출발지만, 목적지 근처), 확장 100~199(포트까지, 출발지 근처). 마지막은 묵시적 deny |
| 15 | VLAN 다름=네트워크 다름 → 통신엔 L3 필요. Access=1개 VLAN, Trunk=여러 개(802.1Q 태깅) |
| 16 | VLAN 간 통신: ①라우터 서브인터페이스(encapsulation dot1q N) ②L3스위치(SVI + ip routing) |
| 17 | NAT: Static(1:1 서버)/Dynamic(풀)/PAT(overload, 포트로 다:1). DHCP=DORA, UDP 67/68 |
| 18 | 유선 CSMA/CD vs 무선 CSMA/CA. WEP(RC4)→WPA(TKIP)→WPA2(AES)→WPA3(SAE) |
| 19 | up/up=정상, adm down=no shutdown 안함, up/down=L2(clock·캡슐화), down/down=L1(케이블) |
| 20 | HSRP: Priority 큰 쪽이 Active(기본 100), PC 게이트웨이=Virtual IP, preempt=자리 되찾기 |
| 22 | secret(Type5)=안전, Type7=크랙됨. no ip directed-broadcast=Smurf 차단. Ingress/Egress 필터링 |

## 숫자 카드

| 숫자 | 의미 | 숫자 | 의미 |
|---|---|---|---|
| 15 | RIP 최대 홉 | 22/23 | SSH/Telnet |
| 30초 | RIP 업데이트 | 67/68 | DHCP 서버/클라 |
| 10/40초 | OSPF Hello/Dead | 69 | TFTP |
| 3/10초 | HSRP Hello/Hold | 53/80/443 | DNS/HTTP/HTTPS |
| 1/110/120 | AD Static/OSPF/RIP | 224.0.0.5·6 | OSPF |
| 32768 | STP 기본 Priority | 224.0.0.9 | RIPv2 |

## 최소 명령어 세트

```
conf t → hostname X → int fa0/0 → ip address A.B.C.D 마스크 → no shutdown
copy running-config startup-config
ip route 0.0.0.0 0.0.0.0 다음홉                    # 디폴트 라우팅
router ospf 10 → network X 와일드카드 area 0      # OSPF
vlan 10 → int fa0/5 → switchport access vlan 10   # VLAN
access-list 100 deny tcp 출발 WC 목적 WC eq 23 → int → ip access-group 100 in
show ip int brief / show ip route / show vlan / show run
```
