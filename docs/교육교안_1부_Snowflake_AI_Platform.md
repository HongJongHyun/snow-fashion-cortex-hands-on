# 스노우패션 Snowflake AI Platform 교육 교안 (1부)

> **대상**: 스노우패션 데이터/IT 담당자  
> **환경**: Snowsight + CoCo (Snowsight 내장)  
> **데이터**: SNOW_FASHION 데이터베이스 (TOPTEN, ZIOZIA, OLZEN, ANDZ 4개 브랜드)  
> **교육용 리소스 네이밍**: 모두 `EDU_` 접두사 (기존 데모용 리소스와 구분)  
> **2부 예고**: CoCo Desktop을 활용한 Streamlit / Snowflake App Runtime 빌드 (별도 세션)

---

## 목차

| Chapter | 제목 | 형식 | 예상 시간 |
|---------|------|------|-----------|
| 1 | Snowflake Cortex AI 플랫폼 개요 | 슬라이드 | 20분 |
| 2 | 데이터 모델링과 시맨틱 레이어 설계 | 슬라이드 + 화면 | 15분 |
| 3 | Semantic View 생성과 고도화 | 라이브 데모 | 40분 |
| 4 | 데이터 사전(Data Dictionary) 구축과 Search 활용 | 라이브 데모 | 30분 |
| 5 | 고객 VOC Search Service 구축 | 라이브 데모 | 20분 |
| 6 | Cortex Agent 생성과 도구 연결 | 라이브 데모 | 30분 |
| 7 | Snowflake Cowork (Intelligence) 활용 | 데모 + 체험 | 25분 |
| 8 | 멀티 도메인 오케스트레이션 | 라이브 데모 | 25분 |
| 9 | Snowsight CoCo로 반복 개선 | 라이브 데모 | 15분 |
| 10 | 모니터링, 피드백, 비용 관리 | 슬라이드 + 데모 | 20분 |

---

## 사전 준비: 데이터 환경 구축

본 교육에 앞서 데이터 환경을 구축합니다.

1. <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/archive/refs/heads/main.zip" target="_blank">교육 자료 전체 다운로드 (ZIP)</a>를 클릭하여 파일을 받고 압축을 해제합니다.
2. `scripts/00_setup_db.sql`을 Snowsight 워크시트에서 실행하여 Database, Schema, Warehouse, Table, Stage를 생성합니다.
3. Snowsight 좌측 메뉴 `Catalog` → `Data Explorer` → `SNOW_FASHION` → `RAW` → `Stages` → `LOAD_STAGE`를 선택한 뒤, `+ Files` 버튼을 클릭하여 `data/` 폴더의 `.csv.gz` 파일 12개를 업로드합니다.
4. `scripts/02_load_data.sql`을 Snowsight 워크시트에서 실행하여 Stage의 데이터를 테이블에 적재합니다.

> Snowflake CLI를 사용할 수 있는 환경이라면 `scripts/01_put_csv.sql`로 파일 업로드를 일괄 처리할 수도 있습니다.

> 상세한 절차는 부록 B의 "데이터 환경 구축" 섹션을 참고하세요.

---

## Chapter 1. Snowflake Cortex AI 플랫폼 개요

### 1.1 학습 목표
- Cortex Analyst, Cortex Search, Cortex Agent의 역할과 차이점 이해
- 각 서비스가 어떤 데이터 유형에 적합한지 판단할 수 있다
- Snowflake Intelligence(Cowork)에서 이들이 어떻게 통합되는지 이해

### 1.2 핵심 개념

#### Cortex Analyst (정형 데이터 → SQL)
- **역할**: 자연어 질문을 SQL로 변환하여 정형 데이터를 조회
- **기반**: Semantic View (시맨틱 뷰)
- **예시**: "지난 분기 TOPTEN 브랜드의 월별 매출 추이를 보여줘"
- **내부 동작**: 질문 → Semantic View의 메타데이터 참조 → SQL 생성 → 실행 → 결과 반환

#### Cortex Search (비정형 데이터 → RAG 검색)
- **역할**: 텍스트 데이터에서 **의미 기반 검색** (키워드 매칭이 아닌 벡터 유사도)
- **기반**: Cortex Search Service (자동 인덱싱)
- **활용 1 - VOC 검색**: "보풀 관련 불만 리뷰가 어떤 브랜드에 많아?"
- **활용 2 - 데이터 사전 검색**: "객단가가 뭐야?" → Agent가 정확한 컬럼/계산식을 파악
- **내부 동작**: 질문 → 벡터 + 키워드 하이브리드 검색 → 관련 문서 반환

#### Cortex Agent (오케스트레이션)
- **역할**: 사용자의 질문을 분석하고, 적절한 도구(Analyst/Search/Custom)를 선택하여 답변
- **핵심 루프**: `Plan → Use Tools → Reflect`
- **예시**: "TOPTEN 매출이 떨어진 원인을 분석해줘" → Agent가 매출 데이터(Analyst) + 고객 리뷰(Search)를 조합

#### Snowflake Cowork (Intelligence)
- **역할**: 비즈니스 사용자를 위한 채팅 인터페이스
- **특징**: Agent를 연결하면 SQL을 모르는 현업 담당자도 데이터 조회 가능
- **부가 기능**: 오토메이션, 아티팩트 공유, 회사 로고 커스터마이징

### 1.3 아키텍처 다이어그램

```
[Snowflake Cowork / REST API]
         │
    ┌────▼────┐
    │ Cortex  │  ← Plan → Use Tools → Reflect 루프
    │  Agent  │
    └────┬────┘
         │
    ┌────┼────────────┬──────────────┬──────────────┬──────────────┐
    ▼    ▼            ▼              ▼              ▼              ▼
 Analyst #1     Analyst #2     Search #1        Search #2      Custom Tool
 (매출 SV)     (SCM SV)       (데이터사전)     (VOC 검색)     (예측 모델)
    │              │              │              │              │
    ▼              ▼              ▼              ▼              ▼
 매출·고객·      재고·발주·     컬럼 설명      리뷰 텍스트    Stored
 상품·매장       배송 테이블    비즈니스 용어   (10만건)       Procedure
```

> **핵심 포인트**: Search는 "문서 검색"만이 아니라 "데이터 사전 검색"으로도 활용됩니다.
> Agent가 현업 용어("객단가", "평효율")를 데이터 사전에서 먼저 검색한 후,
> 올바른 컬럼과 계산식을 파악하여 Analyst에게 정확한 SQL 생성을 유도합니다.

### 1.4 스노우패션 데이터 소개

| 테이블 | 건수 | 설명 |
|--------|------|------|
| SALES_TRANSACTIONS | 2,506,622 | 매출 거래 (2024.01~2025.12) |
| PRODUCTS | 5,000 | 4개 브랜드 SKU 마스터 |
| STORES | 300 | 매장 정보 (TOPTEN 200 + ZIOZIA 40 + OLZEN 35 + ANDZ 25) |
| CUSTOMERS | 500,000 | 고객 마스터 (연령/성별/지역/멤버십) |
| INVENTORY_SNAPSHOT | 780,000 | 일별 재고 스냅샷 (2025년) |
| PRODUCT_REVIEWS | 100,000 | 한국어 리뷰 텍스트 |
| REVIEW_TEMPLATES | 43 | 리뷰 생성 템플릿 |
| VENDORS | 15 | 협력업체 |
| SUPPLY_ORDERS | 20,000 | 발주 오더 |
| SHIPMENTS | 18,064 | 배송/입고 이력 |
| DEMAND_FORECAST | 160 | 수요 예측 데이터 |
| WEEKLY_DEMAND | 2,060 | 주간 수요 집계 |

#### Snowsight CoCo로 데이터 탐색해보기

> Snowsight의 CoCo(Cortex Code)를 사용하면 SQL을 직접 작성하지 않아도 자연어로 데이터를 탐색할 수 있습니다.
> 아래 순서대로 따라 해보세요.

**Step 1: Snowsight에서 CoCo 열기**
1. Snowsight 화면 우측 하단의 **CoCo 아이콘** 클릭하여 채팅 패널 열기
2. 컨텍스트 설정: Database = `SNOW_FASHION`, Schema = `RAW`, Warehouse = `SF_WH`

**Step 2: 자연어로 데이터 구조 탐색**

```
CoCo에게: "SNOW_FASHION.RAW 스키마에 어떤 테이블들이 있는지 보여줘"
→ CoCo가 SHOW TABLES 또는 INFORMATION_SCHEMA 쿼리를 생성하여 테이블 목록 표시
```

```
CoCo에게: "SALES_TRANSACTIONS 테이블의 컬럼 구조를 알려줘"
→ DESCRIBE TABLE 쿼리 생성 → 컬럼명, 데이터타입 확인
```

```
CoCo에게: "SALES_TRANSACTIONS에서 브랜드별 매출 건수를 보여줘"
→ SELECT BRAND, COUNT(*) FROM SALES_TRANSACTIONS GROUP BY BRAND 생성
→ TOPTEN 94만건, ZIOZIA 65만건, OLZEN 53만건, ANDZ 39만건
```

```
CoCo에게: "PRODUCT_REVIEWS 테이블에서 리뷰 텍스트 샘플 5건을 보여줘"
→ SELECT * FROM PRODUCT_REVIEWS LIMIT 5 생성 → 한국어 리뷰 텍스트 확인
```

> **참고**: 이 단계에서는 Semantic View나 Agent 없이, CoCo가 테이블 구조를 직접 참조하여 SQL을 생성합니다.
> Chapter 3 이후에 Semantic View를 만들면 더 정확하고 풍부한 분석이 가능해집니다.

### 1.5 교육에서 생성할 리소스 미리보기

| 리소스 | 이름 | 유형 |
|--------|------|------|
| 매출 Semantic View | `EDU_SALES_SV` | Semantic View |
| SCM Semantic View | `EDU_SCM_SV` | Semantic View |
| 데이터 사전 테이블 | `EDU_DATA_DICTIONARY` | Table |
| 데이터 사전 검색 | `EDU_DICT_SEARCH` | Cortex Search Service |
| VOC 검색 | `EDU_VOC_SEARCH` | Cortex Search Service |
| 매출 분석 Agent | `EDU_SALES_AGENT` | Agent |
| 통합 분석 Agent | `EDU_UNIFIED_AGENT` | Agent |

> 교육에서 생성한 `EDU_` 접두사 리소스만 대상이며, 기존 데이터 테이블은 삭제하지 않습니다.

---

## Chapter 2. 데이터 모델링과 시맨틱 레이어 설계

### 2.1 학습 목표
- Semantic View를 만들기 전 데이터 모델링 설계의 중요성 이해
- 도메인별 시맨틱 레이어 분리 전략 수립
- 데이터 사전의 역할과 Search 연동 구조 이해

### 2.2 왜 시맨틱 레이어가 필요한가?

**문제**: LLM에게 "TOPTEN 매출 알려줘"라고 하면...
- 어떤 테이블을 써야 하는지 모름
- BRAND 컬럼 값이 'TOPTEN'인지 'topten'인지 모름
- SALE_AMOUNT가 VAT 포함인지 모름
- 테이블 간 JOIN 관계를 모름

**해결**: Semantic View + 데이터 사전이 이 모든 메타데이터를 제공

```
┌──────────────────────────────────────────────────────────┐
│                 Semantic View                            │
│  ┌──────┐  ┌──────────┐  ┌──────────────┐               │
│  │Table │  │Dimension │  │ Relationship │               │
│  │정의  │  │Fact 정의  │  │   JOIN 정의  │               │
│  └──────┘  └──────────┘  └──────────────┘               │
│  ┌──────────┐  ┌───────────────────────┐                │
│  │  Metric  │  │   Verified Query      │                │
│  │  정의    │  │   (검증된 쿼리)        │                │
│  └──────────┘  └───────────────────────┘                │
└──────────────────────────────────────────────────────────┘
                            +
┌──────────────────────────────────────────────────────────┐
│              데이터 사전 (Cortex Search)                   │
│  ┌─────────────┐  ┌───────────────┐  ┌───────────────┐  │
│  │ 컬럼 설명    │  │ 비즈니스 용어  │  │ 고유값/범위   │  │
│  │ (한국어)     │  │ 동의어 매핑    │  │ 허용값 목록   │  │
│  └─────────────┘  └───────────────┘  └───────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 2.3 데이터 사전이 필요한 이유

**시나리오**: 현업 담당자가 "객단가 추이를 보여줘"라고 질문

| 없을 때 | 있을 때 |
|---------|---------|
| LLM이 "객단가"를 모름 | Agent가 데이터 사전을 검색 |
| UNIT_PRICE를 쓸지, AVG(SALE_AMOUNT)를 쓸지 모호 | "객단가 = AVG(SALE_AMOUNT), 건당 평균 결제 금액" 확인 |
| 부정확한 SQL 생성 | 정확한 계산식으로 Analyst에 전달 |

**데이터 사전이 커버하는 것:**
- 테이블/컬럼의 한국어 설명
- 비즈니스 용어 → 컬럼/계산식 매핑 (예: "객단가" → `AVG(SALE_AMOUNT)`)
- 컬럼의 허용값 목록 (예: BRAND → TOPTEN, ZIOZIA, OLZEN, ANDZ)
- 도메인 컨텍스트 (브랜드 특성, 시즌 구분 등)

### 2.4 도메인별 시맨틱 뷰 분리 전략

| 도메인 | Semantic View | 포함 테이블 | 주요 분석 |
|--------|---------------|-------------|-----------|
| 매출 분석 | `EDU_SALES_SV` | SALES_TRANSACTIONS, PRODUCTS, CUSTOMERS, STORES | 브랜드별·채널별·지역별 매출 |
| SCM 분석 | `EDU_SCM_SV` | INVENTORY_SNAPSHOT, SUPPLY_ORDERS, SHIPMENTS, VENDORS | 재고, 발주, 배송 |

| Cortex Search | 대상 | 역할 |
|---------------|------|------|
| `EDU_DICT_SEARCH` | 데이터 사전 테이블 | 비즈니스 용어 해석, 컬럼 설명 검색 |
| `EDU_VOC_SEARCH` | PRODUCT_REVIEWS | 고객 VOC 의미 검색 |

### 2.5 ER 다이어그램 (핵심 관계)

```
CUSTOMERS ──────┐
  (CUSTOMER_ID) │
                ▼ many_to_one
         SALES_TRANSACTIONS ◄── PRODUCTS
           (TXN_ID)              (SKU_ID)
                │
                ▼ many_to_one
              STORES
           (STORE_ID)

