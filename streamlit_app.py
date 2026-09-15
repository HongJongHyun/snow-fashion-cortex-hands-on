import streamlit as st
import altair as alt
import pandas as pd

st.set_page_config(page_title="고객 세그먼트 분석", layout="wide")
st.title("고객 세그먼트 분석")

conn = st.connection("snowflake")
session = conn.session()

# ---------------------------------------------------------------------------
# 캐시된 데이터 조회 함수
# ---------------------------------------------------------------------------

@st.cache_data(ttl=600)
def get_brands():
    return session.sql(
        "SELECT DISTINCT BRAND FROM SNOW_FASHION.RAW.SALES_TRANSACTIONS ORDER BY BRAND"
    ).to_pandas()["BRAND"].tolist()

@st.cache_data(ttl=600)
def get_date_range():
    df = session.sql(
        "SELECT MIN(TXN_DATE) AS MIN_DATE, MAX(TXN_DATE) AS MAX_DATE FROM SNOW_FASHION.RAW.SALES_TRANSACTIONS"
    ).to_pandas()
    return pd.to_datetime(df["MIN_DATE"].iloc[0]).date(), pd.to_datetime(df["MAX_DATE"].iloc[0]).date()

@st.cache_data(ttl=600)
def get_membership_tiers():
    return session.sql(
        "SELECT DISTINCT MEMBERSHIP_TIER FROM SNOW_FASHION.RAW.CUSTOMERS ORDER BY MEMBERSHIP_TIER"
    ).to_pandas()["MEMBERSHIP_TIER"].tolist()

# ---------------------------------------------------------------------------
# 필터 공통 WHERE 절 생성
# ---------------------------------------------------------------------------

def _build_where(brands, start_date, end_date, tiers, alias_txn="t", alias_cust="c"):
    clauses = []
    if brands:
        brand_list = ",".join(f"'{b}'" for b in brands)
        clauses.append(f"{alias_txn}.BRAND IN ({brand_list})")
    clauses.append(f"{alias_txn}.TXN_DATE BETWEEN '{start_date}' AND '{end_date}'")
    if tiers:
        tier_list = ",".join(f"'{t}'" for t in tiers)
        clauses.append(f"{alias_cust}.MEMBERSHIP_TIER IN ({tier_list})")
    return " AND ".join(clauses)

# ---------------------------------------------------------------------------
# 탭 1 쿼리 함수
# ---------------------------------------------------------------------------

@st.cache_data(ttl=600)
def query_customer_distribution(brands, start_date, end_date, tiers):
    where = _build_where(brands, start_date, end_date, tiers)
    base = f"""
        SELECT c.CUSTOMER_ID, c.AGE_GROUP, c.GENDER, c.REGION
        FROM SNOW_FASHION.RAW.CUSTOMERS c
        JOIN SNOW_FASHION.RAW.SALES_TRANSACTIONS t ON c.CUSTOMER_ID = t.CUSTOMER_ID
        WHERE {where}
    """
    age_df = session.sql(f"""
        SELECT AGE_GROUP, COUNT(DISTINCT CUSTOMER_ID) AS CNT
        FROM ({base})
        GROUP BY AGE_GROUP ORDER BY AGE_GROUP
    """).to_pandas()
    gender_df = session.sql(f"""
        SELECT GENDER, COUNT(DISTINCT CUSTOMER_ID) AS CNT
        FROM ({base})
        GROUP BY GENDER ORDER BY GENDER
    """).to_pandas()
    region_df = session.sql(f"""
        SELECT REGION, COUNT(DISTINCT CUSTOMER_ID) AS CNT
        FROM ({base})
        GROUP BY REGION ORDER BY CNT DESC
    """).to_pandas()
    return age_df, gender_df, region_df

# ---------------------------------------------------------------------------
# 탭 2 쿼리 함수
# ---------------------------------------------------------------------------

@st.cache_data(ttl=600)
def query_membership_sales(brands, start_date, end_date, tiers):
    where = _build_where(brands, start_date, end_date, tiers)
    df = session.sql(f"""
        SELECT c.MEMBERSHIP_TIER,
               SUM(t.SALE_AMOUNT)          AS TOTAL_SALES,
               COUNT(t.TXN_ID)             AS TXN_COUNT,
               COUNT(DISTINCT c.CUSTOMER_ID) AS CUST_COUNT
        FROM SNOW_FASHION.RAW.CUSTOMERS c
        JOIN SNOW_FASHION.RAW.SALES_TRANSACTIONS t ON c.CUSTOMER_ID = t.CUSTOMER_ID
        WHERE {where}
        GROUP BY c.MEMBERSHIP_TIER
        ORDER BY TOTAL_SALES DESC
    """).to_pandas()
    return df

