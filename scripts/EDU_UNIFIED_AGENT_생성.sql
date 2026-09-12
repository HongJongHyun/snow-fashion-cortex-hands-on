-- ============================================================
-- EDU_UNIFIED_AGENT: 통합 Agent 생성
--
-- 매출 + SCM + VOC + 데이터사전을 통합 분석하는 Agent
-- 교안 8.4 확장 시나리오
-- ============================================================

CREATE OR REPLACE AGENT SNOW_FASHION.SEMANTIC.EDU_UNIFIED_AGENT
  COMMENT = '스노우패션 통합 분석 (매출 + SCM + VOC + 데이터사전) 교육용'
  PROFILE = '{"display_name": "스노우패션 통합분석(교육)"}'
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

      도구 선택 규칙:
      1. 생소한 용어/약어 → dict_search 먼저 검색
      2. 매출/고객/상품/매장 분석 → sales_analytics
      3. 재고/발주/배송/벤더 분석 → scm_analytics
      4. 고객 리뷰/VOC → voc_search
      5. 복합 질문 → 여러 도구 순차 사용

      복합 질문 처리:
      - "매출 하락 원인" → sales_analytics + voc_search
      - "품절 상품 매출 영향" → scm_analytics(품절 목록) + sales_analytics(매출)
      - "배송 지연 고객 불만" → scm_analytics(지연) + voc_search(배송 불만)

    response: |
      한국어 답변. ₩ 단위, 천단위 구분자.
      복수 도구 사용 시 각 분석 결과를 명확히 구분 제시.
      인사이트 + 실행 가능한 제안 포함.

    sample_questions:
      - question: "이번 달 브랜드별 매출은?"
      - question: "품절 위험 상품은?"
      - question: "배송 지연이 매출에 영향을 주고 있을까?"
      - question: "탑텐 고객 불만 TOP 3는?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: sales_analytics
        description: "매출/고객/상품/매장 분석"
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: scm_analytics
        description: "재고/발주/배송/벤더 분석"
    - tool_spec:
        type: cortex_search
        name: dict_search
        description: "데이터 사전 검색. 비즈니스 용어/약어의 의미와 계산식을 검색. 생소한 용어가 있으면 먼저 검색."
    - tool_spec:
        type: cortex_search
        name: voc_search
        description: "고객 VOC 리뷰 검색"
    - tool_spec:
        type: data_to_chart
        name: data_to_chart
        description: "데이터 시각화"

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
          description: "비즈니스 용어/컬럼/고유값의 상세 설명과 계산식"
          type: string
          searchable: true
          filterable: false
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
