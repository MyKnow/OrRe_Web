# 🏪 오리 가오리 - 원격 웨이팅 및 주문 관리 시스템
## 🙋 MyKnow: PM, FE, DevOps, QA
- **Flutter Web을 WebAssembly(WASM)**로 컴파일하여 경량화된 웹 프론트엔드를 구현했습니다.
- 내부 리눅스 서버에 자동 배포되는 CI/CD 파이프라인을 구축했습니다.
- 상태 동기화 및 WebSocket 연결 안정성을 확보하여 실시간성과 운영 안정성 모두를 만족시키는 구조를 설계하였습니다.
- QA 시나리오 수립 및 멀티 플랫폼 테스트를 통해 서비스 품질을 전반적으로 책임졌습니다.

## 📌 프로젝트 소개
- **오리 가오리**는 가게의 웨이팅과 주문을 원격으로 관리할 수 있도록 도와주는 서비스입니다.  
- OrRe_Web은 Flutter로 구축된 웹 기반 웨이팅 서비스로, 비회원도 간편하게 대기열에 등록하고 매장 운영자는 실시간으로 웨이팅/주문 상황을 파악할 수 있도록 돕습니다.
- Flutter Web의 WASM 컴파일 방식을 통해 웹의 로딩 속도와 성능을 최적화하였으며, 자체 리눅스 서버에 자동 배포되도록 DevOps 환경을 설계했습니다.

## 🎯 주요 기능  
![Functions](https://github.com/user-attachments/assets/61309f4f-a3f5-4036-84a2-e9ffb6d6581b)

### 🔹 1. 원격 웨이팅 확인 및 예약  
- ✅ 사용자는 앱에서 대기 인원을 확인하고 사전 웨이팅을 등록할 수 있습니다.  

### 🔹 2. NFC/QR을 통한 비회원 웨이팅  
- ✅ 회원이 아니더라도 매장 앞에서 **QR 코드 또는 NFC 태그**를 이용해 웨이팅을 등록할 수 있습니다.  

### 🔹 3. NFC/QR을 통한 비대면 주문  
- ✅ 테이블마다 부착된 **QR 코드/NFC 태그를 스캔하여 비대면 주문**을 진행할 수 있습니다.  
- ✅ 인력 부담을 줄이고 운영 효율을 높일 수 있습니다.  

### 🔹 4. 점주를 위한 관리 앱 제공  
- ✅ 점주는 **웨이팅 및 주문을 한 곳에서 통합 관리**할 수 있습니다.  
- ✅ 실시간으로 변동되는 데이터를 반영하여 손쉽게 매장을 운영할 수 있습니다.  

## 🏗 시스템 아키텍처  
![System Architecture - BACKEND](https://github.com/user-attachments/assets/5a79d2ee-45c4-415b-8dfb-4d23ad1c0980)
![System Architecture - ORRE](https://github.com/user-attachments/assets/19611b2d-a95b-40f4-9fd9-4f4a263facd6)
![System Architecture - GAORRE](https://github.com/user-attachments/assets/25fc2975-23a8-4b5a-8040-ff7302c7093d)

## 📺 소개 영상  
🔗 [원격 웨이팅 앱 오리, 가오리 시연 영상](https://www.youtube.com/watch?v=tMEdkNkiJkg)  

## 🚀 기술 스택  

### **Frontend**  
- ✅ Flutter Web (WASM 빌드)
- ✅ Riverpod, Responsive UI, Custom Animation

### **Backend**    
- ✅ Spring boot  
- ✅ MySQL  

### **Infrastructure**  
- ✅ 자체 리눅스 서버 (Ubuntu)
- ✅ Nginx (정적 웹 서버 & Reverse Proxy)
- ✅ GitHub Actions 기반 CI/CD 구성
- ✅ TLS 인증서 자동 갱신 (Let’s Encrypt + Certbot)

## 🧪 QA 및 운영 안정화

### ✅ QA 프로세스 정립 및 적용
- 다양한 디바이스/브라우저에서 Flutter Web 렌더링 검증
- 브라우저별 동작 차이 분석 및 대응 (Chrome/Safari/Edge 등)

### ✅ 운영 이슈 모니터링 및 대응
- WASM 컴파일로 인한 초기 로딩 최적화

## 🛠 기술적 과제 및 해결

### 🔥 1. WebSocket 연결 안정성 확보
- WebSocket 연결 상태를 지속적으로 확인하는 헬스 체크 알고리즘 구현
- 연결 해제 시 HTTPS fallback 요청을 통해 서버 상태 점검 및 자동 재연결
- 실시간성이 중요한 웨이팅/주문 서비스 특성에 맞춰 장애 대응 로직 구현

### 🔥 2. Flutter Web의 WASM 배포 자동화
- Flutter build web 시 --wasm 옵션으로 WASM 바이너리 생성
- GitHub Actions 내에서 빌드 결과물을 .tar.gz로 압축 후 SCP를 통해 서버로 전송
- 리눅스 서버에서 자동 압축 해제 및 Nginx static 경로에 배포
- 배포 완료 후 자동 nginx reload + Cache Busting 처리

### 🔥 3. 브라우저 호환성 및 퍼포먼스 개선
- iOS Safari의 WASM 초기 로딩 문제 대응
- 사용자 경험에 영향을 주지 않도록 로딩 인디케이터 및 네트워크 예외처리 로직 강화

## 📸 실제 매장 도입 예시

![sundobu](https://github.com/user-attachments/assets/7044bfa4-729e-427e-a58c-1ac33fbaa013)
![gompocha](https://github.com/user-attachments/assets/20409b38-2d07-483e-bc31-2a792ed335c7)
