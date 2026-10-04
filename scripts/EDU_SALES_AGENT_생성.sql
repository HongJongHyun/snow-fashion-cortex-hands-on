-- ============================================================
-- EDU_SALES_AGENT: 매출분석 Agent 생성
--
-- 매출/고객/상품/매장 분석 + 데이터사전 + VOC 검색
-- 교안 Chapter 4~6에서 단계적으로 구성한 최종 Agent
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

      ■ 도구 사용 규칙:

      1. 사용자의 질문에 생소한 비즈니스 용어, 약어, 한글 브랜드명이 포함되어 있으면
         먼저 dict_search(데이터 사전)를 검색하여 정확한 의미와 계산식을 파악하세요.
         예: "순매출" → dict_search → "SUM(SALE_AMOUNT) WHERE DISCOUNT_RATE < 1.0" 확인 → sales_analytics 호출

      2. 매출, 실적, KPI, 숫자 기반 분석 → sales_analytics 사용
         dict_search 결과를 참고하여 정확한 컬럼명과 필터값을 사용하세요.

      3. 수치를 질문한 경우 반드시 sales_analytics를 호출하여 데이터에 근거한 답변을 제공하세요

      4. 고객 리뷰, VOC, 불만사항, 고객 의견 → voc_search 사용

      5. 복합 질문 → 여러 도구를 순차적으로 사용
         예: "매출 하락 원인 분석" → sales_analytics(수치 확인) + voc_search(고객 의견)

      ■ dict_search 활용 시나리오:
      - "순매출" → dict_search 검색 → SUM(SALE_AMOUNT) WHERE DISCOUNT_RATE < 1.0 확인
      - "주력상품" → dict_search 검색 → CATEGORY IN ('아우터', '상의') 확인
      - "평효율" → dict_search 검색 → SUM(SALE_AMOUNT) / AREA_SQM 확인

      ■ 주의: 아래 용어는 dict_search 없이도 바로 사용 가능합니다:
      - 브랜드명: TOPTEN, ZIOZIA, OLZEN, ANDZ (영문 그대로)
      - 기본 지표: 매출, 수량, 할인율 (SALE_AMOUNT, QUANTITY, DISCOUNT_RATE)

    response: |
      ■ 답변 규칙:
      1. 한국어로 답변하세요
      2. 금액은 원(₩) 단위, 천 단위 구분자 사용 (예: ₩1,234,567)
      3. 수치 데이터와 함께 비즈니스 인사이트를 제공하세요
      4. 차트가 적절한 경우 data_to_chart를 사용하세요
      5. dict_search로 용어를 확인한 경우, 그 의미를 답변에 자연스럽게 포함하세요
      6. 리뷰 검색 결과는 원문을 인용하세요

    sample_questions:
      - question: "브랜드별 이번 달 매출은 얼마야?"
      - question: "브랜드별 순매출 보여줘"
      - question: "사이즈 불만 리뷰를 찾아줘"
      - question: "라방 매출이 전월 대비 어떻게 변했어?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: sales_analytics
        description: "스노우패션 매출, 고객, 상품, 매장 데이터를 SQL로 조회합니다."
    - tool_spec:
        type: cortex_search
        name: dict_search
        description: "데이터 사전을 검색합니다. 비즈니스 용어(순매출, 주력상품, 객단가, 평효율 등)의 의미와 계산식, 회사 고유 규칙을 찾을 수 있습니다. 생소한 용어나 약어가 나오면 이 도구로 먼저 검색하세요."
    - tool_spec:
        type: cortex_search
        name: voc_search
        description: "고객 리뷰(VOC) 텍스트를 검색합니다. 10만건의 한국어 리뷰에서 사이즈, 품질, 배송, 가격 등에 대한 고객 의견을 조회합니다."
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
          description: "비즈니스 용어/컬럼/고유값의 상세 설명과 계산식, 회사 고유 규칙"
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
