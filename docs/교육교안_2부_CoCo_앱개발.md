# 스노우패션 Snowflake AI Platform 교육 교안 (2부) - Cortex Code & App 개발

> **대상**: 스노우패션 데이터/IT 담당자  
> **선행 조건**: 1부 교육 완료 (Cortex AI 제품군, Semantic View, Agent, Cowork)  
> **환경**: Snowsight CoCo + CoCo Desktop  
> **데이터**: SNOW_FASHION 데이터베이스 (1부에서 사용한 동일 데이터)

---

## 목차

| Chapter | 제목 | 형식 | 예상 시간 |
|---------|------|------|-----------|
| 1 | Cortex Code(CoCo) 소개 및 환경 비교 | 슬라이드 + 화면 | 25분 |
| 2 | CoCo 연결 설정 | 핸즈온 | 20분 |
| 3 | Workspace에서 Streamlit 앱 개발 | 슬라이드 + 데모 | 30분 |
| 4 | Snowsight CoCo로 Streamlit 리포트 생성 | 라이브 데모 | 25분 |
| 5 | CoCo Desktop으로 App Runtime 앱 빌드 | 슬라이드 + 라이브 데모 | 50분 |
| 부록 A | 정리: 어떤 도구를 언제 쓸 것인가 | 슬라이드 | 10분 |
| 부록 B | CoCo Desktop 고급 기능 | 참고 | — |
| 부록 C | 참고 자료 | 참고 | — |

---

## Chapter 1. Cortex Code(CoCo) 소개 및 환경 비교

### 1.1 학습 목표
- CoCo의 개념과 주요 기능 이해
- Snowsight CoCo, CLI, Desktop 3가지 환경의 차이점 및 선택 기준
- 1부에서 UI/SQL로 수행한 작업을 CoCo로 어떻게 대체할 수 있는지 이해

### 1.2 CoCo란?

Cortex Code(CoCo)는 Snowflake의 **AI 코딩 에이전트**입니다. 자연어로 요청하면:
- SQL 작성 및 실행
- Streamlit 앱 코드 생성
- Next.js(App Runtime) 앱 프로젝트 초기 구조 생성
- Semantic View 생성/수정
- Agent 생성/수정
- 파일 편집, 배포까지 자동 수행

### 1.3 CoCo의 3가지 환경

| 환경 | 실행 위치 | 주요 용도 |
|------|-----------|-----------|
| **Snowsight CoCo** | 브라우저 (Snowsight 내장) | SQL 작성, 데이터 탐색, 간단한 Streamlit 생성, Semantic View 관리 |
| **CoCo CLI** | 로컬 터미널 | 자동화/CI/CD, 스크립트 실행, 비대화형 작업 |
| **CoCo Desktop** | 로컬 IDE 앱 | 본격적인 앱 개발, 멀티파일 프로젝트, App Runtime 배포 |

### 1.4 CoCo가 할 수 있는 것 (1부 복습 연계)

1부에서는 주로 **Snowsight UI + SQL**로 작업했습니다:
- Semantic View 생성 → Snowsight UI
- Description/Metric 추가 → SQL
- Agent 생성 → Snowsight UI
- Instruction 작성 → Snowsight UI

2부에서는 같은 작업을 **CoCo에게 자연어로 요청**하는 방법을 배웁니다:
- "매출 분석 대시보드를 Streamlit으로 만들어줘"
- "이 대시보드에 브랜드별 필터 추가해줘"
- "이 앱을 Snowflake에 배포해줘"

---

### 1.5 Snowsight CoCo

**접속 방법**: Snowsight 내 여러 곳에서 접근 가능
- Snowsight 우측 하단 CoCo 아이콘
- Workspace 파일 편집 중 CoCo 패널
- AI & ML → Semantic View 편집 화면

**강점**:
- 별도 설치 불필요 (브라우저만 있으면 됨)
- Snowflake 컨텍스트(DB, Schema, Warehouse)가 자동 설정됨
- 워크시트에서 바로 SQL 생성/실행
- Workspace에서 Streamlit 코드 생성/수정 + 미리보기

**한계**:
- 로컬 파일 시스템 접근 불가
- 복잡한 멀티파일 프로젝트 관리 어려움
- App Runtime(Next.js) 프로젝트는 빌드/배포 불가

**적합한 작업**:
- 빠른 SQL 작성, 데이터 탐색
- 간단한 Streamlit 앱 생성
- Semantic View/Agent 수정
- Cowork 오토메이션 설정

### 1.6 CoCo CLI

**접속 방법**: 터미널에서 `cortex` 명령어 실행

**강점**:
- 스크립트/자동화에 적합 (`cortex exec`)
- CI/CD 파이프라인에 통합 가능
- 로컬 파일 시스템 접근 가능
- 비대화형 모드로 배치 작업 가능

**적합한 작업**:
- 반복적인 배포 자동화
- CI/CD 파이프라인에서 Snowflake 작업 실행
- 스크립트 기반 대량 작업

### 1.7 CoCo Desktop

**접속 방법**: 전용 데스크톱 앱 설치 후 실행

**강점**:
- 풀 IDE 경험 (파일 탐색, 편집, 터미널 통합)
- 로컬 파일 + Snowflake 데이터 동시 접근
- 멀티파일 프로젝트 관리 (React, Next.js 등)
- App Runtime 앱의 로컬 개발 → 배포 워크플로우
- Subagent로 병렬 작업 가능
- 플러그인/스킬 생태계 활용

**한계**:
- 로컬에 설치 필요
- Node.js 등 개발 환경이 필요할 수 있음 (App Runtime)

**적합한 작업**:
- 본격적인 Streamlit/App Runtime 앱 개발
- 복잡한 데이터 파이프라인 구축
- Semantic View/Agent 일괄 고도화
- 로컬 데이터 파일 → Snowflake 적재

### 1.8 환경 선택 가이드

**Snowsight CoCo vs Desktop/CLI:**

| 기준 | Snowsight CoCo | CoCo Desktop / CLI |
|------|---------------|-------------------|
| 설치 | 불필요 (브라우저) | 로컬 설치 필요 |
| 적합한 작업 | SQL 작성, 간단한 Streamlit, 데이터 탐색 | 멀티파일 앱 개발, 로컬 테스트, App Runtime |
| 파일 관리 | Workspace (브라우저) | 로컬 파일시스템 |

**CoCo Desktop vs CLI:**

Desktop과 CLI는 동일한 기능을 제공하며, **사용자 선호도와 환경 제약**에 따라 선택합니다.

| 기준 | CoCo Desktop | CoCo CLI |
|------|-------------|----------|
| UI | 직관적인 GUI (diff 뷰, 파일 트리 등) | 터미널 기반 |
| 선택 기준 | 시각적 코드 리뷰, GUI 선호 | 터미널 선호, 키보드 중심 워크플로 |
| CLI만의 특징 | — | `cortex exec` (비대화형 실행), 스크립트/자동화 통합 가능 |
| Desktop 설치 불가 시 | — | GitHub Codespaces, 원격 서버 등 터미널만 제공되는 환경에서 사용 |

> **요약**: 기능 차이가 아니라 환경에 따라 선택합니다. Desktop 설치가 가능하면 Desktop이 직관적이고, 터미널만 있는 환경(Codespaces, SSH 서버 등)이면 CLI를 사용합니다. 비대화형 자동화(`cortex exec`)가 필요하면 CLI입니다.

---