VENDORS ──────┐
  (VENDOR_ID) │
              ▼
        SUPPLY_ORDERS ──► SHIPMENTS
          (ORDER_ID)      (ORDER_ID)
              │
              ▼
           PRODUCTS
           (SKU_ID)
```

## Chapter 3. Semantic View 생성과 고도화

### 3.1 학습 목표
- Snowsight에서 Semantic View를 처음부터 생성하는 과정 실습
- Autopilot이 자동 설정하는 항목과 수동 보완 항목 구분
- Metric, Verified Query, Description 추가로 정확도 높이기
- Snowsight CoCo를 활용한 반복 개선 프로세스 이해

### 3.2 Step 1: 매출 분석용 Semantic View 생성 (Autopilot)

> **데모**: Snowsight에서 `EDU_SALES_SV`를 새로 만드는 과정을 보여줍니다.

#### 3.2.1 생성 경로
1. Snowsight 좌측 메뉴 → `AI & ML` → `Cortex Analyst` → **Semantic views** 탭
2. 우측 상단 `Create with Autopilot` 클릭
3. **Provide context** 단계: 기존 SQL 쿼리나 Tableau/Power BI 파일을 업로드하여 Autopilot의 정확도를 높일 수 있지만, 이번 교육에서는 우측 하단 `Skip` 클릭하여 건너뜁니다.
4. **Name your semantic view**:
   - **Name**: `EDU_SALES_SV`
   - **Select how you want to create the semantic object**: `Semantic view` (Recommended) 선택
   - **Database**: `SNOW_FASHION`, **Schema**: `SEMANTIC` 선택
   - `Next` 클릭
5. **Select tables**: 대상 테이블 추가:
   - `SNOW_FASHION.RAW.SALES_TRANSACTIONS`
   - `SNOW_FASHION.RAW.PRODUCTS`
   - `SNOW_FASHION.RAW.CUSTOMERS`
   - `SNOW_FASHION.RAW.STORES`
   - `Next` 클릭
6. **Select columns**: 분석에 필요한 컬럼만 선택합니다.
   - 화면 안내: *"Select only the columns required to define relationships or answer business questions"*
   - 하단의 **Add sample values** 체크 (실제 데이터 값을 참고하여 Autopilot 정확도 향상)
   - 하단의 **Add descriptions** 체크 (AI가 컬럼 설명을 자동 생성)
   - 이번 교육에서는 `Select all`로 전체 선택 (47개 컬럼)
   - 우측 하단 `Create` 클릭 → Autopilot이 Dimension/Fact 분류, Relationship 추론, Description 생성을 자동으로 수행합니다. 완료까지 잠시 시간이 걸릴 수 있습니다.

> **Semantic View 설계 베스트 프랙티스** (출처: <a href="https://docs.snowflake.com/en/user-guide/views-semantic/best-practices-modeling" target="_blank">Best practices for modeling semantic views</a>)
> 
> UI에서 안내하듯이, 모든 컬럼을 넣는 것보다 **분석에 필요한 컬럼만** 선택하는 것이 좋습니다.
> 
> | 항목 | 권장 | 이유 |
> |------|------|------|
> | **테이블 수** | PoC는 5~10개로 시작, 이후 확장 | Snowflake 공식 가이드: "begin with 5–10 tables for an initial proof of concept". 테이블 수에 hard limit은 없으며, 실 운영 환경에서는 더 많이 사용 가능 |
> | **전체 크기** | 약 100,000 토큰 이내 | 이 범위를 넘으면 LLM 컨텍스트 윈도우에서 pruning이 발생하여 응답 품질 저하 가능 (hard limit 아닌 가이드라인) |
> | **컬럼 선택** | 비즈니스 질문에 필요한 컬럼만 | 공식 가이드: "Include only business-relevant columns. Will my end users ask about this?" |
> | **제외 대상** | 시스템 컬럼 (CREATED_AT 등), 내부 ID | 분석에 쓰이지 않는 노이즈 제거 |
> | **포함 필수** | PK/FK (관계 정의용), 핵심 Fact, 자주 필터하는 Dimension | 관계 정의와 분석의 기본 |
> | **분리 기준** | 비즈니스 도메인별 (Sales, SCM 등) | 공식 가이드: "split by use case rather than by data structure" |
> 
> 이번 교육에서는 4개 테이블에 약 40개 컬럼(전체 선택)으로 진행합니다.
> 실무에서는 PRODUCTS의 CREATED_AT 같은 시스템 컬럼은 제외하는 것이 좋습니다.

#### 3.2.2 Autopilot 생성 결과 확인

Autopilot이 완료되면 Semantic View 편집 화면이 열립니다. 화면 구성:

**좌측 (현재 모델)**:
- **Facts**: Autopilot이 자동 분류한 Fact 컬럼
- **Named Filters**: 0개 (수동 추가 필요)
- **Metrics**: 0개 (수동 추가 필요)
- **Derived metrics**: 0개
- **Relationships**: Autopilot이 컬럼명 매칭으로 자동 추론 (예: SALES_TRANSACTIONS → PRODUCTS via SKU_ID)
- **Verified queries**: **0개** — 컨텍스트를 Skip했으므로 VQR은 자동 등록되지 않습니다 (SQL/BI 컨텍스트 업로드 시에만 자동 추가)

**우측 Suggestions 패널** (핵심):
- Autopilot이 자동 등록하지 않은 항목들을 **추천(Suggestions)** 으로 제안합니다
- 예: Verified queries 19개, Metrics 10개, Filters 10개, Relationships 1개 등
- 각 추천을 클릭하여 `Add verified query` / `Accept` / `Edit` / `Dismiss` 선택 가능
- **추천은 자동 적용되지 않으며, 반드시 리뷰 후 수동으로 추가해야 합니다**

> **Suggestions의 출처** (출처: <a href="https://docs.snowflake.com/en/user-guide/views-semantic/verified-query-suggestions" target="_blank">Suggestions for semantic models and views</a>)
> 
> | 출처 | 설명 |
> |------|------|
> | **Query history** | 해당 테이블에 대한 기존 SQL 실행 이력 분석 → 자주 사용되는 패턴을 VQR/Metric/Filter로 추천 |
> | **Usage data** | Cortex Analyst/Agent/Cowork에서 사용자들이 자주 묻는 질문 분석 → VQR 추천 |
> | **Optimization** | 기존 VQR을 분석하여 일반화 가능한 Metric/Filter/Description 추천 |
> 
> 처음 생성 시에는 Query history 기반 추천이 주로 나오며, 운영하면서 사용자 질문이 쌓이면 Usage data 기반 추천이 추가됩니다.

#### 3.2.3 Suggestions에서 추천 항목 추가하기

> 먼저 Suggestions 패널에서 유용한 추천을 몇 개 선택하여 추가해 봅니다.

1. 우측 **Suggestions** 패널에서 **Verified queries** 섹션 확인
2. 추천된 VQR 중 유용한 것을 클릭 → `Add verified query` 선택
3. SQL을 확인하고 필요하면 수정 후 저장
4. **Metrics** 섹션에서도 유용한 추천을 `Accept`로 추가
5. 상단 `Save` 클릭

> **팁**: 처음에는 Suggestions에서 추천하는 항목을 받아들이면서 시작하고,
> 이후 비즈니스 맥락에 맞는 항목을 수동으로 추가하는 것이 효율적입니다.

#### 3.2.4 Autopilot이 잘 하는 것과 못하는 것

| 항목 | Autopilot이 처리 | 수동 보완 필요 |
|------|:-:|:-:|
| DATE/TIMESTAMP → Time Dimension | O | |
| VARCHAR → Dimension | O | |
| 컬럼명 매칭으로 Relationship 추론 | O | |
| 기본 VQR 자동 생성 | | **X** (SQL/BI 컨텍스트 업로드 시에만 자동 추가) |
| **NUMBER를 Fact vs Dimension 구분** | | **X** (아래 상세) |
| **커스텀 Metric 정의** | | **X** |
| **한국어 Description** | | **X** |
| **비즈니스 맥락의 VQR** | | **X** |
| **컬럼 고유값 설명** | | **X** |

### 3.3 Step 2: Autopilot 결과 검토 및 수정

> Autopilot은 좋은 출발점이지만, 비즈니스 맥락을 반영한 수동 조정이 필수입니다.

#### 3.3.1 Fact/Dimension 수정

Autopilot은 NUMBER 타입 컬럼 중 일부를 Dimension으로 분류합니다. 집계 대상인 컬럼은 Fact로 변경해야 합니다.

| 테이블 | 컬럼 | Autopilot 분류 | 올바른 분류 | 이유 |
|--------|------|:-:|:-:|------|
| SALES_TRANSACTIONS | SALE_AMOUNT | Fact | Fact | ✅ Autopilot이 올바르게 분류 |
| SALES_TRANSACTIONS | QUANTITY | Fact | Fact | ✅ Autopilot이 올바르게 분류 |
| SALES_TRANSACTIONS | DISCOUNT_RATE | Fact | Fact | ✅ Autopilot이 올바르게 분류 |
| SALES_TRANSACTIONS | UNIT_PRICE | Dimension | **Fact** | ⚠️ 단가 평균 등 집계에 사용 |
| PRODUCTS | COST_PRICE | Dimension | **Fact** | ⚠️ 마진 계산(정가-원가)에 사용 |
| PRODUCTS | RETAIL_PRICE | Dimension | **Fact** | ⚠️ 정가 기준 매출 비교에 사용 |
| STORES | AREA_SQM | Fact | Fact | ✅ Autopilot이 올바르게 분류 |
| CUSTOMERS | TOTAL_PURCHASES | Dimension | **Fact** | ⚠️ 고객별 구매횟수 집계 |

> Autopilot은 SALE_AMOUNT, QUANTITY, DISCOUNT_RATE 같은 전형적인 수치 컬럼은 잘 분류하지만,
> UNIT_PRICE, COST_PRICE처럼 "가격"에 해당하는 컬럼은 Dimension으로 분류하는 경향이 있습니다.
> 비즈니스 맥락에서 집계(SUM, AVG)가 필요한 컬럼인지 판단하여 Fact로 변경해 주세요.

**Snowsight UI에서 수정**

> Fact/Dimension 변경은 UI에서 클릭으로 변경합니다.
> `ALTER SEMANTIC VIEW`로는 컬럼 타입(Fact/Dimension)을 변경할 수 없으므로, SQL로 변경하려면 `CREATE OR ALTER SEMANTIC VIEW`로 전체 정의를 다시 작성해야 합니다.

1. `AI & ML` → `Cortex Analyst` → `EDU_SALES_SV` 클릭하여 편집 화면 진입
2. 왼쪽 엔터티 목록에서 `SALES_TRANSACTIONS` 선택
3. 컬럼 목록에서 `UNIT_PRICE` 찾기 → 타입 드롭다운을 **Dimension → Fact**로 변경
4. `PRODUCTS` 엔터티로 이동 → `COST_PRICE`, `RETAIL_PRICE`를 각각 **Fact**로 변경
5. `CUSTOMERS` 엔터티로 이동 → `TOTAL_PURCHASES`를 **Fact**로 변경
6. 상단 **Save** 클릭

> **참고**: `ALTER SEMANTIC VIEW`는 COMMENT, TAG, RENAME, MATERIALIZATION, MAX_STALENESS 변경만 지원합니다.
> 컬럼 타입 등 구조적 변경이 필요하면 `CREATE OR ALTER SEMANTIC VIEW`로 전체 정의를 다시 작성해야 합니다.
> 본 단계의 Fact/Dimension 수정을 SQL로 실행하려면 별도 파일 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_SV_01_Fact%EC%88%98%EC%A0%95.sql" target="_blank">EDU_SALES_SV_01_Fact수정.sql</a>을 참고하세요.
> (<a href="https://docs.snowflake.com/en/sql-reference/sql/alter-semantic-view" target="_blank">ALTER SEMANTIC VIEW 문서</a> 참조)

#### 3.3.2 한국어 Description 추가

Description은 LLM이 컬럼의 의미를 이해하는 데 결정적입니다. **특히 고유값 목록을 명시하면 필터 조건의 정확도가 크게 올라갑니다.**

**방법 A: Snowsight UI에서 Description 추가 (1~2개 체험)**

> BRAND 컬럼의 Description을 UI에서 직접 수정해 봅니다.

1. Semantic View 편집 화면에서 `SALES_TRANSACTIONS` 엔터티 선택
2. `BRAND` 컬럼 옆의 **Edit** (연필 아이콘) 클릭 → Description 입력 필드 활성화
3. **Description** 필드에 입력: `브랜드명. 허용값: TOPTEN, ZIOZIA, OLZEN, ANDZ`
4. **Save** 클릭

> 한두 개는 UI에서 직접 해보면 구조를 이해하기 좋습니다.
> 나머지 컬럼의 Description도 일괄 반영하려면 별도 파일 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_SV_02_Description%EC%B6%94%EA%B0%80.sql" target="_blank">EDU_SALES_SV_02_Description추가.sql</a>의 `CREATE OR ALTER SEMANTIC VIEW`를 실행하세요.
> (Fact/Dimension 변경과 마찬가지로, 컬럼 단위 Description 변경도 `ALTER SEMANTIC VIEW`로는 불가능합니다.)

아래는 주요 컬럼별 권장 Description입니다. 이 내용이 `EDU_SALES_SV_수정.sql`에 모두 반영되어 있습니다.

| 테이블 | 컬럼 | 권장 Description |
|--------|------|-----------------|
| SALES_TRANSACTIONS | BRAND | 브랜드명. 허용값: TOPTEN, ZIOZIA, OLZEN, ANDZ |
| SALES_TRANSACTIONS | CHANNEL | 판매 채널. 허용값: 오프라인, 온라인몰, 모바일앱, 라이브커머스 |
| SALES_TRANSACTIONS | SALE_AMOUNT | 실 결제 금액 (원). 할인 적용 후 최종 결제 금액 |
| SALES_TRANSACTIONS | DISCOUNT_RATE | 할인율. 0.00=무할인, 0.30=30%할인. 범위: 0.00~0.50 |
| SALES_TRANSACTIONS | PAYMENT_METHOD | 결제 수단. 허용값: 신용카드, 간편결제, 체크카드, 현금 |
| CUSTOMERS | MEMBERSHIP_TIER | 멤버십 등급. 허용값: BASIC, SILVER, GOLD, VIP. BASIC이 최하위, VIP가 최상위 |
| CUSTOMERS | AGE_GROUP | 연령대. 허용값: 10대, 20대, 30대, 40대, 50대, 60대+ |
| CUSTOMERS | REGION | 거주 지역. 허용값: 서울, 경기, 인천, 부산, 대구, 광주, 대전, 울산, 경남, 경북, 충남 |
| CUSTOMERS | GENDER | 성별. 허용값: 남성, 여성 |
| CUSTOMERS | SIGNUP_CHANNEL | 가입 경로. 허용값: 매장방문, 온라인몰, 앱설치, SNS |
| PRODUCTS | CATEGORY | 상품 대분류. 허용값: 아우터, 상의, 하의, 액세서리, 언더웨어 |
| PRODUCTS | SUB_CATEGORY | 상품 소분류. 허용값: 패딩, 코트, 점퍼, 자켓, 티셔츠, 셔츠, 니트, 맨투맨, 후드, 슬랙스, 청바지, 면바지, 반바지, 양말, 벨트, 모자, 머플러, 가방, 내의, 속옷세트 |
| PRODUCTS | SEASON | 시즌. 허용값: SS24(2024 봄여름), FW24(2024 가을겨울), SS25(2025 봄여름), FW25(2025 가을겨울) |
| PRODUCTS | GENDER | 대상 성별. 허용값: 남성, 여성, 공용 |
| STORES | STORE_TYPE | 매장 유형. 허용값: 직영점, 대리점, 백화점, 아울렛, 온라인전용 |
| STORES | REGION | 매장 지역권. 허용값: 수도권, 영남권, 충청권, 호남권, 강원제주 |

#### 3.3.3 Metric 추가

Metric은 비즈니스 KPI를 사전 정의하여 LLM이 정확한 집계 SQL을 생성하도록 돕습니다.

**방법 A: Snowsight UI에서 Metric 추가 (1개 시연)**

> `TOTAL_REVENUE` 메트릭을 UI에서 직접 추가하는 과정을 보여줍니다.

1. Semantic View 편집 화면에서 `SALES_TRANSACTIONS` 엔터티 선택
2. Metrics 섹션 옆의 **+** 버튼 클릭
3. 설정:
   - **Name**: `TOTAL_REVENUE`
   - **Expression**: `SUM(SALE_AMOUNT)`
   - **Description**: `총 매출 금액 (원)`
4. **Add** 클릭

> 나머지 메트릭은 SQL로 일괄 추가합니다.

> Metric 추가도 `ALTER SEMANTIC VIEW`로는 불가능합니다.
> UI에서 1개를 직접 추가해 본 후, 나머지는 별도 파일 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_SV_03_Metric%EC%B6%94%EA%B0%80.sql" target="_blank">EDU_SALES_SV_03_Metric추가.sql</a>을 실행하세요.

아래는 추가할 Metric 목록입니다. 이 내용이 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_SV_03_Metric%EC%B6%94%EA%B0%80.sql" target="_blank">EDU_SALES_SV_03_Metric추가.sql</a>에 모두 반영되어 있습니다.

| Metric 이름 | Expression | Description |
|-------------|-----------|-------------|
| TOTAL_REVENUE | SUM(SALE_AMOUNT) | 총 매출 금액 (원) |
| TOTAL_QTY_SOLD | SUM(QUANTITY) | 총 판매 수량 |
| AVG_ORDER_VALUE | AVG(SALE_AMOUNT) | 객단가: 건당 평균 결제 금액 (원) |
| TRANSACTION_COUNT | COUNT(TXN_ID) | 총 거래 건수 |
| UNIQUE_CUSTOMERS | COUNT(DISTINCT CUSTOMER_ID) | 구매 고객 수 (유니크) |
| AVG_DISCOUNT_RATE | AVG(DISCOUNT_RATE) | 평균 할인율 |

### 3.4 Step 3: Verified Query (VQR) 추가

#### 3.4.1 Verified Query란?

검증된 **"질문 → SQL"** 매핑입니다. Analyst가 유사한 질문을 받으면 VQR의 SQL을 참조하여 더 정확한 결과를 생성합니다.

```
사용자 질문: "브랜드별 총 매출은?"
     │
     ▼
