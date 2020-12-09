-- Advent of Code, 2020 ------------------
-- Day 8: Handheld Halting ---------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = 'acc -17
nop +318
jmp +1...'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
drop table if exists #BootSeq
create table #BootSeq(orig varchar(100),pID int identity,op varchar(3),arg int)
declare @curLine varchar(100)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #BootSeq(orig)
    values (ltrim(rtrim(@curLine)))
end
-- Split rows into columns...
update #BootSeq
set op = left(orig,charindex(' ',orig)-1)
    ,arg = cast(right(orig,len(replace(orig,'+',''))-charindex(' ',replace(orig,'+',''))) as int)

-- Generate current boot sequence traversal path...
declare @len int = (select count(*) from #BootSeq)
drop table if exists #Trvrs
;with cte(n,pID,op,arg,NextPos,AccVal) as(
    select 1, pID, op, arg
        ,(1 + case when op = 'jmp' then arg else 1 end) % @len
        ,case when op = 'acc' then arg else 0 end
    from #BootSeq
    where pID = 1
    union all
    select n+1, b.pID, b.op, b.arg
        ,(c.NextPos + case when b.op = 'jmp' then b.arg else 1 end) % @len
        ,c.AccVal + case when b.op = 'acc' then b.arg else 0 end
    from cte c inner join #BootSeq b on b.pID = c.NextPos
    where n < @len
)
select *,count(*) over(partition by pID order by n rows unbounded preceding)[NumExec]
into #Trvrs 
from cte option (maxrecursion 623)

-- Question 1: Final accumulator value before an instruction is called a second time?
select top 1 AccVal[Q1 Answer]
from #Trvrs
where NumExec <2
order by n desc


-- Question 2: What single jmp or nop operation should change to reach the last line of #BootSeq?
-- Well, if we go backwards from the last instruction, what does that path looks like?
-- The instruction that changes in #Trvrs will land somewhere on this path.
declare @ln int = (select count(*) from #BootSeq)
drop table if exists #Rvrs
;with cte(n,pID,op,arg) as(
    select 1, pID, op, arg
    from #BootSeq
    where pID = 623
    union all
    select n+1, b.pID, b.op, b.arg
    from cte c inner join #BootSeq b on (b.pID+1 = c.pID and b.op in ('nop','acc'))
        or (b.pID + b.arg = c.PID and b.op = 'jmp')
    where n < @ln
)
select *,count(*) over(partition by pID order by n rows unbounded preceding)[NumExec]
into #Rvrs 
from cte option (maxrecursion 623)

-- -- Which pIDs have multiple origins, i.e. infinite loops?
-- select count(*) over(partition by e.pID)[NumReps]
--     ,*
-- from #BootSeq e
--     left join #BootSeq n on 
--         (e.pID = n.pID + 1 and n.op in ('acc','nop'))
--         or (e.pID = (n.pID + n.arg + 623) % 623 and n.op = 'jmp')
-- order by e.pID

-- Which pIDs can be arrived at if nop ->jmp or jmp -> nop?
select e.pID
    ,n.pID[AltOrigID]
into #AltOrigs
from #BootSeq e inner join #BootSeq n 
    on e.pID = (n.pID + n.arg + 623) % 623 and n.op = 'nop'

-- Which pIDs can be arrived at if a 'jmp' operation were actually a 'nop'?
insert into #AltOrigs
select e.pID
    ,n.pID[AltOrigID]
from #BootSeq e inner join #BootSeq n 
    on e.pID = (n.pID + 1 + 623) % 623 and n.op = 'jmp' and n.arg <> 1


-- So the pID in 
select t.pID
from #Rvrs r inner join #AltOrigs ao on r.pID = ao.pID
    inner join #Trvrs t on ao.AltOrigID = t.pID and t.NumExec = 1
    

-- Found the pID to change: 299 goes from 'jmp' to 'nop'
declare @lx int = (select count(*) from #BootSeq)
drop table if exists #AltTrvrs
;with cte(n,pID,op,arg,NextPos,AccVal) as(
    select 1, pID, op, arg
        ,(1 + case when op = 'jmp' then arg else 1 end) % @lx
        ,case when op = 'acc' then arg else 0 end
    from #BootSeq
    where pID = 1
    union all
    select n+1, b.pID, b.op, b.arg
        ,(c.NextPos + case when b.op = 'jmp' and (b.pID <> 299) then b.arg else 1 end) % @lx
        ,c.AccVal + case when b.op = 'acc' then b.arg else 0 end
    from cte c inner join #BootSeq b on b.pID = c.NextPos
    where n < @lx
)
select *
    ,count(*) over(partition by pID order by n rows unbounded preceding)[NumExec]
into #AltTrvrs 
from cte  option (maxrecursion 623)

