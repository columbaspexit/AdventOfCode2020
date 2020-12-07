-- Advent of Code, 2020 ------------------
-- Day 7: Handy Haversacks ---------------
-- via SQL Server-------------------------

-- Create table for the problem...
create table #bags(parent varchar(20),qty int,child varchar(20))
-- Sample row for 'dim tan bags contain 1 pale blue bag, 4 drab red bags.' 
insert into #bags values ('dim tan',1,'pale blue'),('dim tan',4,'drab red')

-- Question 1: How many different bags can contain a shiny gold bag?
;with cte(n,parent,child) as(
    select 0,b.parent,b.child
    from #bags b
    where child = 'shiny gold'
    union all
    select n + 1,b.parent,b.child
    from #bags b inner join cte c 
        on b.child = c.parent
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
)
select sum(qty)[Q2 Answer]
from cte