Verified Query 매칭됨?
     │
  ┌──┤
  │ YES → VQR에 정의된 SQL 참조 (정확도 보장)
  │
  │ NO  → LLM이 Semantic View 메타데이터로 SQL 생성 (유연하지만 오차 가능)
  └──┘
```

#### 3.4.2 VQR 추가 방법

**방법 A: Snowsight UI에서 VQR 추가 (1개 시연)**

> 간단한 VQR 1개를 UI에서 직접 추가하는 과정을 보여줍니다.

1. Semantic View 편집 화면에서 **Verified Queries** 탭 클릭
2. Verified queries 섹션 옆의 **+** 버튼 클릭
3. 입력:
   - **Question**: `브랜드별 총 매출은 얼마인가요?`
   - **SQL**: `SELECT BRAND, SUM(SALE_AMOUNT) AS TOTAL_REVENUE FROM SALES_TRANSACTIONS GROUP BY BRAND ORDER BY TOTAL_REVENUE DESC`
4. **Save and continue** 클릭

> 복잡한 VQR(CTE, Window function 등)도 `ALTER SEMANTIC VIEW`로는 추가할 수 없습니다.
> UI에서 1개를 직접 추가해 본 후, 나머지는 별도 파일 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_SV_04_VQR%EC%B6%94%EA%B0%80.sql" target="_blank">EDU_SALES_SV_04_VQR추가.sql</a>을 실행하세요.

아래는 추가할 VQR 목록입니다. 이 내용이 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_SV_04_VQR%EC%B6%94%EA%B0%80.sql" target="_blank">EDU_SALES_SV_04_VQR추가.sql</a>에 모두 반영되어 있습니다.

| VQR 이름 | Question | 주요 SQL 패턴 |
|----------|----------|---------------|
| BRAND_REVENUE | 브랜드별 총 매출은 얼마인가요? | GROUP BY BRAND |
| YOY_BRAND_GROWTH | 브랜드별 전년 대비 매출 성장률은? | CTE + Self JOIN |
| STORE_EFFICIENCY | 매장별 평당 매출(평효율)은? | JOIN STORES + 면적 나누기 |
| VIP_CONTRIBUTION | VIP 고객의 매출 비중은? | JOIN CUSTOMERS + Window SUM |
| WEEKDAY_PATTERN | 요일별 매출 패턴은? | DAYOFWEEK + DECODE |

#### 3.4.3 VQR 작성 가이드라인

| 언제 VQR을 만드는가 | 예시 |
|---------------------|------|
| 현업이 반복 질문하는 KPI | "이번 달 TOPTEN 매출" |
| LLM이 계산식을 틀리는 경우 | "전년 대비 성장률", "평당 매출" |
| 사내 전용 비즈니스 용어 | "객단가", "sell-through율", "기여마진" |
| Window function 등 복잡 SQL | "매출 순위 변화 추이" |
| 경영진 보고용 정확도 필수 질문 | "브랜드별 월별 매출 정산" |

### 3.5 Step 4: Semantic View 테스트

구축한 Semantic View가 제대로 동작하는지 직접 질문을 던져 확인합니다.

#### 3.5.1 Snowsight에서 테스트

1. `AI & ML` → `Cortex Analyst` → `EDU_SALES_SV` 선택하여 편집 화면 진입
2. 우측 상단 **Playground** 탭 클릭
3. 하단 "Enter prompt" 입력창에 아래 질문을 하나씩 입력하고 **Run** 클릭하여 결과를 확인합니다

**기본 질문 (Metric + Dimension 조합)**

| # | 질문 | 확인 포인트 |
|---|------|------------|
| 1 | `브랜드별 총 매출은?` | SQL 하단에 `Generated based on verified query: BRAND_REVENUE` 표시 여부 |
| 2 | `채널별 거래 건수를 보여줘` | `SEMANTIC_VIEW(... DIMENSIONS channel METRICS transaction_count)` — Dimension과 Metric 이름이 사용되는지 |
| 3 | `VIP 고객의 매출 비중은?` | SQL 하단에 `Generated based on verified query: VIP_CONTRIBUTION` 표시 여부 |

**Description 정확도 확인**

| # | 질문 | 확인 포인트 |
|---|------|------------|
| 4 | `라이브커머스 매출이 얼마야?` | CHANNEL = '라이브커머스' 필터가 정확한지 |
| 5 | `GOLD 등급 이상 고객 수는?` | MEMBERSHIP_TIER IN ('GOLD', 'VIP') — 등급 순서 이해 여부 |
| 6 | `FW24 시즌 아우터 매출` | SEASON = 'FW24' AND CATEGORY = '아우터' 필터 조합 |

**복잡한 질문 (VQR 활용)**

| # | 질문 | 확인 포인트 |
|---|------|------------|
| 7 | `매장별 평당 매출 순위는?` | SQL 하단에 `Generated based on verified query: STORE_EFFICIENCY` 표시 여부 |
| 8 | `요일별로 매출 패턴이 어때?` | SQL 하단에 `Generated based on verified query: WEEKDAY_PATTERN` 표시 여부 |

#### 3.5.2 결과 확인 및 개선 판단

각 질문에 대해 다음을 확인하세요:

- **생성된 SQL 확인**: 응답 하단의 SQL 펼치기를 눌러 어떤 SQL이 생성되었는지 확인
- **VQR 활용 여부**: SQL 하단에 **"Generated based on verified query: VQR이름"** 텍스트가 표시되면 VQR이 매칭된 것입니다
  - 예: `Generated based on verified query: BRAND_REVENUE`
- **필터 값 정확도**: Description에 명시한 허용값(TOPTEN, 라이브커머스 등)이 정확히 적용되는지 확인

> **결과가 이상하다면?**
> - 필터 값이 틀림 → Description에 허용값을 더 명확히 추가
> - 계산식이 틀림 → VQR로 정확한 SQL을 등록
> - 조인이 빠짐 → Relationship 확인 (예: CUSTOMERS 테이블 Relationship 미설정)

---

## Chapter 4. 데이터 사전(Data Dictionary) 구축과 Search 활용

### 4.1 학습 목표
- 데이터 사전 테이블을 설계하고 데이터를 적재하는 방법
- Cortex Search Service로 데이터 사전을 검색 가능하게 만드는 방법
- Agent에서 데이터 사전 검색 → Analyst 정확도 향상 연동 구조 이해

### 4.2 왜 데이터 사전 Search인가?

**Semantic View의 Description만으로는 부족한 이유:**
- Description은 컬럼 단위의 짧은 설명 → 비즈니스 컨텍스트가 부족
- 현업이 사용하는 동의어/약어를 매핑할 수 없음
- 테이블 간 관계의 비즈니스적 의미를 설명할 수 없음

**데이터 사전 Search가 해결하는 것:**
```
현업 질문: "탑텐 객단가 추이 보여줘"
                │
Agent 동작:     ▼
  1) [dict_search] "객단가" 검색
     → 결과: "객단가 = 건당 평균 결제 금액. 계산: AVG(SALE_AMOUNT). 
              테이블: SALES_TRANSACTIONS. 관련 메트릭: AVG_ORDER_VALUE"
  2) [dict_search] "탑텐" 검색
     → 결과: "탑텐 = TOPTEN 브랜드. 컬럼: BRAND. 값: 'TOPTEN'"
  3) [sales_analytics] 정확한 SQL 생성
     → SELECT DATE_TRUNC('MONTH', TXN_DATE), AVG(SALE_AMOUNT) 
        FROM ... WHERE BRAND = 'TOPTEN' GROUP BY 1