## Chapter 2. CoCo 연결 설정

### 2.1 학습 목표
- Snowsight CoCo, CLI, Desktop 각 환경의 연결 설정 방법
- PAT(Personal Access Token) 또는 Key Pair 인증 설정
- 연결 확인 및 트러블슈팅

### 2.2 Snowsight CoCo (별도 설정 불필요)

Snowsight에 로그인하면 CoCo가 자동으로 활성화됩니다.
- Snowsight 우측 하단의 CoCo 아이콘 클릭
- 또는 Workspace에서 파일 열면 CoCo 패널 자동 표시

> 매뉴얼: <a href="https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight" target="_blank">CoCo in Snowsight</a>

### 2.3 CoCo CLI 설치 및 연결

> 매뉴얼: <a href="https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-cli" target="_blank">CoCo CLI</a>

#### Step 1: 설치

```bash
# macOS / Linux (WSL 포함)
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh

# Windows (PowerShell)
irm https://ai.snowflake.com/static/cc-scripts/install.ps1 | iex
```

#### Step 2: Snowflake 연결 설정

```bash
# 대화형으로 연결 설정
cortex

# 연결 정보 입력:
# Account: <계정식별자>
# User: (본인 사용자명)
# Authentication: Browser (기본) 또는 PAT
```

연결 방법 옵션:
| 인증 방법 | 설명 | 적합한 경우 |
|-----------|------|-------------|
| **Browser (SSO)** | 브라우저 팝업으로 로그인 | 대화형 사용 (MFA가 있으면 매 4시간마다 재인증) |
| **PAT (Programmatic Access Token)** | 토큰 기반 인증 | 자동화, CI/CD, MFA 재인증 없이 사용 |
| **Key Pair** | RSA 키 기반 | 보안 요구 높은 환경, 서비스 계정 |

#### PAT 생성 방법

**방법 A: Snowsight UI에서 생성**

1. Snowsight 좌측 하단 사용자 아이콘 → `Settings` → `Authentication`
2. `Programmatic access tokens` 항목에서 `Generate token`
3. Name, Expires in(만료일), Role restriction 설정
4. `Generate` 클릭 → 토큰 복사 (이 화면에서만 확인 가능)

**방법 B: SQL로 생성**

```sql
-- 본인 계정에 PAT 생성 (15일 만료)
ALTER USER ADD PAT MY_COCO_TOKEN
  DAYS_TO_EXPIRY = 15
  COMMENT = 'CoCo CLI/Desktop 인증용';
```

> **Network Policy 요구사항**: PAT 사용에는 Network Policy가 필요합니다.
> ```sql
> -- 교육/PoC용: 모든 IP 허용 Network Policy 생성 및 사용자에게 적용
> CREATE NETWORK RULE IF NOT EXISTS allow_all_rule
>   TYPE = IPV4 MODE = INGRESS VALUE_LIST = ('0.0.0.0/0');
>
> CREATE NETWORK POLICY IF NOT EXISTS allow_all_policy
>   ALLOWED_NETWORK_RULE_LIST = ('allow_all_rule');
>
> ALTER USER <사용자명> SET NETWORK_POLICY = 'allow_all_policy';
> ```
> **프로덕션 환경**에서는 허용 IP를 제한하여 보안을 강화하세요.

**PAT를 connections.toml에 등록:**

**방법 A — password 필드에 직접 사용 (간편):**

```toml
# ~/.snowflake/connections.toml
[snow_fashion]
account = "<계정식별자>"
user = "admin"
password = "eyJraWQ..."   # PAT 토큰을 password에 그대로 입력
```

> Snowflake는 password 필드에 PAT가 들어오면 **자동으로 PAT 인증으로 처리**합니다. `authenticator` 설정이 필요 없어 가장 간편합니다.

**방법 B — token_file_path 사용 (보안 권장):**

```toml
# ~/.snowflake/connections.toml
[snow_fashion]
account = "<계정식별자>"
user = "admin"
authenticator = "PROGRAMMATIC_ACCESS_TOKEN"
token_file_path = "/Users/admin/.snowflake/pat_token.txt"
```

PAT 토큰을 파일에 저장:
```bash
# 생성 시 복사한 토큰을 파일에 저장
echo "ver:1-hint:..." > ~/.snowflake/pat_token.txt
chmod 600 ~/.snowflake/pat_token.txt
```

> **보안 권장사항**: 프로덕션 환경에서는 토큰을 설정 파일에 직접 넣지 마세요. 별도 파일(`token_file_path`)이나 환경 변수를 사용합니다. 교육 환경에서는 방법 A로 빠르게 진행해도 됩니다.

#### Key Pair 생성 방법

```bash
# Step 1: RSA 키 쌍 생성
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```

```sql
-- Step 2: 공개키를 Snowflake 사용자에 등록
ALTER USER admin SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqh...';  -- rsa_key.pub 내용 (헤더/푸터 제외)
```

```toml
# Step 3: connections.toml에 등록
[snow_fashion]
account = "<계정식별자>"
user = "admin"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "/Users/admin/.ssh/rsa_key.p8"
```

> **참고**: Key Pair는 Network Policy 없이도 사용 가능하며, MFA 재인증도 불필요합니다. 보안이 중요한 프로덕션 환경에 적합합니다.

#### Step 3: 연결 확인

```bash
# 연결 상태 확인
cortex
> /connections
```

### 2.4 CoCo Desktop 설치 및 연결

> 매뉴얼: <a href="https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-desktop" target="_blank">CoCo Desktop</a>

#### Step 1: 설치

1. 아래 공식 다운로드 페이지에서 OS에 맞는 설치 파일 다운로드
   - <a href="https://www.snowflake.com/en/product/snowflake-coco/downloads/" target="_blank">https://www.snowflake.com/en/product/snowflake-coco/downloads/</a>
   - macOS: `.dmg` 파일
   - Windows: User installer (권장, 관리자 권한 불필요) / System installer (전체 사용자 설치)
2. 설치 후 앱 실행

#### Step 2: Snowflake 계정 연결

1. CoCo Desktop 실행 → 로그인 화면
2. **Account Identifier**: `<계정식별자>`
3. **Username**: 본인 사용자명
4. **인증 방법** (UI에서 3가지 제공):
   - **Local OAuth** (권장) — 브라우저가 열리며 Snowflake 로그인 후 자동 연결
   - **SSO** — 조직의 IdP(Okta, Azure AD 등)를 통한 인증
   - **Password** — Snowflake 비밀번호 또는 PAT를 입력 (MFA 설정 시 추가 인증 필요, PAT 사용 시 MFA 불필요)
5. 연결 완료 후 좌측에 Snowflake 오브젝트 탐색기 표시

#### Step 3: 작업 디렉토리 설정

CoCo Desktop은 **로컬 디렉토리 기반**으로 작업합니다:

1. 1부에서 다운로드한 교육 파일셋을 압축 해제하면 `snow-fashion-cortex-hands-on-main` 폴더가 생성됩니다. 이 폴더를 작업 디렉토리로 사용합니다.
2. CoCo Desktop → `File` → `Open Folder` → `snow-fashion-cortex-hands-on-main` 폴더 선택

> **새 폴더가 필요한 경우**: App Runtime 앱은 별도의 프로젝트 폴더가 필요합니다. Chapter 5 데모에서 CoCo가 `snow-fashion-cortex-hands-on-main` 하위에 앱 폴더를 자동 생성합니다.

---

