-- ============================================================
-- EDU_DATA_DICTIONARY 테이블 생성 및 데이터 적재
--
-- 데이터 사전 테이블을 생성하고, 비즈니스 용어(TERM)와 
-- 컬럼 값 설명(VALUE) 데이터를 적재합니다.
-- ============================================================

-- 데이터 사전 테이블 생성
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

-- ═══════════════════════════════════════════════
-- 1. 비즈니스 용어 (TERM) - Agent가 가장 많이 참조
-- ═══════════════════════════════════════════════

INSERT INTO SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY 
  (ENTRY_TYPE, TABLE_NAME, COLUMN_NAME, TERM, SYNONYMS, DESCRIPTION, DOMAIN)
VALUES
-- 매출 관련 용어
('TERM', 'SALES_TRANSACTIONS', 'SALE_AMOUNT', '매출액',
 '매출, 총매출, 매출금액, 실적, revenue',
 '매출액(매출, 총매출, 매출금액, 실적, revenue)은 실 결제 금액의 합계입니다. 계산: SUM(SALE_AMOUNT). 할인이 적용된 후의 최종 결제 금액입니다. 테이블: SALES_TRANSACTIONS.', '매출'),

('TERM', 'SALES_TRANSACTIONS', 'SALE_AMOUNT', '객단가',
 '건당매출, 평균주문금액, 평균결제금액, AOV, average order value',
 '객단가(건당매출, 평균주문금액, 평균결제금액, AOV, average order value)는 거래 1건당 평균 결제 금액입니다. 계산: AVG(SALE_AMOUNT). 메트릭: AVG_ORDER_VALUE. 고객이 한 번 구매할 때 평균적으로 지출하는 금액. 테이블: SALES_TRANSACTIONS.', '매출'),

('TERM', 'SALES_TRANSACTIONS', NULL, '거래건수',
 '주문건수, 거래수, 판매건수, transaction count',
 '거래건수(주문건수, 거래수, 판매건수, transaction count)는 매출 거래의 총 건수입니다. 계산: COUNT(TXN_ID). 메트릭: TRANSACTION_COUNT. 테이블: SALES_TRANSACTIONS.', '매출'),

('TERM', 'SALES_TRANSACTIONS', NULL, '구매고객수',
 '고객수, 유니크고객, 구매자수, 활성고객',
 '구매고객수(고객수, 유니크고객, 구매자수, 활성고객)는 한 번 이상 구매한 고유 고객의 수입니다. 계산: COUNT(DISTINCT CUSTOMER_ID). 메트릭: UNIQUE_CUSTOMERS. 테이블: SALES_TRANSACTIONS.', '고객'),

('TERM', 'STORES', 'AREA_SQM', '평효율',
 '평당매출, 면적효율, 매장효율, 매장생산성, revenue per sqm',
 '평효율(평당매출, 면적효율, 매장효율, 매장생산성, revenue per sqm)은 매장 면적(㎡) 대비 매출액입니다. 계산: SUM(SALE_AMOUNT) / AREA_SQM. STORES 테이블의 AREA_SQM 컬럼을 JOIN해서 사용. SALES_TRANSACTIONS와 STORES를 STORE_ID로 조인.', '매장'),

('TERM', 'PRODUCTS', NULL, '마진율',
 '이익률, 수익률, gross margin, margin rate',
 '마진율(이익률, 수익률, gross margin, margin rate)은 정가 대비 이익 비율입니다. 계산: (RETAIL_PRICE - COST_PRICE) / RETAIL_PRICE. PRODUCTS 테이블의 RETAIL_PRICE와 COST_PRICE 컬럼 사용.', '상품'),

('TERM', 'SALES_TRANSACTIONS', 'DISCOUNT_RATE', '할인율',
 '디스카운트, 할인비율, 프로모션율',
 '할인율(디스카운트, 할인비율, 프로모션율)은 정가 대비 할인된 비율입니다. DISCOUNT_RATE 컬럼. 0.00=무할인, 0.30=30%할인. 범위: 0.00~0.50. 테이블: SALES_TRANSACTIONS.', '매출'),

('TERM', NULL, NULL, '전년동기대비',
 'YoY, 전년대비, 전년비, 작년대비, year over year',
 '전년동기대비(YoY, 전년대비, 전년비, 작년대비, year over year) 분석은 올해의 특정 기간과 작년 같은 기간을 비교하는 것입니다. 계산: (올해매출 - 작년매출) / 작년매출 * 100. TXN_DATE 컬럼의 YEAR() 함수 사용.', '매출'),

