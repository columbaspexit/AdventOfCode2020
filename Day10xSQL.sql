-- Advent of Code, 2020 ------------------
-- Day 10: Adapter Array -----------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = '165
78
151
15...'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
drop table if exists #input
create table #input(orig bigint,oID int identity)
declare @curLine varchar(100)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #input(orig)
    values (cast(ltrim(rtrim(@curLine)) as bigint))
end

select *
from #input

-- Question 1:
;with cte as(
    select i.orig,i.oID
        ,count(distinct j.orig)[NumJoins]
    from #input i
        left join #input j on i.orig - j.orig between 1 and 3
    group by i.orig,i.oID
)
select *
    -- count(case when NumJoins = 1 then orig end)
    --     * count(case when NumJoins = 3 then orig end)
from cte
order by orig --NumJoins,orig

drop table if exists #Choices
select i.*
    ,case when i.orig = 1 then 0 else d1.orig end[d1]
    ,d2.orig[d2]
    ,d3.orig[d3]
into #Choices
from #input i
    left join #input d1 on i.orig - d1.orig = 1
    left join #input d2 on i.orig - d2.orig = 2
    left join #input d3 on i.orig - d3.orig = 3


select * --count(d1),count(d2),count(d3)
from #Choices
order by orig

-- Question 2: 