## Chapter 3. Workspace에서 Streamlit 앱 개발

### 3.1 학습 목표
- Workspace의 개념과 Development App / Deployed App 차이 이해
- Workspace에서 Streamlit 앱을 생성하고 배포하는 전체 워크플로우 실습
- Git 연동 및 Shared Workspace를 활용한 협업 모델 이해

### 3.2 Workspace란?

Snowsight Workspace는 Snowflake 내장 **파일 기반 개발 환경**입니다.
- 코드 편집기 + 파일 탐색기 + 터미널
- Streamlit 앱을 작성하고 바로 미리보기 가능
- 배포(Deploy) 버튼으로 다른 사용자에게 공개

### 3.3 핵심 개념

#### Development App vs Deployed App

| 구분 | Development App | Deployed App |
|------|----------------|--------------|
| **누가 보는가** | 본인만 (비공개) | 권한 받은 모든 사용자 |
| **코드 변경** | 실시간 반영 | Deploy해야 반영 |
| **용도** | 개발/테스트 | 프로덕션 서비스 |

> 코드를 수정해도 Deployed App에는 영향 없음 → Deploy를 눌러야 반영됩니다.

#### Streamlit 프로젝트 구조

```
my-streamlit-app/
├── streamlit_app.py       ← 앱 메인 코드 (엔트리포인트)
├── pyproject.toml         ← Python 패키지 의존성 (uv 사용)
├── snowflake.yml          ← 배포 설정 (컴퓨트 풀, 웨어하우스, 런타임 등)
└── .streamlit/
    └── config.toml        ← Streamlit 설정 (선택)
```

> Workspace에서 만든 Streamlit은 **Container Runtime**으로 동작합니다. 과거에 사용하던 Warehouse Runtime(`environment.yml`, `ROOT_LOCATION` 기반)은 레거시 방식이며, Workspace의 멀티파일 편집과 Git 연동을 지원하지 않습니다.

> `snowflake.yml`은 Workspace에서 Streamlit 앱을 만들면 **자동 생성**되며, 배포 설정(Compute Pool, Query Warehouse, Runtime 등)을 저장합니다. Deploy 대화상자에서 변경한 설정도 이 파일에 반영됩니다.

### 3.4 리소스 관리

Workspace의 Streamlit 앱(Container Runtime)은 **Compute Pool** 위에서 실행됩니다. 비용은 Compute Pool 노드 가동 시간 기반으로 과금되므로, 리소스 관리가 중요합니다.

#### 구성 요소

| 항목 | 설명 |
|------|------|
| **Compute Pool** | 앱이 실행되는 컨테이너 환경. 계정에 기본 컴퓨트 풀이 설정되어 있어야 함 |
| **Query Warehouse** | 앱 내 SQL 쿼리를 실행하는 웨어하우스 (예: `SF_WH`) |

> **참고**: `SYSTEM_COMPUTE_POOL_CPU`(시스템 제공 풀)를 사용하면 전용 Compute Pool을 별도로 생성하지 않아도 됩니다. 노드당 최대 3개 앱이 공유 실행되며, 전용 풀과 달리 앱이 없을 때 빈 노드를 점유하지 않습니다. 반면, 사용자가 직접 생성한 **전용 Compute Pool**에서는 Streamlit 앱 1개가 노드 1개를 독점 사용합니다.

#### 자동 중지 동작

| 단계 | 조건 | 동작 |
|------|------|------|
| 1. Streamlit 서버 종료 | **3일간 뷰어 비활동** | Streamlit 서버 프로세스 자동 종료 (모든 Container Runtime 앱 공통, 변경 불가) |
| 2. Compute Pool 노드 해제 | 풀 내 모든 서비스/잡 종료 후 `AUTO_SUSPEND_SECS` 경과 | 노드 자동 해제 |

#### 상황별 관리 방안

**1. 개별 앱 중지/재시작**

Streamlit 앱은 **Projects → Streamlit** 메뉴에서 개별적으로 관리할 수 있습니다.

| 작업 | 방법 |
|------|------|
| 개별 앱 중지 | **Projects → Streamlit** → 해당 앱 선택 → 우측 상단 `⋮` → **Shutdown** |
| 개별 앱 재시작 | Shutdown된 앱에 **접속만 하면 자동 재시작** (Projects 또는 Apps 어디서든 가능) |

> **참고**: Snowsight 좌측 메뉴의 **Apps**에서 Streamlit 앱에 진입하면 뷰어 모드로만 표시되어 관리 메뉴가 없습니다. 앱 중지(Shutdown/Delete 등)는 **Projects → Streamlit** 경로로 진입해야 합니다.

교육 후 리소스 정리가 필요하다면, 개별 앱을 **Shutdown**하는 것이 가장 간단한 방법입니다. 3일을 기다리지 않아도 즉시 리소스가 해제되며, 나중에 앱에 접속하면 자동으로 다시 시작됩니다.

**2. Compute Pool 관리**

| 작업 | SQL | UI |
|------|-----|-----|
| 풀 중지 | `ALTER COMPUTE POOL my_pool SUSPEND;` | Manage → Compute → 리스트에서 `⋮` → Suspend |
| 풀 재시작 | `ALTER COMPUTE POOL my_pool RESUME;` | 동일 경로에서 `⋮` → Resume |

> **주의**: Compute Pool의 `AUTO_RESUME = TRUE`(기본값)인 경우, 풀을 Suspend하더라도 **브라우저에서 앱이 열려있으면 서비스 요청이 발생하여 풀이 자동으로 다시 재개**됩니다. 풀을 완전히 중지하려면 먼저 앱에 접속 중인 모든 브라우저 탭을 닫은 후 Suspend해야 합니다.

**3. 자동 중지/재시작 동작 정리**

| 상황 | 동작 |
|------|------|
| 3일간 뷰어 비활동 | Streamlit 서버 자동 종료 (Container Runtime 공통, 변경 불가) |
| Shutdown된 앱에 사용자 접속 | **자동 재시작** (경로 무관, 콜드 스타트 발생) |
| Compute Pool Suspend (`AUTO_RESUME = TRUE`) | 브라우저 탭이 열려있으면 즉시 자동 재개됨 |
| Compute Pool Suspend (모든 탭 종료 후) | 풀 중지 유지, 이후 앱 접속 시 자동 재개 |

**4. 비용 최적화 팁**

| 방법 | 효과 |
|------|------|
| 미사용 앱 **Shutdown** (Projects → Streamlit → `⋮` → Shutdown) | 3일 대기 없이 즉시 리소스 해제, 접속 시 자동 재시작 |
| 시스템 풀(`SYSTEM_COMPUTE_POOL_CPU`) 사용 | 전용 풀 생성 불필요, 앱 미사용 시 빈 노드 점유 없음 |
| `AUTO_SUSPEND_SECS`를 짧게 설정 | 모든 서비스 종료 후 빠르게 노드 해제 |

#### 배포 흐름

```
Workspace에서 코드 작성
     ↓ [Run] 버튼
Development App (본인만 보임)
     ↓ [Deploy] 버튼
배포 설정:
  ├── App title: 앱 이름
  ├── Location: Database.Schema (배포 위치)
  ├── Execution: Compute Pool + Query Warehouse
  ├── Network: External Access Integration (외부 API 호출 시)
  └── Sharing: 접근 권한 부여할 Role
     ↓
Deployed App (공개 URL)
```

#### Compute Pool 생성 (배포 시)

