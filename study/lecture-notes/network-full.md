# 🌐 네트워크 수업 핵심 정리 (Chapter 1 ~ 22)

> 교수님 필기 + 시스코 명령어 모음을 챕터별로 정리한 스터디 노트.
> 각 챕터는 **① 한 줄 요약 → ② 꼭 알아야 할 개념 → ③ 핵심 명령어 → ④ 시험 포인트** 순서.
> 🍯 = 쉽게 이해하기 위한 비유

---

## 📖 목차

| Ch | 주제 | Ch | 주제 |
|----|------|----|------|
| 1 | 통신모델과 네트워크 환경 | 12 | OSPF 라우팅 |
| 2 | 서브넷 계산 | 13 | 다중영역 OSPF |
| 3 | 전송매체 (케이블) | 14 | ACL |
| 4 | 라우터 셋업모드 | 15 | VLAN |
| 5 | 라우터 기본설정 | 16 | VLAN 간 라우팅 |
| 6 | 라우터 전역설정 | 17 | NAT & DHCP |
| 7 | 스위치 기본설정 | 18 | 무선랜 |
| 8 | 패스워드 복구 & IOS | 19 | 네트워크 문제 해결 |
| 9 | 정적 라우팅 | 20 | 이중화 (HSRP) |
| 10 | 동적 라우팅 (RIP) | 22 | 라우터 보안설정 |
| 11 | 클래스리스 라우팅 | 부록 | 명령어 치트시트 |

---

# Chapter 1. 통신모델과 네트워크 환경

## ① 한 줄 요약
네트워크가 뭔지, 데이터가 어떤 "층(계층)"을 거쳐 전달되는지 배우는 챕터. **OSI 7계층이 이 과목 전체의 뼈대**다.

## ② 꼭 알아야 할 개념

### 네트워크 = 노드 + 링크
- **노드(Node)** : 네트워크 장비 (컴퓨터, 스위치, 라우터...)
- **링크(Link)** : 장비를 잇는 선
- 🍯 도시(노드)와 도로(링크)라고 생각하면 됨.

### LAN / MAN / WAN
| 종류 | 범위 | 비유 🍯 |
|------|------|--------|
| LAN | 건물/학교 하나 (수 km 이내, 단일 기관 소유) | 우리 동네 |
| MAN | 도시 규모, LAN끼리 연결 | 시내버스 노선 |
| WAN | 나라/세계, LAN·MAN을 중계 (= 인터넷) | 고속도로·비행기 |

### 프로토콜(Protocol) = 통신 약속
- 서로 같은 약속(프로토콜)을 써야 대화 가능. 인터넷의 약속 = **TCP/IP**
- 3요소: **Syntax(형식) / Semantics(의미) / Timing(타이밍)**

### 이더넷(Ethernet) — 지금의 LAN 표준
- **IEEE 802.3**, 방식은 **CSMA/CD** (말하기 전에 듣고, 충돌하면 잠깐 기다렸다 다시 말함 = backoff)
- 속도 진화: 10M → Fast(100M, 802.3u) → Gigabit(1000M, 802.3ab/z) → 10G...
- 옛날 LAN 기술: **토큰링**(802.5, 토큰 가진 사람만 말함), **FDDI**(광케이블 이중 링, 100M)

### ⭐ 충돌 영역 vs 브로드캐스트 영역 (매우 중요!)
| | 충돌(Collision) 영역 | 브로드캐스트 영역 |
|---|---|---|
| 발생 | 같은 세그먼트 안 | 같은 네트워크 안 |
| 분리하는 장비 | **L2 이상** (브리지, 스위치) | **L3 이상** (라우터, L3스위치) |
| 🍯 | 한 방에서 여럿이 동시에 말하면 시끄러움 | 교내 방송은 학교 전체에 울림 |

- L1 장비(허브, 리피터)는 충돌영역을 **못** 나눔 → 오히려 키움

### 토폴로지(연결 모양)
- **물리적**: 버스 / 링 / 스타(성형, LAN에서 주로) / 메쉬(망형, WAN에서 주로, 링크 수 = n(n-1)/2) / 계층형(Core-Distribution-Access 3티어)
- **논리적**: 버스(경쟁 방식) / 링(토큰 패싱)

### ⭐ OSI 7계층 (통째로 암기!)
🍯 택배에 비유: 물건(데이터)을 상자에 넣고(캡슐화), 주소를 붙이고, 트럭에 실어 보내는 과정을 7단계로 나눈 것.

| 계층 | 이름 | 전송 단위 | 핵심 역할 | 대표 장비/프로토콜 |
|---|---|---|---|---|
| L7 | 응용 (Application) | 데이터 | 사용자 서비스 창구 | HTTP, FTP, SSH, 방화벽 |
| L6 | 표현 (Presentation) | 데이터 | 형식 변환, 암호화, 압축 | JPG, ASCII, SSL |
| L5 | 세션 (Session) | 데이터 | 대화 시작·유지·종료 | TLS/SSL, RPC |
| L4 | 전송 (Transport) | **세그먼트** | 종단 간(End-to-End) 전달, 오류/흐름 제어 | TCP, UDP, L4스위치 |
| L3 | 네트워크 (Network) | **패킷** | 경로 선택(라우팅), IP 주소 | IP, ICMP, 라우터 |
| L2 | 데이터링크 (Data Link) | **프레임** | 인접 장비 간 신뢰성 전송, MAC 주소 | 이더넷, PPP, 스위치 |
| L1 | 물리 (Physical) | **비트** | 전기 신호로 보내기 | 케이블, 허브, 리피터 |

- 암기 팁: 아래서부터 "**물데네전세표응**"
- **캡슐화**: 위→아래로 내려가며 각 층이 헤더를 붙임 (L2는 트레일러도 붙임)
- L2 동작: 목적지 MAC 확인 → MAC 테이블에 없으면 **플러딩(Flooding)**
- L3 동작: 목적지 IP 확인 → 라우팅 테이블에 없으면 **폐기(Drop)**

### TCP/IP 4계층 (OSI를 실무용으로 압축)
| TCP/IP | OSI 대응 | 핵심 |
|---|---|---|
| 응용 (Application) | L5~L7 | DNS, HTTP, SMTP, DHCP... |
| 전송 (Transport) | L4 | TCP(신뢰성 O), UDP(신뢰성 X, 빠름) |
| 인터넷 (Internet) | L3 | IP, ICMP, ARP |
| 네트워크 접속 (Network Access) | L1~L2 | 이더넷, Wi-Fi, MAC 주소 |

### 꼭 아는 프로토콜들
- **ARP**: IP 주소 → MAC 주소 찾기 ("이 IP 가진 사람 MAC 알려줘!" 방송)
- **RARP**: 반대. MAC → IP
- **ICMP**: IP의 오류 알림 도우미. **ping이 쓰는 프로토콜** (echo request/reply)
- **IGMP**: 멀티캐스트 그룹 관리
- 프로토콜 번호: ICMP(1), TCP(6), UDP(17)

### ⭐ 주요 포트 번호 (Well-Known: 0~1023)
| 서비스 | 포트 | 서비스 | 포트 |
|---|---|---|---|
| FTP | 20(데이터)/21(제어) | HTTP | 80 |
| SSH | 22 | HTTPS | 443 |
| Telnet | 23 | POP3 | 110 |
| SMTP | 25 | SNMP | 161/162(trap) |
| DNS | 53 | DHCP | 67(서버)/68(클라) |
| TFTP | 69 | | |

