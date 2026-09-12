-- ============================================================
-- EDU_SALES_AGENT: 매출분석 Agent 생성
--
-- 매출/고객/상품/매장 분석 + 데이터사전 + VOC 검색
-- 교안 6.5
-- ============================================================

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

      도구 사용 규칙:
      1. 생소한 비즈니스 용어나 약어가 있으면 먼저 dict_search로 검색하세요.
         예: "객단가" → dict_search → "AVG(SALE_AMOUNT)" 확인 → sales_analytics
      2. 매출/실적/KPI 숫자 분석 → sales_analytics
      3. 고객 리뷰/VOC/불만사항 → voc_search
      4. 복합 질문 → 여러 도구 순차 사용

      dict_search 활용 시나리오:
      - 한글 브랜드명("탑텐") → 정확한 필터값('TOPTEN') 확인
      - 약어("라방") → 정확한 채널명('라이브커머스') 확인
      - 사내 용어("평효율") → 계산식(SUM(SALE_AMOUNT)/AREA_SQM) 확인

    response: |
      한국어 답변. ₩ 단위, 천단위 구분자.
      수치 + 인사이트 함께. 차트 적극 활용.
      리뷰 인용 시 원문 포함.

    sample_questions:
      - question: "브랜드별 이번 달 매출은 얼마야?"
      - question: "탑텐 객단가 추이를 보여줘"
      - question: "사이즈 불만 리뷰를 찾아줘"
      - question: "라방 매출이 전월 대비 어떻게 변했어?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: sales_analytics
        description: "매출, 고객, 상품, 매장 데이터를 SQL로 조회"
    - tool_spec:
        type: cortex_search
        name: dict_search
        description: "데이터 사전 검색. 비즈니스 용어 의미, 계산식, 컬럼 설명, 고유값 조회. 생소한 용어가 나오면 먼저 검색."
    - tool_spec:
        type: cortex_search
        name: voc_search
        description: "고객 VOC 리뷰 검색. 사이즈/품질/배송/가격 관련 고객 의견 조회."
    - tool_spec:
        type: data_to_chart
        name: data_to_chart
        description: "데이터 시각화"
    - tool_spec:
        type: code_execution
        name: code_execution

  tool_resources:
    sales_analytics:
      semantic_view: "SNOW_FASHION.SEMANTIC.EDU_SALES_SV"
      execution_environment:
        type: warehouse
        warehouse: SF_WH
    dict_search:
      search_service: "SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH"
      max_results: 4
      columns_and_descriptions:
        DESCRIPTION:
          description: "비즈니스 용어/컬럼/고유값의 상세 설명과 계산식"
          type: string
          searchable: true
          filterable: false
        ENTRY_TYPE:
          description: "항목 유형: TERM(비즈니스용어), COLUMN(컬럼설명), VALUE(고유값)"
          type: string
          searchable: false
          filterable: true
        DOMAIN:
          description: "도메인: 매출, 고객, 상품, 매장, SCM"
          type: string
          searchable: false
          filterable: true
    voc_search:
      search_service: "SNOW_FASHION.SEMANTIC.EDU_VOC_SEARCH"
      max_results: 4
      columns_and_descriptions:
        REVIEW_TEXT:
          description: "고객 리뷰 텍스트 (한국어)"
          type: string
          searchable: true
          filterable: false
        BRAND:
          description: "브랜드명: TOPTEN, ZIOZIA, OLZEN, ANDZ"
          type: string
          searchable: false
          filterable: true
        RATING:
          description: "평점 1~5"
          type: string
          searchable: false
          filterable: true
  $$;