배포 시 Compute Pool을 지정해야 합니다. 시스템 제공 풀(`SYSTEM_COMPUTE_POOL_CPU`)을 사용할 수도 있지만, 교육용으로 별도 풀을 생성하려면 아래 SQL을 실행합니다.

```sql
CREATE COMPUTE POOL IF NOT EXISTS SF_COMPUTE_POOL
  MIN_NODES = 1
  MAX_NODES = 3
  INSTANCE_FAMILY = CPU_X64_XS
  AUTO_RESUME = TRUE
  AUTO_SUSPEND_SECS = 300;   -- 5분 비활동 시 노드 해제
```

| 파라미터 | 설명 |
|----------|------|
| `INSTANCE_FAMILY` | 머신 타입. `CPU_X64_XS`(최소) 권장 — Streamlit은 단일 프로세스로 실행되므로 다중 CPU 이점 없음 |
| `MIN_NODES / MAX_NODES` | MIN=1(최소 1노드 유지), MAX=3(앱 추가 생성 대비 여유). AUTO_SUSPEND_SECS와 함께 사용하여 비활동 시 노드 해제 |
| `AUTO_RESUME = TRUE` | 앱 접속 시 자동 재개 |
| `AUTO_SUSPEND_SECS = 300` | 5분 비활동 시 노드 해제 (비용 절감) |

> **시스템 풀 사용 시**: 별도 생성 없이 `SYSTEM_COMPUTE_POOL_CPU`를 선택하면 됩니다. 노드당 최대 3개 앱이 공유 실행되며, 전용 풀처럼 MIN_NODES를 유지할 필요가 없어 간편합니다. 단, 리소스를 다른 앱과 공유하므로 성능 변동이 있을 수 있습니다.

### 3.5 Workspace에서 Streamlit 앱 만들기

1. Snowsight → `Projects` → `Workspaces`
2. 기존 Workspace 선택 또는 `+` 로 새 Workspace 생성
3. Workspace 내에서 `+ Add new` → `Streamlit app` 선택
4. 앱 폴더 이름 입력 (예: `sf_dashboard`) → Enter
5. 자동으로 starter 파일이 생성됨 (`streamlit_app.py`, `pyproject.toml`, `snowflake.yml`) — `streamlit_app.py`에는 예제 코드가 미리 작성되어 있음
5. `Run` 버튼 → 우측에 미리보기 표시

### 3.6 배포하기

1. 프로젝트 패널 상단의 **Deploy** 클릭
2. 배포 설정:
   - **App title**: 앱 이름 입력 (좌측 하단 및 대시보드에 표시)
   - **App ID** (optional): URL에 사용될 식별자 (자동 생성됨, 필요 시 수정)
   - ☑ **Deployed app owner role matches the preview execution role**: 체크 시 배포된 앱이 현재 역할로 실행
3. **Execution** 탭:
   - **App location**: 데이터베이스 및 스키마 선택 (예: `SNOW_FASHION.ANALYTICS`)
   - **Compute pool**: 앱이 실행될 Compute Pool 선택 (예: `SF_COMPUTE_POOL` 또는 `SYSTEM_COMPUTE_POOL_CPU`)
   - **Query warehouse**: 앱의 SQL 쿼리가 실행될 Warehouse 선택 (예: `SF_WH`)
   - **Artifact repositories**: Python 라이브러리 저장소 (기본값 사용)
4. **Network** 탭 (선택):
   - 외부 인터넷 연결이 필요한 경우 External Access Integration 활성화
   - 교육에서는 변경 불필요
5. **Sharing** 탭 (선택):
   - 다른 역할에 앱 접근 권한 부여 (`Add role to share with`)
   - 배포 후에도 추가 가능
6. **Deploy** 클릭
7. 배포 완료 후 `Projects` → `Streamlit`에서 확인 가능

### 3.7 협업 모델

| 모델 | 설명 | 적합한 팀 |
|------|------|-----------|
| **Git-backed Workspace** | Git 리포지토리와 연동. Snowsight에서 직접 commit/push 가능 | Git에 익숙한 개발팀 |
| **Shared Workspace** | Git 없이 여러 사용자가 동일 Workspace에서 실시간 협업 | Git 없이 협업하는 팀 |

#### Git-backed Workspace 설정

**사전 준비 (관리자, ACCOUNTADMIN 권한 필요)**

```sql
-- 1. GitHub Personal Access Token을 Secret으로 저장
CREATE OR REPLACE SECRET my_db.my_schema.my_git_secret
  TYPE = password
  USERNAME = '<github_username>'
  PASSWORD = '<github_personal_access_token>';

-- 2. API Integration 생성 (GitHub의 경우)
CREATE OR REPLACE API INTEGRATION my_git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/<your_account>')
  ALLOWED_AUTHENTICATION_SECRETS = (my_db.my_schema.my_git_secret)
  ENABLED = TRUE;

-- 3. 사용 권한 부여
GRANT USAGE ON INTEGRATION my_git_api_integration TO ROLE <role>;
GRANT USAGE ON SECRET my_db.my_schema.my_git_secret TO ROLE <role>;
```

> **GitHub OAuth 방식 (더 간편)**: Snowflake GitHub App을 사용하면 Secret 없이도 연동 가능합니다.
> ```sql
> CREATE OR REPLACE API INTEGRATION my_git_api_integration
>   API_PROVIDER = git_https_api
>   API_ALLOWED_PREFIXES = ('https://github.com')
>   API_USER_AUTHENTICATION = (TYPE = SNOWFLAKE_GITHUB_APP)
>   ENABLED = TRUE;
> ```

**Workspace에서 Git 연동 (Snowsight UI)**

1. `Projects` → `Workspaces`
2. Workspaces 메뉴에서 **From Git repository** 선택
3. Repository URL 입력 (예: `https://github.com/my-user/my-repo`)
4. API Integration 선택 → 인증 방법 선택 (OAuth2 / Personal access token / Public repository)
5. **Create** 클릭

**워크플로우**

- 파일 변경 후 → 상단 **Changes** 탭 → 커밋 메시지 입력 → **Push**
- 원격 변경사항 가져오기 → **Pull**
- 브랜치 전환/생성 → Changes 탭 → 브랜치 드롭다운

#### Shared Workspace 설정

**사전 준비 (관리자)**

```sql
-- Workspace를 생성할 스키마에 권한 부여
GRANT USAGE ON DATABASE <database> TO ROLE <role>;
GRANT USAGE, CREATE WORKSPACE ON SCHEMA <database>.<schema> TO ROLE <role>;

-- 생성 후 다른 역할에 편집 권한 부여
GRANT WRITE ON WORKSPACE <workspace_name> TO ROLE <role>;
```

**Shared Workspace 생성 (Snowsight UI)**

1. `Projects` → `Workspaces`
2. Workspaces 메뉴에서 **Shared workspace** 선택
3. Workspace 이름 입력
4. 저장할 Database / Schema 선택
5. 공유할 Role 추가
6. **Create** 클릭

**협업 모델**: 파일 편집 시 자동으로 Draft 상태 → 변경사항을 **Publish** 해야 다른 사용자에게 반영됨

---

## Chapter 4. Snowsight CoCo로 Streamlit 리포트 생성

### 4.1 학습 목표
- CoCo에게 자연어로 Streamlit 앱을 만들어달라고 요청하는 과정 체험
- 한 번에 완벽한 앱을 만들기보다 **단계적으로 기능을 추가하는 반복 빌드 워크플로우** 실습
- 생성된 코드를 확인하고 배포하는 과정

