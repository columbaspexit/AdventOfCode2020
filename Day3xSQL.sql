-- Advent of Code, 2020 ------------------
-- Day 3: Toboggan Trajectory ------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = '.........#....#.###.........##.
..###.#......#......#.......##.
##....#.#.......#.....#........'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
drop table if exists #input
create table #input(orig varchar(100),pID int identity)
declare @curLine varchar(100)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #input(orig)
    values (ltrim(rtrim(@curLine)))
end


-- Question 1: How many trees/hits on a 3-right/1-down slope?
drop table if exists #slopes
create table #slopes(StepsRight int, StepsDown int, m numeric(25,15), b numeric(25,15))
insert into #slopes(StepsRight, StepsDown) values (3,1) 
update #slopes
set m = cast(StepsDown as numeric(25,15))/StepsRight
    ,b = 1 - cast(StepsDown as numeric(25,15))/StepsRight

declare @PatLen int = (select top 1 len(orig) from #input order by len(orig))
;with cte as(
    select concat(s.StepsRight,' right, ',s.StepsDown,' down')[Slope]
        ,case when (pID-1) % s.StepsDown +1 = 1 and pID > 1 then 
            case substring(orig,isnull(nullif(cast(round((pID-s.b)/s.m,0) as int) % @PatLen,0),@PatLen),1)
                when '#' then 1 else 0 end
            else 0 end[Hit]
    from #input i cross join #slopes s
)
select Slope,sum(Hit)[Q1 Answer]
from cte
group by Slope


-- Question 2: Same, bUt VaRriAbLEs!
insert into #slopes(StepsRight,StepsDown) values (1,1),(5,1),(7,1),(1,2)
update #slopes
set m = cast(StepsDown as numeric(25,15))/StepsRight
    ,b = 1 - cast(StepsDown as numeric(25,15))/StepsRight

drop table if exists #wtf
;with cte as(
    select concat(s.StepsRight,' right, ',s.StepsDown,' down')[Slope]
        ,case when (pID-1) % s.StepsDown +1 = 1 and pID > 1 then 
            case substring(orig,isnull(nullif(cast(round((pID-s.b)/s.m,0) as int) % @PatLen,0),@PatLen),1)
                when '#' then 1 else 0 end
            else 0 end[Hit]
    from #input i cross join #slopes s
)
,HitTotals as(
    select Slope,sum(Hit)[Hits]
    from cte
    group by Slope 
)
select round(exp(sum(log(Hits))),0)[Q2 Answer]
from HitTotals