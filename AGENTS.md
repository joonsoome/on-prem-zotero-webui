## On-Prem Zotero WebUI / PDF Proxy – Codex 워크스페이스 지침

### 1. 프로젝트 개요

- **목표**
  - Zotero 7 WebDAV(압축 기반) 환경에서,
  - WebDAV 스토리지를 그대로 사용하면서
  - On-Prem Web Library(UI) + PDF Proxy(FastAPI)로 브라우저에서 바로 PDF를 열 수 있는 셀프호스트 솔루션 구현.
- **핵심 흐름**
  - `Zotero Desktop → WebDAV(<key>.zip 구조) → On-Prem Web Library(zotero/web-library 포크) → PDF Proxy(/pdf/{key}) → 브라우저 PDF 뷰`
- **제약**
  - WebDAV 구조(`<key>.prop`, `<key>.zip`)는 Zotero가 관리하므로 수정하지 않고, Proxy는 읽기·캐시 디렉터리 생성만 수행.

### 2. MVP 환경 설명 (네트워크·역할)

- **code-server 개발 환경**
  - 위치: `http://192.168.0.205`
  - 용도: 이 Codex 세션이 붙어 있는 주 개발 IDE.
  - 모든 소스 편집·테스트·도커 구성 초안은 이 환경에서 작성.

- **실제 배포 대상 – Synology NAS 920DS+**
  - 관리 UI: `http://192.168.0.50`
  - 역할: PDF Proxy + (추후) Web Library + Zotero 메타데이터 스택을 포함하는 최종 Docker Compose 스택의 실행 호스트.
  - WebDAV 로컬 경로(예상): `/volume1/Reference/zotero` → 컨테이너에서 `/data/zotero`로 마운트.

- **Portainer**
  - 위치: `https://192.168.0.204:9443`
  - 역할: Synology·기타 호스트의 컨테이너 스택 모니터링 및 배포 관리.
  - 추후 MCP(예: HTTP MCP 또는 별도 MCP 서버)를 통해 스택 상태 조회/간단 오퍼레이션을 할 수도 있음  
    (현재는 “연결 가능성 확인 필요” 상태로 간주).

- **Zotero Desktop**
  - 위치: `http://192.168.0.110` (실제는 로컬 앱, URL은 관리용 참고)
  - 역할: WebDAV 스토리지와 메타데이터를 동기화하는 정식 클라이언트.
  - 이 프로젝트는 Zotero Desktop의 동작을 변경하지 않고, 동기화된 WebDAV 파일만 읽어서 제공.

- **Zotero WebDAV 스토리지**
  - URL: `https://192.168.0.50/Reference/zotero`
  - 인증: 기본 인증 사용 (실제 자격증명은 코드/리포지토리에 평문 저장하지 말 것; 환경변수/시크릿로 관리).
  - 이 디렉터리에 `<key>.prop`, `<key>.zip` 파일이 저장되며, Proxy는 이를 읽고 `/zotero/<key>/...` 형태의 캐시 디렉터리를 생성.

- **Zotero 메타데이터**
  - 현재: `zotero.org` 공식 계정을 사용해 클라우드 메타데이터 UI 이용.
  - 목표: `http://192.168.0.50` 상에서 Portainer 스택(이 프로젝트의 Docker Compose)로 On-Prem Web Library UI를 호스팅하여,  
    On-Prem 메타데이터 + PDF Proxy를 함께 제공.

### 3. MCP 및 툴 사용 지침

- **MCP 서버 구성 (이미 설정됨)**
  - `shell` MCP  
    - 명령: `npx -y @modelcontextprotocol/server-shell`  
    - 허용 명령: `ls, cat, python3, curl, docker, docker-compose`  
    - 사용 예:
      - WebDAV 샘플 폴더·zip/PDF 생성
      - 간단한 Python 스크립트로 zip·PDF 구조 검사
      - 로컬 컨테이너 로그 확인 등
  - `http` MCP  
    - 명령: `npx -y @modelcontextprotocol/server-http`  
    - 사용 예:
      - 로컬/On-Prem HTTP 서비스(FastAPI PDF Proxy, Web Library, Portainer API)가 열려 있을 때 상태·헬스체크 호출
      - 추후 API 기반 운영/모니터링 통합
  - `mcphub` MCP  
    - URL: `http://192.168.0.110:3000/mcp`  
    - 사용 예:
      - 사내 공용 MCP 서버(예: 포트테이너 제어, 네트워크 스캐너, 모니터링 등)와 연동할 때 중앙 허브로 사용