### 4.2 데모 시나리오: 브랜드별 매출 대시보드

CoCo와 대화하며 4단계로 앱을 점진적으로 발전시킵니다.

```
Step 1: 데이터 테이블 → Step 2: 차트 추가 → Step 3: 필터 추가 → Step 4: 디자인 마무리 → Step 5: 배포
```

#### Step 1: Streamlit 앱 생성 — 데이터 테이블 먼저

> 가장 먼저 데이터가 제대로 조회되는지 확인합니다. 차트나 필터 없이 **테이블만** 보여주는 앱을 만듭니다.

1. Snowsight → `Projects` → `Workspaces` → Workspace 선택
2. `+ Add new` → `Streamlit app` → 앱 이름 입력 (예: `sales_dashboard`) → Enter
3. 자동 생성된 `streamlit_app.py` 파일이 열림 — **Ctrl+A** (macOS: Cmd+A) → **Delete** 키로 샘플 코드 전체 삭제
4. 우측 CoCo 패널에서 아래 프롬프트를 입력:

```
아래 조건에 맞는 Streamlit 앱을 streamlit_app.py에 작성해줘.

## 사전 작업
- 먼저 SHOW COLUMNS IN TABLE SNOW_FASHION.RAW.SALES_TRANSACTIONS 를 실행해서
  실제 컬럼명과 데이터 타입을 확인한 뒤, 아래 요구사항에 맞는 컬럼을 사용할 것

## 데이터 소스
- 테이블: SNOW_FASHION.RAW.SALES_TRANSACTIONS
- 필요한 컬럼 역할: 거래 일자(DATE 타입), 브랜드명(TEXT 타입), 매출 금액(NUMBER 타입)

## Snowflake 연결 방법
- st.connection("snowflake") 를 사용해 Snowflake에 연결할 것
- session = conn.session() 으로 Snowpark 세션 획득
- SQL 실행은 session.sql("...").to_pandas() 를 사용할 것
- USE WAREHOUSE, USE DATABASE, USE SCHEMA 구문은 쓰지 말 것
- 쿼리에서 테이블은 항상 fully qualified name
  (SNOW_FASHION.RAW.SALES_TRANSACTIONS) 을 사용할 것

## 집계 쿼리
- DATE_TRUNC('MONTH', <날짜컬럼>) AS MONTH 으로 월 단위 집계
- 브랜드별 월별 매출 합계: SUM(<매출컬럼>) AS TOTAL_SALES
- MONTH 컬럼은 pandas에서 pd.to_datetime()으로 변환
- 정렬: MONTH ASC, BRAND ASC

## 화면 구성
- st.title("브랜드별 매출 대시보드")
- 집계 결과를 st.dataframe으로 표시
- MONTH은 'YYYY-MM' 형식, TOTAL_SALES는 천 단위 구분 기호 포함

## 에러 처리
- 쿼리 실행 중 예외 발생 시: st.error(f"데이터 조회 실패: {e}") 표시
```

5. CoCo가 코드를 생성하면 **Run** 버튼으로 미리보기 — 테이블에 브랜드별 월별 매출이 잘 나오는지 확인

> **팁**: 첫 프롬프트에서 CoCo에게 **스키마를 직접 조회하도록 지시**하면 컬럼명 오류를 방지할 수 있습니다.

#### Step 2: 차트 추가

> 데이터가 잘 나오면, 시각화를 추가합니다.

CoCo에게 다음 프롬프트를 입력:

```
현재 앱에 차트를 추가해줘.

- 테이블 위에 브랜드별 월별 매출 추이 라인 차트 추가 (st.altair_chart 사용)
- X축: MONTH (yearmonth 형식, %Y-%m), Y축: TOTAL_SALES ("매출 (원)"), Color: BRAND
- 차트 제목: "브랜드별 월별 매출 추이"
- 범례 위치: 오른쪽
- use_container_width=True
- 기존 테이블은 차트 아래에 유지
```

**Run** 으로 확인 — 라인 차트에 4개 브랜드가 색상으로 구분되는지 확인

#### Step 3: 필터 추가

> 차트가 잘 되면, 사용자가 원하는 조건으로 필터링할 수 있게 합니다.

```
사이드바에 필터를 추가해줘.

## 필터 UI (st.sidebar)
1. 브랜드 멀티셀렉트
   - 데이터에서 브랜드 컬럼의 고유값을 조회해 선택지로 사용
   - 기본값: 전체 선택
2. 기간 선택 (시작일/종료일을 각각 st.date_input 으로 구성)
   - 기본 시작일: 데이터의 날짜 컬럼 최솟값
   - 기본 종료일: 데이터의 날짜 컬럼 최댓값

## 필터 적용
- SQL은 f-string으로 구성할 것 (Snowpark session.sql()은 named binding 미지원)
- 브랜드 목록이 비어 있으면 브랜드 필터를 WHERE 절에서 제외
- st.date_input은 datetime.date 객체를 반환하므로, .date()를 다시 호출하지 말 것.
  날짜를 문자열로 변환할 때는 str(date_value) 또는 date_value.strftime('%Y-%m-%d') 사용
- SQL에서 날짜는 TO_DATE('{date_str}') 형태로 변환
- 필터 결과가 0건이면 st.warning("조건에 해당하는 데이터가 없습니다.") 표시, 차트와 테이블은 렌더링하지 말 것

## 캐싱
- @st.cache_data 로 브랜드 목록 조회 결과 캐싱 (ttl=600)
- 집계 쿼리 결과도 @st.cache_data 로 캐싱 (필터값을 인자로 받는 함수로 분리)
```

**Run** 으로 확인 — 사이드바에서 브랜드/기간을 변경하면 차트와 테이블이 함께 업데이트되는지 확인

#### Step 4: 디자인 마무리

> 기본 기능이 완성되면, 디자인과 UX를 다듬습니다. 여러 수정을 한번에 요청합니다.

```
다음 사항을 한번에 수정해줘:
1. 차트 위에 브랜드별 총 매출 합계를 KPI 카드로 보여주는 섹션 추가
2. 차트 색상을 브랜드별로 지정 (TOP10=파란색, ZIOGIA=빨간색, OLDZEN=초록색, NG=주황색)
3. KPI 카드도 동일한 색상 적용
4. 화면 좌우 여백 최소화 (wide layout)
```

**Run** 으로 최종 형태 확인

#### Step 5: 배포

1. 에디터 상단의 **Deploy** 버튼 클릭
2. **Deploy app** 대화상자에서 설정:
   - **App title**: `Sales_dashboard` (앱 좌측 상단과 대시보드에 표시)
   - **App ID**: `SALES_DASHBOARD` (URL에 사용, 자동 생성됨)
   - **App location**: `SNOW_FASHION.PUBLIC` (Database/Schema 선택)
   - **Compute pool**: `SYSTEM_COMPUTE_POOL_CPU`
   - **Query warehouse**: `SF_WH` (앱의 SQL 쿼리가 실행될 웨어하우스)
   - **Artifact repositories**: 기본값 유지 (Snowflake 관리 저장소)

3. **Deploy** 클릭
4. 배포 완료 후 `Projects` → `Streamlit`에서 배포된 앱 확인

