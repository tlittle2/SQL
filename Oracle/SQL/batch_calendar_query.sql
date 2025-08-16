select batch_indicator.*
    , case
        when DAY_OF_WEEK_NUM IN ('1', '2')  then 'N'
        when POST_HOLIDAY_IND = 'Y' AND lag(DAY_OF_WEEK_NUM) over(order by date_id) = '2' THEN 'N'
        when POST_HOLIDAY_IND = 'Y' THEN 'N'
        --add any manual dates here if needed
    end AS BATCH_IND
from (
    select post_holiday.*
    , case when lag(HOLIDAY_IND) over(order by date_id) = 'Y' then 'Y' END AS POST_HOLIDAY_IND
    from(
            select to_char(dt, 'yyyymmdd') as DATE_ID
                , dt as CALENDAR_DATE
                , to_char(dt, 'MM') as CALENDAR_MONTH
                , to_char(dt, 'DD') as CALENDAR_DAY
                , to_char(dt, 'YYYY') as CALENDAR_YEAR
				, to_char(dt, 'D') as DAY_OF_WEEK_NUM
				, to_char(dt, 'DAY') as DAY_OF_WEEK
                , case when to_char(dt, 'DY') in ('SAT', 'SUN') THEN 'Y' else 'N' end as WEEKEND_IND
                , case when dt in (
                    --put dates when the holiday's are OBSERVED here?
                                to_date('2023-JAN-02', 'YYYY/MM/DD'), --NEW YEAR'S DAY
                                to_date('2023-JAN-16', 'YYYY/MM/DD'), --MLK DAY
                                to_date('2023-FEB-20', 'YYYY/MM/DD'), --PRESIDENT'S DAY
                                to_date('2023-APR-07', 'YYYY/MM/DD'), --GOOD FRIDAY
                                to_date('2023-MAY-29', 'YYYY/MM/DD'), --MEMORIAL DAY
                                to_date('2023-JUN-19', 'YYYY/MM/DD'), --JUNTEEETH
                                to_date('2023-JUL-04', 'YYYY/MM/DD'), --INDEPENDENCE DAY
                                to_date('2023-SEP-04', 'YYYY/MM/DD'), --LABOR DAY
                                to_date('2023-NOV-23', 'YYYY/MM/DD'), --THANKSGIVING
                                to_date('2023-DEC-25', 'YYYY/MM/DD')  --CHRISTMAS
                                  )  
                       or to_char(dt, 'DY') in ('SAT', 'SUN') THEN 'N' -- WEEKENDS
                       ELSE 'Y' end as BUSINESS_DAY_IND     

                , case when dt in (
                    --put dates when the holiday's are OBSERVED here?
                                to_date('2023-JAN-02', 'YYYY/MM/DD'), --NEW YEAR'S DAY
                                to_date('2023-JAN-16', 'YYYY/MM/DD'), --MLK DAY
                                to_date('2023-FEB-20', 'YYYY/MM/DD'), --PRESIDENT'S DAY
                                to_date('2023-APR-07', 'YYYY/MM/DD'), --GOOD FRIDAY
                                to_date('2023-MAY-29', 'YYYY/MM/DD'), --MEMORIAL DAY
                                to_date('2023-JUN-19', 'YYYY/MM/DD'), --JUNTEEETH
                                to_date('2023-JUL-04', 'YYYY/MM/DD'), --INDEPENDENCE DAY
                                to_date('2023-SEP-04', 'YYYY/MM/DD'), --LABOR DAY
                                to_date('2023-NOV-23', 'YYYY/MM/DD'), --THANKSGIVING
                                to_date('2023-DEC-25', 'YYYY/MM/DD')  --CHRISTMAS
                                  )  then 'Y' 
                       ELSE 'N' end as HOLIDAY_IND 
                from(

                    select date'2023-01-01' + level-1 as dt
                    from dual connect by level<=365
                ) 
        
    ) post_holiday
)batch_indicator;