# ---------------------------------------------------------------------------
# 탭 3 쿼리 함수
# ---------------------------------------------------------------------------

@st.cache_data(ttl=600)
def query_cohort(brands, start_date, end_date, tiers):
    where = _build_where(brands, start_date, end_date, tiers)
    df = session.sql(f"""
        SELECT DATE_TRUNC('MONTH', c.SIGNUP_DATE) AS COHORT_MONTH,
               DATE_TRUNC('MONTH', t.TXN_DATE)    AS TXN_MONTH,
               SUM(t.SALE_AMOUNT)                  AS TOTAL_SALES
        FROM SNOW_FASHION.RAW.CUSTOMERS c
        JOIN SNOW_FASHION.RAW.SALES_TRANSACTIONS t ON c.CUSTOMER_ID = t.CUSTOMER_ID
        WHERE {where}
        GROUP BY COHORT_MONTH, TXN_MONTH
        ORDER BY COHORT_MONTH, TXN_MONTH
    """).to_pandas()
    return df

# ---------------------------------------------------------------------------
# 사이드바 필터
# ---------------------------------------------------------------------------

try:
    all_brands = get_brands()
    min_date, max_date = get_date_range()
    all_tiers = get_membership_tiers()
except Exception as e:
    st.error(f"데이터 조회 실패: {e}")
    st.stop()

with st.sidebar:
    st.header("필터")
    sel_brands = st.multiselect("브랜드", all_brands, default=all_brands)
    col1, col2 = st.columns(2)
    with col1:
        sel_start = st.date_input("시작일", value=min_date, min_value=min_date, max_value=max_date)
    with col2:
        sel_end = st.date_input("종료일", value=max_date, min_value=min_date, max_value=max_date)
    sel_tiers = st.multiselect("멤버십 등급", all_tiers, default=all_tiers)

start_str = sel_start.strftime("%Y-%m-%d")
end_str = sel_end.strftime("%Y-%m-%d")

# ---------------------------------------------------------------------------
# 탭 구성
# ---------------------------------------------------------------------------

tab1, tab2, tab3 = st.tabs(["고객 분포", "멤버십별 매출 기여도", "코호트 분석"])

# ---- 탭 1: 고객 분포 ----
with tab1:
    try:
        age_df, gender_df, region_df = query_customer_distribution(
            tuple(sel_brands), start_str, end_str, tuple(sel_tiers)
        )
    except Exception as e:
        st.error(f"데이터 조회 실패: {e}")
        st.stop()

    if age_df.empty and gender_df.empty and region_df.empty:
        st.warning("조건에 해당하는 데이터가 없습니다.")
    else:
        st.subheader("연령대별 고객 수")
        chart_age = (
            alt.Chart(age_df)
            .mark_bar()
            .encode(
                y=alt.Y("AGE_GROUP:N", sort="-x", title="연령대"),
                x=alt.X("CNT:Q", title="고객 수"),
                tooltip=["AGE_GROUP", alt.Tooltip("CNT:Q", format=",")],
            )
            .properties(height=300)
        )
        st.altair_chart(chart_age, use_container_width=True)

        col_g, col_r = st.columns(2)
        with col_g:
            st.subheader("성별 분포")
            chart_gender = (
                alt.Chart(gender_df)
                .mark_arc(innerRadius=50)
                .encode(
                    theta=alt.Theta("CNT:Q"),
                    color=alt.Color("GENDER:N", title="성별"),
                    tooltip=["GENDER", alt.Tooltip("CNT:Q", format=",")],
                )
                .properties(height=300)
            )
            st.altair_chart(chart_gender, use_container_width=True)

        with col_r:
            st.subheader("지역별 분포")
            chart_region = (
                alt.Chart(region_df)
                .mark_bar()
                .encode(
                    y=alt.Y("REGION:N", sort="-x", title="지역"),
                    x=alt.X("CNT:Q", title="고객 수"),
                    tooltip=["REGION", alt.Tooltip("CNT:Q", format=",")],
                )
                .properties(height=300)
            )
            st.altair_chart(chart_region, use_container_width=True)