> **반복 빌드 패턴 정리**: 실무에서 CoCo를 사용할 때도 이 패턴이 효과적입니다.
> 1. **데이터 확인** — 테이블로 데이터가 맞는지 먼저 검증
> 2. **시각화** — 차트를 추가하여 트렌드 파악
> 3. **인터랙션** — 필터를 추가하여 탐색 가능하게
> 4. **디자인** — KPI 카드, 색상, 레이아웃 등 UX 마무리

### 4.3 Streamlit in Snowflake(SiS)의 한계

SiS는 Snowflake 내장 Streamlit 환경으로 빠른 데이터 시각화에 적합하지만, 본격적인 웹 앱 개발에는 한계가 있습니다.

| 영역 | SiS로 가능한 것 | SiS의 한계 | App Runtime으로 해결 가능? |
|------|------|----------------|---------|
| **UI** | Streamlit 기본 위젯 (차트, 테이블, 필터) | 커스텀 HTML/JS 컴포넌트, 자유로운 UI 디자인 | O — React/Next.js 기반 자유로운 UI 구현 |
| **구조** | 단일/멀티페이지 앱 (`st.navigation`, `pages/`) | 프론트엔드-백엔드 분리 아키텍처 | O — Next.js의 서버/클라이언트 컴포넌트 분리 |
| **데이터** | Snowflake 데이터 조회 | 외부 API 호출 (EAI 설정 필요) | △ — 외부 API 호출은 동일하게 EAI 설정 필요 |
| **인터랙션** | 필터/버튼 기반 단방향 조작 | 실시간 양방향 인터랙션, 폼 기반 데이터 입력/수정 | O — React 상태 관리, 폼/CRUD 자유롭게 구현 |
| **배포** | Snowflake 내부 사용자 공유 | 외부(비인증) 사용자 접근, 커스텀 도메인 | X — App Runtime도 Snowflake 인증 사용자만 접근 가능 |

> **이런 한계를 넘어서려면 → CoCo Desktop + App Runtime**을 활용합니다 (Chapter 5).

---

## Chapter 5. CoCo Desktop으로 App Runtime 앱 빌드

### 5.1 학습 목표
- App Runtime의 개념과 Streamlit 대비 장점 이해
- 로컬 프로젝트 기반 개발 방식과 Git을 활용한 팀 협업 모델 이해
- CoCo Desktop에서 자연어로 App Runtime 앱을 **단계적으로 빌드하고 배포**하는 과정 체험
- 각 Step마다 배포(`snow app deploy`)하여 실제 동작을 확인하는 반복 빌드 워크플로우 실습

### 5.2 App Runtime이란?

Snowflake App Runtime은 **Node.js(Next.js) 기반 웹 앱**을 Snowflake 내에서 빌드하고 배포하는 플랫폼입니다.

- CoCo CLI 또는 CoCo Desktop에서 자연어로 앱 생성
- `snow app deploy`로 Snowflake에 배포
- 별도의 Docker, CI/CD 파이프라인 불필요
- Snowflake 인증/RBAC을 그대로 상속

### 5.3 Streamlit vs App Runtime: 언제 무엇을 쓸까?

| 기준 | Streamlit | App Runtime |
|------|-----------|-------------|
| **언어** | Python | JavaScript/TypeScript (Next.js) |
| **UI 자유도** | 제한적 (Streamlit 위젯) | 높음 (React 컴포넌트, 단 Snowflake 보안 샌드박스 내) |
| **적합한 앱** | 대시보드, 데이터 탐색, 분석 도구 | 관리 포털, CRUD 앱, 복잡한 워크플로우 |
| **개발 속도** | 매우 빠름 (Python만으로) | 중간 (프론트엔드 지식 필요) |
| **멀티페이지** | 지원 (`st.navigation`, `pages/`) | Next.js 파일 기반 라우팅으로 자유롭게 구성 |
| **개발 환경** | Snowsight Workspace 또는 CoCo Desktop | CoCo Desktop 필수 (Snowsight CoCo 미지원) |
| **배포** | Workspace에서 Deploy 버튼 | `snow app deploy` |

#### App Runtime에서만 가능한 인터랙션

| 기능 | Streamlit | App Runtime |
|------|:-:|:-:|
| 인라인 데이터 편집 (셀 클릭 → 수정) | X | O |
| 실시간 검색 (입력 중 자동 필터링) | X | O |
| 키보드 단축키 | X | O |
| 탭 전환 시 페이지 리로드 없이 유지 | X | O |
| 커스텀 차트 (D3.js, Recharts 등) | 제한적 | O |

#### 선택 기준 요약

```
"대시보드나 리포트를 빠르게 만들고 싶다" → Streamlit
"데이터 입력/수정 폼이 필요하다"         → App Runtime
"복잡한 UI/UX가 필요하다"               → App Runtime
"프론트엔드 개발 경험이 없다"            → Streamlit
"사내 관리 포털을 만들고 싶다"           → App Runtime
```

### 5.4 App Runtime 리소스 구조

```
로컬 프로젝트 (Next.js)
     ↓ snow app deploy
┌─────────────────────────────────┐
│         Snowflake 내부           │
│                                  │
│  Upload → Build → Deploy         │
│                                  │
│  ┌──────────┐  ┌──────────────┐ │
│  │ Build    │  │ Application  │ │
│  │ (SPCS    │→│  Service     │ │
│  │  Job)    │  │ (런타임)     │ │
│  └──────────┘  └──────┬───────┘ │
│                       │          │
│              HTTPS 엔드포인트     │
│         *.snowflakecomputing.app │
└─────────────────────────────────┘
```

| 항목 | 설명 |
|------|------|
| **Upload** | 로컬 소스 파일을 Snowflake 내부 스테이지 또는 Workspace에 업로드 |
| **Build** | SPCS에서 `npm ci` + `npm run build` 실행. 빌드 완료 후 종료되는 임시 작업 |
| **Application Service** | 빌드 결과를 실행하는 장기 실행 서비스. HTTPS 엔드포인트 자동 생성 |
| **Artifact Repository** | 빌드된 패키지 버전을 저장 (immutable). 기본값: `<앱이름>_REPO` |
| **app.yml** | 배포 설정 파일 — 데이터베이스, 스키마, 웨어하우스, 인스턴스 수, install/build/run 명령 등 정의 |

### 5.5 프로젝트 관리와 협업

#### 5.5.1 로컬 프로젝트 구조

CoCo Desktop에서 `/snowflake-apps` 스킬로 앱을 생성하면 **로컬에 다음과 같은 프로젝트 폴더**가 만들어집니다:

```
my-snow-fashion-app/
├── app.yml              ← 앱 설정 (제목, 웨어하우스, 컴퓨트풀 등)
├── src/
│   ├── app/             ← Next.js 페이지 및 라우팅
│   ├── components/      ← 재사용 UI 컴포넌트
│   └── lib/             ← Snowflake 쿼리 등 유틸리티
├── public/              ← 정적 파일 (이미지, 아이콘)
├── package.json         ← 의존성 관리
└── ...
```

> **핵심**: 이 폴더는 일반적인 Next.js 프로젝트와 동일한 구조입니다. 별도의 Snowflake 전용 도구 없이도 로컬에서 코드를 확인하고 수정할 수 있습니다.

#### 5.5.2 개인 실습에서의 프로젝트 관리

- 로컬 폴더에서 소스 코드를 직접 열어 구조를 파악할 수 있음
- VS Code, WebStorm 등 **익숙한 IDE로 코드 탐색 및 직접 수정 가능**
- CoCo Desktop은 AI 기반 코드 생성, IDE는 세밀한 수동 편집 — 병행 활용
- `snow app deploy` 명령으로 Snowflake에 배포