```

### 4.3 Step 1: 데이터 사전 테이블 설계

데이터 사전은 3가지 유형의 엔트리를 포함합니다:

| 유형 | 설명 | 예시 |
|------|------|------|
| `COLUMN` | 개별 컬럼 설명 | SALE_AMOUNT: 실 결제 금액 |
| `TERM` | 비즈니스 용어 → 계산식 매핑 | 객단가 → AVG(SALE_AMOUNT) |
| `VALUE` | 컬럼 고유값 + 설명 | BRAND = 'TOPTEN': 가성비 영캐주얼 |

### 4.4 Step 2: 데이터 사전 테이블 생성 및 적재

> 전체 SQL은 별도 파일 <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_DATA_DICTIONARY_%EC%83%9D%EC%84%B1.sql" target="_blank">EDU_DATA_DICTIONARY_생성.sql</a>을 실행하세요.
> 아래는 테이블 구조와 INSERT 예시입니다.

**테이블 생성**
```sql
CREATE OR REPLACE TABLE SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY (
    ENTRY_ID    NUMBER AUTOINCREMENT,
    ENTRY_TYPE  VARCHAR(20),          -- COLUMN, TERM, VALUE
    TABLE_NAME  VARCHAR(100),         -- 해당 테이블 (없으면 NULL)
    COLUMN_NAME VARCHAR(100),         -- 해당 컬럼 (없으면 NULL)
    TERM        VARCHAR(200),         -- 비즈니스 용어 또는 컬럼명
    SYNONYMS    VARCHAR(500),         -- 동의어/약어 (쉼표 구분)
    DESCRIPTION TEXT,                 -- 상세 설명 (검색 대상)
    DOMAIN      VARCHAR(50),          -- 도메인: 매출, 고객, 상품, 매장, SCM
    UPDATED_AT  TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

**INSERT 예시 — 비즈니스 용어 (TERM)**
```sql
INSERT INTO SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY 
  (ENTRY_TYPE, TABLE_NAME, COLUMN_NAME, TERM, SYNONYMS, DESCRIPTION, DOMAIN)
VALUES
('TERM', 'SALES_TRANSACTIONS', 'SALE_AMOUNT', '객단가',
 '건당매출, 평균주문금액, 평균결제금액, AOV, average order value',
 '객단가는 거래 1건당 평균 결제 금액입니다. 계산: AVG(SALE_AMOUNT). 메트릭: AVG_ORDER_VALUE.', '매출');
```

**INSERT 예시 — 컬럼 값 설명 (VALUE)**
```sql
INSERT INTO SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY 
  (ENTRY_TYPE, TABLE_NAME, COLUMN_NAME, TERM, SYNONYMS, DESCRIPTION, DOMAIN)
VALUES
('VALUE', 'SALES_TRANSACTIONS', 'BRAND', 'TOPTEN',
 '탑텐, 톱텐, top ten, topten, 탑10',
 'TOPTEN은 스노우패션의 가성비 영캐주얼 브랜드입니다. 필터: BRAND = ''TOPTEN''', '상품');
```

> **<a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_DATA_DICTIONARY_%EC%83%9D%EC%84%B1.sql" target="_blank">EDU_DATA_DICTIONARY_생성.sql</a>에 포함된 전체 데이터:**
> - TERM 14건: 매출액, 객단가, 거래건수, 구매고객수, 평효율, 마진율, 할인율, 전년동기대비, 전월대비, 배송지연, 벤더품질, 리드타임, 가용재고, 재고상태
> - VALUE 16건: 브랜드 4개, 채널 4개, 멤버십 2개, 매장유형 2개, 시즌 4개

**적재 확인**
```sql
SELECT ENTRY_TYPE, COUNT(*) FROM SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY GROUP BY ENTRY_TYPE;
```

### 4.5 Step 3: 데이터 사전 Cortex Search Service 생성

#### 방법 A: Snowsight UI에서 생성

1. 좌측 메뉴에서 `AI & ML` → `Cortex Search` → **Create** 클릭

2. **New service** 단계:
   - Role: `ACCOUNTADMIN`, Warehouse: `SF_WH`
   - Database: `SNOW_FASHION`, Schema: `SEMANTIC`
   - Service name: `EDU_DICT_SEARCH`
   - **Next** 클릭

3. **Select data** 단계:
   - **Table or view** 선택
   - `SNOW_FASHION` → `SEMANTIC` → `EDU_DATA_DICTIONARY` 선택 → **Next** 클릭

4. **Select search column** 단계:
   - 검색 대상 컬럼: `DESCRIPTION` 선택 → **Next** 클릭
   - > **Search column**: 사용자가 입력한 검색어와 매칭되는 텍스트 컬럼. 이 컬럼에 대해 벡터 임베딩 + 키워드 인덱스가 생성됩니다.

5. **Select attributes** 단계:
   - 필터 가능 속성: `ENTRY_TYPE`, `TABLE_NAME`, `DOMAIN` 선택 → **Next** 클릭
   - > **Attributes**: 검색 시 `filter` 조건으로 사용할 수 있는 컬럼. 예: `"filter": {"@eq": {"DOMAIN": "매출"}}` 처럼 특정 도메인만 검색 가능.

6. **Select columns** 단계:
   - 결과에 포함할 컬럼: `ENTRY_TYPE`, `TABLE_NAME`, `COLUMN_NAME`, `TERM`, `SYNONYMS`, `DOMAIN` 선택 → **Next** 클릭
   - > **Columns**: 검색 결과에 함께 반환할 부가 정보 컬럼. Search column과 Attributes에 포함되지 않은 컬럼 중 결과에 필요한 것을 선택합니다.

7. **Configure indexing** 단계:
   - Target lag: `1 day` → **Create** 클릭

> 생성이 완료되면 Search Service가 활성화되고, 데이터가 인덱싱됩니다.

#### 방법 B: SQL로 생성

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH
  ON DESCRIPTION
  ATTRIBUTES ENTRY_TYPE, TABLE_NAME, DOMAIN
  WAREHOUSE = SF_WH
  TARGET_LAG = '1 day'
  COMMENT = '스노우패션 데이터 사전 검색 - 비즈니스 용어/컬럼/고유값 검색'
AS (
  SELECT 
    DESCRIPTION,
    ENTRY_TYPE,
    TABLE_NAME,
    COLUMN_NAME,
    TERM,
    SYNONYMS,
    DOMAIN
  FROM SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY
);
```

#### 데이터 변경 시 Search Service 인덱싱 동작

Cortex Search Service는 `TARGET_LAG`에 설정된 주기로 원본 테이블의 변경을 감지하고 인덱스를 갱신합니다.

| 상황 | 동작 | 비용 |
|------|------|------|
| **변경 없음** | 변경 감지만 수행, 인덱스 갱신 없음 | Warehouse 비용 없음 (Cloud Services 비용만 소량 발생) |
| **행 추가/수정** | **인크리멘탈 갱신** — 변경된 행에 대해서만 임베딩 재계산 및 인덱스 갱신 | 변경된 행의 토큰 수에 비례한 임베딩 비용 |
| **행 삭제** | 다음 refresh에서 삭제된 행의 인덱스 제거 (임베딩 재계산 없음) | 소량 — Warehouse 비용만 |
| **스키마 변경** (컬럼 추가/삭제) | **전체 재인덱싱** — 모든 임베딩 재계산 | 전체 데이터에 대한 임베딩 비용 |

> **참고 — Primary Key와 인크리멘탈 갱신**:
> - 인크리멘탈 갱신(변경된 행만 재임베딩)은 PK 없이도 기본 동작입니다.
> - Search Service에 PRIMARY KEY를 정의하면 변경 감지가 더 최적화되어 비용과 지연이 줄어듭니다.
> - 단, Search Service의 PK 컬럼은 **TEXT 타입만** 가능합니다 (NUMBER 불가).
> - (<a href="https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-costs" target="_blank">Understanding cost for Cortex Search Services</a> 참조)

### 4.6 Step 4: 데이터 사전 검색 테스트

#### Playground에서 테스트

1. `AI & ML` → `Cortex Search` → `EDU_DICT_SEARCH` 클릭하여 서비스 상세 화면 진입
2. 우측 상단 **Playground** 버튼 클릭
3. 우측 Settings에서 결과에 포함할 컬럼을 설정:
   - **Columns**: `DESCRIPTION` (기본값) 외에 `TERM`, `TABLE_NAME`, `COLUMN_NAME` 등 추가
   - **Limit**: `10`

4. 아래 검색어를 하나씩 입력하고 결과를 확인합니다

| # | 검색어 | 확인 포인트 |
|---|--------|------------|
| 1 | `객단가` | 1위 결과에 "AVG(SALE_AMOUNT)" 계산식이 포함되어 있는지 |
| 2 | `탑텐` | 1위 결과에 "BRAND = 'TOPTEN'" 필터 안내가 포함되어 있는지 |
| 3 | `라방 매출` | 결과에 "라이브커머스" 관련 설명이 나오는지 |
| 4 | `평효율` | 1위 결과에 "SUM(SALE_AMOUNT) / AREA_SQM" 계산식이 포함되어 있는지 |

> **검색 정확도 설계 원칙**: Search column(`DESCRIPTION`)만 임베딩되어 인덱싱됩니다.
> TERM이나 SYNONYMS 컬럼은 Attribute로 반환될 뿐, 검색 매칭에는 직접 사용되지 않습니다.
> 따라서 **DESCRIPTION 텍스트 안에 용어명과 핵심 동의어를 함께 기술**해야 정확한 검색이 됩니다.
> 
> ```
> -- 좋은 예: DESCRIPTION에 용어명+동의어 포함
> '객단가(건당매출, 평균주문금액, AOV)는 거래 1건당 평균 결제 금액입니다...'
> 
> -- 나쁜 예: DESCRIPTION에 용어명 없음 (TERM/SYNONYMS에만 존재)
> '거래 1건당 평균 결제 금액입니다...'
> ```

> **Filter 활용**: Playground 우측 **Filter** 섹션에서 `Add condition`을 클릭하면 Attribute 기반 필터를 설정할 수 있습니다.
> 예: `DOMAIN = SCM`으로 필터 후 `리드타임` 검색 → SCM 도메인 결과만 반환

#### SQL로 테스트 (참고)

Playground 외에 SQL로도 검색을 테스트할 수 있습니다.

```sql
-- 비즈니스 용어 검색
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
  'SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH',
  '{
    "query": "객단가",
    "columns": ["TERM", "DESCRIPTION", "TABLE_NAME", "COLUMN_NAME"],
    "limit": 3
  }'
);

-- 도메인 필터 적용 검색
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
  'SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH',
  '{
    "query": "리드타임",
    "columns": ["TERM", "DESCRIPTION", "TABLE_NAME"],
    "filter": {"@eq": {"DOMAIN": "SCM"}},
    "limit": 3
  }'
);
```

### 4.7 데이터 사전의 확장 가이드

데이터 사전은 운영하면서 지속적으로 보강합니다:

| 시점 | 추가할 내용 |
|------|-------------|
| Agent 오답 발생 시 | 틀린 용어/계산식을 사전에 추가 |
| 새 현업 용어 발견 시 | 동의어/약어 매핑 추가 |
| 새 테이블/컬럼 추가 시 | 컬럼 설명 + 고유값 추가 |
| 정기 리뷰 (월 1회) | 사용 빈도 높은 질문 패턴 반영 |

```sql
-- 데이터 사전 항목 추가 예시 (운영 중)
INSERT INTO SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY 
  (ENTRY_TYPE, TABLE_NAME, COLUMN_NAME, TERM, SYNONYMS, DESCRIPTION, DOMAIN)
VALUES
('TERM', 'SALES_TRANSACTIONS', NULL, 'sell-through율',
 '판매율, 소진율, sell through, 셀스루',
 'Sell-through율(판매율, 소진율, sell through, 셀스루)은 입고 수량 대비 판매 수량의 비율입니다. 계산: SUM(판매수량) / SUM(입고수량) * 100. SALES_TRANSACTIONS의 QUANTITY와 SUPPLY_ORDERS의 ORDER_QTY를 SKU_ID로 조인하여 계산.', '상품');
```

데이터를 추가한 후에는 `TARGET_LAG` (1 day) 주기에 따라 다음 refresh 때 자동 반영됩니다.
**즉시 반영**이 필요하면 수동 refresh 명령을 실행하세요:

```sql
-- 수동 refresh: 즉시 변경 사항을 인덱스에 반영
ALTER CORTEX SEARCH SERVICE SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH REFRESH;
```

> 수동 refresh를 실행하면 서비스가 즉시 원본 데이터의 변경을 감지하고 인덱스를 갱신합니다.
> INSERT/UPDATE된 행만 인크리멘탈로 처리되므로 전체 재인덱싱보다 빠르고 비용이 적습니다.

---

## Chapter 5. 고객 VOC Search Service 구축

### 5.1 학습 목표
- 고객 리뷰 텍스트를 검색 가능하게 만드는 과정 이해
- 데이터 사전 Search와의 차이점 파악
- Agent에서 VOC Search 도구 활용법

### 5.2 데이터 사전 Search vs VOC Search

| 구분 | 데이터 사전 Search | VOC Search |
|------|-------------------|------------|
| **목적** | 비즈니스 용어 해석 + 컬럼 매핑 | 고객 리뷰 텍스트 검색 |
| **데이터** | 메타데이터 (수십~수백 건) | 원본 텍스트 (10만건) |
| **Agent 활용** | Analyst 호출 전 "사전 검색" | 비정형 분석 도구 |
| **데이터 변경 빈도** | 비정기 (용어 추가/수정 시) | 상시 (리뷰 데이터 유입) |

### 5.3 Step 1: VOC Search Service 생성

**방법 A: Snowsight UI에서 생성**

1. Snowsight 좌측 메뉴 → `AI & ML` → `Cortex Search` → `+ Create` 클릭

2. **New service** — 기본 정보 입력:
   - Role: `ACCOUNTADMIN`, Warehouse: `SF_WH`
   - Database: `SNOW_FASHION`, Schema: `SEMANTIC`
   - Service name: `EDU_VOC_SEARCH`
   - **Next** 클릭

3. **Select data** — 인덱싱할 데이터 선택:
   - `Table or view` 선택 (기본값)
   - 좌측 트리에서 `RAW` → `Tables` → `PRODUCT_REVIEWS` 선택
   - 우측 Data preview에서 REVIEW_TEXT, BRAND, RATING 등 컬럼 확인
   - **Next** 클릭

4. **Select search column** — 검색 대상 텍스트 컬럼:
   - `REVIEW_TEXT` 선택 (리뷰 본문이 임베딩되어 검색 대상이 됨)
   - **Next** 클릭

5. **Select attributes** — 필터용 속성 컬럼:
   - `BRAND`, `RATING`, `REVIEW_CHANNEL` 선택
   - 이 컬럼들은 검색 시 `filter` 파라미터로 결과를 필터링할 때 사용됩니다
   - **Next** 클릭

6. **Select columns** — 결과에 포함할 추가 컬럼:
   - `REVIEW_DATE`, `SKU_ID` 선택
   - 검색에는 사용되지 않지만 결과 반환 시 함께 조회할 수 있는 컬럼입니다
   - **Next** 클릭

7. **Configure indexing** — 인덱싱 설정:
   - **Target lag**: `1 day`
   - **Create** 클릭

> 10만건의 리뷰 데이터를 임베딩하므로, 데이터 사전(30건)보다 생성 시간이 더 걸립니다.

**방법 B: SQL로 생성**

```sql
-- VOC 리뷰 검색 서비스 생성
CREATE OR REPLACE CORTEX SEARCH SERVICE SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH
  ON REVIEW_TEXT                                    -- 검색 대상 텍스트
  ATTRIBUTES BRAND, RATING, REVIEW_CHANNEL          -- 필터 속성
  WAREHOUSE = SF_WH
  TARGET_LAG = '1 day'
  COMMENT = '스노우패션 고객 VOC 리뷰 검색 (10만건 한국어 리뷰)'
