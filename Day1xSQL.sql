-- Advent of Code, 2020 ------------------
-- Day 1: Report Repair ------------------
-- via SQL Server-------------------------

declare @input varchar(1200) = '1891
1975
1987
1923...'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
create table #Expenses(ExpEntry int,eID int identity)
declare @curLine varchar(6)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #Expenses(ExpEntry)
    values (cast(ltrim(rtrim(@curLine)) as int))
end

select i.ExpEntry, j.ExpEntry,i.ExpEntry * j.ExpEntry[Prod]
from #Expenses i cross join #Expenses j
where i.ExpEntry + j.ExpEntry = 2020


