('TERM', NULL, NULL, '전월대비',
 'MoM, 전월비, 월간비교, month over month',
 '전월대비(MoM, 전월비, 월간비교, month over month) 분석은 이번 달과 지난 달을 비교하는 것입니다. 계산: (이번달매출 - 지난달매출) / 지난달매출 * 100. TXN_DATE 컬럼의 DATE_TRUNC(MONTH) 사용.', '매출'),

-- SCM 관련 용어
('TERM', 'SHIPMENTS', 'DELAY_DAYS', '배송지연',
 '지연, 납기지연, 입고지연, 배송늦음, delivery delay',
 '배송지연(지연, 납기지연, 입고지연, 배송늦음, delivery delay)은 예상 입고일 대비 실제 입고가 늦어진 일수입니다. DELAY_DAYS 컬럼. 0이면 정상, 양수이면 지연. 테이블: SHIPMENTS.', 'SCM'),

('TERM', 'VENDORS', 'QUALITY_SCORE', '벤더품질',
 '협력업체품질, 품질점수, 벤더점수, vendor quality',
 '벤더품질(협력업체품질, 품질점수, 벤더점수, vendor quality) 점수는 협력업체의 품질 수준을 0~100 범위로 평가한 점수입니다. QUALITY_SCORE 컬럼. 테이블: VENDORS. 높을수록 우수.', 'SCM'),

('TERM', 'VENDORS', 'LEAD_TIME_DAYS', '리드타임',
 '소요일수, 납기, 발주리드타임, lead time',
 '리드타임(소요일수, 납기, 발주리드타임, lead time)은 발주부터 입고까지 걸리는 기본 소요 일수입니다. LEAD_TIME_DAYS 컬럼. 테이블: VENDORS. 단위: 일(days).', 'SCM'),

('TERM', 'INVENTORY_SNAPSHOT', NULL, '가용재고',
 '실재고, 판매가능재고, available stock',
 '가용재고(실재고, 판매가능재고, available stock)는 현재 보유 재고에서 예약분을 뺀 실제 판매 가능 수량입니다. 계산: ON_HAND_QTY - RESERVED_QTY. 테이블: INVENTORY_SNAPSHOT.', 'SCM'),

('TERM', 'INVENTORY_SNAPSHOT', 'STATUS', '재고상태',
 '재고현황, 재고위험, stock status',
 '재고상태(재고현황, 재고위험, stock status)는 품목의 재고 수준을 나타냅니다. STATUS 컬럼. 허용값: 정상, 부족, 과잉. 테이블: INVENTORY_SNAPSHOT.', 'SCM');

-- ═══════════════════════════════════════════════
-- 2. 컬럼 값 설명 (VALUE) - 필터 조건 정확도 향상
-- ═══════════════════════════════════════════════

INSERT INTO SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY 
  (ENTRY_TYPE, TABLE_NAME, COLUMN_NAME, TERM, SYNONYMS, DESCRIPTION, DOMAIN)
VALUES
-- 브랜드 값
('VALUE', 'SALES_TRANSACTIONS', 'BRAND', 'TOPTEN',
 '탑텐, 톱텐, top ten, topten, 탑10',
 'TOPTEN(탑텐, 톱텐, top ten, 탑10)은 스노우패션의 가성비 영캐주얼 브랜드입니다. 매장 수 200개로 가장 많습니다. 가격대가 가장 낮은 대중적 브랜드. 필터: BRAND = ''TOPTEN''', '상품'),

('VALUE', 'SALES_TRANSACTIONS', 'BRAND', 'ZIOZIA',
 '지오지아, ziozia',
 'ZIOZIA(지오지아, ziozia)는 스노우패션의 남성 프리미엄 정장/비즈캐주얼 브랜드입니다. 매장 수 40개. 가격대가 가장 높은 프리미엄 라인. 필터: BRAND = ''ZIOZIA''', '상품'),

('VALUE', 'SALES_TRANSACTIONS', 'BRAND', 'OLZEN',
 '올젠, olzen',
 'OLZEN(올젠, olzen)은 스노우패션의 중년 남성 캐주얼 브랜드입니다. 매장 수 35개. 40~60대 남성 타겟. 필터: BRAND = ''OLZEN''', '상품'),

('VALUE', 'SALES_TRANSACTIONS', 'BRAND', 'ANDZ',
 '앤드지, andz',
 'ANDZ(앤드지, andz)는 스노우패션의 여성 컨템포러리 브랜드입니다. 매장 수 25개로 가장 적습니다. 20~30대 여성 타겟. 필터: BRAND = ''ANDZ''', '상품'),