AS (
  SELECT 
    REVIEW_TEXT,
    BRAND,
    RATING,
    REVIEW_CHANNEL,
    REVIEW_DATE,
    SKU_ID
  FROM SNOW_FASHION.RAW.PRODUCT_REVIEWS
);
```

### 5.4 Step 2: VOC Search 테스트

#### Playground에서 테스트

1. `AI & ML` → `Cortex Search` → `EDU_VOC_SEARCH` 클릭하여 서비스 상세 화면 진입
2. 우측 상단 **Playground** 버튼 클릭
3. 우측 Settings에서 설정:
   - **Columns**: `REVIEW_TEXT` 외에 `BRAND`, `RATING`, `REVIEW_CHANNEL` 추가
   - **Limit**: `5`

4. 아래 검색어를 하나씩 입력하고 결과를 확인합니다

| # | 검색어 | 확인 포인트 |
|---|--------|------------|
| 1 | `보풀이 심해요` | 보풀 관련 리뷰가 상위에 나오는지 |
| 2 | `배송이 빠르네요` | 배송 관련 긍정 리뷰가 나오는지 |

> **참고**: 시맨틱 검색은 의미가 유사한 문장을 찾는 방식이므로, 검색어의 감성(긍정/부정)과 무관하게 주제가 비슷한 리뷰가 함께 나올 수 있습니다. 예를 들어 "지퍼 고장"을 검색해도 지퍼와 관련 없는 리뷰가 상위에 나올 수 있습니다. 이는 임베딩 모델의 특성이며 오류가 아닙니다.

5. **Filter 활용**: 검색 결과의 정확도를 높이려면 필터를 함께 사용합니다.
   - 우측 Settings의 **Filter** → `Add condition` 클릭
   - `BRAND` = `TOPTEN` 필터 설정 후 `보풀이 심해요` 검색
   - TOPTEN 브랜드 리뷰만 필터링되는지 확인
   - 필터를 추가로 `RATING` = `2` 로 설정하면 저평점 불만 리뷰만 좁혀서 볼 수 있음

> **데이터 사전 Search와의 차이**: 데이터 사전은 메타데이터 30건을 검색하지만,
> VOC Search는 고객 리뷰 원문 10만건을 의미 검색합니다.
> 동일한 Cortex Search 엔진이지만 용도와 데이터 규모가 다릅니다.

> **참고**: 교육용 PRODUCT_REVIEWS 데이터는 약 55개 리뷰 템플릿을 브랜드/채널/상품별로 반복 생성한 데모 데이터입니다.
> 동일한 리뷰 텍스트가 여러 브랜드에 걸쳐 나타나므로 검색 결과에 같은 문장이 반복될 수 있습니다. 이는 오류가 아닙니다.

#### SQL로 테스트 (참고)

Playground 외에 SQL로도 검색을 테스트할 수 있습니다.

```sql
-- 일반 검색
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
  'SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH',
  '{"query": "보풀이 심해요", "columns": ["REVIEW_TEXT","BRAND","RATING"], "limit": 5}'
);

-- 브랜드 필터 적용
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
  'SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH',
  '{
    "query": "보풀이 심해요",
    "columns": ["REVIEW_TEXT", "BRAND", "RATING"],
    "filter": {"@eq": {"BRAND": "TOPTEN"}},
    "limit": 5
  }'
);
```

### 5.5 핵심 설정 파라미터 가이드

| 파라미터 | 설명 | 데이터 사전 | VOC |
|----------|------|:-:|:-:|
| `ON` | 검색 대상 컬럼 | DESCRIPTION | REVIEW_TEXT |
| `ATTRIBUTES` | 필터 속성 | ENTRY_TYPE, DOMAIN | BRAND, RATING |
| `TARGET_LAG` | 갱신 주기 | '1 day' | '1 day' |

---

## Chapter 6. Cortex Agent 생성과 도구 연결

### 6.1 학습 목표
- Agent를 Snowsight UI에서 생성하는 전체 과정 실습
- Analyst + Search(데이터 사전) + Search(VOC) 3개 도구를 연결
- Instruction 작성법과 모범 사례
- 데이터 사전 Search를 Agent가 "사전 검색"으로 활용하는 패턴

### 6.2 Step 1: Agent 생성 (Snowsight UI)

1. Snowsight 좌측 메뉴 → `AI & ML` → `Agents`
2. 우측 상단 `+ Create agent` 클릭
3. 기본 정보 입력:
   - **Database/Schema**: `SNOW_FASHION.SEMANTIC`
   - **Object Name**: `EDU_SALES_AGENT`
   - **Display Name**: `스노우패션 매출분석(교육)`
4. **Create** 클릭

> 생성 후 Agent 상세 화면(Overview)으로 이동합니다.
> 상단 탭에 Overview, **Configuration**, Access, Evaluations, Observability, Preview가 있습니다.

### 6.3 Step 2: 도구 추가

Agent 상세 화면 → **Configuration** 탭 → **Tools** 서브탭으로 이동합니다.

Tools 화면에는 다음 섹션이 순서대로 나열됩니다:

| 섹션 | 설명 | 설정 |
|------|------|------|
| **Web search** | 인터넷 검색을 통해 외부 정보를 참조 | 토글 OFF (사용 안 함) |
| **Analytical search** | Search Service 위에 AI 함수(AI_FILTER, AI_EXTRACT, AI_AGG) + SQL을 조합하여 대량 문서에 대한 집계·트렌드 분석 수행 (Search Service 추가 후 활성화 가능) | 토글 OFF (이번 교육에서는 사용 안 함) |
| **Code Execution tool** | Agent가 Python 코드를 생성·실행할 수 있는 격리 샌드박스 (Preview). 대화 세션마다 자동 생성되며, pandas/matplotlib 등이 사전 설치되어 데이터 가공·차트 생성에 활용 | 토글 ON (기본값 유지) |
| **Query structured data** | Semantic View를 연결하여 자연어 → SQL 변환 (Cortex Analyst) | `+ Add semantic view` |
| **Search documents and unstructured data** | Cortex Search Service를 연결하여 비정형 텍스트 검색 (기본 RAG) | `+ Add search service` |
| **Custom tools** | Stored Procedure 또는 UDF를 도구로 연결 | 사용 안 함 |


#### 도구 1: Cortex Analyst (매출 분석)

1. **Query structured data** 섹션에서 `+ Add semantic view` 클릭
2. 설정:
   - **Schema**: `SNOW_FASHION.SEMANTIC`
   - **Semantic View**: `EDU_SALES_SV`
   - **Name**: `sales_analytics`
   - **Description**: `스노우패션 매출, 고객, 상품, 매장 데이터를 SQL로 조회합니다.`
   - **Warehouse**: Custom → `SF_WH`
   - **Query timeout**: 비워두기 (기본 타임아웃 적용)

#### 도구 2: Cortex Search — 데이터 사전

3. **Search documents and unstructured data** 섹션에서 `+ Add search service` 클릭
4. 설정:
   - **Schema**: `SEMANTIC` (Database: `SNOW_FASHION`)
   - **Search service**: `EDU_DICT_SEARCH`
   - **Name**: `dict_search`
   - **Description**: `데이터 사전을 검색합니다. 비즈니스 용어(객단가, 평효율 등)의 의미와 계산식, 컬럼 설명, 고유값 정보를 찾을 수 있습니다. 생소한 용어나 약어가 나오면 이 도구로 먼저 검색하세요.`
   - **Advanced configuration** (나머지는 기본값 유지):
     - **Max results**: `4` (기본값 — Search Service가 반환할 최대 문서 수)
     - **Target results**: 비워두기 (고품질 결과 목표 수)
     - **ID column**: 비워두기 (검색 결과에 하이퍼링크를 생성할 때 사용하는 고유 식별자 컬럼)
     - **Title column**: 비워두기 (검색 결과 인용 시 출처 카드에 표시되는 제목 컬럼)
     - **Source stage**: 비워두기 (문서 원본이 저장된 Snowflake Stage. 앱 내 문서 미리보기에 필요)
     - **Relative path column**: 비워두기 (Source stage 내 파일 경로를 담은 컬럼)
     - **Indexed columns**: `+ Add column row`로 컬럼별 설명 추가 가능. Agent가 각 컬럼의 용도를 이해하여 검색·필터링 품질이 향상됨. **Filter column** 체크 시 최대 5개까지 필터 컬럼으로 지정할 수 있으며, Agent가 검색 시 해당 컬럼으로 자동 필터링 조건을 적용함
     - **Named scoring profile**: 비워두기 (Search Service에 정의된 커스텀 스코어링 프로필 선택)

#### 도구 3: Cortex Search — VOC

5. 다시 `+ Add search service` 클릭
6. 설정:
   - **Schema**: `SEMANTIC` (Database: `SNOW_FASHION`)
   - **Search service**: `EDU_VOC_SEARCH`
   - **Name**: `voc_search`
   - **Description**: `고객 리뷰(VOC) 텍스트를 검색합니다. 10만건의 한국어 리뷰에서 사이즈, 품질, 배송, 가격 등에 대한 고객 의견을 조회합니다.`
   - **Advanced configuration** (나머지는 기본값 유지):
     - **Max results**: `4` (기본값)
     - **Target results**: 비워두기
     - **ID column / Title column**: 비워두기
     - **Source stage / Relative path column**: 비워두기
     - **Indexed columns**: 비워두기 (필요 시 BRAND, RATING 등을 Filter column으로 추가 가능)
     - **Named scoring profile**: 비워두기

> 모든 도구 추가 후 우측 상단 **Saved** 표시를 확인합니다 (자동 저장).

### 6.4 Step 3: Instruction 작성

Agent 상세 화면 → **Configuration** 탭 → **Instructions** 서브탭으로 이동합니다.

Instructions 화면에는 다음 항목이 순서대로 나열됩니다:

#### Model

- Agent의 오케스트레이션(작업 분해, 도구 선택, 응답 생성)에 사용할 LLM 모델을 선택합니다.
- **`auto`** (기본값): Snowflake가 계정에서 사용 가능한 최고 품질 모델을 자동 선택합니다.
- 특정 모델을 고정하고 싶다면 드롭다운에서 선택합니다 (예: `claude-sonnet-4-6`).
- 설정: **`auto`** (기본값 유지)

#### Orchestration instructions

Agent가 작업을 분해하고 도구를 선택하는 방식을 자연어로 지시합니다. 어떤 질문에 어떤 도구를 사용할지, 도구 호출 순서 등을 명시합니다.

입력:

```
당신은 스노우패션의 데이터 분석 전문가입니다.

■ 도구 사용 규칙:

1. 사용자의 질문에 생소한 비즈니스 용어, 약어, 한글 브랜드명이 포함되어 있으면
   먼저 dict_search(데이터 사전)를 검색하여 정확한 의미와 계산식을 파악하세요.
   예: "객단가" → dict_search → "AVG(SALE_AMOUNT)" 확인 → sales_analytics 호출

2. 매출, 실적, KPI, 숫자 기반 분석 → sales_analytics 사용
   dict_search 결과를 참고하여 정확한 컬럼명과 필터값을 사용하세요.

3. 고객 리뷰, VOC, 불만사항, 고객 의견 → voc_search 사용

4. 복합 질문 → 여러 도구를 순차적으로 사용
   예: "매출 하락 원인 분석" → sales_analytics(수치 확인) + voc_search(고객 의견)

■ dict_search 활용 시나리오:
- "탑텐" → dict_search 검색 → BRAND = 'TOPTEN' 확인
- "라방" → dict_search 검색 → CHANNEL = '라이브커머스' 확인
- "25년 FW" → dict_search 검색 → SEASON = 'FW25' 확인
- "평효율" → dict_search 검색 → SUM(SALE_AMOUNT) / AREA_SQM 확인

