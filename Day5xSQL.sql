-- Advent of Code, 2020 ------------------
-- Day 5: : Binary Boarding --------------
-- via SQL Server-------------------------

-- Create table for the problem...
drop table if exists #Day5
create table #Day5(
  	BoardingPass varchar(10)
   ,rowBin varchar(7)
   ,colBin varchar(3)
   ,rowInt int default (0)
   ,colInt int default (0)
   ,SeatID int)
   
-- Not typing out all 717 boarding passes, but it'd look like this...
insert into #Day5(BoardingPass) values 
    ('FFBFFBFLLR'),('BFBFBFBRLR'),('FBFFBFBRRL')

-- Recode the F/Bs & L/Rs as 0/1s and convert it all to integers...
declare @rowChars int = 7 -- Row number encoded in first 7 chars
declare @colChars int = 3 -- Column number encoded in last 3 chars

update #Day5
  set rowBin = replace(replace(left(BoardingPass,@rowChars),'F','0'),'B','1')
      ,colBin = replace(replace(right(BoardingPass,@colChars),'L','0'),'R','1')

-- I don't know how to convert literal binary to hex binary
-- (to take advantage of the convert function, thx SQL Server! >.<),
-- so manually converting rowBin and colBin to decimal numbers.
declare @i int = 0
while @i < @rowChars
begin
    update #Day5
    	set rowInt = rowInt + left(right(rowBin,@i+1),1) * power(2,@i)
    set @i = @i + 1
    if @i >= @rowChars break
    else continue
end 

set @i = 0
while @i < @colChars
begin
    update #Day5
    	set colInt = colInt + left(right(colBin,@i+1),1) * power(2,@i)
    set @i = @i + 1
    if @i >= @colChars break
    else continue
end 

update #Day5
	set SeatID = rowInt * 8 + colInt

-- Check the seq to SeatID mapping is correct...
select 'Error! SeatID maps to two boarding passes'[No Results = WIN]
    ,SeatID,count(*)
from #Day5
group by SeatID
having count(*) > 1

-- Question 1: Max seatID?
select top 1 SeatID [Max SeatID]
from #Day5
order by SeatID desc

-- Question 2: Your SeatID will be one less than the (only?)
-- SeatID with a gap of 2 between it and the previous SeatID...
;with cte as(
	select SeatID
    	,SeatID - lag(SeatID,1,null) over(order by SeatID) [idGap]
	from #Day5
)
select (SeatID - 1)[Your SeatID]
from cte 
where idGap = 2