> **Streamlit과의 차이**: Workspace의 Streamlit은 Snowsight 브라우저 내에서 코드를 편집합니다. App Runtime은 로컬 파일시스템에 프로젝트가 존재하므로, 익숙한 도구(IDE, 터미널 등)를 자유롭게 사용할 수 있습니다.

#### 5.5.3 팀 협업으로의 확장

실제 프로젝트에서는 로컬 프로젝트를 **Git 저장소로 관리**하여 팀 협업이 가능합니다:

```
[개인 실습 — 오늘]                  [팀 프로젝트 — 실무]
                                    
로컬 폴더                          원격 Git 저장소 (GitHub/GitLab)
  └─ CoCo Desktop으로 생성/수정        ↑ push / ↓ pull
  └─ snow app deploy               로컬 폴더 (git clone)
                                      └─ CoCo Desktop으로 생성/수정
   ↓ Git 초기화하면                    └─ feature 브랜치에서 작업
   바로 팀 프로젝트로 전환 가능          └─ PR 리뷰 → main 머지
                                      └─ CI/CD → snow app deploy 자동화
```

> **핵심**: 팀 프로젝트에서도 각 개발자의 **로컬 폴더는 그대로 존재**합니다. 차이점은 그 로컬 폴더가 Git 저장소의 클론(clone)이라는 것입니다. 개인 실습에서 만든 폴더에 `git init` → `git remote add`만 하면 바로 팀 프로젝트 구조로 전환할 수 있습니다.

**Git 연동 흐름**:
- **초기화**: `git init` → `git remote add origin <repo-url>` → `git push`
- **기존 저장소 참여**: `git clone <repo-url>` → 로컬에 프로젝트 폴더 생성 → CoCo Desktop에서 해당 폴더 열기
- **브랜치 전략**: feature 브랜치에서 개발 → main 머지 시 배포
- **코드 리뷰**: PR(Pull Request)을 통해 변경사항 검토 후 머지
- **CI/CD**: GitHub Actions 등으로 `snow app deploy` 자동화 가능

> **오늘 실습에서는** Git 설정 없이 로컬 폴더에서 직접 빌드/배포합니다. 실제 프로젝트에서는 위 워크플로우를 적용하면 팀 협업, 코드 리뷰, 자동 배포까지 자연스럽게 확장됩니다.

#### 5.5.4 Streamlit vs App Runtime: 프로젝트 관리 비교

| 항목 | Streamlit (Workspace) | App Runtime |
|------|----------------------|-------------|
| 코드 위치 | Snowsight 내 편집기 (Stage) | 로컬 프로젝트 폴더 |
| 코드 수정 | Snowsight 편집기 또는 파일 업로드 | 로컬 IDE + CoCo Desktop |
| 버전 관리 | Git-backed Workspace 또는 수동 백업 | Git 네이티브 (로컬 파일이므로 자연스럽게 적용) |
| 팀 협업 | Shared Workspace 또는 Git-backed Workspace | Git 워크플로우 (브랜치, PR, 리뷰) |
| CI/CD | 별도 구성 필요 | `snow app deploy` 기반 자동화 용이 |

### 5.6 데모: 운영 관리 포털 — 반복 빌드

CoCo Desktop에서 자연어로 App Runtime 앱을 **4단계로 점진적으로 발전**시킵니다. **각 Step마다 배포하여 실제 동작을 확인**합니다.

```
Step 1: 매출 대시보드 → 배포 → 확인
  ↓
Step 2: + 재고 현황 페이지 → 재배포 → 확인
  ↓
Step 3: + 발주 관리 페이지 → 재배포 → 확인
  ↓
Step 4: UI 마무리 → 재배포 → 최종 확인
```

> **참고**: App Runtime은 Snowflake 내부에서 실행되므로, 로컬 환경에서는 Snowflake 데이터에 접근할 수 없습니다. `npm run dev`로 로컬 서버를 띄워도 데이터 연결이 되지 않으므로, 코드 변경 후 반드시 **배포(`snow app deploy`)하여 실제 동작을 확인**합니다. 재배포 시 기존 앱이 업데이트됩니다.

#### Step 1: 프로젝트 생성 + 매출 대시보드

1. CoCo Desktop 실행
2. `File` → `Open Folder` → 1부에서 사용한 `snow-fashion-cortex-hands-on-main` 폴더 선택 → 열기
3. CoCo Desktop 채팅에서 `/snowflake-apps` 스킬을 호출하여 앱 생성:

```
/snowflake-apps

SNOW_FASHION.RAW 스키마의 데이터를 활용한 스노우패션 운영 관리 포털을 만들어줘.
우선 첫 번째 페이지 "매출 대시보드"만 만들자.

## 주의사항
- 로컬에서 npm run dev 또는 localhost로 테스트하지 말 것. App Runtime 앱은 Snowflake에 배포해야만 데이터 접근이 가능함
- 코드 작성이 완료되면 바로 snow app deploy로 배포할 것

## 사전 작업
- 먼저 SHOW TABLES IN SCHEMA SNOW_FASHION.RAW 을 실행해서 어떤 테이블이 있는지 확인할 것
- STORES, SALES_TRANSACTIONS 테이블의 컬럼을 SHOW COLUMNS 로 조회할 것
- 조회한 컬럼명과 타입을 기반으로 코드에 적용할 것

## Snowflake 연결
- 서버 컴포넌트에서 Snowflake SDK를 사용해 쿼리 실행
- 테이블은 항상 fully qualified name (SNOW_FASHION.RAW.테이블명) 사용
- SF_WH 웨어하우스를 사용

## 페이지: 매출 대시보드
- 상단 KPI 카드 4개 (카드마다 배경색 구분): 총 매출, 거래 건수, 평균 거래 단가, 활성 매장 수
- 차트 영역 (가로 2열):
  - 브랜드별 매출 막대 차트 (Bar Chart)
  - 월별 매출 추이 선 차트 (Line Chart), 브랜드별 선 색상 구분
- 하단: 매장별 상세 테이블 (STORES JOIN, 정렬/검색 가능)
- 차트: recharts 사용
- 숫자: 천 단위 구분 기호
```

4. CoCo가 프로젝트를 생성하면, **`snow-fashion-cortex-hands-on-main` 폴더 하위에 앱 파일이 생성된 것을 확인** — 좌측 파일 탐색기에서 `app.yml`, `src/` 등 구조를 살펴봅니다.

5. **배포 및 확인**: CoCo에게 요청합니다:

```
이 앱을 Snowflake에 배포하고, 브라우저에서 열어서 확인해줘
```

6. CoCo Desktop이 배포를 완료하면 **내장 브라우저에서 앱을 바로 열어줍니다**. KPI 카드, 차트, 테이블이 실제 데이터로 표시되는지 확인합니다.

> **참고**: 배포된 앱은 `*.snowflakecomputing.app` URL로 접근 가능합니다. CoCo Desktop의 내장 브라우저뿐 아니라 외부 브라우저에서도 동일한 URL로 접속할 수 있습니다.

#### Step 2: 재고 현황 페이지 추가

