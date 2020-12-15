-- Advent of Code, 2020 ------------------
-- Day 9: Encoding Error -----------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = 'LLLLLLLLLLLLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLL.LLLL.LLLL.LLLLLLLLLL.LLLLLL.LLLLL
LLLLL.LLLL.LLLLL.LLLLL.L.LLLLLL.LLLL.LLLLLL.LL....LLLLLLLL.LLLLLLLLL.LLLL.LLLLLLLLLL.LLLLLLL
LLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLL.LL.LLLLLL.L.'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
drop table if exists #input
create table #input(orig varchar(100),oID int identity)
declare @curLine varchar(100)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #input(orig)
    values (ltrim(rtrim(@curLine)))
end

select count(*)
from #input

-- Question 1:
-- First order of business, how to grab the up to 8 adjacent chars...
-- Joining sets is easy in SQL, unlike trying to write up a bunch of substring nonsense.
-- If each indiv char is its own row, instead of mirroring entire actual rows,
-- we can just join our way to the needed counts, iterating till we get a steady state.
--   declare @curLine varchar(100)
drop table if exists #tokens
create table #tokens(oID int,cID int,seat int)
declare @curSeat int
declare @seatPos int = 1
declare @rowPos int = 1
while @rowPos <= (select max(oID) from #input)
begin
    set @curLine = (select orig from #input where oID = @rowPos)
    while len(@curLine) > 0
    begin
        set @curSeat = case left(@curLine,1) when 'L' then 0 when '#' then 1 else null end
        set @curLine = substring(@curLine,2,len(@curLine))
        if @curSeat is not null
        begin
            insert into #tokens(oID,cID,seat)
            values(@rowPos,@seatPos,@curSeat)
        end
        set @seatPos = @seatPos + 1
    end
    set @rowPos = @rowPos + 1
    set @seatPos = 1
end


select *
from #tokens
where oid = 1

-- Join showing the number of seats adjacent to each seat and the number of occupied seats
select i.*
    ,count(a.cID)[AdjSeats]
    ,sum(a.seat)[OccSeats]
from #tokens i
    left join #tokens a on (i.oID = a.oID + 1 or i.oID + 1 = a.oID or i.oID = a.oID)
        and ((i.cID = a.cID and i.oID <> a.oID)
            or i.cID = a.cID + 1 
            or i.cID + 1 = a.cID)
where i.oID = 2
group by i.seat 
    ,i.oID,i.cID
order by i.cID

-- fail... manually ran this till it reached a steady state.
-- aka the whole table toggled
;with cte as(
    select i.*
    ,count(a.cID)[AdjSeats]
    ,sum(a.seat)[OccSeats]
from #tokens i
    left join #tokens a 
        on  (i.oID = a.oID + 1 or i.oID + 1 = a.oID or i.oID = a.oID)
        and (i.cID = a.cID + 1 or i.cID + 1 = a.cID 
              or (i.cID = a.cID and i.oID <> a.oID))
group by i.seat 
    ,i.oID,i.cID
)
update t
set t.seat = case when OccSeats = 0 then 1
                  when OccSeats >= 4 then 0 end
from #tokens t inner join cte c 
    on t.cID = c.cID and t.oID = c.oID
where OccSeats = 0 or OccSeats >= 4

select sum(seat)
from #tokens


select *
from #tokens
where oid < 3
order by cID,oID

-- Question 2: 







