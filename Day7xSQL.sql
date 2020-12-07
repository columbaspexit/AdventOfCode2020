-- Advent of Code, 2020 ------------------
-- Day 7: Handy Haversacks ---------------
-- via SQL Server-------------------------

create table #bags(
    parent varchar(20)
    ,qty int
    ,child varchar(20)
)
-- E.g. 'pale turquoise bags contain 1 pale tan bag, 4 striped red bags, 1 bright olive bag.' 
-- ...becomes three rows in #bags:
insert into #bags
values ('pale turquoise',1,'pale tan')
    ,('pale turquoise',4,'striped red')
    ,('pale turquoise',1,'bright olive')
    

-- Question 1: How many different bags can contain a shiny gold bag?
-- How many different bag types are there?
select count(distinct child) from #bags

-- No idea how many times this needs to loop, so I just
-- added 1 till the distinct parent count stopped increasing,
-- or if it got to the total number of different bags as found above.
;with cte(n,parent,child) as(
    select 0,b.parent,b.child
    from #bags b
    where child = 'shiny gold'
    union all
    select n + 1,b.parent,b.child
    from #bags b inner join cte c 
        on b.child = c.parent
    where n < 7
)
select count(distinct parent)[Q1 Answer]
from cte


-- Question 2: How many bags does a shiny gold bag need to hold?
;with cte(n,parent,child,qty) as(
    select 0,b.parent,b.child,b.qty
    from #bags b 
    where parent = 'shiny gold'
    union all
    select n + 1,b.parent,b.child
        ,b.qty*c.qty
    from #bags b inner join cte c
        on c.child = b.parent 
    where n < 7
)
select sum(qty)[Q2 Answer]
from cte