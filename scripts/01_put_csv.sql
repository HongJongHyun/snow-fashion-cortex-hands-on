-- =============================================================================
-- Snow Fashion CSV 업로드 스크립트
-- 사전 조건: 00_setup_db.sql 실행 완료
-- 실행 방법: snow sql -f scripts/01_put_csv.sql -c <연결명>
--           또는 SnowSQL에서 실행
-- 주의: PUT 명령은 Snowsight 워크시트에서 실행할 수 없습니다.
--       Snowflake CLI(snow) 또는 SnowSQL에서 실행하세요.
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE SF_WH;
USE SCHEMA SNOW_FASHION.RAW;

-- 아래 /path/to/data/ 를 실제 CSV 파일이 있는 로컬 경로로 변경하세요.
-- 예: file:///Users/jhong/Downloads/snow-fashion-cortex-hands-on-main/data/

PUT file:///path/to/data/CUSTOMERS.csv.gz          @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/DEMAND_FORECAST.csv.gz    @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/INVENTORY_SNAPSHOT.csv.gz @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/PRODUCTS.csv.gz           @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/PRODUCT_REVIEWS.csv.gz    @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/REVIEW_TEMPLATES.csv.gz   @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/SALES_TRANSACTIONS.csv.gz @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/SHIPMENTS.csv.gz          @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/STORES.csv.gz             @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/SUPPLY_ORDERS.csv.gz      @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/VENDORS.csv.gz            @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/data/WEEKLY_DEMAND.csv.gz      @SNOW_FASHION.RAW.LOAD_STAGE/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- 업로드 확인 (12개 파일이 보여야 합니다)
LIST @SNOW_FASHION.RAW.LOAD_STAGE;
