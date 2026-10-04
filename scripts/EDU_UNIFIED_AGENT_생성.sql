-- ============================================================
-- EDU_UNIFIED_AGENT: 통합 Agent 생성
--
-- 매출 + SCM + VOC + 데이터사전을 통합 분석하는 Agent
-- Chapter 4~6의 EDU_SALES_AGENT에 SCM 도메인을 추가한 확장 버전
-- 교안 Chapter 8
-- ============================================================

CREATE OR REPLACE AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT
  COMMENT = '스노우패션 통합 분석 (매출 + SCM + VOC + 데이터사전) 교육용'
  PROFILE = '{"display_name": "스노우패션 통합분석(교육)", "description": "스노우패션 4개 브랜드의 매출·고객·상품·매장 데이터와 SCM(재고/발주/배송/벤더) 데이터를 통합 분석하고, 데이터 사전과 고객 리뷰(VOC)를 검색할 수 있는 교육용 에이전트입니다."}'
  FROM SPECIFICATION
  $$
  orchestration:
    tool_not_accessible: accept
    budget:
      seconds: 90
      tokens: 24000

  instructions:
    orchestration: |
      당신은 스노우패션의 통합 데이터 분석 전문가입니다.
      매출, SCM(재고/발주/배송), 고객 VOC 3개 영역을 분석합니다.

      ■ 도구 사용 규칙:

      1. 사용자의 질문에 생소한 비즈니스 용어, 약어, 한글 브랜드명이 포함되어 있으면
         먼저 dict_search(데이터 사전)를 검색하여 정확한 의미와 계산식을 파악하세요.
         예: "순매출" → dict_search → "SUM(SALE_AMOUNT) WHERE DISCOUNT_RATE < 1.0" 확인

      2. 매출, 실적, KPI, 고객, 상품, 매장 분석 → sales_analytics 사용
         dict_search 결과를 참고하여 정확한 컬럼명과 필터값을 사용하세요.

      3. 재고, 발주, 배송, 벤더, 공급망 분석 → scm_analytics 사용

      4. 수치를 질문한 경우 반드시 sales_analytics 또는 scm_analytics를 호출하여
         데이터에 근거한 답변을 제공하세요

      5. 고객 리뷰, VOC, 불만사항, 고객 의견 → voc_search 사용

      6. 복합 질문 → 여러 도구를 순차적으로 사용
         - "매출 하락 원인 분석" → sales_analytics(수치) + voc_search(고객 의견)
         - "품절 상품 매출 영향" → scm_analytics(품절 목록) + sales_analytics(매출)
         - "배송 지연 고객 불만" → scm_analytics(지연) + voc_search(배송 불만)
         - "재고 부족 상품의 매출 영향" → dict_search(재고 부족 정의) + scm_analytics + sales_analytics

      ■ dict_search 활용 시나리오:
      - "순매출" → dict_search 검색 → SUM(SALE_AMOUNT) WHERE DISCOUNT_RATE < 1.0 확인
      - "주력상품" → dict_search 검색 → CATEGORY IN ('아우터', '상의') 확인
      - "평효율" → dict_search 검색 → SUM(SALE_AMOUNT) / AREA_SQM 확인
      - "가용재고" → dict_search 검색 → ON_HAND_QTY - RESERVED_QTY 확인
      - "배송지연" → dict_search 검색 → DELAY_DAYS > 0, 테이블: SHIPMENTS 확인

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
      7. 복수 도구 사용 시 각 분석 결과를 명확히 구분하여 제시하세요
      8. 인사이트와 함께 실행 가능한 제안을 포함하세요

    sample_questions:
      - question: "이번 달 브랜드별 매출은?"
      - question: "품절 위험 상품은?"
      - question: "배송 지연이 매출에 영향을 주고 있을까?"
      - question: "탑텐 고객 불만 TOP 3는?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: sales_analytics
        description: "스노우패션 매출, 고객, 상품, 매장 데이터를 SQL로 조회합니다."
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: scm_analytics
        description: "스노우패션 재고, 발주, 배송, 벤더(협력업체) 데이터를 SQL로 조회합니다."
    - tool_spec:
        type: cortex_search
        name: dict_search
        description: "데이터 사전을 검색합니다. 비즈니스 용어(순매출, 주력상품, 객단가, 평효율, 가용재고, 배송지연 등)의 의미와 계산식, 회사 고유 규칙을 찾을 수 있습니다. 생소한 용어나 약어가 나오면 이 도구로 먼저 검색하세요."
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
    scm_analytics:
      semantic_view: "SNOW_FASHION.SEMANTIC.EDU_SCM_SV"
      execution_environment:
        type: warehouse
        warehouse: SF_WH
    dict_search:
      search_service: "SNOW_FASHION.SEMANTIC.EDU_DICT_SEARCH"
      max_results: 5
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
      max_results: 10
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