■ 주의: 아래 용어는 dict_search 없이도 바로 사용 가능합니다:
- 브랜드명: TOPTEN, ZIOZIA, OLZEN, ANDZ (영문 그대로)
- 기본 지표: 매출, 수량, 할인율 (SALE_AMOUNT, QUANTITY, DISCOUNT_RATE)
```

#### Response instructions

Agent가 사용자에게 답변을 생성하는 방식을 지시합니다. 답변 언어, 톤, 형식 등을 지정합니다.

입력:

```
■ 답변 규칙:
1. 한국어로 답변하세요
2. 금액은 원(₩) 단위, 천 단위 구분자 사용 (예: ₩1,234,567)
3. 수치 데이터와 함께 비즈니스 인사이트를 제공하세요
4. 차트가 적절한 경우 data_to_chart를 사용하세요
5. 리뷰 검색 결과는 원문을 인용하세요
6. dict_search로 용어를 확인한 경우, 그 의미를 답변에 자연스럽게 포함하세요
```

#### Budget configuration (Optional)

Agent의 단일 응답 생성에 대한 리소스 제한을 설정합니다. 둘 중 하나라도 먼저 도달하면 응답 생성이 중단됩니다.

- **Time Limit (seconds)**: 최대 실행 시간 (초 단위). 설정: `No limit` (기본값 유지)
- **Token Limit**: 오케스트레이션에 사용할 최대 토큰 수. Cortex Analyst, Cortex Search 등 도구가 사용하는 토큰은 포함되지 않음. 설정: `No limit` (기본값 유지)

#### Example questions (General 서브탭)

**Configuration** → **General** 서브탭에서 다음 항목을 설정합니다.

- **Display name**: `스노우패션 매출분석(교육)` (이미 입력됨)
- **Description**: Agent의 용도와 사용 방법을 설명합니다. Agent를 선택하는 사용자에게 표시되며, Agent의 동작이나 로직에는 영향을 주지 않습니다.

  입력 예: `스노우패션 4개 브랜드(TOPTEN, ZIOZIA, OLZEN, ANDZ)의 매출·고객·상품 데이터를 분석하고, 데이터 사전과 고객 리뷰(VOC)를 검색할 수 있는 교육용 에이전트입니다.`

- **Example questions**: `Add question` 버튼으로 최대 15개의 추천 질문을 등록합니다. 사용자가 대화를 시작할 때 도움이 되는 질문으로 표시됩니다.

  등록할 질문:
  - "브랜드별 이번 달 매출은 얼마야?"
  - "탑텐 객단가 추이를 보여줘"
  - "사이즈 불만 리뷰를 찾아줘"
  - "라방 매출이 전월 대비 어떻게 변했어?"

> 모든 설정 완료 후 우측 상단 **Save** 버튼을 클릭하여 저장합니다.

### 6.5 Step 4: SQL로 Agent 생성 (전체 코드)

> **별도 SQL 파일**: <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SALES_AGENT_%EC%83%9D%EC%84%B1.sql" target="_blank">`EDU_SALES_AGENT_생성.sql`</a>

위 Step 1~3에서 UI로 설정한 내용을 SQL로 표현하면 아래와 같습니다. 전체 코드는 별도 SQL 파일을 참조하세요.

```sql
CREATE OR REPLACE AGENT SNOW_FASHION.SEMANTIC.EDU_SALES_AGENT
  COMMENT = '스노우패션 매출분석 교육용 에이전트 (Analyst + 데이터사전 + VOC)'
  PROFILE = '{"display_name": "스노우패션 매출분석(교육)"}'
  FROM SPECIFICATION
  $$
  orchestration:
    tool_not_accessible: accept

  instructions:
    orchestration: |
      당신은 스노우패션의 데이터 분석 전문가입니다.
      -- (도구 사용 규칙, dict_search 활용 시나리오 등 — 전체는 SQL 파일 참조)

    response: |
      한국어 답변. ₩ 단위, 천단위 구분자. 차트 적극 활용.

  tools:
    - tool_spec: { type: cortex_analyst_text_to_sql, name: sales_analytics, ... }
    - tool_spec: { type: cortex_search, name: dict_search, ... }
    - tool_spec: { type: cortex_search, name: voc_search, ... }
    - tool_spec: { type: data_to_chart, name: data_to_chart, ... }
    - tool_spec: { type: code_execution, name: code_execution }

  tool_resources:
    sales_analytics: { semantic_view: "SNOW_FASHION.SEMANTIC.EDU_SALES_SV", ... }
    dict_search: { search_service: "SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH", max_results: 4, ... }
    voc_search: { search_service: "SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH", max_results: 4, ... }
  $$;
```

### 6.6 Step 5: Agent 테스트 시나리오

Agent 상세 화면 상단의 **Preview** 탭으로 이동합니다.

Preview 화면에는 다음이 표시됩니다:
- Agent 이름 (`EDU_SALES_AGENT`)과 Description
- General 서브탭에서 등록한 **Example questions** 버튼들
- 하단 입력창 (`Enter a message to test your agent`)
- 우측 상단: **New thread** (대화 초기화), **Show Traces** (도구 호출 과정 확인), **Preview in Snowflake CoWork** (CoWork에서 열기)

Example questions 버튼을 클릭하거나 직접 질문을 입력하여 테스트합니다.

#### 테스트 시나리오

| # | 질문 | 확인 포인트 |
|---|------|------------|
| 1 | "브랜드별 총 매출" | SQL이 정상 생성되고 4개 브랜드 매출이 출력되는지 |
| 2 | "탑텐 객단가 추이" | BRAND='TOPTEN' 필터와 객단가 계산이 올바른지, 차트가 생성되는지 |
| 3 | "라방 매출 현황" | "라방"을 "라이브커머스"로 정확히 매핑하는지 (dict_search 호출 여부 확인) |
| 4 | "사이즈 불만 리뷰 검색" | 매출 도구가 아닌 voc_search를 올바르게 선택하는지 |
| 5 | "ANDZ 매출 하락 원인 분석" | 질문의 전제("하락")가 데이터와 다를 때 사실에 근거하여 정정하는지 (할루시네이션 방지) |

> **참고**: Agent는 Semantic View의 메타데이터만으로 용어를 해석할 수 있다고 판단하면 dict_search를 호출하지 않을 수 있습니다. dict_search는 Semantic View에 정보가 없는 약어나 고유 용어에서 주로 활용됩니다. Trace에서 도구 호출 여부를 확인하고, dict_search 없이도 정확한 결과가 나오는지를 함께 확인하세요.

> **Show Traces로 확인하기**: 우측 상단 **Show Traces**를 켜면 Agent가 어떤 도구를 어떤 순서로 호출했는지 단계별로 확인할 수 있습니다.
>
> 확인할 핵심 포인트:
> 1. **올바른 도구 라우팅**: 매출 질문은 sales_analytics, 리뷰 질문(#4)은 voc_search로 정확히 분기하는지
> 2. **SQL 정확성**: 생성된 SQL의 SELECT/WHERE 절이 질문 의도에 맞는지
> 3. **할루시네이션 방지**: 질문의 전제가 데이터와 다를 때(#5) 데이터에 근거하여 사실을 정정하는지
> 4. **dict_search 활용**: 약어(#3 "라방")에서 dict_search가 호출되었는지, 호출되지 않았다면 결과가 정확한지

> **참고 — Publish와 버전 관리**: 우측 상단 **Publish** 버튼을 누르면 현재 Draft(LIVE) 상태가 불변의 Named Version(`VERSION$1`, `VERSION$2`, ...)으로 확정됩니다. Publish할 때마다 버전이 누적되며, alias(`production` 등)를 부여하여 API/CoWork 트래픽을 특정 버전으로 라우팅하거나 롤백할 수 있습니다. 이번 교육에서는 Preview 테스트까지만 진행합니다.

---

## Chapter 7. Snowflake Cowork (Intelligence) 활용

### 7.1 학습 목표
- Cowork에서 Agent를 사용하는 방법
- 오토메이션, 아티팩트, 커스터마이징 기능

### 7.2 Cowork에서 Agent 사용

#### Agent를 CoWork에 등록

Agent 상세 화면 상단의 `+ Add to Snowflake CoWork` 버튼을 클릭합니다.

> **참고**: 이 버튼을 누르지 않으면 CoWork 화면의 Agent 목록에 표시되지 않습니다. 등록하지 않은 Agent는 직접 링크 또는 Snowsight UI(Preview 탭)에서만 접근 가능합니다.  
>
> **CoWork 오브젝트와 Agent 가시성**: Snowflake CoWork에는 Agent 목록을 중앙 관리하는 "CoWork 오브젝트"라는 계정 수준 설정이 있습니다. 이 오브젝트의 존재 여부에 따라 Agent 표시 방식이 달라집니다.
>
> | CoWork 오브젝트 | Agent 표시 방식 |
> |---|---|
> | **없음** (기본) | USAGE 권한이 있는 모든 Agent가 **자동 표시** |
> | **있음** | `+ Add to Snowflake CoWork`으로 **명시 등록한 Agent만** 표시 |
>
> CoWork 오브젝트는 Snowsight에서 `AI & ML → Agents → Open settings`를 처음 클릭하거나, SQL `CREATE SNOWFLAKE INTELLIGENCE` 명령을 실행하면 생성됩니다. Agent를 만드는 것만으로는 생성되지 않습니다. 현재 교육 환경에서는 이미 존재하므로 위 버튼으로 등록해야 합니다.

#### CoWork에서 질문하기

1. Snowsight 좌측 메뉴 → `AI & ML` → `Snowflake CoWork`
2. 채팅 화면 하단에서 `스노우패션 매출분석(교육)` Agent 선택
3. 질문 입력:
```
탑텐 브랜드의 이번 분기 객단가 추이를 차트로 보여줘
```

### 7.3 오토메이션 (Automation)

정기적으로 반복되는 분석을 자동화할 수 있습니다. Automation이 실행되면 최신 데이터 기준으로 질문을 다시 수행하고, 결과를 이메일로 발송합니다.

> **참고**: Automation은 Preview 기능입니다. 이메일은 Automation을 만든 본인에게 발송됩니다.

**활용 시나리오 예시:**

| 시나리오 | 주기 | 질문 |
|----------|------|------|
| 주간 매출 리포트 | 매주 월요일 오전 9시 | "지난 주 브랜드별 매출 요약과 전주 대비 증감" |
| 일일 VOC 알림 | 매일 오전 8시 | "어제 1-2점 리뷰 중 핵심 불만 요약" |
| 월말 KPI 리포트 | 매월 1일 | "지난 달 브랜드별 매출/객단가/구매고객수 요약" |

**설정 방법 (2가지):**

1. **대화 중 생성**: CoWork에서 질문 → 답변 확인 후 "이 리포트를 매주 월요일에 보내줘" 라고 요청
2. **Automations 탭에서 생성**: CoWork 좌측 `Automations` 탭 → `Create automation` → 이름/질문/주기 설정

### 7.4 아티팩트 (Artifacts)

- 유용한 분석 결과를 **저장** → 재사용 가능
- 팀원에게 **공유** (링크)
- 이전 분석 결과 **히스토리** 추적

### 7.5 커스터마이징

**1. Agent 프로필 설정 (개별 Agent):**

Snowsight `AI & ML` → `Agents` → Agent 선택 → `Edit` 에서 **Display name** 수정 가능.

> **참고**: PROFILE에는 `color` 속성도 있으나, 현재 CoWork UI에서 반영이 확인되지 않으므로 교육에서는 Display name 설정만 다룹니다.

**2. CoWork 인터페이스 설정 (전체 CoWork):**

Snowsight `AI & ML` → `Agents` → `Open settings` 에서 수정:

| 항목 | 설명 |
|------|------|
| Display name | CoWork 전체 표시 이름 |
| Welcome message | 사용자가 처음 접속 시 보이는 메시지 |
| Color theme | CoWork 인터페이스 색상 (hex 코드 지원) |
| Full-length logo / Compact logo | 네비게이션 로고 및 브라우저 탭 아이콘 (투명 배경 PNG 권장) |

### 7.6 데모 시나리오: 비즈니스 사용자 관점

```
시나리오: MD(상품기획) 담당자의 일상 업무

1. "탑텐 아우터 카테고리 이번 달 매출은?"
   → dict_search("탑텐") + sales_analytics → 정확한 매출 수치

2. "아우터 중에서 고객 불만이 많은 부분은?"
   → voc_search → 사이즈/배송/품질 불만 요약

3. "라방 채널 매출이 지난달 대비 어때?"
   → dict_search("라방") + sales_analytics → 라이브커머스 MoM 비교

4. 유용한 답변 → Artifact로 저장 → 팀에 공유
5. "매주 이 분석을 자동으로 보내줘" → Automation 설정
```

---

## Chapter 8. 멀티 도메인 오케스트레이션

### 8.1 학습 목표
- 여러 Semantic View를 하나의 Agent에 연결하는 방법
- Agent Toolsets를 활용한 Agent 간 조합
- 데이터 사전 Search가 멀티 도메인에서 더 중요해지는 이유

### 8.2 왜 멀티 도메인인가?

단일 Semantic View의 한계:
- 매출 + SCM + VOC를 하나의 뷰에 넣으면 테이블이 많아 LLM 혼란
- 도메인별 관리/업데이트가 어려워짐

**데이터 사전 Search가 멀티 도메인에서 더 강력해지는 이유:**
```
질문: "재고 부족 상품의 매출 영향은?"
  ↓
Agent: "재고 부족"이 어느 도메인? → dict_search("재고 부족")
  → 결과: "재고상태 STATUS = '부족'. 테이블: INVENTORY_SNAPSHOT. 도메인: SCM"
  → scm_analytics로 재고 부족 상품 리스트 조회
  → sales_analytics로 해당 상품 매출 조회
  → 종합 분석