- **Codex 툴 사용 기본 원칙**
  - 가능한 한 `shell` MCP를 사용해 파일 조회/간단 스크립트를 돌리고, 직접 호스트에 명령을 치는 것은 최소화한다.
  - 네트워크 접근은 내부 IP(`192.168.x.x`)만 대상으로 하고, 외부 인터넷 사용은 필요할 때만 한다.
  - Portainer·NAS 등 운영 대상에 대해서는 “읽기/헬스체크 중심”으로 접근하고,  
    파괴적인 조작(컨테이너 삭제 등)은 사용자가 명시적으로 요구하지 않는 이상 수행하지 않는다.
  - 사용자와 구현중 수정사항이 있을때 지시를 기다리지 않고 AGENTS.md와 README-draft.md에 자동 수정 문서화 한다.

### 4. 구현·코드 작성 지침

- **기술 스택**
  - PDF Proxy: Python FastAPI + Uvicorn, README의 샘플 `main.py` 구조를 기본으로 사용.
  - Web Library: `zotero/web-library` 포크 또는 공식 이미지 기반으로, 최소한 “Open PDF” 버튼의 링크만 커스터마이즈.
  - Docker: `docker-compose.yml` 중심으로 Synology 배포를 염두에 둔 구성(볼륨/경로, UID/GID 등) 설계.

- **PDF Proxy 설계 기본**
  - 입력: `/pdf/{key}`
  - 동작:
    - `/data/zotero/{key}/`에 캐시된 PDF가 있으면 즉시 스트리밍.
    - 없으면 `/data/zotero/{key}.zip`에서 첫 번째 PDF를 추출 → `{key}/` 디렉터리에 저장 → 스트리밍.
  - 응답: `StreamingResponse`, `Content-Type: application/pdf`.
  - 오류 처리: zip 없음, PDF 없음, 권한 문제 등은 명확한 HTTP 코드(예: 404, 500)와 메시지로 반환.

- **코드 스타일·구조**
  - 함수/모듈은 역할 중심으로 분리:
    - 경로·환경 설정 모듈, zip 처리 유틸리티, FastAPI 라우터, 로그/예외 핸들링 등.
  - “한 번에 큰 리팩터링”보다는, 작은 단계별 변경 + 테스트를 우선한다.
  - 리포지토리에 비즈니스 로직만 두고, 환경 의존적인 값(경로, URL, 자격증명 등)은 환경변수/설정 파일로 분리한다.

### 5. 보안·환경 변수 지침

- WebDAV 계정/비밀번호, Zotero 토큰, Portainer API 토큰 등은:
  - 코드/리포지토리에 평문으로 쓰지 않는다.
  - `.env` 또는 Docker 시크릿/Portainer 시크릿으로 관리하고,  
    Codex가 생성하는 예제에는 플레이스홀더(예: `ZOTERO_WEBDAV_USER`, `ZOTERO_WEBDAV_PASSWORD`)만 사용한다.
- 내부 IP·URL은 문서화용으로 사용하되, 외부 공유 시에는 마스킹 또는 범위를 설명만 한다.

### 6. 작업 순서 (기본 로드맵)

Codex가 이 워크스페이스에서 작업할 때 기본적으로 따를 단계이다.

1. **FastAPI PDF Proxy MVP 구현**
   - README의 샘플 `main.py`를 기반으로 `/pdf/{key}` 라우트, zip → PDF 캐시/스트리밍 로직 완성.
   - 로컬 테스트용 WebDAV 샘플 디렉터리 구성.
2. **테스트 및 로깅 추가**
   - 주요 에러 케이스 단위 테스트, 간단한 요청 로그(처리 시간, 캐시 히트 여부 등) 추가.
3. **Docker Compose (Synology 대상) 구성**
   - `/volume1/Reference/zotero:/data/zotero` 볼륨 마운트, 포트/환경변수 정의, 재시작 정책 설정.
4. **On-Prem Zotero Web Library 연동**
   - “Open PDF” 버튼 링크를 `https://pdf.example.com/pdf/<key>` 형태로 변경.
   - NAS 상에서 Web Library + PDF Proxy가 하나의 스택으로 동작하도록 구성.
5. **Reverse Proxy / TLS / Portainer 연계**
   - Nginx Proxy Manager 또는 Traefik으로 도메인·TLS 구성.
   - Portainer 스택 정의로 배포·롤백이 가능하도록 정리.
6. **최종 문서화**
   - README(현재 `README-draft.md`)를 본문 + 운영 가이드 + 트러블슈팅 섹션으로 정리.
