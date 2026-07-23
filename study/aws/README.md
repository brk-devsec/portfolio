# ☁️ AWS Study

AWS 학습 기록을 정리한 공간입니다.

## 📁 Projects

| 프로젝트 | 설명 | 주요 기술 |
|---|---|---|
| [terraform-aws-3tier](./terraform-aws-3tier) | Terraform으로 구축한 AWS 3-Tier 웹 아키텍처 | VPC, ALB, Auto Scaling, RDS, NAT Gateway |

## 🛠 terraform-aws-3tier 요약

Bastion / Web / DB 3계층 구조를 코드로 배포하는 IaC 실습 프로젝트입니다.

- **네트워크**: VPC(10.0.0.0/16), 서브넷 10개, IGW + NAT Gateway 이중 라우팅
- **컴퓨팅**: EC2 → AMI 캡처 → Launch Template → Auto Scaling Group (min 1 / max 6)
- **로드밸런싱**: ALB + Target Group, Health check 기반 트래픽 분산
- **데이터베이스**: RDS MySQL 8.0 (Multi-AZ 서브넷 그룹)
- **자동화**: `user_data` + `templatefile()`로 WordPress 설치 및 RDS 엔드포인트 동적 주입
- **보안**: 비밀번호 변수 분리(`sensitive`), tfstate gitignore 처리

자세한 아키텍처 다이어그램과 트러블슈팅 기록은 [프로젝트 README](./terraform-aws-3tier/README.md) 참고.
