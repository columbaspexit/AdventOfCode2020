-- Advent of Code, 2020 ------------------
-- Day 9: Encoding Error -----------------
-- via SQL Server-------------------------

-- Data as pasted from site... 
declare @input varchar(max) = '165
78
151
15
138
97
152
64
4
111
7
90
91
156
73
113
93
135
100
70
119
54
80
170
139
33
123
92
86
57
39
173
22
106
166
142
53
96
158
63
51
81
46
36
126
59
98
2
16
141
120
35
140
99
121
122
58
1
60
47
10
87
103
42
132
17
75
12
29
112
3
145
131
18
153
74
161
174
68
34
21
24
85
164
52
69
65
45
109
148
11
23
129
84
167
27
28
116
110
79
48
32
157
130'

-- Define separator pattern...
declare @Sep varchar(4) = concat('%',char(13),char(10),'%')
-- Split @input into rows...
drop table if exists #input
create table #input(orig bigint,oID int identity)
declare @curLine varchar(100)
while len(@input) > 0
 begin
    set @curLine = left(@input, isnull(nullif(patindex(@Sep,@input) - 1, -1),len(@input)))
    set @input = substring(@input,isnull(nullif(patindex(@Sep,@input), 0),len(@input)) + len(@Sep)-2, len(@input))
    insert into #input(orig)
    values (cast(ltrim(rtrim(@curLine)) as bigint))
end

select *
from #input

-- Question 1:
;with cte as(
    select i.orig,i.oID
        ,count(distinct j.orig)[NumJoins]
    from #input i
        left join #input j on i.orig - j.orig between 1 and 3
    group by i.orig,i.oID
)
select *
    -- count(case when NumJoins = 1 then orig end)
    --     * count(case when NumJoins = 3 then orig end)
from cte
order by orig --NumJoins,orig

drop table if exists #Choices
select i.*
    ,case when i.orig = 1 then 0 else d1.orig end[d1]
    ,d2.orig[d2]
    ,d3.orig[d3]
into #Choices
from #input i
    left join #input d1 on i.orig - d1.orig = 1
    left join #input d2 on i.orig - d2.orig = 2
    left join #input d3 on i.orig - d3.orig = 3


select * --count(d1),count(d2),count(d3)
from #Choices
order by orig

-- Question 2: 