```

### 8.3 SCM 분석용 Semantic View 생성

Chapter 3에서 만든 `EDU_SALES_SV`는 매출/고객/상품/매장 데이터를 다룹니다. SCM(공급망) 영역을 추가로 분석하기 위해 재고/발주/배송/벤더 4개 테이블을 묶는 별도의 Semantic View를 생성합니다.

| 테이블 | 설명 | 주요 Fact |
|--------|------|----------|
| INVENTORY_SNAPSHOT | 매장별 일 단위 재고 스냅샷 | 보유재고, 입고대기, 예약수량 |
| SUPPLY_ORDERS | 협력업체 발주 주문 | 발주수량, 원가, 총금액 |
| SHIPMENTS | 발주에 대한 배송 기록 | 출하수량, 지연일수 |
| VENDORS | 협력업체 마스터 | 리드타임, 품질점수 |

> **별도 SQL 파일**: <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_SCM_SV_01_%EC%83%9D%EC%84%B1.sql" target="_blank">`EDU_SCM_SV_01_생성.sql`</a>

```sql
CREATE OR ALTER SEMANTIC VIEW SNOW_FASHION.SEMANTIC.EDU_SCM_SV

  TABLES (
    INVENTORY_SNAPSHOT AS SNOW_FASHION.RAW.INVENTORY_SNAPSHOT
      PRIMARY KEY (SNAPSHOT_DATE, STORE_ID, SKU_ID) ...,
    SUPPLY_ORDERS AS SNOW_FASHION.RAW.SUPPLY_ORDERS
      PRIMARY KEY (ORDER_ID) ...,
    SHIPMENTS AS SNOW_FASHION.RAW.SHIPMENTS
      PRIMARY KEY (SHIPMENT_ID) ...,
    VENDORS AS SNOW_FASHION.RAW.VENDORS
      PRIMARY KEY (VENDOR_ID) ...
  )

  RELATIONSHIPS (
    ORDERS_TO_VENDORS AS SUPPLY_ORDERS (VENDOR_ID) REFERENCES VENDORS,
    SHIPMENTS_TO_ORDERS AS SHIPMENTS (ORDER_ID) REFERENCES SUPPLY_ORDERS,
    SHIPMENTS_TO_VENDORS AS SHIPMENTS (VENDOR_ID) REFERENCES VENDORS
  )

  FACTS ( ... )       -- 11개: 재고수량, 발주수량/원가, 출하수량/지연일수, 리드타임/품질점수
  DIMENSIONS ( ... )  -- 22개: 매장/상품/브랜드/상태, 발주/배송, 벤더 정보

  COMMENT = '스노우패션 SCM 분석 - 재고/발주/배송/벤더 (교육용)';
```

### 8.4 통합 Agent 생성

Chapter 6에서 만든 `EDU_SALES_AGENT`는 매출 Semantic View + 데이터사전 + VOC 3개 도구를 사용합니다. 여기서는 SCM Semantic View를 추가하여 **매출 + SCM + VOC + 데이터사전** 4개 영역을 하나의 Agent에서 분석할 수 있는 통합 Agent를 만듭니다.

| 도구 | 유형 | 데이터 소스 | 분석 영역 |
|------|------|------------|----------|
| sales_analytics | Cortex Analyst | EDU_SALES_SV | 매출/고객/상품/매장 |
| scm_analytics | Cortex Analyst | EDU_SCM_SV | 재고/발주/배송/벤더 |
| dict_search | Cortex Search | EDU_DICT_SEARCH | 비즈니스 용어 사전 |
| voc_search | Cortex Search | EDU_VOC_SEARCH | 고객 리뷰/VOC |
| data_to_chart | 내장 도구 | — | 데이터 시각화 |

> **별도 SQL 파일**: <a href="https://github.com/HongJongHyun/snow-fashion-cortex-hands-on/blob/main/scripts/EDU_UNIFIED_AGENT_%EC%83%9D%EC%84%B1.sql" target="_blank">`EDU_UNIFIED_AGENT_생성.sql`</a>

```sql
CREATE OR REPLACE AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT
  COMMENT = '스노우패션 통합 분석 (매출 + SCM + VOC + 데이터사전) 교육용'
  PROFILE = '{"display_name": "스노우패션 통합분석(교육)"}'
  FROM SPECIFICATION
  $$
  orchestration:
    tool_not_accessible: accept
    budget: { seconds: 90, tokens: 24000 }

  instructions:
    orchestration: |
      당신은 스노우패션의 통합 데이터 분석 전문가입니다.
      -- (도구 선택 규칙, 복합 질문 처리 등 — 전체는 SQL 파일 참조)

    response: |
      한국어 답변. ₩ 단위, 천단위 구분자. 인사이트 + 실행 가능한 제안 포함.

  tools:
    - tool_spec: { type: cortex_analyst_text_to_sql, name: sales_analytics, ... }
    - tool_spec: { type: cortex_analyst_text_to_sql, name: scm_analytics, ... }
    - tool_spec: { type: cortex_search, name: dict_search, ... }
    - tool_spec: { type: cortex_search, name: voc_search, ... }
    - tool_spec: { type: data_to_chart, name: data_to_chart, ... }

  tool_resources:
    sales_analytics: { semantic_view: "SNOW_FASHION.SEMANTIC.EDU_SALES_SV", ... }
    scm_analytics: { semantic_view: "SNOW_FASHION.SEMANTIC.EDU_SCM_SV", ... }
    dict_search: { search_service: "SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH", max_results: 5, ... }
    voc_search: { search_service: "SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH", max_results: 10, ... }
  $$;
```

### 8.5 생성 결과 확인

**Semantic View 확인:**

1. Snowsight → `AI & ML` → `Cortex Analyst`
2. `EDU_SCM_SV`가 목록에 표시되는지 확인
3. 클릭하여 Tables, Relationships, Facts, Dimensions가 정상 등록되었는지 확인

**Agent 확인:**

1. Snowsight → `AI & ML` → `Agents`
2. `EDU_UNIFIED_AGENT`가 목록에 표시되는지 확인
3. 클릭 → `Configuration` → `Tools` 서브탭에서 4개 도구가 모두 등록되었는지 확인:
   - `sales_analytics` (Cortex Analyst → EDU_SALES_SV)
   - `scm_analytics` (Cortex Analyst → EDU_SCM_SV)
   - `dict_search` (Cortex Search → EDU_DICT_SEARCH)
   - `voc_search` (Cortex Search → EDU_VOC_SEARCH)
4. `Configuration` → `Instructions` 서브탭에서 Orchestration/Response 지침이 입력되어 있는지 확인
5. `Preview` 탭으로 이동 → 다음 8.6 데모 시나리오에서 동작을 테스트합니다.

### 8.6 멀티 도메인 데모 시나리오

`Preview` 탭에서 아래 질문들을 테스트합니다. 복수 도구를 순차 사용하여 영역 간 연결 분석이 되는지 확인하세요.

```
Q: "TOPTEN 아우터 재고가 부족한 매장이 있어? 있다면 해당 상품 매출은 어때?"
→ Agent:
  1) scm_analytics → TOPTEN 아우터 재고 부족 매장/상품 조회
  2) sales_analytics → 해당 상품의 매출 현황 조회
  3) 종합: "OO매장에서 패딩 재고 부족 → 해당 상품 매출 전월 대비 -15%"

Q: "배송 지연이 잦은 협력업체 상품에 대한 고객 불만은?"
→ Agent:
  1) scm_analytics → 배송 지연 TOP 벤더 + 상품 리스트
  2) voc_search → 해당 상품 부정적 리뷰 검색
  3) 종합: "XX벤더의 니트 상품 배송 지연 → 고객 리뷰에서 '배송 느림' 불만 다수"
```

### 8.7 CoWork에 통합 Agent 등록

데모 테스트가 완료되면 통합 Agent도 CoWork에 등록합니다.

1. Snowsight → `AI & ML` → `Agents` → `EDU_UNIFIED_AGENT` 선택
2. 상단의 `+ Add to Snowflake CoWork` 버튼 클릭

> **참고**: 7.2에서 안내한 것과 동일하게, 이 버튼을 누르지 않으면 CoWork Agent 목록에 표시되지 않습니다.

---

## Chapter 9. Snowsight CoCo로 반복 개선

### 9.1 학습 목표
- Agent 테스트 → 문제 발견 → CoCo로 수정하는 반복 프로세스
- 수동 SQL vs CoCo 자연어 수정 비교

### 9.2 CoCo를 활용한 개선 프로세스

```
1. Agent 테스트 (Playground 또는 Cowork)
   ↓
2. 부정확한 답변 발견
   ↓
3. 원인 파악:
   ├── 용어를 모름 → 데이터 사전에 항목 추가 (INSERT)
   ├── SQL이 잘못됨 → Verified Query 추가
   ├── 컬럼 의미 오해 → Description 보강
   ├── 도구 선택 오류 → Planning Instruction 수정
   └── 답변 형식 부적절 → Response Instruction 수정
   ↓
4. CoCo 또는 수동으로 수정
   ↓
5. 재테스트 → 1로 돌아감
```

### 9.3 CoCo 수정 예시

**시나리오 1: 새 비즈니스 용어를 데이터 사전에 추가**

Step 1 — 테이블에 데이터 추가:
```
CoCo에게: "EDU_DATA_DICTIONARY 테이블에 '재고회전율' 용어를 추가해줘.
동의어는 inventory turnover이고, 
계산식은 SUM(판매수량) / AVG(보유재고) 이야.
도메인은 SCM이야."
```

Step 2 — 테이블 반영 확인:
```sql
SELECT * FROM SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY WHERE TERM = '재고회전율';
```

Step 3 — Search Service에 즉시 반영:
> **참고**: 테이블에 데이터를 추가해도 Cortex Search Service에는 바로 반영되지 않습니다. `TARGET_LAG` 설정에 따라 자동 갱신되지만, 즉시 반영하려면 수동 Refresh가 필요합니다.

```
CoCo에게: "EDU_DICT_SEARCH Cortex Search Service를 수동으로 refresh 해줘."
```
또는 직접 SQL 실행:
```sql
ALTER CORTEX SEARCH SERVICE SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH REFRESH;
```

Step 4 — Agent에서 확인:

Agent Preview 또는 CoWork에서 "재고회전율이 뭐야?" 질문 → `dict_search`를 통해 방금 추가한 용어가 검색되는지 확인

**시나리오 2: Semantic View에 VQR 추가**
```
CoCo에게: "EDU_SALES_SV Semantic View에 Verified Query를 추가해줘.
질문: '분기별 브랜드 매출은?'
SQL은 DATE_TRUNC('QUARTER', TXN_DATE) 기준으로 BRAND별 SUM(SALE_AMOUNT)."
```
확인: Snowsight → `AI & ML` → `Cortex Analyst` → `EDU_SALES_SV` → `Verified Queries` 탭에서 새 VQR이 추가되었는지 확인

**시나리오 3: Agent Instruction 수정**
```
CoCo에게: "EDU_UNIFIED_AGENT의 Response Instruction에 추가해줘:
'전년 동기 대비 분석 시 반드시 비교 기간을 명시하세요. 
예: 2025년 Q3 vs 2024년 Q3'"
```

> **참고**: Orchestration Instruction은 도구 선택/순서 등 **분석 전략**에 관한 지침, Response Instruction은 답변 형식/톤 등 **응답 방식**에 관한 지침입니다. 이 시나리오는 응답에 비교 기간을 표시하라는 내용이므로 Response 쪽이 적절합니다.
확인: Snowsight → `AI & ML` → `Agents` → `EDU_UNIFIED_AGENT` → `Configuration` → `Instructions` 서브탭에서 Response 지침에 문구가 추가되었는지 확인

---

## Chapter 10. 모니터링, 피드백, 비용 관리

### 10.1 학습 목표
- Agent 응답 품질 모니터링 방법
- 사용자 피드백 수집 → 반영 프로세스
- Cortex AI 비용 구조 이해 및 확인

### 10.2 Agent 모니터링

Snowsight `AI & ML` → `Agents` → Agent 선택 → `Threads` 탭:
- 사용자별 질문 내역
- 도구 호출 로그 (어떤 도구가 사용되었는지)
- 생성된 SQL 검토
- 응답 시간

| 지표 | 확인 방법 | 개선 액션 |
|------|-----------|----------|
| 도구 선택 정확도 | Thread 도구 호출 확인 | Instruction 개선 |
| SQL 정확도 | 생성 SQL 검토 | VQR 추가 |
| 용어 매핑 정확도 | dict_search 결과 확인 | 데이터 사전 보강 |
| 응답 시간 | Thread 타임스탬프 | Budget/웨어하우스 조정 |
| 사용자 만족도 | Cowork 피드백 | 전반적 개선 |

### 10.3 피드백 기반 개선 루프

```
Cowork 👎 피드백 수집
   │
문제 분류:
   ├── Agent가 용어를 모름 → EDU_DATA_DICTIONARY에 항목 추가
   ├── SQL 부정확 → VQR 추가 또는 Semantic View 개선
   ├── 도구 선택 오류 → Planning Instruction 수정
   ├── 검색 부적절 → Search 필터/설정 조정
   └── 답변 형식 불만 → Response Instruction 수정
   │
수정 적용 → 재테스트 → 재배포
```

### 10.4 Agent 버전 관리

```sql
-- LIVE 버전을 커밋하여 새 Named Version 생성 (예: VERSION$2)
ALTER AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT COMMIT
  COMMENT = 'Instructions 수정 반영';

-- 문제 시 이전 버전으로 롤백 (기본 버전 변경)
ALTER AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT
  SET DEFAULT_VERSION = 'VERSION$1';

-- 특정 버전에 alias 부여 (예: production)
ALTER AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT
  MODIFY VERSION VERSION$2 SET ALIAS = production;

-- 버전 목록 확인
SHOW VERSIONS IN AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT;

