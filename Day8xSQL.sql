-- Advent of Code, 2020 ------------------
-- Day 8: Handheld Halting ---------------
-- via SQL Server-------------------------

,len(@input)) + len(@Sep)-2, len(@input))
    insert into #BootSeq(orig)
    values (ltrim(rtrim(@curLine)))
end
update #BootSeq 
set op = left(orig,charindex(' ',orig)-1)
    ,arg = cast(right(orig,len(replace(orig,'+',''))-charindex(' ',replace(orig,'+',''))) as int)

-- Question 1: Final accumulator value before an instruction is called a second time?
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

select top 1 AccVal[Q1 Answer]
from #Trvrs
where NumExec <2
order by n desc

-- Question 2: What single jmp or nop operation change reaches the last line of #BootSeq?
-- If we go backwards from the last instruction, what does that path looks like?
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

-- Which pIDs can be arrived at if nop ->jmp or jmp -> nop?
drop table if exists #AltOrigs
select e.pID
    ,n.pID[AltOrigID]
into #AltOrigs
from #BootSeq e inner join #BootSeq n 
    on e.pID = (n.pID + n.arg + 623) % 623 and n.op = 'nop'
insert into #AltOrigs
select e.pID
    ,n.pID[AltOrigID]
from #BootSeq e inner join #BootSeq n 
    on e.pID = (n.pID + 1 + 623) % 623 and n.op = 'jmp' and n.arg <> 1

-- So the pID to change is...
declare @altID int, @altOp varchar(3)
select @altID = t.pID ,@altOp = t.op
from #Rvrs r inner join #AltOrigs ao on r.pID = ao.pID
    inner join #Trvrs t on ao.AltOrigID = t.pID and t.NumExec = 1
    
-- Rerun #Trvrs with the one modified operation...
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
        ,(c.NextPos + case when b.op = 'jmp' or (@altOp = 'nop' and @altID = b.pID) 
                            then b.arg else 1 end) % @lx
        ,c.AccVal + case when b.op = 'acc' then b.arg else 0 end
    from cte c inner join #BootSeq b on b.pID = c.NextPos
    where n < @lx
)
select top 1 AccVal[Q2 Answer]
from cte 
order by n desc
option (maxrecursion 623)
