CREATE TABLE JUDGING (
  ANSWER VARCHAR2(15 BYTE)
);

with dom_ip as (
select rownum as DOM_RN, answer as DOM_ANSWER from judging
)
,kattis_ip as (
select rownum as KATTIS_RN, answer as KATTIS_ANSWER from judging
)

, joined_ds as (
    select dom_answer, kattis_answer from dom_ip
    join kattis_ip
    on dom_rn - 5 = kattis_rn
)

, dom_agg as(
    select dom_answer, count(1) as dom_cnt from joined_ds group by dom_answer
)

, kattis_agg as(
    select kattis_answer, count(1) as kattis_cnt from joined_ds group by kattis_answer
)


select sum(summation) from (
select dom_answer, least(dom_cnt, kattis_cnt) as summation from dom_agg join kattis_agg on dom_agg.dom_answer = kattis_agg.kattis_answer
);