-- 채널 값
('VALUE', 'SALES_TRANSACTIONS', 'CHANNEL', '오프라인',
 '오프라인매장, 매장, 오프라인판매, 매장판매, 오프라인채널',
 '오프라인(오프라인매장, 매장, 오프라인판매, 매장판매)은 실물 매장에서의 직접 판매 채널입니다. 전체 매출의 약 45% 차지. 필터: CHANNEL = ''오프라인''', '매출'),

('VALUE', 'SALES_TRANSACTIONS', 'CHANNEL', '온라인몰',
 '온라인, 자사몰, 인터넷, 이커머스, 온라인쇼핑몰',
 '온라인몰(온라인, 자사몰, 이커머스, 온라인쇼핑몰)은 자사 인터넷 쇼핑몰을 통한 판매 채널입니다. 전체 매출의 약 44% 차지. 필터: CHANNEL = ''온라인몰''', '매출'),

('VALUE', 'SALES_TRANSACTIONS', 'CHANNEL', '모바일앱',
 '모바일, 앱, 앱주문, 모바일주문',
 '모바일앱(모바일, 앱주문, 모바일주문)은 스노우패션 공식 모바일 앱을 통한 판매 채널입니다. 전체 매출의 약 10%. 필터: CHANNEL = ''모바일앱''', '매출'),

('VALUE', 'SALES_TRANSACTIONS', 'CHANNEL', '라이브커머스',
 '라이브, 라방, 라이브방송, 라이브쇼핑',
 '라이브커머스(라이브, 라방, 라이브방송, 라이브쇼핑)는 실시간 방송 판매 채널입니다. 전체 매출의 약 0.6%로 가장 적음. 필터: CHANNEL = ''라이브커머스''', '매출'),

-- 멤버십 등급 값
('VALUE', 'CUSTOMERS', 'MEMBERSHIP_TIER', 'VIP',
 'VIP고객, 최상위고객, vip, 브이아이피',
 'VIP(VIP고객, 최상위고객, 브이아이피)는 멤버십 최상위 등급입니다. 가장 높은 구매력과 충성도를 가진 고객. 필터: MEMBERSHIP_TIER = ''VIP''', '고객'),

('VALUE', 'CUSTOMERS', 'MEMBERSHIP_TIER', 'GOLD',
 '골드, 골드등급, gold',
 'GOLD(골드, 골드등급)는 멤버십 상위 등급입니다. VIP 다음으로 높은 등급. 필터: MEMBERSHIP_TIER = ''GOLD''', '고객'),

-- 매장 유형 값
('VALUE', 'STORES', 'STORE_TYPE', '직영점',
 '직영매장, 직영, 본사직영',
 '직영점(직영매장, 직영, 본사직영)은 스노우패션이 직접 운영하는 매장입니다. 필터: STORE_TYPE = ''직영점''', '매장'),

('VALUE', 'STORES', 'STORE_TYPE', '아울렛',
 '아울렛매장, outlet, 할인매장',
 '아울렛(아울렛매장, outlet, 할인매장)은 이월 상품 위주의 할인 판매 매장입니다. 필터: STORE_TYPE = ''아울렛''', '매장'),

-- 시즌 값
('VALUE', 'PRODUCTS', 'SEASON', 'SS25',
 '2025봄여름, 2025SS, 봄여름2025, 25SS, 25년SS',
 'SS25(2025봄여름, 2025SS, 25SS)는 2025년 봄/여름 시즌입니다. 3월~8월 시즌 상품. 필터: SEASON = ''SS25''', '상품'),

('VALUE', 'PRODUCTS', 'SEASON', 'FW25',
 '2025가을겨울, 2025FW, 가을겨울2025, 25FW, 25년FW',
 'FW25(2025가을겨울, 2025FW, 25FW)는 2025년 가을/겨울 시즌입니다. 9월~2월 시즌 상품. 필터: SEASON = ''FW25''', '상품'),

('VALUE', 'PRODUCTS', 'SEASON', 'SS24',
 '2024봄여름, 2024SS, 봄여름2024, 24SS',
 'SS24(2024봄여름, 2024SS, 24SS)는 2024년 봄/여름 시즌입니다. 필터: SEASON = ''SS24''', '상품'),

('VALUE', 'PRODUCTS', 'SEASON', 'FW24',
 '2024가을겨울, 2024FW, 가을겨울2024, 24FW',
 'FW24(2024가을겨울, 2024FW, 24FW)는 2024년 가을/겨울 시즌입니다. 필터: SEASON = ''FW24''', '상품');

-- 적재 확인
SELECT ENTRY_TYPE, COUNT(*) FROM SNOW_FASHION.SEMANTIC.EDU_DATA_DICTIONARY GROUP BY ENTRY_TYPE;