### IP 주소 & MAC 주소
- **IPv4**: 32비트, 점+십진수 (예: 192.168.1.1), 유니/멀티/브로드캐스트
- **IPv6**: 128비트, 콜론+16진수, 유니/멀티/**애니캐스트**(가장 가까운 서버가 응답)
- **MAC**: 48비트 = OUI(제조사, 24bit) + Serial(24bit). 하드웨어에 새겨진 주소(BIA)
- 루프백(자기 자신 테스트): IPv4 `127.0.0.1`, IPv6 `::1`
- IP 관리 체계: IANA(전세계) → RIR(대륙, 아시아=APNIC) → KRNIC(한국, KISA)

### 도메인
- `www.google.com` = 호스트(www) + 도메인(google.com)
- **FQDN**: 호스트+도메인 전체 이름
- **DNS**: 도메인 이름 → IP 주소 번역기 🍯 전화번호부

## ③ 핵심 명령어 (Windows PC 점검용)
```
ipconfig /all      # 내 PC 네트워크 정보 전부 보기
ipconfig /flushdns # DNS 캐시 지우기
ping 8.8.8.8       # 연결 테스트 (-t: 계속)
arp -a             # IP↔MAC 변환 테이블 보기
netstat -an        # 현재 연결/포트 상태 (숫자로)
netstat -r         # 라우팅 테이블 (= route PRINT)
tracert google.com # 목적지까지 경유지 확인
nslookup naver.com # 도메인의 IP 찾기
```

## ④ 시험 포인트
- OSI 7계층 각 층의 **전송 단위**(비트-프레임-패킷-세그먼트-데이터)와 **대표 장비** 매칭
- 충돌영역은 L2, 브로드캐스트영역은 L3 장비로 분리
- 포트 번호 암기 (특히 SSH 22, Telnet 23, DNS 53, HTTP 80)
- ARP(IP→MAC) vs RARP(MAC→IP) 방향 헷갈리지 않기

---

# Chapter 2. 서브넷 계산

## ① 한 줄 요약
큰 네트워크 하나를 여러 개의 작은 네트워크로 쪼개는(서브네팅) 계산법. **자격증·시험 단골 계산 문제!**

## ② 꼭 알아야 할 개념

### IP 주소 클래스 (첫 옥텟 값으로 구분)
| 클래스 | 첫 비트 | 첫 옥텟 범위 | 기본 마스크 | 용도 |
|---|---|---|---|---|
| A | 0 | 0~127 | /8 | 대규모 |
| B | 10 | 128~191 | /16 | 중규모 |
| C | 110 | 192~223 | /24 | 소규모 |
| D | 1110 | 224~239 | - | 멀티캐스트 |
| E | 1111 | 240~255 | - | 실험용 |

### ⭐ 사설 IP (외우기!)
- A: `10.0.0.0/8`
- B: `172.16.0.0 ~ 172.31.0.0` → 묶어서 `172.16.0.0/12`
- C: `192.168.0.0 ~ 192.168.255.0` → 묶어서 `192.168.0.0/16`
- `169.254.0.0/16` = 링크 로컬 (IP를 못 받아왔다는 신호! DHCP 실패)
- 사설 IP는 인터넷 직접 접속 불가 → 그래서 보안엔 유리, 밖에 나가려면 NAT 필요

### 서브네팅 원리
🍯 큰 피자 한 판(네트워크)을 여러 조각(서브넷)으로 자르는 것. 자를수록 조각 수는 늘지만, 각 조각의 크기(호스트 수)는 작아짐.

```
IP 주소 = 네트워크(N) + 호스트(H)
서브네팅 후 = 네트워크(N) + 서브넷(s) + 호스트(h)
→ 호스트 비트 일부를 빌려서 서브넷 비트로 씀
```

- **서브넷 마스크**: 네트워크+서브넷 부분은 1, 호스트 부분은 0
- 각 서브넷에서 **첫 주소(전부 0) = 네트워크 주소**, **끝 주소(전부 1) = 브로드캐스트 주소** → 이 2개는 호스트에게 못 줌
- 공식:
  - 서브넷 개수 = 2^(서브넷 비트 수)
  - 서브넷당 호스트 수 = 2^(호스트 비트 수) − 2

### 계산 예제 1 (동일 크기 분할)
> 195.5.5.0/24를 8개 서브넷으로 나눠라
- 8 = 2³ → 서브넷 비트 3개, 호스트 비트 5개 → 마스크 /27 (255.255.255.224)
- 각 서브넷 크기 = 256 ÷ 8 = **32씩 증가**
- 1번째: 195.5.5.0 ~ 31 (사용 가능 IP: .1~.30)
- 2번째: 195.5.5.32 ~ 63 ... 8번째: 195.5.5.224 ~ 255

### 계산 예제 2 (VLSM: 크기가 다른 부서별 분할)
> 173.16.10.0/24를 교육부(100대), 영업부(50대), 기술부(21대), 총무부(13대)로
- 큰 것부터 반씩 자름:
  - 교육부(100대) → /25 (128개) : 173.16.10.0/25
  - 영업부(50대) → /26 (64개) : 173.16.10.128/26
  - 기술부(21대) → /27 (32개) : 173.16.10.192/27
  - 총무부(13대) → /28 (16개) : 173.16.10.224/28
- 🍯 필요한 만큼만 잘라 쓰는 게 VLSM (Variable Length Subnet Mask)

### "X번째 서브넷" 문제 푸는 법
- X번째 서브넷 = 서브넷 비트 값이 **(X−1)** 인 것
- 예: 192.168.0.0/24를 /30으로 쪼갤 때 20번째 서브넷? → 서브넷 값 19 → 19×4 = 76 → `192.168.0.76/30`

## ③ 핵심 명령어
```
R(config)# ip subnet-zero   # 첫 번째·마지막 서브넷도 쓸 수 있게 (요즘은 기본)
```

## ④ 시험 포인트
- 클래스 구분은 **첫 옥텟 값**만 보면 됨
- 호스트 부분 전부 0 = 네트워크 주소, 전부 1 = 브로드캐스트 주소
- C클래스 최대 서브넷 비트 = 6 (호스트 최소 2비트는 남겨야 하므로 8−2)
- B클래스: 네트워크 수 2^14, 네트워크당 호스트 2^16−2

---

# Chapter 3. 전송매체 제작과 활용

## ① 한 줄 요약
랜케이블(UTP)을 직접 만들고, 계층별 네트워크 장비를 구분하는 챕터.

## ② 꼭 알아야 할 개념

### ⭐ 계층별 장비 총정리 (초 단골!)
| 계층 | 장비 | 역할 |
|---|---|---|
| L1 | 리피터, 허브, 모뎀, DSU, 무선AP | 신호 증폭·전달만 (생각 없음) |
| L2 | NIC, 브리지, **스위치** | MAC 주소 보고 전달, **충돌영역 분리** |
| L3 | **라우터**, L3 스위치(백본) | IP 보고 경로 결정, **브로드캐스트영역 분리** |
| L4 | L4 스위치 | 로드밸런서 (부하 분산) |
| L7 | 게이트웨이, 방화벽, L7 스위치(보안) | 내용까지 보고 판단 |

- 🍯 허브 = 확성기(들어온 말을 전원에게 반복), 스위치 = 우체부(주소 보고 그 사람에게만), 라우터 = 국제우체국(다른 나라·네트워크로)
- **허브**: 대역폭 공유 (100M 허브 4포트 → 포트당 25M), Half Duplex
- **스위치**: 포트마다 전용 대역폭 (포트당 100M), Full Duplex
- 방화벽: 외부→내부 기본 deny / IDS: 침입 탐지만 / IPS: 탐지+차단

### 꼬임선 (Twisted Pair)
- 꼬는 이유: **전자기 간섭(EMI)을 줄이려고** → 오류↓ → 속도↑
- 종류: UTP(차폐 없음) < FTP(외부 차폐) < STP(외부+내부 차폐) — 성능·가격 순
- **카테고리**: Cat.5(100M) / **Cat.5e(1G)** / Cat.6A(10G) / Cat.8(40G)
- 커넥터: **RJ-45** (8P8C)

### ⭐ 케이블 3종류 (언제 뭘 쓰나)
| 케이블 | 연결 대상 | 예 |
|---|---|---|
| **스트레이트(다이렉트)** | 다른 종류끼리 (DTE—DCE) | PC—스위치, 라우터—스위치 |
| **크로스오버** | 같은 종류끼리 (DTE—DTE, DCE—DCE) | PC—PC, 스위치—스위치 |
| **롤오버(콘솔)** | 장비 설정용 | PC—라우터 콘솔포트 |

- DTE = 호스트 장비(PC, 서버, 라우터) / DCE = 허브, 스위치
- 배선 표준: **T568B** 주-녹-파-갈 기준, 크로스는 한쪽 568B + 한쪽 568A (1↔3, 2↔6 교차)
- 롤오버는 1↔8, 2↔7... 완전히 뒤집기

### 광섬유 케이블
| | 멀티모드 (주황) | 싱글모드 (노랑) |
|---|---|---|
| 광원 | LED | LD(레이저) |
| 거리 | 건물 내 (짧음) | 건물 간·장거리 |
| 코어 | 50/62.5㎛ | 9~10㎛ |
- 장점: 전자기 간섭 없음, 대역폭 넓음, 도청 어려움 / 단점: 비쌈, 작업 어려움
- 광모듈: GBIC(SC 커넥터) → SFP(LC 커넥터, 업그레이드판)

### 이더넷 명명법: `속도 BASE 매체`
- 예: **100BASE-TX** = 100Mbps + Baseband(디지털) + TP(꼬임선, 100m)
- 1000BASE-T(UTP), 1000BASE-SX(멀티모드 광), 1000BASE-LX(싱글/멀티 광, 장거리)

## ③ 실습 요약
1. 스트리퍼로 피복 제거 → 색 순서대로 정리 → RJ-45에 삽입 → 랜툴로 압착 → 테스터 확인
2. PC—PC 직접 연결은 **크로스**, 스위치 경유는 **스트레이트**

## ④ 시험 포인트
- "같은 장비끼리 = 크로스" 한 줄만 기억해도 반은 맞춤
- 롤오버 케이블 = 콘솔 설정용
- 100BASE-TX 풀이 (100M / 베이스밴드 / TP / 100m)

---

# Chapter 4. 라우터 셋업모드

## ① 한 줄 요약
라우터의 속(부품)과 부팅 과정을 배우는 챕터. 🍯 라우터도 작은 컴퓨터다!

## ② 꼭 알아야 할 개념

### ⭐ 라우터 메모리 4형제 (진짜 자주 나옴)
| 메모리 | 들어있는 것 | PC로 치면 🍯 |
|---|---|---|
| **ROM** | POST, 부트스트랩, 비상용 미니 IOS | BIOS |
| **Flash** | IOS (운영체제 파일) | SSD의 OS |
| **NVRAM** | **startup-config** (저장된 설정) | 문서 저장 폴더 |
| **RAM** | **running-config** (지금 쓰는 설정) + 실행 중 IOS | 작업 중인 메모리 |

- RAM은 전원 끄면 날아감! → 그래서 저장 명령이 필요:
  `copy running-config startup-config`

### 부팅 순서
1. 전원 ON → **POST** (하드웨어 자가 점검, ROM)
2. **부트스트랩**이 Flash의 IOS를 RAM에 로드 (IOS 없으면 → rommon 모드)
3. NVRAM의 startup-config로 환경 설정 (없으면 → **셋업 모드**로 질문 시작)

### 인터페이스 종류
- LAN용: 이더넷(RJ-45, 네트워크의 게이트웨이 역할)
- WAN용: 시리얼(전용선, PPP/HDLC)
- 설정용: **콘솔 포트**(현장), **AUX 포트**(전화망으로 원격 설정)
- 표기법: `FastEthernet 1/2/3` = 모듈1 / 슬롯2 / 포트3

### 시리얼 백투백 연결
- 라우터 둘을 시리얼 케이블로 직접 연결하면 한쪽이 DCE → **DCE 쪽에 `clock rate` 설정 필수!**

## ③ 핵심 명령어
```
Router> enable                    # 사용자 → 관리자 모드
Router# configure terminal       # → 전역설정 모드
Router(config)# hostname R       # 장비 이름 바꾸기
Router# erase startup-config     # 설정 초기화 (공장 초기화)
Router# reload                   # 재부팅
Router# show version             # IOS, 메모리, 레지스터 값 확인
Router# show ip interface brief  # 인터페이스 상태 한눈에
Router# show controllers serial 0/0/0  # DTE/DCE 확인
```

## ④ 시험 포인트
- 메모리별 저장 내용 매칭 (Flash=IOS, NVRAM=startup-config, RAM=running-config)
- startup-config 없으면 → 셋업 모드로 부팅
- `show version`으로 볼 수 있는 것: 부트스트랩, IOS, 인터페이스, 레지스터 값

---

# Chapter 5. 라우터 기본설정

## ① 한 줄 요약
CLI 4가지 모드를 오가며 패스워드·IP를 설정하는, **모든 실습의 기본기** 챕터.

## ② 꼭 알아야 할 개념

### ⭐ 4가지 모드 (프롬프트 모양으로 구분!)
| 프롬프트 | 모드 | 할 수 있는 것 | 진입 명령 |
|---|---|---|---|
| `R>` | 사용자 모드 | 제한된 조회만 (show run 불가) | 로그인 직후 |
| `R#` | 관리자(특권) 모드 | 모든 조회, 저장, 재부팅 | `enable` |
| `R(config)#` | 전역설정 모드 | 장비 전체 설정 | `configure terminal` |
| `R(config-if)#` 등 | 세부설정 모드 | 인터페이스/라인/라우팅 설정 | `interface ...`, `line ...`, `router ...` |

- 빠져나가기: `exit`(한 단계), `end` 또는 Ctrl+Z(바로 관리자 모드로)
- 편의 기능: `?`(도움말), Tab(자동완성), ↑↓(히스토리), `Ctrl+Shift+6`(멈추기)

### ⭐ 패스워드 2종류
1. **로그인(login) 패스워드** — 장비에 "들어올 때" (콘솔/AUX/VTY 각각 설정)
2. **enable 패스워드** — 관리자 모드로 "올라갈 때"
   - `enable password`(평문 저장) vs `enable secret`(암호화 저장) → **둘 다 있으면 secret이 이김!**

```
R(config)# enable secret 암호            # 관리자 패스워드 (암호화)
R(config)# line console 0               # 콘솔 로그인 암호
R(config-line)# password 암호
R(config-line)# login                    # "암호 확인해라"는 뜻
R(config)# line vty 0 4                  # 텔넷/SSH 접속 (동시 5명: 0~4)
R(config-line)# password 암호
R(config-line)# login
```

### 인터페이스 설정 3종 세트
```
R(config)# interface fastethernet 0/0
R(config-if)# ip address 192.168.1.1 255.255.255.0
R(config-if)# no shutdown        # ★ 인터페이스는 기본이 꺼짐! 켜줘야 함
```

### ⭐ 인터페이스 상태 읽는 법 (`show interfaces`)
| 표시 | 의미 |
|---|---|
| `up, line protocol is up` | 정상 ✅ |
| `administratively down` | 관리자가 끈 상태 (no shutdown 안 함) |
| `up, line protocol is down` | 물리적으론 연결됐지만 L2 문제 (clock rate 누락, 캡슐화 불일치 등) |
| `down, down` | 케이블 자체가 안 꽂힘 (L1 문제) |

### 시동 모드
- **ROM 모니터(rommon)**: 부팅 60초 내 Ctrl+Break로 진입. 패스워드 복구·IOS 복구용
  - `confreg 0x2142` = startup-config 무시하고 부팅 / `0x2102` = 정상 부팅
- **셋업 모드**: startup-config 없을 때 대화형 설정

## ③ 핵심 명령어
```
R# show running-config           # 현재 설정 (RAM)
R# show startup-config           # 저장된 설정 (NVRAM)
R# copy running-config startup-config   # 저장!
R(config)# no ip domain-lookup   # 오타 쳤을 때 DNS 검색 안 하게 (실습 필수)
```

## ④ 시험 포인트
- 모드별 프롬프트와 진입 명령어 매칭
- password vs secret → secret 우선
- login 패스워드는 line 설정 모드, enable 패스워드는 전역설정 모드에서
- 레지스터 0x2102(정상) / 0x2142(설정 무시) 구분

---

# Chapter 6. 라우터 전역설정

## ① 한 줄 요약
show 명령어 모음 + ping/telnet/ssh/traceroute로 네트워크를 확인하는 법.

## ② 꼭 알아야 할 개념

### show 명령어 사전 (뭘 보고 싶을 때 뭘 치나)
| 보고 싶은 것 | 명령어 |
|---|---|
| 인터페이스 상태 | `show interfaces` / `show ip interface brief` |
| 시리얼 DTE/DCE | `show controllers serial X` |
| 라우팅 테이블 | `show ip route` |
| IOS·하드웨어 정보 | `show version` |
| Flash 파일 | `show flash:` |
| 접속 중인 사용자 | `show users` |
| IP↔MAC | `show arp` |
| 라우팅+인터페이스 요약 | `show protocols` |
| 이전 명령어들 | `show history` |
- 설정 취소는 명령 앞에 `no` 붙이기 (예: `no enable secret`)

### ⭐ ping 응답 기호
| 기호 | 의미 |
|---|---|
| `!` | 성공 |
| `.` | 시간 초과 (응답 없음) |
| `U` | 도달 불가 (Unreachable) |

### 원격 접속: Telnet vs SSH
- **Telnet(23)**: 평문 전송 → 도청 위험 ⚠️
- **SSH(22)**: 암호화 전송 → 실무 표준 ✅
- SSH 설정 필수 4요소: **호스트이름 + 도메인 + RSA 키 생성 + 로컬 계정**
```
R(config)# hostname S1
R(config)# ip domain-name korea.com
R(config)# crypto key generate rsa      # 1024비트 이상
R(config)# username boan password 암호
R(config)# line vty 0 4
R(config-line)# login local             # 로컬 계정으로 인증
R(config-line)# transport input ssh     # ssh만 허용
```

### CDP (Cisco Discovery Protocol)
- 시스코 전용. **이웃한 시스코 장비 정보**를 60초마다 광고
- `show cdp neighbors [detail]` / 끄기: `no cdp run`
- 범용 표준판은 **LLDP** (802.1ab, 기본 꺼짐)

### debug
- `debug ip rip` 실시간 동작 확인, 끝나면 반드시 `undebug all`

## ④ 시험 포인트
- ping 기호 (! . U)
- 백투백 시리얼 = DCE에 clock rate
- CDP는 시스코 전용, 60초 주기
- traceroute(장비/리눅스) vs tracert(윈도우)

---

# Chapter 7. 스위치 기본설정

## ① 한 줄 요약
스위치의 동작 원리(MAC 테이블, 스위칭 모드)와 루프를 막는 STP 프로토콜.

## ② 꼭 알아야 할 개념

### 스위치 기본 동작
1. 프레임 수신 → 2. 목적지 MAC을 **MAC 주소 테이블**에서 검색 → 3. 해당 포트로만 전송(**필터링**)
- 테이블에 없으면? → 받은 포트 빼고 전부 전송(**플러딩**)
- 각 포트가 독립된 세그먼트 = **마이크로세그먼테이션** → 충돌영역이 포트 수만큼 잘게 나뉨

### ⭐ 스위칭 모드 3가지
| 모드 | 방식 | 속도 | 오류검사 |
|---|---|---|---|
| **Store and Forward** | 프레임 전체 받고 → 오류검사 → 전송 | 느림 | 최고 |
| **Cut Through** | 목적지 MAC만 보고 바로 전송 | 최고 | 없음 (runt 문제: 64바이트 미만 오류 프레임) |
| **Fragment Free** | 64바이트까지만 받고 전송 (절충안) | 중간 | 중간 |

### ⭐ STP (Spanning Tree Protocol) — 루프 방지
- 🍯 스위치를 빙 둘러 연결하면 프레임이 뱅글뱅글 무한 회전(루프) → 네트워크 마비. STP가 일부러 한 포트를 막아서(Blocking) 고리를 끊음.
- 포트 상태 변화: **Blocking → Listening(15초) → Learning(15초) → Forwarding** (총 약 30초)
- 선출 규칙 (전부 "작은 값이 이김"):
  - **루트 브리지**: Bridge ID(Priority 32768 + MAC)가 가장 작은 스위치
  - **루트 포트(RP)**: 루트까지 비용(cost)이 가장 적은 포트
  - **지정 포트(DP)**: 세그먼트당 1개
  - 나머지 = 비지정 포트(Blocking, 주황불)
- 포트 LED: 초록 = Forwarding, 주황 = Blocking

### 스위치 관리 IP
- L2 스위치엔 원래 IP가 필요 없음. **관리(원격 접속)용**으로 VLAN 1에 IP를 줌:
```
S(config)# interface vlan 1
S(config-if)# ip address 192.168.1.2 255.255.255.0
S(config-if)# no shutdown
S(config)# ip default-gateway 192.168.1.1
```
- 스위치의 startup-config 위치 = `flash:config.text`

## ④ 시험 포인트
- 스위칭 모드 속도 순: Cut through > Fragment free > Store and forward (오류검사는 반대)
- STP 상태 순서와 시간 (Listening 15초 + Learning 15초)
- 허브 = 충돌영역 1개 / 스위치 = 포트 수만큼

---

# Chapter 8. 패스워드 복구와 IOS 설치

## ① 한 줄 요약
패스워드를 까먹었거나 IOS가 날아갔을 때 살리는 응급처치 챕터.

## ② 꼭 알아야 할 개념

### 환경설정 레지스터
- **0x2102**: 정상 부팅 (startup-config 사용)
- **0x2142**: startup-config **건너뛰고** 부팅 → 패스워드 복구에 사용
- 🍯 0x2142 = "저장된 자물쇠 설정을 무시하고 열린 문으로 들어가기"

### ⭐ 라우터 패스워드 복구 절차 (순서 암기!)
1. 재부팅하며 60초 내 **Ctrl+Break** → rommon 모드
2. `confreg 0x2142` → `reset` (재부팅)
3. 부팅 후 `enable` (암호 없이 들어가짐)
4. `copy startup-config running-config` (기존 설정 불러오기)
5. 패스워드 재설정 (`enable secret 새암호` 등)
6. `config-register 0x2102` (레지스터 원상복구!) ← 까먹기 쉬움
7. `copy running-config startup-config` (저장)

### 스위치 패스워드 복구 (라우터와 다름!)
1. **MODE 버튼 누른 채 전원 인가** → rommon
2. `flash_init` → `rename flash:config.text flash:config.old` → `boot`
3. 부팅 후 `copy flash: running-config` (파일명 config.old)
4. 패스워드 재설정 → 저장 → config.old 삭제

### 설정파일 & IOS 백업/복구 (TFTP/FTP)
| 작업 | 명령어 |
|---|---|
| 설정 백업 | `copy running-config tftp:` |
| 설정 복구 | `copy tftp: running-config` |
| IOS 백업 | `copy flash: tftp:` |
| IOS 복구 | `copy tftp: flash:` |
- **TFTP**: UDP 69번, 인증 없음, 단순 → rommon에서도 사용 가능 (`tftpdnld`)
- **FTP**: TCP 20/21, 인증 필요 (`ip ftp username/password` 미리 설정)

## ④ 시험 포인트
- 0x2102 vs 0x2142
- 라우터(Ctrl+Break) vs 스위치(MODE 버튼) 진입 방법 차이
- TFTP = UDP 69, 인증 불필요

---

# Chapter 9. 정적 라우팅 설정

## ① 한 줄 요약
관리자가 직접 "이 목적지는 이쪽으로 보내!"라고 손으로 경로를 적어주는 방식.

## ② 꼭 알아야 할 개념

### 라우팅 = 패킷을 목적지까지 전달하는 과정
- 라우터의 두 가지 일: **경로 결정** + **패킷 스위칭(전송)** — 둘 다 라우팅 테이블 기반
- **라우티드 프로토콜**(짐) vs **라우팅 프로토콜**(내비게이션)
  - 라우티드: IP, IPX, AppleTalk — 실제 데이터가 담긴 것
  - 라우팅: RIP, OSPF, EIGRP, BGP — 경로를 찾아주는 프로그램

### 라우팅 메트릭 (최적 경로를 고르는 기준)
- Hop count(거치는 라우터 수, **RIP**), Bandwidth(대역폭, **OSPF**), Delay, Load, Reliability
- 🍯 RIP = "환승 적은 경로", OSPF = "제일 넓고 빠른 도로"

### ⭐ 관리거리 (AD, Administrative Distance)
- 여러 라우팅 프로토콜이 같은 목적지 경로를 알려줄 때, **AD가 작은 쪽을 믿음** (신뢰도)
| 경로 | AD |
|---|---|
| 직접 연결(Connected) | 0 |
| **정적(Static)** | **1** |
| eBGP | 20 |
| EIGRP | 90 |
| **OSPF** | **110** |
| IS-IS | 115 |
| **RIP** | **120** |

### 정적 라우팅의 장단점
- 장점: 라우터에 부하 없음, 대역폭 낭비 없음, **보안에 유리**(경로 정보를 밖으로 안 흘림)
- 단점: 네트워크가 바뀌면 사람이 일일이 수정해야 함 (수렴 느림)
- **Stub 네트워크**(밖으로 나가는 길이 하나뿐인 네트워크)엔 정적/디폴트 라우팅이 딱!

### 라우팅 테이블 읽기
```
S    192.168.1.0/24 [1/0] via 10.10.10.1
│         │           │        └ 다음 홉(경유 라우터)
│         │           └ [관리거리/메트릭]
│         └ 목적지 네트워크
└ S=Static, C=Connected, R=RIP, O=OSPF, * = 디폴트 후보
```

## ③ 핵심 명령어
```
! 방법1: 다음 홉 IP 지정
R(config)# ip route 192.168.3.0 255.255.255.0 10.10.20.2
! 방법2: 나가는 내 인터페이스 지정
R(config)# ip route 192.168.3.0 255.255.255.0 serial 0/0/0
! 디폴트 라우팅 (테이블에 없으면 무조건 이쪽으로)
R(config)# ip route 0.0.0.0 0.0.0.0 10.10.20.2
! 삭제
R(config)# no ip route 192.168.3.0 255.255.255.0
! 확인
R# show ip route [static]
```

## ④ 시험 포인트
- AD 값 암기: Connected 0 < Static 1 < OSPF 110 < RIP 120
- `ip route 0.0.0.0 0.0.0.0 ...` = 디폴트 라우트, 테이블에 `S*`로 표시
- Stub 네트워크 → 디폴트 라우팅이 정답

---

# Chapter 10. 동적 라우팅 설정 (RIP)

## ① 한 줄 요약
라우터들끼리 스스로 경로 정보를 주고받아 자동으로 길을 찾는 방식. 첫 번째 주자는 RIP.

## ② 꼭 알아야 할 개념

### ⭐ 거리벡터 vs 링크상태 (누구에게/무엇을/언제 — 3요소로 암기)
| | 거리벡터 (RIP) | 링크상태 (OSPF) |
|---|---|---|
| 누구에게 | **이웃** 라우터에게 | **전체** 라우터에게 |
| 무엇을 | **모든** 경로 정보 | **변화된** 정보만 |
| 언제 | **주기적** (RIP 30초) | 변화가 생기면 **즉시** |
| 규모 | 소규모 | 대규모 (수렴 빠름) |

### RIP 핵심
- 메트릭 = **홉 카운트**, 최대 **15** (16 = 도달 불가!)
- 30초마다 이웃에게 전체 테이블 전송
- **라우팅 루프 방지책** (홉 수가 무한히 증가하는 문제):
  - 최대 홉 15 제한
  - **Split Horizon**: 받은 쪽으로 그 정보를 되돌려 보내지 않음
  - **Poison Reverse**: 되돌려 보내되 메트릭 16(죽은 경로)으로 표시
  - Hold Down Timer, Triggered Update
- RIP 타이머: 업데이트 30초 / Invalid 180초 / Flush 240초

### 다른 동적 프로토콜 한 줄씩
- **OSPF**: 링크상태, 메트릭=링크 비용(대역폭 반비례), 대규모용 → Ch12
- **EIGRP**: 시스코 전용 하이브리드, DUAL 알고리즘, 대역폭+지연 조합
- **BGP**: AS **사이**(외부) 라우팅. BGP 빼고 전부 내부(IGP)용
  - IGP(같은 AS 안): RIP, OSPF, EIGRP, IS-IS / EGP(AS 사이): BGP

## ③ 핵심 명령어
```
R(config)# router rip
R(config-router)# network 192.168.2.0    # 내 인터페이스가 속한 네트워크 (클래스 기준!)
R(config-router)# network 10.0.0.0
R(config-router)# version 2              # 기본은 v1
R(config-router)# no auto-summary        # 자동 요약 끄기
R# show ip route rip
R# show ip protocols                     # 타이머, 버전, 네트워크 확인
R# debug ip rip / undebug all
```

### RIP 라우팅 테이블 읽기
```
R  192.168.4.0/24 [120/2] via 10.10.20.2, 00:00:23, Serial0/0/0
   → RIP로 배운 경로 / AD 120 / 홉 2개 / 10.10.20.2 라우터 경유 / s0/0/0으로 나감
```

## ④ 시험 포인트
- RIP: 이웃/전체정보/30초, 최대 홉 15
- 정적(AD 1) vs RIP(120) vs OSPF(110) 경쟁 → 정적이 이김
- 루프 방지 기법 이름들 (Split Horizon 등)

---

# Chapter 11. 클래스리스 라우팅 설정

## ① 한 줄 요약
서브넷 마스크 정보까지 함께 전달하는 "클래스리스" 라우팅. RIPv1과 v2 차이가 핵심.

## ② 꼭 알아야 할 개념

### 클래스풀 vs 클래스리스
- **클래스풀**: 클래스(A/B/C) 단위로만 인식. 서브넷 마스크를 안 보냄 → 서브네팅한 네트워크를 제대로 못 알아봄
- **클래스리스**: 마스크 길이도 함께 전달 → **VLSM, CIDR** 지원
- 지원 프로토콜: 클래스풀(RIPv1, BGPv3) / 클래스리스(**RIPv2, OSPF, EIGRP, IS-IS, BGPv4**)

### CIDR & 라우트 요약(수퍼네팅)
- 연속된 여러 네트워크를 하나로 묶어 전달 → 라우팅 테이블·대역폭 절약
- 예: 172.16.0.0/16 ~ 172.31.0.0/16 (16개) → `172.16.0.0/12` 하나로!
- 🍯 "서울 강남구 1동, 2동, 3동..." 대신 "서울 강남구 전체"라고 한 번에 말하기

### ⭐ RIPv1 vs RIPv2 비교표
| | RIPv1 | RIPv2 |
|---|---|---|
| 클래스 | 클래스풀 | **클래스리스** (마스크 전달) |
| 전송 방식 | 브로드캐스트 (255.255.255.255) | **멀티캐스트 (224.0.0.9)** |
| 인증 | 불가 | 가능 |
| 라우트 태그 | 불가 | 가능 |
- 둘 다 UDP 520 사용
- 실습 교훈: v1으로는 /27, /25 같은 서브넷이 라우팅 테이블에 안 뜸 → `version 2` + `no auto-summary` 해야 전부 보임

## ④ 시험 포인트
- RIPv2 = 멀티캐스트 224.0.0.9 (암기!)
- 클래스리스 지원 프로토콜 목록
- 요약의 장점 = 대역폭 절약, 예: /16 연속 8개 → /13

---

# Chapter 12. OSPF 라우팅 설정

## ① 한 줄 요약
대규모 네트워크의 표준 라우팅 프로토콜. 링크 상태를 공유하고 SPF 알고리즘으로 최단경로 계산.

## ② 꼭 알아야 할 개념

### OSPF 기본
- **링크상태** 프로토콜, **SPF(다익스트라) 알고리즘**
- 메트릭 = 링크 비용 = **10⁸ ÷ 대역폭(bps)** → 빠른 회선일수록 비용 작음
  - FastEthernet(100M) = 1, T1 시리얼(1.544M) = 64
  - 경로 비용 = 지나가는 링크 비용의 **합** (예: 시리얼+FE = 64+1 = 65)
- AD = 110, VLSM/CIDR 지원, 변화 시 즉시 업데이트(수렴 빠름)
- 트래픽 문제 해결책 = **영역(Area)** 분할

### ⭐ OSPF 패킷 5종
| 타입 | 이름 | 역할 |
|---|---|---|
| 1 | **Hello** | 이웃 맺기·생존 확인 (네이버 테이블) |
| 2 | **DBD** | 내 링크 상태 요약 설명 |
| 3 | **LSR** | "그 정보 자세히 줘" 요청 |
| 4 | **LSU** | 링크 상태 업데이트(광고) 전달 |
| 5 | **LSAck** | "잘 받았어" 확인 |

### ⭐ OSPF 7단계 상태 (순서 암기!)
```
Down → Init → 2-Way → ExStart → Exchange → Loading → Full
(미동작)  (Hello 전송) (이웃 형성)  (DR/BDR 선출·마스터 결정)  (DBD 교환)  (LSR/LSU/LSAck)  (완전 인접)
```

### 3개의 데이터베이스
1. 인접 DB(네이버 테이블) ← Hello
2. 링크상태 DB(토폴로지 테이블) ← DBD/LSU
3. 포워딩 DB(**라우팅 테이블**) ← SPF 계산 결과

### DR / BDR (멀티액세스 네트워크에서)
- LAN처럼 라우터 여럿이 붙은 곳에서 아무나 서로 정보 교환하면 난리 → 대표(**DR**)와 부대표(**BDR**)를 뽑아 DR을 통해서만 전파
- 선출 기준(**큰 값**이 이김): ① Priority(기본 1, 0~255) → ② Router ID
- **Router ID 결정 순서**: 수동 설정(`router-id`) > 루프백 주소 > 인터페이스 중 가장 큰 IP
- 멀티캐스트 주소: **224.0.0.5**(모든 OSPF 라우터에게) / **224.0.0.6**(DR/BDR에게)
- Point-to-Point 연결은 DR 선출 안 함

### 타이머
- Hello **10초** / Dead **40초** (= Hello×4) — BMA, P-P 기준 (NBMA는 30/120)
- **양쪽 타이머가 다르면 이웃 못 맺음!**

### 와일드카드 마스크 (OSPF·ACL 공용 ⭐)
- 서브넷 마스크의 0↔1 반전. **0 = 그 비트는 정확히 일치해야 함, 1 = 아무거나 OK**
- 255.255.255.0 → `0.0.0.255` / 255.255.255.128 → `0.0.0.127`
- `192.168.1.1 0.0.0.0` = 딱 그 호스트 / `... 255.255.255.255` = any

## ③ 핵심 명령어
```
R(config)# router ospf 10                 # 10 = 프로세스 ID (라우터끼리 달라도 됨)
R(config-router)# network 192.168.2.0 0.0.0.255 area 0
R(config-router)# router-id 1.1.1.1
R(config-if)# ip ospf priority 100        # DR 선출용 (인터페이스에서)
R(config-if)# ip ospf hello-interval 5    # dead는 자동으로 4배 권장
! 인증 (MD5)
R(config-router)# area 0 authentication message-digest
R(config-if)# ip ospf message-digest-key 1 md5 암호
! 확인
R# show ip ospf neighbor      # FULL이면 성공
R# show ip ospf interface
R# show ip ospf database
```

## ④ 시험 포인트
- 링크 비용 계산: 10⁸/BW, 시리얼 64 + FE 1 = 65
- 7단계 상태 순서, 패킷 5종
- Router ID 우선순위: router-id > loopback > 최대 IP
- Hello 10 / Dead 40, 불일치 시 이웃 형성 실패
- 와일드카드 마스크 변환

---

# Chapter 13. 다중영역 OSPF

## ① 한 줄 요약
OSPF 네트워크가 커지면 영역(Area)으로 쪼개고, 모든 영역은 백본(Area 0)에 붙인다.

## ② 꼭 알아야 할 개념

### 왜 영역을 나누나?
- 단일 영역이 커지면: SPF 계산 빈번, 링크 정보 폭주, 라우팅 테이블 비대
- 다중 영역: 영역 안에서만 상세 정보 교환, **영역 사이엔 요약 정보만** → 부하↓
- 규칙: **모든 영역은 반드시 Area 0(백본)과 연결**, 영역 간 정보는 백본을 통해서만

### ⭐ OSPF 라우터 역할 4종
| 역할 | 뜻 |
|---|---|
| Internal | 모든 인터페이스가 한 영역 안 |
| Backbone | 인터페이스 하나 이상이 Area 0에 |
| **ABR** (Area Border Router) | 서로 다른 **영역 사이** 연결 (Area 0 ↔ Area X) |
| **ASBR** (AS Boundary Router) | OSPF와 **외부(비 OSPF)** 연결, 재분배 수행 |

### ⭐ LSA 타입 & 라우팅 테이블 표기
| LSA | 생성자 | 내용 | 테이블 표기 |
|---|---|---|---|
| Type 1 | 모든 라우터 | 자기 링크 상태 (영역 내) | O |
| Type 2 | DR | 네트워크 정보 (영역 내) | O |
| Type 3 | **ABR** | 다른 영역 네트워크 요약 | **O IA** |
| Type 4 | ABR | ASBR 위치 정보 | O IA |
| Type 5 | **ASBR** | 외부 네트워크 | O E1/E2 |
| Type 7 | NSSA의 ASBR | NSSA 외부 정보 (ABR이 Type5로 번역) | O N1/N2 |

### 영역 종류
- 표준 영역 / 백본 영역(Area 0, 통과 영역)
- **스텁(Stub)**: 외부 상세 정보 안 받고 디폴트 경로 사용
- Totally Stubby: 스텁보다 더 차단 (시스코 전용)
- **NSSA**: 스텁인데 예외적으로 외부 정보를 Type 7로 받음

### 라우팅 업데이트 멀티캐스트 주소 모음 (비교 암기)
- OSPF: 224.0.0.5 / 224.0.0.6
- RIPv2: 224.0.0.9
- EIGRP: 224.0.0.10

## ③ 핵심 명령어
```
! 인터페이스마다 다른 area 지정하면 그 라우터가 ABR이 됨
R(config)# router ospf 10
R(config-router)# network 10.10.10.0 0.0.0.255 area 0
R(config-router)# network 192.168.2.0 0.0.0.255 area 200
R# show ip ospf              # "It is an area border router" 확인
R# show ip ospf database     # 영역별 LSA 확인
```

## ④ 시험 포인트
- O IA = 다른 영역에서 온 경로 (ABR이 전달)
- LSA 타입별 생성 주체 (3·4 = ABR, 5 = ASBR)
- 모든 영역은 Area 0에 연결

---

# Chapter 14. ACL 설정

## ① 한 줄 요약
라우터에 "이 패킷은 통과(permit), 저 패킷은 차단(deny)" 규칙을 만드는 것. **보안의 시작!**

## ② 꼭 알아야 할 개념

### ACL 동작 원리
- 규칙을 **위에서 아래로(Top-Down)** 순서대로 비교, 처음 맞는 규칙 적용
- ⭐ 맞는 규칙이 하나도 없으면? → **묵시적 deny any** (자동 전부 차단!)
  - 그래서 마지막에 `permit any`를 넣어주는 게 보통
- 2단계: **① 전역설정에서 정책 만들기 → ② 인터페이스에 적용하기**

### ⭐ 표준 vs 확장 ACL
| | 표준 (Standard) | 확장 (Extended) |
|---|---|---|
| 번호 | **1~99** (1300~1999) | **100~199** (2000~2699) |
| 검사 항목 | **송신지 주소만** | 프로토콜+송신지+목적지+**포트** |
| 적용 위치 | **목적지에 가까운** 인터페이스 | **출발지에 가까운** 인터페이스 |
- 🍯 표준 = "어디서 왔니?"만 검사하는 단순 검문소 → 목적지 근처에 세워야 다른 길까지 안 막음.
  확장 = "어디서, 어디로, 무슨 볼일로?"까지 검사 → 출발지 근처에서 일찍 걸러야 효율적.
- **Named ACL**: 번호 대신 이름 사용 (`ip access-list standard/extended 이름`)

### 와일드카드 마스크 (다시!)
- `host 192.168.1.5` = `192.168.1.5 0.0.0.0`
- `192.168.1.0 0.0.0.255` = 그 네트워크 전체
- `any` = `0.0.0.0 255.255.255.255`

## ③ 핵심 명령어
```
! === 표준 ACL: 192.168.2.0에서 오는 패킷 차단 ===
R(config)# access-list 1 deny 192.168.2.0 0.0.0.255
R(config)# access-list 1 permit any          # 나머진 허용 (안 하면 전부 차단!)
R(config)# interface fastethernet 0/0
R(config-if)# ip access-group 1 out          # 인터페이스에 적용 (in/out)

! === 확장 ACL: 1.0 네트워크에서 2.0으로 가는 telnet만 차단 ===
R(config)# access-list 102 deny tcp 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255 eq 23
R(config)# access-list 102 permit ip any any
R(config-if)# ip access-group 102 in

! === 특정 호스트만 웹서버 허용 (Named) ===
R(config)# ip access-list extended TEST1
R(config-ext-nacl)# permit tcp host 192.168.1.10 host 192.168.2.100 eq 80
R(config-ext-nacl)# deny tcp 192.168.1.0 0.0.0.255 host 192.168.2.100 eq 80
R(config-ext-nacl)# permit ip any any

! === ping(ICMP) 차단 ===
deny icmp 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255 echo

! === 가상터미널(telnet/ssh) 접근 제한 → access-class! ===
R(config)# access-list 10 deny 192.168.1.0 0.0.0.255
R(config)# access-list 10 permit any
R(config)# line vty 0 4
R(config-line)# access-class 10 in

! 확인/해제
R# show ip access-lists
R(config)# no access-list 102
R(config-if)# no ip access-group 102 in
```

## ④ 시험 포인트
- 번호 범위: 표준 1~99, 확장 100~199
- 묵시적 deny any (마지막 permit any 필수 여부 판단 문제)
- 표준=목적지 근처, 확장=출발지 근처
- 인터페이스는 `ip access-group`, VTY는 `access-class`
- 규칙 순서: 좁은 범위·빈번한 것 먼저!

---

# Chapter 15. 가상랜(VLAN) 설정

## ① 한 줄 요약
스위치 하나를 **논리적으로** 여러 네트워크처럼 쪼개는 기술. 브로드캐스트 영역을 L2 장비로 나누는 유일한 방법.

## ② 꼭 알아야 할 개념

### VLAN이란
- 🍯 한 교실(스위치)에 칸막이를 세워 1반·2반으로 나누는 것. 물리적으론 한 방이지만 서로 말이 안 통함.
- **VLAN이 다르다 = 네트워크가 다르다 = 브로드캐스트 도메인이 다르다** → 서로 직접 통신 불가 (통신하려면 L3 장비 필요 → Ch16)
- 효과: 브로드캐스트 트래픽↓(성능↑), 불필요한 접근 차단(보안↑), 공간 제약 없음
- 기본값: **모든 포트는 VLAN 1** 소속
- 정적 VLAN(포트별 할당, 일반적) vs 동적 VLAN(MAC 기반, VMPS 소프트웨어)
- VLAN 정보 저장 위치: `flash:vlan.dat` (초기화하려면 이 파일도 지워야 함!)

### ⭐ Access 포트 vs Trunk 포트
| | Access | Trunk |
|---|---|---|
| 소속 | 특정 VLAN 하나 | 어느 VLAN에도 안 속함 |
| 전달 | 그 VLAN 프레임만 | **여러 VLAN 프레임** (스위치끼리 연결) |
- 🍯 Access = 1반 전용 문, Trunk = 모든 반이 함께 쓰는 복도

### 프레임 태깅 (트렁크에서 VLAN 구분법)
- **802.1Q (dot1q)**: IEEE 표준, 프레임에 태그(꼬리표)를 끼워 넣음
- **ISL**: 시스코 전용, 프레임 전체를 캡슐화
- **Native VLAN**: 태그를 붙이지 않는 VLAN (기본 = VLAN 1). 양쪽 스위치의 Native가 다르면 mismatch 오류!

### VTP (VLAN Trunking Protocol)
- 시스코 전용. 스위치들끼리 **VLAN 정보(생성/삭제)를 자동 동기화** (포트 할당은 동기화 안 됨!)
- 조건: 트렁크 연결 + 같은 도메인 + 같은 패스워드
| 모드 | VLAN 관리 | 동기화 | 광고 전달 |
|---|---|---|---|
| Server (기본) | O | O | O |
| Client | X | O | O |
| Transparent | O (자기만) | X | O (전달만) |
- Revision 번호 큰 쪽으로 동기화됨

## ③ 핵심 명령어
```
! VLAN 만들기
S(config)# vlan 10
S(config-vlan)# name Group10
! 포트 할당
S(config)# interface fastethernet 0/5
S(config-if)# switchport mode access
S(config-if)# switchport access vlan 10
! 여러 포트 한 번에
S(config)# interface range fastethernet 0/20 - 24
! 트렁크 설정 (스위치끼리 연결하는 포트)
S(config)# interface fastethernet 0/1
S(config-if)# switchport mode trunk
S(config-if)# switchport trunk allowed vlan all
S(config-if)# switchport trunk allowed vlan remove 30
S(config-if)# switchport trunk native vlan 20
! VTP
S(config)# vtp mode server
S(config)# vtp domain net1
S(config)# vtp password net1pass
! 확인/초기화
S# show vlan
S# show interfaces trunk
S# show vtp status
S# delete flash:vlan.dat      # VLAN 초기화
```

## ④ 시험 포인트
- 서로 다른 VLAN 통신 = L3 장비 필요
- 802.1Q(표준, 태깅) vs ISL(시스코, 캡슐화)
- Default VLAN = 1, Native VLAN 기본 = 1
- VTP 3모드 표, vlan.dat 파일

---

# Chapter 16. 가상랜 간 라우팅

## ① 한 줄 요약
서로 다른 VLAN끼리 통신시키는 두 가지 방법: ① 라우터의 서브인터페이스(Router-on-a-Stick), ② L3 스위치(MLS).

## ② 꼭 알아야 할 개념

### 방법 1: 라우터 서브인터페이스 (Router-on-a-Stick)
- 물리 포트 하나를 논리적으로 여러 개(fa0/0.10, fa0/0.20...)로 쪼개서 각 VLAN의 게이트웨이로 사용
- 라우터 ↔ 스위치는 **트렁크**로 연결
- 🍯 문 하나(물리 포트)에 창구 여러 개(서브인터페이스)를 만드는 것
```
R(config)# interface fastethernet 0/0
R(config-if)# no shutdown                 # 물리 포트를 먼저 켠다!
R(config)# interface fastethernet 0/0.10  # 서브인터페이스
R(config-subif)# encapsulation dot1q 10   # VLAN 10 태그 처리 (native면 뒤에 native)
R(config-subif)# ip address 192.168.15.1 255.255.255.0
R(config)# interface fastethernet 0/0.20
R(config-subif)# encapsulation dot1q 20
R(config-subif)# ip address 192.168.25.1 255.255.255.0
```
- PC들의 게이트웨이 = 자기 VLAN의 서브인터페이스 IP

### 방법 2: L3 스위치 (MLS, Multi-Layer Switch)
- VLAN 인터페이스(SVI)에 직접 IP를 주고 스위치가 라우팅까지 수행
```
S(config)# vlan 10
S(config)# interface vlan 10
S(config-if)# ip address 192.168.1.1 255.255.255.0
S(config-if)# no shutdown
S(config)# interface vlan 20
S(config-if)# ip address 192.168.2.1 255.255.255.0
S(config)# ip routing                    # ★ 라우팅 기능 켜기!
! MLS는 트렁크 시 캡슐화 지정 필요
S(config-if)# switchport trunk encapsulation dot1q
S(config-if)# switchport mode trunk
```

### 트렁크의 장점 정리
- 물리 인터페이스 절약, 필요 없는 VLAN 정보 제거(pruning) 가능
- 단점: 태그만큼 프레임 커짐 → Native VLAN으로 일부 보완

## ④ 시험 포인트
- 서브인터페이스 설정 순서 (물리 포트 no shutdown 먼저!)
- `encapsulation dot1q [vlan번호]` 필수
- MLS는 `ip routing` 명령이 핵심
- MLS 종류: L3(백본) / L4(로드밸런서) / L7(보안)

---

# Chapter 17. NAT와 DHCP 설정

## ① 한 줄 요약
NAT = 사설 IP를 공인 IP로 바꿔 인터넷에 내보내기. DHCP = IP를 자동으로 나눠주기. 둘 다 IPv4 주소 부족 해결사.

## ② 꼭 알아야 할 개념

### NAT (Network Address Translation)
- 🍯 회사 대표번호: 직원(사설 IP) 수백 명이 밖에 전화할 땐 회사 대표번호(공인 IP)로 나감
- 장점: 주소 절약 + **보안**(밖에서 내부가 안 보임) / 단점: 변환 지연, 출발지 추적 곤란

### ⭐ NAT 3종류
| 종류 | 매핑 | 용도 |
|---|---|---|
| **정적 (Static)** | 1:1 고정 | 서버 (밖에서 찾아올 수 있어야 하니까) |
| **동적 (Dynamic)** | 다:다 (풀에서 빌려 씀) | 일반 클라이언트 |
| **PAT (오버로딩)** | 다:1 (**포트 번호**로 구분) | 공인 IP 1개로 수백 명 — 가정용 공유기 방식 |

### 주소 용어
- Inside Local(내부에서 본 내부, 사설) → Inside Global(외부에서 본 내부, 공인)
- Outside Global / Outside Local

### NAT 설정 (동적 NAT 4단계)
```
! 1) 내부 사용자 지정
R(config)# access-list 10 permit 192.168.1.0 0.0.0.255
! 2) 공인 IP 풀 지정
R(config)# ip nat pool natPool 200.10.10.11 200.10.10.60 netmask 255.255.255.192
! 3) 매핑 (PAT이면 뒤에 overload 추가!)
R(config)# ip nat inside source list 10 pool natPool [overload]
! 3') PAT을 인터페이스 IP로 할 수도 있음
R(config)# ip nat inside source list 10 interface serial 0/0/0 overload
! 4) 인터페이스 안/밖 지정
R(config-if)# ip nat inside     # LAN 쪽
R(config-if)# ip nat outside    # WAN 쪽

! 정적 NAT은 한 줄
R(config)# ip nat inside source static 192.168.1.10 200.10.10.10

! 확인
R# show ip nat translations
R# clear ip nat translations *
```

### DHCP
- 나눠주는 것: IP/서브넷마스크, 게이트웨이, DNS 서버, 도메인 이름 등
- 포트: 서버 **UDP 67** / 클라이언트 **UDP 68**

### ⭐ DHCP 4단계 (DORA로 암기!)
| 단계 | 방향 | 방식 | 🍯 |
|---|---|---|---|
| **D**iscover | C→S | 브로드캐스트 | "IP 주실 분~?" |
| **O**ffer | S→C | 브로드/유니 | "이거 어때요?" |
| **R**equest | C→S | 브로드캐스트 | "그걸로 주세요!" |
| **A**ck | S→C | 브로드/유니 | "확정!" |

### DHCP 서버 & 릴레이 설정
```
R(config)# ip dhcp pool Net1
R(dhcp-config)# network 192.168.1.0 255.255.255.0
R(dhcp-config)# default-router 192.168.1.1
R(dhcp-config)# dns-server 192.168.1.10
R(dhcp-config)# domain-name korea1.com
R(config)# ip dhcp excluded-address 192.168.1.1 192.168.1.10  # 배부 제외
R# show ip dhcp binding

! DHCP 서버가 다른 네트워크에 있으면? → 릴레이
! (브로드캐스트는 라우터를 못 넘으니까, 게이트웨이가 대신 전달)
R(config)# interface gigabitethernet 0/0     # 클라이언트 쪽 인터페이스
R(config-if)# ip helper-address DHCP서버_IP
```

## ④ 시험 포인트
- PAT = overload 키워드, 포트로 구분
- 동적 NAT 풀에 IP 9개면 동시 접속 9명까지
- DHCP DORA 순서 + 각 단계 브로드/유니캐스트 구분
- 릴레이 = `ip helper-address` (클라이언트 쪽 게이트웨이 인터페이스에!)

---

# Chapter 18. 무선랜 설정

## ① 한 줄 요약
Wi-Fi의 규격(802.11), 접속 과정, 그리고 **보안 프로토콜(WEP→WPA3) 진화**가 핵심. 보안 과정 학생이라면 특히 중요한 챕터!

## ② 꼭 알아야 할 개념

### 무선 네트워크 크기별 분류
- PAN(802.15: 블루투스·Zigbee, ~10m) < **LAN(802.11, Wi-Fi)** < MAN(802.16, WiMAX) < WAN(이동통신)

### 802.11 규격 진화
| 규격 | Wi-Fi 이름 | 주파수 | 최대속도 |
|---|---|---|---|
| 802.11b | 1 | 2.4GHz | 11M |
| 802.11a | 2 | 5GHz | 54M |
| 802.11g | 3 | 2.4GHz | 54M |
| 802.11n | 4 | 2.4/5 | 600M |
| 802.11ac | 5 | 5GHz | 6G |
| 802.11ax | **6/6E** | 2.4/5(/6) | 9.6~11G |
- 유선(CSMA/**CD**: 충돌 감지) vs 무선(CSMA/**CA**: 충돌 회피) ← 자주 나옴!
- 2.4GHz: 14개 중첩 채널 중 동시 사용 약 3개 / 5GHz: 비중첩 채널 많음
- 기술: OFDM(고속 변조), MIMO(안테나 여러 개)
- 모드: Infrastructure(AP 사용) / Ad-hoc(AP 없이 단말끼리)

### 무선 접속 4단계
**비컨(AP가 SSID 방송) → 프로브(단말이 AP 찾기) → 인증 → 접속(Association)**
- SSID = AP 이름표. 숨기면(브로드캐스트 off) 수동 입력해야 접속 가능

### ⭐ 무선 보안 프로토콜 진화 (보안 시험 최중요!)
| | 인증 | 암호화 | 문제점 |
|---|---|---|---|
| **WEP** | 사전공유키(64/128bit) | **RC4** (고정 키) | 키 크랙 매우 쉬움 ❌ |
| **WPA** | PSK / 802.1X(RADIUS) | RC4(**TKIP**) | RC4 자체가 약함 |
| **WPA2** | PSK / 802.1X(RADIUS) | **AES(CCMP)** | 무차별 대입에 취약 |
| **WPA3** | **SAE** (동시 인증) | GCMP-256 | 현재 최선 ✅ |
- Personal(PSK, 집) vs Enterprise(RADIUS 인증서버, 회사) 구분
- TKIP: WEP 보완, MIC로 무결성 검사 / AES: WPA2부터

### 무선랜 위협
- **Rogue AP**(몰래 설치된 가짜 AP), **MITM**(중간자 공격), DoS

### 무선 라우터(공유기) = 5역할 합체
스위치 + 무선 AP + 라우터 + **DHCP 서버** + **NAT**
- 관리자 페이지: 브라우저에서 게이트웨이 IP 접속 / 계정 분실 시 → 초기화

## ④ 시험 포인트
- CSMA/CD(유선) vs CSMA/CA(무선)
- WEP=RC4, WPA2=AES(CCMP), WPA3=SAE — 매칭 문제 단골
- 접속 순서: 비컨→프로브→인증→접속

---

# Chapter 19. 네트워크 문제 해결

## ① 한 줄 요약
문제가 생기면 **L1부터 위로 한 층씩** 올라가며 원인을 좁혀가는 트러블슈팅 방법론.

## ② 꼭 알아야 할 개념

### 문제 해결 순서
파악 → 데이터 수집·비교 → 분석·해결책 → 적용 → 안 되면 **원상복구**
- 네트워크를 조금씩 분리하며 문제 영역 좁히기, 해결 과정 **문서화**

### ⭐ 계층별 문제 유형과 확인법
| 계층 | 흔한 문제 | 증상/확인 |
|---|---|---|
| **L1 물리** | 케이블 단선·잘못된 케이블·전원 | `down, line protocol down` / LED 확인 |
| **L2 데이터링크** | **clock rate 누락**, 캡슐화(HDLC↔PPP) 불일치, keepalive | `up, line protocol down` |
| **L3 네트워크** | IP/마스크/GW 오류, 라우팅 설정 오류 | show ip route, ping |
| **L4 전송** | **ACL 설정 오류**로 차단 | ping 되는데 telnet 안 됨 등 |
- 관리자가 끈 것: `administratively down` → no shutdown 필요

### 사례로 외우기
- **ping은 OK인데 telnet 실패** → 포트 닫힘 / 방화벽·ACL / ssh만 허용된 상태
- **up / protocol down (시리얼)** → clock rate 또는 encapsulation 불일치부터 의심
- telnet 성공 = L1~L7 전부 정상이라는 뜻

### 유동 정적 라우팅 (Floating Static Route)
- 동적 라우팅의 **백업 경로**. 정적 경로의 AD를 동적보다 **크게** 설정
```
R(config)# ip route 192.168.2.0 255.255.255.0 192.168.10.2 130
# RIP(120)이 살아있으면 RIP 사용, 죽으면 이 정적(130) 경로가 등판
```

### 확장 ping (라우터에서)
- `ping` 만 치고 엔터 → 대화형으로 **송신지 주소 지정** 등 상세 테스트 가능

## ③ 진단 명령어 툴박스
```
장비: show interfaces / show protocols / show ip interface brief
     show controllers serial X (DTE/DCE, clock)
     show cdp neighbors [detail]
     show ip protocols / show ip route
     debug ip packet, debug ip rip → undebug all
     clear ip route *
PC:  ipconfig /all, ping, tracert, arp -a, netstat -an, nslookup
```

## ④ 시험 포인트
- 상태 메시지 → 계층 매칭 (up/down 조합 3가지)
- 유동 정적 경로 = AD를 크게
- L4 문제의 대표 = ACL

---

# Chapter 20. 이중화 (HSRP)

## ① 한 줄 요약
게이트웨이 라우터를 2대 두고, 하나가 죽으면 다른 하나가 즉시 이어받는 시스코의 고가용성 프로토콜.

## ② 꼭 알아야 할 개념

### HSRP (Hot Standby Router Protocol)
- 🍯 운전기사 2명: 주 기사(Active)가 몰다가 쓰러지면 예비 기사(Standby)가 바로 핸들을 잡음. 승객(PC)은 기사가 바뀐 줄도 모름 — 늘 같은 "가상 기사(Virtual IP)"만 보니까.
- 시스코 전용, **부하분산은 없음** (Active/Standby 구조)
- PC의 게이트웨이 = **Virtual IP** (실제 라우터 IP가 아님!)
- Virtual MAC: v1 = `0000.0C07.ACXX` (XX=그룹번호) / v2 = `0000.0C9F.FXXX`
- UDP 1985, 멀티캐스트: v1 = 224.0.0.2 / v2 = 224.0.0.102
- 그룹 번호: v1(0~255), v2(0~4095)

### Active 선출
① **Priority 큰** 쪽 (기본 100) → ② 같으면 IP 큰 쪽

### 핵심 옵션들
| 옵션 | 뜻 |
|---|---|
| **preempt** | 장애 복구된 원래 Active가 자리를 되찾음 (없으면 못 되찾음!) |
| **priority** | 우선순위 (기본 100) |
| **timers** | Hello 3초 / Hold 10초 (Hold ≥ Hello×3) |
| **track** | 지정 인터페이스가 죽으면 priority 자동 감소 (기본 −10) |
| authentication | HSRP끼리 MD5 인증 |

### 상태 변화
Initial → Learn → Listen → Speak → Standby → **Active**

## ③ 핵심 명령어
```
R0(config)# interface fastethernet 0/0
R0(config-if)# standby version 2
R0(config-if)# standby 1 ip 1.1.1.7          # 그룹1, 가상 IP
R0(config-if)# standby 1 priority 105        # R0을 Active로 (R1은 100)
R0(config-if)# standby 1 preempt
R0(config-if)# standby 1 timers 1 3
R0(config-if)# standby 1 track FastEthernet0/1
R# show standby [brief]
```

## ④ 시험 포인트
- Active 선출: Priority 큰 값 > IP 큰 값
- Virtual MAC 형식 0000.0C07.ACxx
- preempt와 track의 역할
- 부하분산 원하면 그룹 2개(가상 IP 2개)로 호스트를 반씩 나눔

---

# Chapter 22. 시스코 라우터 기본 및 보안설정

## ① 한 줄 요약
라우터 보안 강화(하드닝) 체크리스트. **보안 과정이라면 이 챕터가 실무·면접에 가장 가깝다!**

## ② 꼭 알아야 할 개념

### 패스워드 보안
- 패스워드 Type: **0**(평문) / **7**(Vigenère, 복호화 가능 = 위험!) / **5**(MD5 해시, 일방향 = 안전)
- `service password-encryption`은 Type 7 → 온라인 크랙 사이트로도 뚫림
- ∴ 반드시 `enable secret` (Type 5) 사용 + `security passwords min-length 8`

### 접근 통제
- 콘솔/VTY에 password + login 설정
- VTY는 **SSH만 허용** (`transport input ssh`) + 로컬 계정(`login local`)
- 관리자 PC만 접근: ACL + `access-class 99 in` (VTY에)
- 방치 세션 자동 종료: `exec-timeout 300` (300초)
- `username admin privilege 15 secret ...` → 레벨 15면 바로 관리자 모드

### ⭐ 불필요한 서비스 끄기 (하드닝 체크리스트)
| 설정 | 막는 공격/이유 |
|---|---|
| `no ip redirects` | ICMP 리다이렉트 위조 → 라우팅 경로 조작 |
| `no ip directed-broadcast` | **Smurf 공격**(브로드캐스트 증폭 DoS) |
| `no ip unreachables` | 포트 스캐닝 정보 유출 |
| `no ip source-route` | 공격자가 패킷 경로 임의 지정 |
| `no ip proxy-arp` | ARP 위조로 네트워크 정보 획득 |
| `no ip finger` | 사용자 정보 유출 |
| `no cdp run` | 장비 정보 유출 (인터페이스만: no cdp enable) |
| `no service tcp/udp-small-servers` | echo·chargen 등 불필요 포트 |
| `no ip bootp server` | 불필요 서비스 |
| SNMP 커뮤니티 변경 | 기본 public/private 유추 방지 + ACL 적용 |

### 로그·시간 관리
- **NTP**: 시간 동기화 (`ntp server IP`, `clock timezone KST 9`) — 로그 분석·사고 대응의 기본
- **Syslog 서버**: 원격 로그 보관 (`logging IP`, `logging trap debugging`)
  - Severity: emergencies(0) → ... → debugging(7) — 숫자 작을수록 심각

### ⭐ 패킷 필터링 4종 (보안 기사·면접 단골)
| 필터링 | 방향/방법 | 목적 |
|---|---|---|
| **Ingress** | 외부→내부 입구에서 | 위조된 출발지(사설·예약 IP가 밖에서 들어옴) 차단 |
| **Egress** | 내부→외부 출구에서 | 내 네트워크 주소가 아닌 패킷 차단 (내부 감염 PC의 위조 공격 방지) |
| **Blackhole (Null routing)** | `ip route X.X.X.X 255.255.255.255 null 0` | 특정 IP 트래픽을 쓰레기통으로 |
| **Unicast RPF** | `ip verify unicast reverse-path` | 출발지 주소 위변조 자동 차단 |
- Ingress에서 차단할 예약 대역: 127/8, 10/8, 172.16/12, 192.168/16, 224/4, 240/5 등

## ④ 시험 포인트
- Type 5(secret, 안전) vs Type 7(password-encryption, 크랙 가능)
- directed-broadcast ↔ Smurf 공격 연결
- Ingress vs Egress 방향 구분

---

# 📎 부록 A. 시스코 명령어 치트시트 (실습 직전 훑어보기)

```
=== 모드 이동 ===
enable / disable / configure terminal / exit / end (Ctrl+Z)

=== 기본 설정 ===
hostname 이름
no ip domain-lookup
enable secret 암호
line console 0 → password 암호 → login
line vty 0 4 → password 암호 → login
banner motd # 경고문 #

=== 인터페이스 ===
interface fa0/0 → ip address IP 마스크 → no shutdown
(시리얼 DCE) clock rate 속도
(시리얼) encapsulation ppp|hdlc
description 설명

=== 저장/초기화 ===
copy running-config startup-config   (= write memory)
erase startup-config → reload
delete flash:vlan.dat                (스위치)

=== 라우팅 ===
ip route 목적지 마스크 다음홉|인터페이스 [AD]
ip route 0.0.0.0 0.0.0.0 다음홉
router rip → network N.N.N.N → version 2 → no auto-summary
router ospf 10 → network N.N.N.N 와일드카드 area 0 → router-id A.B.C.D

=== VLAN ===
vlan 10 → name 이름
int fa0/5 → switchport mode access → switchport access vlan 10
int fa0/1 → switchport mode trunk [→ switchport trunk encapsulation dot1q (MLS)]
int fa0/0.10 → encapsulation dot1q 10 → ip address ...   (라우터 서브IF)
int vlan 10 → ip address ... → no shutdown → ip routing  (MLS)

=== ACL ===
access-list 1 deny|permit 주소 와일드카드              (표준 1-99)
access-list 100 deny|permit tcp 출발 WC 목적 WC eq 포트  (확장 100-199)
int → ip access-group 번호 in|out
line vty 0 4 → access-class 번호 in

=== NAT/DHCP ===
ip nat inside source static 사설IP 공인IP
ip nat pool 이름 시작 끝 netmask 마스크
ip nat inside source list 번호 pool 이름 [overload]
int → ip nat inside | ip nat outside
ip dhcp pool 이름 → network/default-router/dns-server
ip dhcp excluded-address 시작 끝
int → ip helper-address 서버IP        (릴레이)

=== SSH ===
hostname X → ip domain-name Y → crypto key generate rsa (1024+)
username ID secret PW → line vty 0 4 → login local → transport input ssh

=== HSRP (인터페이스에서) ===
standby 1 ip 가상IP / priority 105 / preempt / track fa0/1

=== 확인(show) 베스트 ===
show running-config | show startup-config | show version
show ip interface brief | show interfaces | show controllers serial X
show ip route [rip|ospf|static] | show ip protocols
show ip ospf neighbor | show ip ospf database
show vlan | show interfaces trunk | show vtp status
show ip access-lists | show ip nat translations | show ip dhcp binding
show standby brief | show cdp neighbors | show flash:
```

---

# 📎 부록 B. 헷갈리는 것 최종 비교표

| 짝꿍 | 구분 포인트 |
|---|---|
| 허브 vs 스위치 | L1 플러딩·공유대역폭 vs L2 MAC필터링·전용대역폭 |
| 충돌영역 vs 브로드캐스트영역 | L2 장비로 분리 vs L3 장비로 분리 |
| running vs startup-config | RAM(지금) vs NVRAM(저장) |
| password vs secret | 평문 vs 암호화, 동시 설정 시 **secret 승** |
| Telnet vs SSH | 23·평문 vs 22·암호화 |
| RIPv1 vs v2 | 클래스풀·브로드캐스트 vs 클래스리스·224.0.0.9 |
| RIP vs OSPF | 이웃·전부·30초·홉수 vs 전체·변화분·즉시·비용 |
| 표준 vs 확장 ACL | 1-99·출발지만·목적지근처 vs 100-199·전부·출발지근처 |
| Access vs Trunk | VLAN 1개 vs 여러 개(태깅) |
| 802.1Q vs ISL | IEEE 표준·태깅 vs 시스코·캡슐화 |
| Static vs Dynamic vs PAT | 1:1서버 vs 풀 vs 포트로 다:1(overload) |
| CSMA/CD vs CA | 유선(충돌 감지) vs 무선(충돌 회피) |
| ARP vs RARP | IP→MAC vs MAC→IP |
| 0x2102 vs 0x2142 | 정상 부팅 vs 설정 무시(패스워드 복구) |
| WEP→WPA→WPA2→WPA3 | RC4 → TKIP → AES(CCMP) → SAE·GCMP |

---

# 📎 부록 C. 숫자 암기 카드

| 숫자 | 의미 |
|---|---|
| 15 | RIP 최대 홉 (16 = 도달불가) |
| 30초 | RIP 업데이트 주기 |
| 10 / 40초 | OSPF Hello / Dead |
| 3 / 10초 | HSRP Hello / Hold |
| 1 / 110 / 120 | AD: Static / OSPF / RIP |
| 100 | HSRP 기본 Priority |
| 32768 | STP 기본 Bridge Priority |
| 15+15초 | STP Listening + Learning |
| 224.0.0.5/6 | OSPF 멀티캐스트 (전체/DR) |
| 224.0.0.9 | RIPv2 / 224.0.0.10 = EIGRP |
| 67/68 | DHCP 서버/클라이언트 (UDP) |
| 69 | TFTP (UDP) |
| 22/23 | SSH/Telnet |
| 520 | RIP (UDP) |
| 1985 | HSRP (UDP) |

---

*교수님 필기 원본(Chapter 1~22 txt + 명령어 모음 + 판서)을 기반으로 재구성한 정리본입니다. `.pkt` 파일은 각 챕터의 패킷트레이서 실습 정답 파일이니, 이 노트로 개념을 잡고 → 해당 챕터의 pkt를 열어 직접 명령어를 쳐보는 순서로 복습하는 걸 추천!*
