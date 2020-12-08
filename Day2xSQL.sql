-- Advent of Code, 2020 ------------------
-- Day 2: Password Philosophy ------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = '13-14 f: ffffffffnfffvv
10-12 w: kwtzpnzspwwwdz
2-3 n: nnjn...'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
create table #input(orig varchar(100),pID int identity)
declare @curLine varchar(100)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #input(orig)
    values (ltrim(rtrim(@curLine)))
end

-- Question 1: How many valid passwords are there?
;with cte as(
    select *
        ,cast(replace(left(orig,2),'-','') as int)[minQ]
        ,cast(substring(orig,charindex('-',orig)+1,charindex(' ',orig)-charindex('-',orig)) as int)[maxQ]
        ,substring(orig,charindex(':',orig)-1,1)[Letter]
        ,right(orig,len(orig)-charindex(':',orig)-1)[Pwd]
    from #input
)
select sum(case when len(pwd)-len(replace(pwd,Letter,'')) between minQ and maxQ then 1 else 0 end)[Q1 Answer]
from cte

-- Question 2: How many valid passwords are there with the new rule interpretation?
;with cte as(
    select *
        ,cast(replace(left(orig,2),'-','') as int)[minQ]
        ,cast(substring(orig,charindex('-',orig)+1,charindex(' ',orig)-charindex('-',orig)) as int)[maxQ]
        ,substring(orig,charindex(':',orig)-1,1)[Letter]
        ,right(orig,len(orig)-charindex(':',orig)-1)[Pwd]
    from #input
)
select sum(case len(replace(concat(substring(pwd,minQ,1),substring(pwd,maxQ,1)),Letter,''))
                - len(concat(substring(pwd,minQ,1),substring(pwd,maxQ,1)))
            when -1 then 1 else 0 end)[Q2 Answer]
from cte
