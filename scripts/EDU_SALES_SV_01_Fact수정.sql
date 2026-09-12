-- ============================================================
-- EDU_SALES_SV Step 1: Fact/Dimension 수정
-- 
-- Autopilot이 Dimension으로 잘못 분류한 4개 컬럼을 Fact로 변경:
--   - SALES_TRANSACTIONS.UNIT_PRICE
--   - PRODUCTS.COST_PRICE
--   - PRODUCTS.RETAIL_PRICE
--   - CUSTOMERS.TOTAL_PURCHASES
--
-- Description은 Autopilot이 생성한 영문 원본을 유지합니다.
-- 한국어 Description 추가는 EDU_SALES_SV_02_Description추가.sql 을 사용하세요.
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
      COMMENT = 'The discount rate applied to a sales transaction expressed as a decimal value.'
      SAMPLE_VALUES ('0.11', '0.00', '0.25'),
    SALES_TRANSACTIONS.QUANTITY AS QUANTITY
      COMMENT = 'The number of units sold in a sales transaction.'
      SAMPLE_VALUES ('3', '2', '1'),
    SALES_TRANSACTIONS.SALE_AMOUNT AS SALE_AMOUNT
      COMMENT = 'The monetary amount associated with a sales transaction.'
      SAMPLE_VALUES ('164500', '10440', '12600'),

    -- SALES_TRANSACTIONS (수정: Dimension → Fact)
    SALES_TRANSACTIONS.UNIT_PRICE AS UNIT_PRICE
      COMMENT = 'The price per unit of a sold item.'
      SAMPLE_VALUES ('6670', '56120', '127211'),

    -- PRODUCTS (수정: Dimension → Fact)
    PRODUCTS.COST_PRICE AS COST_PRICE
      COMMENT = 'The cost price of a product.'
      SAMPLE_VALUES ('44000', '16200', '28000'),
    PRODUCTS.RETAIL_PRICE AS RETAIL_PRICE
      COMMENT = 'The retail price of a product.'
      SAMPLE_VALUES ('60000', '28100', '17500'),

    -- STORES (기존 Fact - Autopilot 정확)
    STORES.AREA_SQM AS AREA_SQM
      COMMENT = 'The area of the store measured in square meters.'
      SAMPLE_VALUES ('265.0', '203.0', '198.0'),

    -- CUSTOMERS (수정: Dimension → Fact)
    CUSTOMERS.TOTAL_PURCHASES AS TOTAL_PURCHASES
      COMMENT = 'The total number of purchases made by a customer.'
      SAMPLE_VALUES ('0')
  )

  -- ============================================================
  -- DIMENSIONS: 수정 대상 4개를 제외한 나머지 (Autopilot 분류 유지)
  -- ============================================================
  DIMENSIONS (
    -- PRODUCTS
    PRODUCTS.BRAND AS BRAND
      COMMENT = 'The brand name associated with a product.'
      SAMPLE_VALUES ('TOPTEN', 'OLZEN', 'ZIOZIA'),
    PRODUCTS.CATEGORY AS CATEGORY
      COMMENT = 'The category of a product.'
      SAMPLE_VALUES ('아우터', '액세서리', '하의'),
    PRODUCTS.COLOR AS COLOR
      COMMENT = 'The color of the product.'
      SAMPLE_VALUES ('블루', '네이비', '핑크'),
    PRODUCTS.GENDER AS GENDER
      COMMENT = 'The gender category associated with the product.'
      SAMPLE_VALUES ('여성', '공용', '남성'),
    PRODUCTS.IS_ACTIVE AS IS_ACTIVE
      COMMENT = 'Indicates whether a product is currently active.'
      SAMPLE_VALUES ('TRUE'),
    PRODUCTS.PRODUCT_NAME AS PRODUCT_NAME
      COMMENT = 'The full name of a product, including brand, category, color, and size information.'
      SAMPLE_VALUES ('ZIOZIA 가방 블루 S', 'OLZEN 패딩 네이비 S', 'ZIOZIA 내의 블루 XS'),
    PRODUCTS.SEASON AS SEASON
      COMMENT = 'The fashion season associated with the product, combining a period of the year with a two-digit year indicator.'
      SAMPLE_VALUES ('FW24', 'SS24', 'SS25'),
    PRODUCTS.SEASON_YEAR AS SEASON_YEAR
      COMMENT = 'The year associated with the product''s season.'
      SAMPLE_VALUES ('2024', '2025'),
    PRODUCTS.SIZE_GROUP AS SIZE_GROUP
      COMMENT = 'The size grouping or category assigned to a product.'
      SAMPLE_VALUES ('S', 'FREE', 'XS'),
    PRODUCTS.SKU_ID AS SKU_ID
      COMMENT = 'Stock Keeping Unit (SKU) identifier used to uniquely identify a product.'
      SAMPLE_VALUES ('AZ-000019', 'AZ-000153', 'TT-000139'),
    PRODUCTS.SUB_CATEGORY AS SUB_CATEGORY
      COMMENT = 'The sub-category classification of a product.'
      SAMPLE_VALUES ('점퍼', '가방', '청바지'),
    PRODUCTS.CREATED_AT AS CREATED_AT
      COMMENT = 'The date and time when the product record was created.'
      SAMPLE_VALUES ('2026-09-01T10:51:46.720Z', '2026-09-01T10:52:01.208Z'),
    PRODUCTS.LAUNCH_DATE AS LAUNCH_DATE
      COMMENT = 'The date on which a product was launched.'
      SAMPLE_VALUES ('2024-02-27', '2024-05-17', '2025-08-23'),

    -- SALES_TRANSACTIONS
    SALES_TRANSACTIONS.BRAND AS BRAND
      COMMENT = 'The brand associated with each sales transaction.'
      SAMPLE_VALUES ('OLZEN', 'ZIOZIA', 'TOPTEN'),
    SALES_TRANSACTIONS.CHANNEL AS CHANNEL
      COMMENT = 'The sales or distribution channel through which a transaction was made.'
      SAMPLE_VALUES ('라이브커머스', '모바일앱', '온라인몰'),
    SALES_TRANSACTIONS.CUSTOMER_ID AS CUSTOMER_ID
      COMMENT = 'Unique identifier assigned to each customer.'
      SAMPLE_VALUES ('C-00223016', 'C-00080677', 'C-00305509'),
    SALES_TRANSACTIONS.PAYMENT_METHOD AS PAYMENT_METHOD
      COMMENT = 'The method of payment used for a sales transaction.'
      SAMPLE_VALUES ('현금', '간편결제', '체크카드'),
    SALES_TRANSACTIONS.SKU_ID AS SKU_ID
      COMMENT = 'Stock Keeping Unit (SKU) identifier used to uniquely identify individual products in sales transactions.'
      SAMPLE_VALUES ('TT-004430', 'AZ-001348', 'TT-000217'),
    SALES_TRANSACTIONS.STORE_ID AS STORE_ID
      COMMENT = 'Unique identifier assigned to each store involved in a sales transaction.'
      SAMPLE_VALUES ('SZ-0028', 'SO-0001', 'SZ-0010'),
    SALES_TRANSACTIONS.TXN_ID AS TXN_ID
      COMMENT = 'Unique identifier assigned to each sales transaction.'
      SAMPLE_VALUES ('T-V0054716', 'T-V0054624', 'T-V0054670'),
    SALES_TRANSACTIONS.TXN_DATE AS TXN_DATE
      COMMENT = 'The date on which a sales transaction occurred.'
      SAMPLE_VALUES ('2025-08-30', '2025-09-09', '2025-07-11'),
    SALES_TRANSACTIONS.TXN_TIME AS TXN_TIME
      COMMENT = 'The date and time at which a sales transaction occurred.'
      SAMPLE_VALUES ('2025-11-06T20:58:40.000Z', '2025-01-01T10:45:52.000Z', '2024-12-09T15:28:05.000Z'),

    -- CUSTOMERS
    CUSTOMERS.AGE_GROUP AS AGE_GROUP
      COMMENT = 'The age group or generational bracket of the customer.'
      SAMPLE_VALUES ('20대', '10대', '40대'),
    CUSTOMERS.CUSTOMER_ID AS CUSTOMER_ID
      COMMENT = 'Unique identifier assigned to each customer.'
      SAMPLE_VALUES ('C-00000044', 'C-00000078', 'C-00000232'),
    CUSTOMERS.GENDER AS GENDER
      COMMENT = 'The gender of the customer.'
      SAMPLE_VALUES ('여성', '남성'),
    CUSTOMERS.IS_ACTIVE AS IS_ACTIVE
      COMMENT = 'Indicates whether a customer is currently active.'
      SAMPLE_VALUES ('FALSE', 'TRUE'),
    CUSTOMERS.MEMBERSHIP_TIER AS MEMBERSHIP_TIER
      COMMENT = 'The membership tier level assigned to a customer.'
      SAMPLE_VALUES ('SILVER', 'GOLD', 'VIP'),
    CUSTOMERS.REGION AS REGION
      COMMENT = 'The region or geographic area associated with a customer.'
      SAMPLE_VALUES ('부산', '서울', '경기'),
    CUSTOMERS.SIGNUP_CHANNEL AS SIGNUP_CHANNEL
      COMMENT = 'The channel through which a customer completed their sign-up.'
      SAMPLE_VALUES ('매장방문', 'SNS', '온라인몰'),
    CUSTOMERS.SIGNUP_DATE AS SIGNUP_DATE
      COMMENT = 'The date on which a customer signed up.'
      SAMPLE_VALUES ('2026-04-05', '2026-04-03', '2024-04-30'),

    -- STORES
    STORES.BRAND AS BRAND
      COMMENT = 'The brand name associated with the store.'
      SAMPLE_VALUES ('ANDZ', 'TOPTEN', 'OLZEN'),
    STORES.CITY AS CITY
      COMMENT = 'The city or regional area where the store is located.'
      SAMPLE_VALUES ('인천', '경기', '서울'),
    STORES.DISTRICT AS DISTRICT
      COMMENT = 'The district or sub-regional area associated with a store location in South Korea.'
      SAMPLE_VALUES ('성남시', '영등포구', '안양시'),
    STORES.IS_ACTIVE AS IS_ACTIVE
      COMMENT = 'Indicates whether a store is currently active.'
      SAMPLE_VALUES ('TRUE'),
    STORES.REGION AS REGION
      COMMENT = 'The geographic region where the store is located.'
      SAMPLE_VALUES ('수도권', '영남권', '충청권'),
    STORES.STORE_ID AS STORE_ID
      COMMENT = 'Unique identifier assigned to each store.'
      SAMPLE_VALUES ('SZ-0022', 'ST-0150', 'ST-0054'),
    STORES.STORE_NAME AS STORE_NAME
      COMMENT = 'The full name of the store including the brand and location.'
      SAMPLE_VALUES ('TOPTEN 청주 흥덕구점', 'ANDZ 인천 남동구점', 'ANDZ 서울 서초구점'),
    STORES.STORE_TYPE AS STORE_TYPE
      COMMENT = 'The type or classification of a store.'
      SAMPLE_VALUES ('대리점', '아울렛', '온라인전용'),
    STORES.OPEN_DATE AS OPEN_DATE
      COMMENT = 'The date on which a store was opened.'
      SAMPLE_VALUES ('2023-07-25', '2024-12-13', '2024-06-14')
  );