```
두 번째 페이지 "재고 현황"을 추가해줘.

## 사전 작업
- INVENTORY_SNAPSHOT, STORES 테이블의 컬럼을 SHOW COLUMNS 로 조회하여 확인할 것

## 페이지: 재고 현황
- KPI 카드: 전체 SKU 수, 재고 부족 항목 수(빨간색 강조), 입고 대기 수량
- 도넛 차트: 재고 STATUS별 비율
- 재고 부족 알림 테이블:
  - ON_HAND_QTY < REORDER_POINT 인 항목 조회
  - STORES와 JOIN하여 매장명, 브랜드 표시
  - 부족 수량이 큰 순서로 정렬, 부족 수량 셀은 빨간색 텍스트
  - 행 클릭 시 해당 SKU의 최근 입고 이력을 펼쳐서 표시
```

**재배포 및 확인**:
```
수정된 앱을 다시 배포하고, 브라우저에서 열어서 확인해줘
```

내장 브라우저에서 재고 현황 페이지로 이동하여 도넛 차트와 부족 알림 테이블이 정상 동작하는지 확인

#### Step 3: 발주 관리 페이지 추가

```
세 번째 페이지 "발주 관리"를 추가해줘.

## 사전 작업
- SUPPLY_ORDERS, SHIPMENTS 테이블의 컬럼을 SHOW COLUMNS 로 조회하여 확인할 것

## 페이지: 발주 관리
- KPI 카드: 진행중 발주 건수, 이번 달 발주 총액, 지연 발주 건수(빨간색)
- 발주 상태 분포 가로 막대 차트 (STATUS별 건수)
- 발주 목록 테이블:
  - 필터: STATUS 드롭다운 + 브랜드 드롭다운
  - 상태별 뱃지 색상 구분 (완료=초록, 진행중=파랑, 지연=빨강)
  - 행 클릭 시 해당 발주의 배송 상태(SHIPMENTS JOIN)를 펼쳐서 표시
```

**재배포 및 확인**:
```
수정된 앱을 다시 배포하고, 브라우저에서 열어서 확인해줘
```

발주 관리 페이지에서 상태별 뱃지, 필터, 행 클릭 동작 확인

#### Step 4: 마무리

```
전체 앱을 다듬어줘:
1. 앱 제목 "스노우패션 운영 관리 포털"
2. 3개 페이지 간 네비게이션 일관성 확인
3. 로딩 스피너 추가
4. 좌우 여백 최소화

```

**재배포 및 최종 확인**:
```
다시 배포하고, 브라우저에서 열어서 확인해줘
```

3개 페이지를 순서대로 확인하며 전체 앱이 의도한 대로 동작하는지 점검

> **반복 빌드 패턴 정리**: Chapter 4(Streamlit)에서와 마찬가지로, 한 번에 모든 것을 만들지 않고 **핵심 기능 → 페이지 확장 → UI 마무리** 순서로 점진적으로 발전시킵니다. App Runtime에서는 각 Step마다 배포하여 실제 데이터 연동을 확인하는 것이 핵심입니다.

---

## 부록

### A. 정리: 어떤 도구를 언제 쓸 것인가

#### 전체 도구 맵

```
┌─────────────────────────────────────────────────┐
│              스노우패션 AI 플랫폼 도구 맵            │
│                                                   │
│  ┌─── 데이터 분석 ────────────────────────────┐  │
│  │ Cowork: 현업 담당자가 자연어로 데이터 질의   │  │
│  │ Agent: 정형(Analyst) + 비정형(Search) 통합   │  │
│  │ Semantic View: 데이터의 비즈니스 의미 정의    │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  ┌─── 앱 개발 ────────────────────────────────┐  │
│  │ Streamlit: 빠른 대시보드/리포트              │  │
│  │   → Snowsight CoCo + Workspace              │  │
│  │ App Runtime: 본격적인 웹 앱                  │  │
│  │   → CoCo Desktop + snow app deploy          │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  ┌─── AI 코딩 에이전트 ───────────────────────┐  │
│  │ Snowsight CoCo: 브라우저에서 빠르게          │  │
│  │ CoCo Desktop: 본격적인 프로젝트              │  │
│  │ CoCo CLI: 자동화/CI/CD                      │  │
│  └────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

#### 역할별 추천 도구

| 역할 | 주요 도구 | 보조 도구 |
|------|-----------|-----------|
| **현업 담당자** (MD, 마케팅) | Cowork | — |
| **데이터 분석가** | Cowork + Snowsight CoCo | CoCo Desktop |
| **데이터 엔지니어** | CoCo Desktop + CLI | Snowsight CoCo |
| **앱 개발자** | CoCo Desktop | Snowsight Workspace |
| **팀 리더** | Cowork (오토메이션) | Snowsight CoCo |

#### 1부 + 2부 전체 워크플로우

```
1. 데이터 모델링과 시맨틱 레이어 설계                     ← 1부 Ch2
   ↓
2. Semantic View 생성과 고도화                            ← 1부 Ch3
   ↓
3. Agent 생성과 기본 동작                                 ← 1부 Ch4
   ↓
4. 데이터 사전 구축과 Agent 정확도 향상                    ← 1부 Ch5
   ↓
5. 고객 VOC Search와 Agent 기능 확장                      ← 1부 Ch6
   ↓
6. Cowork에서 현업 사용                                   ← 1부 Ch7
   ↓
7. 멀티 도메인 오케스트레이션                              ← 1부 Ch8
   ↓
8. 반복 개선, 모니터링, 비용 관리                          ← 1부 Ch9
   ↓
9. 대시보드/리포트 (Streamlit)                            ← 2부 Ch4
   ↓
10. 관리 포털/고급 앱 (App Runtime)                       ← 2부 Ch5
```

### B. CoCo Desktop 고급 기능

| 기능 | 설명 |
|------|------|
| **Subagent** | 여러 작업을 병렬로 실행 (예: "파일 3개를 동시에 수정해줘") |
| **Plan Mode** | 복잡한 작업 전 계획을 먼저 세우고 확인 후 실행 |
| **스킬** | `/snowflake-apps`, `/sql-author` 등 특화된 워크플로우 |
| **플러그인** | MCP 서버 연동, 외부 도구 통합 |
| **Memory** | 프로젝트 컨텍스트를 기억하여 일관성 유지 |
| **#멘션** | `#SNOW_FASHION.RAW.SALES_TRANSACTIONS` 으로 테이블 참조 (Desktop에서는 `#`, Snowsight에서는 `@`) |

### C. 참고 자료

| 주제 | 문서 |
|------|------|
| Snowsight CoCo | <a href="https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight" target="_blank">CoCo in Snowsight</a> |
| CoCo CLI | <a href="https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-cli" target="_blank">CoCo CLI</a> |
| CoCo Desktop | <a href="https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-desktop" target="_blank">CoCo Desktop</a> |
| Streamlit in Workspaces | <a href="https://docs.snowflake.com/en/developer-guide/streamlit/streamlit-in-workspaces/streamlit-in-workspaces-overview" target="_blank">Streamlit in Snowflake in Workspaces</a> |
| App Runtime | <a href="https://docs.snowflake.com/en/developer-guide/snowflake-app-runtime/about-snowflake-app-runtime" target="_blank">Snowflake App Runtime</a> |
| app.yml 설정 | <a href="https://docs.snowflake.com/en/developer-guide/snowflake-app-runtime/app-yml" target="_blank">app.yml manifest for Snowflake App Runtime</a> |

---

*교안 버전: v1.0 (초안)*  
*작성일: 2026-09-04*  
*대상 고객: 스노우패션*
