-- SQL Final Exam
-- Sam (Dong Wook) Ko

-- 1. Find the name and title of every professor or associate professor who was hired in 1992. 
select concat(s.StfFirstName,' ',s.StfLastName) as name, f.title, s.datehired
from staff s
join faculty f
on s.staffid = f.staffid
where date_part('year',s.datehired) = '1992' and f.title in ('Associate Professor','Professor'); 


-- 2. For each student, compute the average score of all the classes that they have completed. 
-- Class status = [1: enrolled, 2: completed, 3: withdraw]. Ordered in desc by student_average_grade
select concat(s.studfirstname,' ', s.studlastname) as student_name, avg(ss.grade) as student_average_grade
from students s
join student_schedules ss
on s.studentid = ss.studentid
where ss.classstatus = '2'
group by student_name
order by student_average_grade desc


-- 3. Which subject is not assigned a faculty member to teach it?
select s.subjectcode, s.subjectname
from subjects s
left join faculty_subjects fs
on s.subjectid = fs.subjectid
where fs.staffid is null


-- 4. List each faculty member and the count of classes each is scheduled to teach.
-- Limit the result to only those who teach more than 7 classes.
select concat(s.StfLastName,', ',s.StfFirstName) as concat, count(fc.classid) as "count"  -- I concatenated so that it is (lastname, firsname)
from staff s
join faculty_classes fc 
on s.staffid = fc.staffid
group by concat
having count(fc.classid) > 7
order by "count"
-- Per Abbass, "classes scheduled to teach" include all the classes. It doesn't have to do with any time period and therefore includes
-- all classes in the database. 



-- 5. Show what new salaries for the full time faculty would be if you give 5% raise to instructor, 4% raise to associate professor,
-- and 3% raise to professors. Round to nearest integer. 
select s.staffid, s.StfLastName, s.StfFirstName, f.title, f.status, cast(s.salary as int),
case when f.title = 'Professor' then cast(s.salary * 1.035 as int)
when f.title = 'Associate Professor' then cast(s.salary * 1.04 as int)
else cast(s.salary * 1.05 as int) end as newsalary
from staff s
join faculty f
on s.staffid = f.staffid
where f.status = 'Full Time'


-- 6. For each subject, report the highest grade that's been received. 
-- Also, report the highest grade thats been received for each category. order by category id
select distinct s.categoryid, s.subjectcode, s.subjectname,    -- 'distinct' allows to present 1 subject at a time. 
max(ss.grade) over (partition by s.subjectname) as subjectmax,
max(ss.grade) over (partition by s.categoryid) as categorymax
from subjects s
join classes c on s.subjectid = c.subjectid
join student_schedules ss on c.classid = ss.classid
where ss.classstatus = '2'     -- this indicates that the grades have been received since the course is complete
order by s.categoryid         

-- 7. For each dept, report the score of the professor with the highest avg proficiency rating. 
with tb1 as (                  -- tb1 identifies average rating for all of professors 
	select fs.staffid, avg(fs.proficiencyrating) as average_rating
	from faculty_subjects fs
	group by fs.staffid),
tb2 as (                       -- tb2 identifies department name and all of the staffid
	select d.deptname, fs.staffid
	from departments d
	join categories c on d.departmentid = c.departmentid
	join subjects s on c.categoryid = s.categoryid
	join faculty_subjects fs on s.subjectid = fs.subjectid)
select tb2.deptname, max(average_rating) as max_score
from tb1 
join tb2
on tb1.staffid = tb2.staffid
group by tb2.deptname