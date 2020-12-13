-- Advent of Code, 2020 ------------------
-- Day 4: Passport Processing ------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = 'eyr:2029 pid:157374862
byr:1991 ecl:amb hcl:#a97842 hgt:178cm

byr:1962 pid:547578491 eyr:2028 ecl:hzl hgt:65in iyr:2013 hcl:#623a2f

hgt:71in eyr:2037
ecl:#8e276e hcl:z iyr:2019
byr:2022 pid:157cm'

-- Define separator pattern...
declare @Sep varchar(6) = concat('%',char(13),char(10),char(13),char(10),'%')
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

-- List of all the fields in the data...
drop table if exists #fields
create table #fields(field varchar(3),fID int identity)
insert into #fields values ('byr'),('iyr'),('eyr'),('hgt'),('hcl'),('ecl'),('pid'),('cid')

-- Replace straggling carriage returns with normal spaces...
update #input
set orig = replace(orig,concat(char(13),char(10)),char(32))

-- Question 1: How many passport records have all 7 required fields?
;with cte as(
    select i.*,f.*
        ,charindex(field,orig)[FieldPos]
    from #input i cross join #fields f
)
, FieldCounts as(
    select pID,count(*)[NumFields]
    from cte
    where field <> 'cid'
        and FieldPos > 0
    group by pID
    having count(*) = 7
)
select count(*)[Q1 Answer]
from FieldCounts

-- Question 2: How many passport records are completely valid?
drop table if exists #PassportFields
;with cte as(
    select i.*,f.*
        ,charindex(field,orig)[FieldPos]
    from #input i cross join #fields f
    where charindex(field,orig) > 0
)
select *
    ,substring(orig,FieldPos+4,lead(FieldPos,1,len(orig)+1) over(partition by pID order by FieldPos)-FieldPos-4)[FieldVal]
    ,cast(null as bit)[FieldErr]
into #PassportFields
from cte
order by pID,FieldPos

update #PassportFields 
set FieldVal = ltrim(rtrim(FieldVal))

update #PassportFields -- byr (Birth Year) - four digits; at least 1920 and at most 2002.
set FieldErr = case when cast(FieldVal as int) between 1920 and 2002 then 0 else 1 end
where field = 'byr'

update #PassportFields -- iyr (Issue Year) - four digits; at least 2010 and at most 2020.
set FieldErr = case when cast(FieldVal as int) between 2010 and 2020 then 0 else 1 end
where field = 'iyr'

update #PassportFields -- eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
set FieldErr = case when cast(FieldVal as int) between 2020 and 2030 then 0 else 1 end
where field = 'eyr'

update #PassportFields-- hgt (Height) - a number followed by either cm or in:
                        -- If cm, the number must be at least 150 and at most 193.
                        -- If in, the number must be at least 59 and at most 76.
set FieldErr = case right(FieldVal,2) 
                when 'cm' then case when cast(replace(FieldVal,'cm','') as int) between 150 and 193 then 0 else 1 end
                when 'in' then case when cast(replace(FieldVal,'in','') as int) between 59 and 76 then 0 else 1 end
                else 1 end
where field = 'hgt' 

update #PassportFields -- hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
set FieldErr = case when FieldVal like '#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]' then 0 else 1 end
where field = 'hcl' 

update #PassportFields -- ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
set FieldErr = case when FieldVal in ('amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth') then 0 else 1 end
where field = 'ecl'

update #PassportFields -- pid (Passport ID) - a nine-digit number, including leading zeroes.
set FieldErr = case when len(FieldVal) = 9 and isnumeric(FieldVal) = 1 then 0 else 1 end
where field = 'pid'

;with cte as(
    select pID
        ,count(distinct field)[TotFields]
        ,sum(cast(FieldErr as int))[TotErrs]
    from #PassportFields
    where field <> 'cid'
    group by pID
    having sum(cast(FieldErr as int)) = 0
        and count(distinct field) = 7
)
select count(*)[Q2 Answer]
from cte