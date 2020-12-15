-- Advent of Code, 2020 ------------------
-- Day 9: Encoding Error -----------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = '23
3
36...'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
drop table if exists #input
create table #input(orig bigint,pID int identity)
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

drop table if exists #Solns
;with cte as(
    
;with cte as(
select i.orig,i.pID
    ,jOrig,jID,kOrig,kID
from #input i
    left join (select j.orig[jOrig],j.pID[jID]
                    ,k.orig[kOrig],k.pID[kID]
                from #input j cross join #input k
                where k.pID-j.pID between 1 and 24) jk 
        on i.orig = jOrig + kOrig
            and i.pID - kID between 1 and 25
where i.pID > 25
group by i.orig,i.pID
    ,jOrig,jID,kOrig,kID
)
select *
    ,count(*) over(partition by pID order by jID desc rows unbounded preceding)[NumSolns]
into #Solns
from cte

select top 100*
from #Solns
where (kID is null and NumSolns = 1)
    or orig = jOrig + kOrig
order by pID,jID


;with cte as(
    select i.*
        ,j.orig[jo],j.pID[jID]
        ,k.orig[ko],k.pID[kID]
        ,count(*) over(partition by i.orig order by i.pID rows unbounded preceding)[nSolns]
    from #input i
        left join #input j on j.pID >= i.pID-25 and j.pID < i.pID
        left join #input k on k.pID >= i.pID-25 and k.pID < i.pID
    where (i.orig = isnull(j.orig,i.orig) + isnull(k.orig,i.orig)
            -- or (j.orig is null and k.orig is null)
            )
        and i.pID > 25
)
select *
from cte
-- where jOrig is null
order by pID

select *
from #input
where pid = 540


select 1,*
    ,i.orig + lead(i.orig,1) over(order by pID)[2sum]
from #input i
where pID >= 1