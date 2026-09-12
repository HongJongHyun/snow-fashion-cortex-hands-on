-- ============================================================
-- EDU_SALES_SV Step 3: Metric 추가
-- 
-- Step 1(Fact/Dimension 수정) + Step 2(한국어 Description)에 이어서,
-- 비즈니스 KPI 메트릭을 추가합니다.
--
-- 변경 내용:
--   1) Fact/Dimension 수정 (Step 1과 동일)
--   2) 한국어 Description (Step 2와 동일)
--   3) METRICS 6개 추가: TOTAL_REVENUE, TOTAL_QTY_SOLD, AVG_ORDER_VALUE,
--      TRANSACTION_COUNT, UNIQUE_CUSTOMERS, AVG_DISCOUNT_RATE
--
-- 참고: 이 파일은 CREATE OR ALTER로 전체 정의를 다시 작성하므로,
--       EDU_SALES_SV_01, 02의 변경 내용이 모두 포함되어 있습니다.
--       이 파일만 실행해도 Step 1+2+3이 모두 적용됩니다.
-- ============================================================

CREATE OR ALTER SEMANTIC VIEW SNOW_FASHION.SEMANTIC.EDU_SALES_SV

  TABLES (
    PRODUCTS AS SNOW_FASHION.RAW.PRODUCTS
      PRIMARY KEY (SKU_ID)
      COMMENT = 'The table contains records of individual products in a retail catalog. Each record represents a single product and includes details about its classification (brand, category, and subcategory), attributes (color, size, gender, and season), and pricing, along with availability and launch information.',

    SALES_TRANSACTIONS AS SNOW_FASHION.RAW.SALES_TRANSACTIONS
      PRIMARY KEY (TXN_ID)
      COMMENT = 'The table contains records of individual sales transactions. Each record captures details about the customer, store, and product involved, along with transaction timing, sales channel, and financial details such as pricing, discounts, and payment method.',

    CUSTOMERS AS SNOW_FASHION.RAW.CUSTOMERS
      PRIMARY KEY (CUSTOMER_ID)
      COMMENT = 'The table contains records of individual customers and their associated profile and behavioral attributes. Each record represents a single customer and includes demographic details, membership information, acquisition data, and purchase activity status.',

    STORES AS SNOW_FASHION.RAW.STORES
      PRIMARY KEY (STORE_ID)
      COMMENT = 'The table contains records of physical store locations. Each record represents a single store and includes details about its identity and branding, geographic location, operational status, and physical characteristics such as size and store type.'
  )

  RELATIONSHIPS (
    SALES_TRANSACTIONS_TO_PRODUCTS AS SALES_TRANSACTIONS(SKU_ID) REFERENCES PRODUCTS(SKU_ID),
    SALES_TRANSACTIONS_TO_STORES AS SALES_TRANSACTIONS(STORE_ID) REFERENCES STORES(STORE_ID)
  )

  -- ============================================================
  -- FACTS: Autopilot이 이미 올바르게 분류한 것 + 수정 대상 4개
  -- ============================================================
  FACTS (
    -- SALES_TRANSACTIONS (기존 Fact - Autopilot 정확)
    SALES_TRANSACTIONS.DISCOUNT_RATE AS DISCOUNT_RATE
      COMMENT = '할인율. 0.00=무할인, 0.30=30%할인. 범위: 0.00~0.50'
      SAMPLE_VALUES ('0.11', '0.00', '0.25'),
    SALES_TRANSACTIONS.QUANTITY AS QUANTITY
      COMMENT = '판매 수량'
      SAMPLE_VALUES ('3', '2', '1'),
    SALES_TRANSACTIONS.SALE_AMOUNT AS SALE_AMOUNT
      COMMENT = '실 결제 금액 (원). 할인 적용 후 최종 결제 금액'
      SAMPLE_VALUES ('164500', '10440', '12600'),

    -- SALES_TRANSACTIONS (수정: Dimension → Fact)
    SALES_TRANSACTIONS.UNIT_PRICE AS UNIT_PRICE
      COMMENT = '개당 판매 단가 (원)'
      SAMPLE_VALUES ('6670', '56120', '127211'),

    -- PRODUCTS (수정: Dimension → Fact)
    PRODUCTS.COST_PRICE AS COST_PRICE
      COMMENT = '상품 원가 (원). 마진 계산에 사용: RETAIL_PRICE - COST_PRICE'
      SAMPLE_VALUES ('44000', '16200', '28000'),
    PRODUCTS.RETAIL_PRICE AS RETAIL_PRICE
      COMMENT = '상품 정가 (원). 할인 전 소비자 가격'
      SAMPLE_VALUES ('60000', '28100', '17500'),

    -- STORES (기존 Fact - Autopilot 정확)
    STORES.AREA_SQM AS AREA_SQM
      COMMENT = '매장 면적 (제곱미터)'
      SAMPLE_VALUES ('265.0', '203.0', '198.0'),

    -- CUSTOMERS (수정: Dimension → Fact)
    CUSTOMERS.TOTAL_PURCHASES AS TOTAL_PURCHASES
      COMMENT = '고객별 누적 구매 횟수'
      SAMPLE_VALUES ('0')
  )

  -- ============================================================
  -- DIMENSIONS: 수정 대상 4개를 제외한 나머지 (Autopilot 분류 유지)
  -- ============================================================
  DIMENSIONS (
    -- PRODUCTS
    PRODUCTS.BRAND AS BRAND
      COMMENT = '브랜드명. 허용값: TOPTEN, ZIOZIA, OLZEN, ANDZ'
      SAMPLE_VALUES ('TOPTEN', 'OLZEN', 'ZIOZIA'),
    PRODUCTS.CATEGORY AS CATEGORY
      COMMENT = '상품 대분류. 허용값: 아우터, 상의, 하의, 액세서리, 언더웨어'
      SAMPLE_VALUES ('아우터', '액세서리', '하의'),
    PRODUCTS.COLOR AS COLOR
      COMMENT = '상품 색상'
      SAMPLE_VALUES ('블루', '네이비', '핑크'),
    PRODUCTS.GENDER AS GENDER
      COMMENT = '대상 성별. 허용값: 남성, 여성, 공용'
      SAMPLE_VALUES ('여성', '공용', '남성'),
    PRODUCTS.IS_ACTIVE AS IS_ACTIVE
      COMMENT = '상품 활성 여부'
      SAMPLE_VALUES ('TRUE'),
    PRODUCTS.PRODUCT_NAME AS PRODUCT_NAME
      COMMENT = '상품 전체 이름 (브랜드 + 카테고리 + 색상 + 사이즈)'
      SAMPLE_VALUES ('ZIOZIA 가방 블루 S', 'OLZEN 패딩 네이비 S', 'ZIOZIA 내의 블루 XS'),
    PRODUCTS.SEASON AS SEASON
      COMMENT = '시즌. 허용값: SS24(2024 봄여름), FW24(2024 가을겨울), SS25(2025 봄여름), FW25(2025 가을겨울)'
      SAMPLE_VALUES ('FW24', 'SS24', 'SS25'),
    PRODUCTS.SEASON_YEAR AS SEASON_YEAR
      COMMENT = '시즌 연도'
      SAMPLE_VALUES ('2024', '2025'),
    PRODUCTS.SIZE_GROUP AS SIZE_GROUP
      COMMENT = '사이즈 그룹'
      SAMPLE_VALUES ('S', 'FREE', 'XS'),
    PRODUCTS.SKU_ID AS SKU_ID
      COMMENT = '상품 고유 식별자 (SKU)'
      SAMPLE_VALUES ('AZ-000019', 'AZ-000153', 'TT-000139'),
    PRODUCTS.SUB_CATEGORY AS SUB_CATEGORY
      COMMENT = '상품 소분류. 허용값: 패딩, 코트, 점퍼, 자켓, 티셔츠, 셔츠, 니트, 맨투맨, 후드, 슬랙스, 청바지, 면바지, 반바지, 양말, 벨트, 모자, 머플러, 가방, 내의, 속옷세트'
      SAMPLE_VALUES ('점퍼', '가방', '청바지'),
    PRODUCTS.CREATED_AT AS CREATED_AT
      COMMENT = '상품 레코드 생성 일시'
      SAMPLE_VALUES ('2026-09-01T10:51:46.720Z', '2026-09-01T10:52:01.208Z'),
    PRODUCTS.LAUNCH_DATE AS LAUNCH_DATE
      COMMENT = '상품 출시일'
      SAMPLE_VALUES ('2024-02-27', '2024-05-17', '2025-08-23'),

    -- SALES_TRANSACTIONS
    SALES_TRANSACTIONS.BRAND AS BRAND
      COMMENT = '브랜드명. 허용값: TOPTEN, ZIOZIA, OLZEN, ANDZ'
      SAMPLE_VALUES ('OLZEN', 'ZIOZIA', 'TOPTEN'),
    SALES_TRANSACTIONS.CHANNEL AS CHANNEL
      COMMENT = '판매 채널. 허용값: 오프라인, 온라인몰, 모바일앱, 라이브커머스'
      SAMPLE_VALUES ('라이브커머스', '모바일앱', '온라인몰'),
    SALES_TRANSACTIONS.CUSTOMER_ID AS CUSTOMER_ID
      COMMENT = '고객 고유 식별자'
      SAMPLE_VALUES ('C-00223016', 'C-00080677', 'C-00305509'),
    SALES_TRANSACTIONS.PAYMENT_METHOD AS PAYMENT_METHOD
      COMMENT = '결제 수단. 허용값: 신용카드, 간편결제, 체크카드, 현금'
      SAMPLE_VALUES ('현금', '간편결제', '체크카드'),
    SALES_TRANSACTIONS.SKU_ID AS SKU_ID
      COMMENT = '상품 고유 식별자 (SKU)'
      SAMPLE_VALUES ('TT-004430', 'AZ-001348', 'TT-000217'),
    SALES_TRANSACTIONS.STORE_ID AS STORE_ID
      COMMENT = '매장 고유 식별자'
      SAMPLE_VALUES ('SZ-0028', 'SO-0001', 'SZ-0010'),
    SALES_TRANSACTIONS.TXN_ID AS TXN_ID
      COMMENT = '거래 고유 식별자'
      SAMPLE_VALUES ('T-V0054716', 'T-V0054624', 'T-V0054670'),
    SALES_TRANSACTIONS.TXN_DATE AS TXN_DATE
      COMMENT = '거래 일자'
      SAMPLE_VALUES ('2025-08-30', '2025-09-09', '2025-07-11'),
    SALES_TRANSACTIONS.TXN_TIME AS TXN_TIME
      COMMENT = '거래 일시 (Timestamp)'
      SAMPLE_VALUES ('2025-11-06T20:58:40.000Z', '2025-01-01T10:45:52.000Z', '2024-12-09T15:28:05.000Z'),

    -- CUSTOMERS
    CUSTOMERS.AGE_GROUP AS AGE_GROUP
      COMMENT = '연령대. 허용값: 10대, 20대, 30대, 40대, 50대, 60대+'
      SAMPLE_VALUES ('20대', '10대', '40대'),
    CUSTOMERS.CUSTOMER_ID AS CUSTOMER_ID
      COMMENT = '고객 고유 식별자'
      SAMPLE_VALUES ('C-00000044', 'C-00000078', 'C-00000232'),
    CUSTOMERS.GENDER AS GENDER
      COMMENT = '성별. 허용값: 남성, 여성'
      SAMPLE_VALUES ('여성', '남성'),
    CUSTOMERS.IS_ACTIVE AS IS_ACTIVE
      COMMENT = '고객 활성 여부'
      SAMPLE_VALUES ('FALSE', 'TRUE'),
    CUSTOMERS.MEMBERSHIP_TIER AS MEMBERSHIP_TIER
      COMMENT = '멤버십 등급. 허용값: BASIC, SILVER, GOLD, VIP. BASIC이 최하위, VIP가 최상위'
      SAMPLE_VALUES ('SILVER', 'GOLD', 'VIP'),
    CUSTOMERS.REGION AS REGION
      COMMENT = '거주 지역. 허용값: 서울, 경기, 인천, 부산, 대구, 광주, 대전, 울산, 경남, 경북, 충남'
      SAMPLE_VALUES ('부산', '서울', '경기'),
    CUSTOMERS.SIGNUP_CHANNEL AS SIGNUP_CHANNEL
      COMMENT = '가입 경로. 허용값: 매장방문, 온라인몰, 앱설치, SNS'
      SAMPLE_VALUES ('매장방문', 'SNS', '온라인몰'),
    CUSTOMERS.SIGNUP_DATE AS SIGNUP_DATE
      COMMENT = '고객 가입일'
      SAMPLE_VALUES ('2026-04-05', '2026-04-03', '2024-04-30'),

    -- STORES
    STORES.BRAND AS BRAND
      COMMENT = '매장 브랜드. 허용값: TOPTEN, ZIOZIA, OLZEN, ANDZ'
      SAMPLE_VALUES ('ANDZ', 'TOPTEN', 'OLZEN'),
    STORES.CITY AS CITY
      COMMENT = '매장 소재 도시'
      SAMPLE_VALUES ('인천', '경기', '서울'),
    STORES.DISTRICT AS DISTRICT
      COMMENT = '매장 소재 구/시'
      SAMPLE_VALUES ('성남시', '영등포구', '안양시'),
    STORES.IS_ACTIVE AS IS_ACTIVE
      COMMENT = '매장 영업 여부'
      SAMPLE_VALUES ('TRUE'),
    STORES.REGION AS REGION
      COMMENT = '매장 지역권. 허용값: 수도권, 영남권, 충청권, 호남권, 강원제주'
      SAMPLE_VALUES ('수도권', '영남권', '충청권'),
    STORES.STORE_ID AS STORE_ID
      COMMENT = '매장 고유 식별자'
      SAMPLE_VALUES ('SZ-0022', 'ST-0150', 'ST-0054'),
    STORES.STORE_NAME AS STORE_NAME
      COMMENT = '매장 전체 이름 (브랜드 + 지역 + 구점)'
      SAMPLE_VALUES ('TOPTEN 청주 흥덕구점', 'ANDZ 인천 남동구점', 'ANDZ 서울 서초구점'),
    STORES.STORE_TYPE AS STORE_TYPE
      COMMENT = '매장 유형. 허용값: 직영점, 대리점, 백화점, 아울렛, 온라인전용'
      SAMPLE_VALUES ('대리점', '아울렛', '온라인전용'),
    STORES.OPEN_DATE AS OPEN_DATE
      COMMENT = '매장 오픈일'
      SAMPLE_VALUES ('2023-07-25', '2024-12-13', '2024-06-14')
  )

  -- ============================================================
  -- METRICS: 비즈니스 KPI 메트릭
  -- ============================================================
  METRICS (
    SALES_TRANSACTIONS.TOTAL_REVENUE AS SUM(SALE_AMOUNT)
      COMMENT = '총 매출 금액 (원)',
    SALES_TRANSACTIONS.TOTAL_QTY_SOLD AS SUM(QUANTITY)
      COMMENT = '총 판매 수량',
    SALES_TRANSACTIONS.AVG_ORDER_VALUE AS AVG(SALE_AMOUNT)
      COMMENT = '객단가: 건당 평균 결제 금액 (원)',
    SALES_TRANSACTIONS.TRANSACTION_COUNT AS COUNT(TXN_ID)
      COMMENT = '총 거래 건수',
    SALES_TRANSACTIONS.UNIQUE_CUSTOMERS AS COUNT(DISTINCT CUSTOMER_ID)
      COMMENT = '구매 고객 수 (유니크)',
    SALES_TRANSACTIONS.AVG_DISCOUNT_RATE AS AVG(DISCOUNT_RATE)
      COMMENT = '평균 할인율'
  );
