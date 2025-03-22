with ip as(
    select 7 as ip1 from dual
    
)
select
    case when ip1 = 0
        then 0
    else
        case when ip1 <> 7
        then ip1 + 1
        else 7
        end
    end as answer
    from ip;