-- 커밋 후 LIVE 버전 재개 (최근 커밋본에서 다시 편집)
ALTER AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT ADD LIVE VERSION FROM LAST;
```

### 10.5 비용 확인

#### 비용 구조

| 항목 | 과금 기준 |
|------|-----------|
| Agent 오케스트레이션 | 토큰 사용량 (크레딧) |
| Cortex Analyst | 토큰 사용량 (크레딧) |
| Cortex Search | 웨어하우스 리프레시 + 임베딩 토큰 + 서빙(GB-month) + 스토리지 |
| Warehouse | SQL 실행 시간 (크레딧) |
| Code Execution | Preview — 별도 과금 구조 미공개 |

> **참고**: Cortex Search 비용은 `METERING_DAILY_HISTORY`의 `CORTEX_SEARCH` 타입 외에 전용 뷰 `CORTEX_SEARCH_DAILY_USAGE_HISTORY`, `CORTEX_SEARCH_SERVING_USAGE_HISTORY`에서 상세 확인 가능합니다.

#### 비용 조회 SQL

```sql
-- Cortex AI 관련 서비스별 일별 크레딧 사용량 (최근 30일)
-- SERVICE_TYPE 이름은 계정/시점에 따라 다를 수 있음
SELECT 
  SERVICE_TYPE,
  USAGE_DATE,
  CREDITS_USED
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
WHERE SERVICE_TYPE IN (
    'CORTEX_AGENTS',        -- Agent 오케스트레이션
    'AI_SERVICES',          -- Cortex AI Functions + Cortex Analyst
    'AI_FUNCTIONS',         -- AI_COMPLETE, AI_EXTRACT 등
    'CORTEX_SEARCH',        -- Cortex Search 서빙/인덱싱
    'CORTEX_AI_GUARDRAILS', -- AI 가드레일
    'SNOWFLAKE_COWORK'      -- CoWork
  )
  AND USAGE_DATE >= DATEADD('DAY', -30, CURRENT_DATE())
ORDER BY USAGE_DATE DESC, CREDITS_USED DESC;
```

> **참고**: SERVICE_TYPE 이름은 릴리스에 따라 변경될 수 있습니다. 현재 계정에서 실제 사용 중인 타입을 확인하려면:
> ```sql
> SELECT DISTINCT SERVICE_TYPE FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY 
> WHERE USAGE_DATE >= DATEADD('DAY', -7, CURRENT_DATE()) ORDER BY 1;
> ```

#### 상세 비용 조회 (전용 뷰)

Cortex Search와 Cortex Analyst는 전용 뷰에서 서비스별/사용자별 상세 내역을 확인할 수 있습니다.

```sql
-- Cortex Search: 교육용 서비스별 일별 크레딧 (서빙/임베딩)
SELECT
  USAGE_DATE,
  SERVICE_NAME,
  CONSUMPTION_TYPE,
  SUM(CREDITS) AS CREDITS
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_DAILY_USAGE_HISTORY
WHERE USAGE_DATE >= DATEADD('DAY', -30, CURRENT_DATE())
  AND DATABASE_NAME = 'SNOW_FASHION'
  AND SERVICE_NAME IN ('EDU_DICT_SEARCH', 'EDU_VOC_SEARCH')
GROUP BY 1, 2, 3
ORDER BY 1 DESC, 4 DESC;
```

```sql
-- Cortex Analyst: 사용자별 요청수/크레딧
SELECT
  DATE_TRUNC('DAY', START_TIME) AS USAGE_DATE,
  USERNAME,
  SUM(REQUEST_COUNT) AS REQUESTS,
  SUM(CREDITS) AS CREDITS
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_ANALYST_USAGE_HISTORY
WHERE START_TIME >= DATEADD('DAY', -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, CREDITS DESC;
```

#### 비용 최적화

| 방법 | 설명 |
|------|------|
| Agent Budget | `seconds: 60, tokens: 16000`으로 과도한 소비 방지 |
| Warehouse AUTO_SUSPEND | 60초 미사용 시 자동 중단 |
| Search TARGET_LAG | 실시간 불필요 시 '1 day' |
| VQR 활용 | VQR 매칭 시 SQL 생성 정확도 향상 + 지연 감소 |
| 데이터 사전 활용 | Agent가 사전에서 바로 답 얻으면 Analyst 호출 줄어듦 |

### 10.6 운영 체크리스트

| 주기 | 작업 | 담당 |
|------|------|------|
| 매일 | Cowork 피드백(👎) 확인 | AI 담당자 |
| 매주 | Agent Thread 샘플링 검토 | 데이터팀 |
| 매주 | AI 크레딧 사용량 모니터링 | 인프라팀 |
| 격주 | 데이터 사전 보강 (오답 패턴 기반) | 데이터팀 |
| 격주 | VQR 추가/수정 | 데이터팀 |
| 매월 | Semantic View 메트릭 업데이트 | 데이터팀 |
| 분기 | 도메인 Semantic View 추가 검토 | 기획팀 + 데이터팀 |

---

## 부록 A. Instruction 작성 가이드

### Orchestration Instruction과 Response Instruction의 차이

| 구분 | Orchestration Instruction | Response Instruction |
|------|--------------------------|---------------------|
| 목적 | **분석 전략** — 어떤 도구를 언제, 어떤 순서로 사용할지 | **응답 형식** — 답변의 톤, 포맷, 언어, 포함할 내용 |
| 예시 | "환불 관련 질문은 Search 도구 사용" | "항상 간결하게, 친근한 톤으로 답변" |
| 예시 | "생소한 용어가 있으면 dict_search 먼저" | "₩ 단위, 천단위 구분자 사용" |
| 예시 | "매출 분석 → sales_analytics, SCM → scm_analytics" | "차트를 우선적으로 생성" |

### Orchestration Instruction 템플릿

```
[역할 정의]
당신은 OOO의 데이터 분석 전문가입니다.

[데이터 사전 활용 규칙]
생소한 용어/약어가 있으면 먼저 dict_search로 검색하세요.

[도구 선택 기준]
■ 질문 유형 → 사용 도구
- 정량적 분석 → analyst_tool_name
- 비정형 검색 → search_tool_name
- 데이터 가공 → code_execution

[복합 질문 처리]
여러 도구가 필요한 경우의 조합 규칙

[비즈니스 컨텍스트]
도메인 특화 정보
```

### Response Instruction 템플릿

```
[언어/톤]
한국어로 답변. 비즈니스 전문가 톤.

[숫자 포맷]
₩ 단위, 천단위 구분자. 소수점 1자리.

[응답 구조]
1. 핵심 수치/결과
2. 분석 인사이트
3. 실행 가능한 제안

[차트]
가능하면 차트를 포함하세요.

[불확실한 경우]
데이터로 확인할 수 없는 내용은 가정을 명시하세요.
```

### Instruction 작성 원칙

| 원칙 | Good | Bad |
|------|------|-----|
| 구체적 도구 매핑 | "매출 → sales_analytics" | "적절히 사용해" |
| 사전 검색 유도 | "모르는 용어는 dict_search" | (규칙 없음) |
| 고유값 명시 | "채널: 오프라인, 온라인몰..." | "여러 채널 있음" |
| 복합 처리 순서 | "수치 확인 후 원인 탐색" | (단일 도구만) |
| 한계 인정 | "불확실하면 가정 명시" | (항상 자신있게) |
| 내용이 길어지면 목차 구조 | 위 템플릿처럼 `[섹션명]`으로 구분 | 긴 문장을 한 덩어리로 작성 |

### Tool Description 작성 가이드

Tool Description은 Agent가 도구를 선택하는 핵심 판단 기준입니다. 부정확한 설명은 잘못된 도구 호출과 hallucination으로 이어집니다.

| 포함할 내용 | 예시 |
|------------|------|
| 도구가 **무엇을 하는지** | "매출/고객/상품/매장 데이터를 SQL로 분석" |
| **어떤 데이터**에 접근하는지 | "SALES_TRANSACTIONS, PRODUCTS, STORES, CUSTOMERS 테이블" |
| **언제** 사용해야 하는지 | "매출, 객단가, 구매 고객 등 정량적 분석 질문에 사용" |
| **언제 사용하면 안 되는지** | "고객 리뷰/VOC 분석에는 사용하지 마세요" |

> **출처**: Snowflake 공식 문서 "Build agents" — *Write a useful tool description*

---

## 부록 B. 교육 환경 사전 준비

### 데이터 환경 구축 (첫 교육 시 1회)

배포 패키지의 `scripts/`와 `data/` 폴더를 사용합니다.

**Step 1: DB, Schema, Warehouse, Table 생성**

Snowsight 워크시트에서 `scripts/00_setup_db.sql`을 열어 실행합니다.
- SNOW_FASHION 데이터베이스, RAW/ANALYTICS/SEMANTIC 스키마, SF_WH 웨어하우스, 12개 테이블이 생성됩니다.

**Step 2: CSV 데이터 업로드**

`data/` 폴더의 `.csv.gz` 파일 12개를 Snowflake에 업로드합니다.

방법 A: **Snowsight UI** (간단)
1. Snowsight → `SNOW_FASHION` → `RAW` 스키마 → 각 테이블 선택
2. `Load Data` 클릭 → `.csv.gz` 파일 선택 → 업로드

방법 B: **SnowSQL / Snowflake CLI** (일괄)
```bash
# data/ 폴더 경로를 01_load_data.sql 내 PUT 경로에 맞게 수정 후 실행
snow sql -f scripts/01_load_data.sql -c <연결명>
```

**Step 3: 데이터 확인**
```sql
SELECT 'CUSTOMERS' AS TBL, COUNT(*) AS CNT FROM SNOW_FASHION.RAW.CUSTOMERS
UNION ALL SELECT 'SALES_TRANSACTIONS', COUNT(*) FROM SNOW_FASHION.RAW.SALES_TRANSACTIONS
UNION ALL SELECT 'STORES', COUNT(*) FROM SNOW_FASHION.RAW.STORES;
-- CUSTOMERS: 500,000 / SALES_TRANSACTIONS: 2,506,622 / STORES: 300 이면 정상
```

### 강사 사전 준비
- [ ] 웨어하우스 생성: `CREATE WAREHOUSE IF NOT EXISTS SF_WH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;`
- [ ] SEMANTIC 스키마 생성: `CREATE SCHEMA IF NOT EXISTS SNOW_FASHION.SEMANTIC;`
- [ ] CoCo 사용을 위한 롤 부여:
  ```sql
  GRANT DATABASE ROLE SNOWFLAKE.COPILOT_USER TO ROLE <교육_참석자_롤>;
  GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE <교육_참석자_롤>;
  ```
- [ ] `EDU_SALES_SV` Semantic View 생성 완료
- [ ] `EDU_SCM_SV` Semantic View 생성 완료
- [ ] `EDU_DATA_DICTIONARY` 테이블 적재 완료
- [ ] `EDU_DICT_SEARCH` Cortex Search Service 생성 완료
- [ ] `EDU_VOC_SEARCH` Cortex Search Service 생성 완료
- [ ] `EDU_SALES_AGENT` Agent 생성 + 테스트 완료
- [ ] `EDU_UNIFIED_AGENT` Agent 생성 + 테스트 완료
- [ ] Cowork에서 Agent 동작 테스트 완료

### 참석자 사전 준비
- [ ] Snowflake 계정 접속 확인 (Snowsight)
- [ ] SNOW_FASHION 데이터베이스 읽기 권한
- [ ] SF_WH 웨어하우스 사용 권한

---

## 부록 C. 2부 예고: CoCo Desktop 활용

2부에서는 **CoCo Desktop(로컬 설치형)**을 활용합니다:

| 주제 | 내용 |
|------|------|
| CoCo Desktop 설치 | 설치, PAT 설정, Snowflake 연결 |
| Streamlit 앱 빌드 | 자연어 → Streamlit 코드 → SiS 배포 |
| Snowflake App Runtime | Next.js 앱 → SPCS 배포 |
| Semantic View 수정 | CoCo Desktop에서 SV 고도화 |
| 스킬/플러그인 | 고급 자동화 팁 |

---

## 부록 D. 교육 리소스 초기화 (Cleanup)

> 교육을 반복 진행하기 위해, 교안에서 생성한 모든 오브젝트를 삭제하는 SQL입니다.
> **주의: 기존 데이터 테이블(RAW 스키마)은 삭제하지 않습니다. EDU_ 접두사 오브젝트만 삭제합니다.**

```sql
-- ═══════════════════════════════════════════════
-- 교육 리소스 전체 초기화 (EDU_ 접두사 오브젝트)
-- 실행 순서: Agent → Search Service → Semantic View → Table
-- (의존성 역순으로 삭제)
-- ═══════════════════════════════════════════════

-- 1. Agent 삭제 (Search/Semantic View를 참조하므로 먼저)
DROP AGENT IF EXISTS SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT;
DROP AGENT IF EXISTS SNOW_FASHION.SEMANTIC.EDU_SALES_AGENT;

-- 2. Cortex Search Service 삭제
DROP CORTEX SEARCH SERVICE IF EXISTS SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH;
DROP CORTEX SEARCH SERVICE IF EXISTS SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH;

-- 3. Semantic View 삭제
DROP SEMANTIC VIEW IF EXISTS SNOW_FASHION.SEMANTIC.EDU_SALES_SV;
DROP SEMANTIC VIEW IF EXISTS SNOW_FASHION.SEMANTIC.EDU_SCM_SV;

-- 4. 데이터 사전 테이블 삭제
DROP TABLE IF EXISTS SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY;

-- 확인
SHOW AGENTS IN SCHEMA SNOW_FASHION.SEMANTIC;
SHOW CORTEX SEARCH SERVICES IN SCHEMA SNOW_FASHION.SEMANTIC;
SHOW SEMANTIC VIEWS IN SCHEMA SNOW_FASHION.SEMANTIC;
```

---

*교안 버전: v2.0*  
*작성일: 2026-09-03*  
*변경 이력: v1.0 → v2.0: 교육용 EDU_ 접두사 분리, 데이터 사전 Search 챕터 추가*  
*대상 고객: 스노우패션*