# ---- 탭 2: 멤버십별 매출 기여도 ----
with tab2:
    try:
        mem_df = query_membership_sales(
            tuple(sel_brands), start_str, end_str, tuple(sel_tiers)
        )
    except Exception as e:
        st.error(f"데이터 조회 실패: {e}")
        st.stop()

    if mem_df.empty:
        st.warning("조건에 해당하는 데이터가 없습니다.")
    else:
        st.subheader("멤버십 등급별 매출 비중")
        chart_mem = (
            alt.Chart(mem_df)
            .mark_arc(innerRadius=50)
            .encode(
                theta=alt.Theta("TOTAL_SALES:Q"),
                color=alt.Color("MEMBERSHIP_TIER:N", title="멤버십 등급"),
                tooltip=[
                    "MEMBERSHIP_TIER",
                    alt.Tooltip("TOTAL_SALES:Q", format=",", title="매출 합계"),
                ],
            )
            .properties(height=350)
        )
        st.altair_chart(chart_mem, use_container_width=True)

        st.subheader("등급별 상세")
        display_df = mem_df.copy()
        display_df.columns = ["멤버십 등급", "매출 합계", "거래 건수", "고객 수"]
        display_df["매출 합계"] = display_df["매출 합계"].apply(lambda x: f"{x:,.0f}")
        display_df["거래 건수"] = display_df["거래 건수"].apply(lambda x: f"{x:,.0f}")
        display_df["고객 수"] = display_df["고객 수"].apply(lambda x: f"{x:,.0f}")
        st.dataframe(display_df, use_container_width=True)

# ---- 탭 3: 코호트 분석 ----
with tab3:
    try:
        cohort_df = query_cohort(
            tuple(sel_brands), start_str, end_str, tuple(sel_tiers)
        )
    except Exception as e:
        st.error(f"데이터 조회 실패: {e}")
        st.stop()

    if cohort_df.empty:
        st.warning("조건에 해당하는 데이터가 없습니다.")
    else:
        cohort_df["COHORT_MONTH"] = pd.to_datetime(cohort_df["COHORT_MONTH"])
        cohort_df["TXN_MONTH"] = pd.to_datetime(cohort_df["TXN_MONTH"])
        cohort_df["COHORT_LABEL"] = cohort_df["COHORT_MONTH"].dt.strftime("%Y-%m")
        cohort_df["TXN_LABEL"] = cohort_df["TXN_MONTH"].dt.strftime("%Y-%m")

        st.subheader("코호트별 월별 매출 히트맵")
        heatmap = (
            alt.Chart(cohort_df)
            .mark_rect()
            .encode(
                x=alt.X("TXN_LABEL:O", title="거래 월", sort=None),
                y=alt.Y("COHORT_LABEL:O", title="가입 코호트", sort=None),
                color=alt.Color("TOTAL_SALES:Q", title="매출 합계", scale=alt.Scale(scheme="blues")),
                tooltip=[
                    alt.Tooltip("COHORT_LABEL:N", title="가입 코호트"),
                    alt.Tooltip("TXN_LABEL:N", title="거래 월"),
                    alt.Tooltip("TOTAL_SALES:Q", format=",", title="매출 합계"),
                ],
            )
            .properties(height=400)
        )
        st.altair_chart(heatmap, use_container_width=True)

        st.subheader("코호트별 월별 매출 추이")
        line_chart = (
            alt.Chart(cohort_df)
            .mark_line(point=True)
            .encode(
                x=alt.X("TXN_LABEL:O", title="거래 월", sort=None),
                y=alt.Y("TOTAL_SALES:Q", title="매출 합계"),
                color=alt.Color("COHORT_LABEL:N", title="가입 코호트"),
                tooltip=[
                    alt.Tooltip("COHORT_LABEL:N", title="가입 코호트"),
                    alt.Tooltip("TXN_LABEL:N", title="거래 월"),
                    alt.Tooltip("TOTAL_SALES:Q", format=",", title="매출 합계"),
                ],
            )
            .properties(height=400)
        )
        st.altair_chart(line_chart, use_container_width=True)
