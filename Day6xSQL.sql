-- Advent of Code, 2020 ------------------
-- Day 6: : Custom Customs ---------------
-- via SQL Server-------------------------


-- A small sample of data from the input file...
declare @input varchar(max)
set @input = 'clvxybjp
kripatlzy

yrn
labirzd
noypr

ioluwteykdrcavfgqh
ioevhcfnwjduqyagkr
syjgrehokavfdqwuic
iroexhkqgauwsdbyfcv
ykdiguarfqochwvex

xjgrzncsiqhm
ijzmquhasgxrcn
rqczuimnxgh
xodicfvgnqhrzm

ai
qjaw
agez

kfugexhdbvqrc
wslhcyqzpboxita'


-- Double carriage returns mean the start of a new group. 
-- Single carriage return means a new person in the current group.
-- Trial & error found that a carriage return in ascii is the 2-char sequence 13 & 10
declare @pSep varchar(4) = concat('%',char(13),char(10),'%')
declare @gSep varchar(7) = concat('%',char(13),char(10),char(13),char(10),'%')

declare @allData varchar(max) 

-- tokenize string by group...
set @allData = @input 
drop table if exists #Groups
create table #Groups(gAnswer varchar(126),gID int identity)
-- 
declare @curGrp varchar(126)
while len(@allData) > 0
 begin
    -- Peel off just the current group...
    set @curGrp = left(@allData, isnull(nullif(patindex(@gSep,@allData) - 1, -1),LEN(@allData)))
    -- Cut current group from remaining groups...
    set @allData = SUBSTRING(@allData,isnull(nullif(patindex(@gSep,@allData), 0),LEN(@allData)) + 4, LEN(@allData))
    insert into #Groups(gAnswer)
    values (ltrim(rtrim(@curGrp)))
end

-- tokenize string by person...
set @allData = @input 
drop table if exists #Persons
create table #Persons(pAnswer varchar(26),pID int identity,gID int)
-- 
declare @curPrsn varchar(26)
while LEN(@allData) > 0
 begin
    set @curPrsn = left(@allData, ISNULL(nullif(patindex(@pSep,@allData) - 1, -1),LEN(@allData)))
    set @allData = SUBSTRING(@allData,ISNULL(nullif(patindex(@pSep,@allData), 0),LEN(@allData)) + 2, LEN(@allData))
    insert into #Persons(pAnswer)
    values
        (ltrim(rtrim(@curPrsn)))
end

-- Count up ''s to id which group a person is in...
;with cte as(
    select pID,count(case when pAnswer = '' then pAnswer end) over(order by pID rows unbounded preceding) + 1[groupID]
    from #Persons
)
update #Persons
    set gID = groupID
    from #Persons orig
        inner join cte src on orig.pID = src.pID


-- Helper table listing all letters, a-z
declare @n as int = ascii('a')
drop table if exists #Letters
create table #Letters(letter varchar(5),n int)
while @n <= ascii('z')
begin
    insert into #Letters(letter) values(char(@n))
    set @n = @n + 1
end


-- Question 1 -----------------------------------
-- Each group gets an entry for each letter/question, if ANY person in the group answered yes to it
drop table if exists #GrpxLtr
select g.*, l.letter
into #GrpxLtr
from #Groups g cross join #Letters l
where charindex(letter,gAnswer) > 0 

;with cte as(
    select gID,gAnswer,count(*)[DiffLetters]
    from #GrpxLtr
    group by gID,gAnswer
)
select sum(DiffLetters)[Q1 Answer]
from cte


-- Question 2 -----------------------------------
-- Each person gets an entry for each letter/question, if they answered yes to it
drop table if exists #PrsnxLtr
select p.*, l.letter, 1[n]
into #PrsnxLtr
from #Persons p cross join #Letters l
where charindex(letter,pAnswer) > 0 


;with cte as(
    select gID
        -- # of persons in each group
        ,count(distinct pID)[NumPersons]
    from #PrsnxLtr
    group by gID
)
, cte2 as(
    select tl.gID
        ,np.NumPersons
        ,tl.letter
        -- Number of yeses for a given letter/question, among group members...
        ,sum(tl.n)[nYes]
    from #PrsnxLtr tl
        inner join cte np on tl.gID = np.gID
    group by tl.gID
        ,np.NumPersons
        ,tl.letter
    -- limit entries to the letters/questions that ALL group members answered yes to
    having sum(tl.n) = np.NumPersons
)
select count(*)[Q2 Answer]
from cte2
