--Q1 WE NEED TO KNOW THE SALES MANAGERS FULL NAME, HIS TOTAL SALES (BASED ON CAR), AND THE PERCENTAGE OF HIS TARGET LEFT (BASED ON CAR PRICE)

with t1 as
	(select *, extract(month from "sold_on") as "month"
	from "sales_data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "car_data" cd
on cd.car_code = t1.customer_car_code
join "sales_team" st
on st.sales_manager_id = t1.sales_manager_id)
select name,sum(car_price) over(partition by months,name)as car_sum,months,
round(((monthly_target - sum(car_price))/monthly_target)*100,2) as percentage_left
from t2
group by name,months,car_price,monthly_target
order by name;

-- question 2 
-- FOR THE SALES WITH SALES MANAGER ID AS 12134 WHICH CAR CONSTITUTED HOW MUCH PERCENTAGE OF HIS TARGET

with t1 as
	(select *, extract(month from "sold_on") as "month"
	from "sales_data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "car_data" cd
on cd.car_code = t1.customer_car_code
join "sales_team" st
on st.sales_manager_id = t1.sales_manager_id)

select car_name,sum(car_price) over(partition by months)as car_sum,months,
((sum(car_price))/monthly_target)*100 as "percentage_target(%)"
from t2
where name = 'Ajay Alex'
group by car_name,months,car_price,monthly_target;


-- question 3
-- WHO HAS THE LEAST AND THE MOST DEPOSIT COLLECT AS A PERCENTAGE OF THE TOTAL PRICE OF CARS SOLD BY EACH SALES MANAGER 
with t1 as
	(select *, extract(month from "sold_on") as "month"
	from "sales_data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "car_data" cd
on cd.car_code = t1.customer_car_code
join "sales_team" st
on st.sales_manager_id = t1.sales_manager_id),
t3 as
(select name,
round((sum(deposit_paid_for_booking)/sum(car_price))*100,2) as percentage_left
from t2
group by name
order by name),
t4 as
(select name,percentage_left,
case when percentage_left < lead(percentage_left) over() and
		percentage_left < lag(percentage_left) over() then 'min'
	when percentage_left > lead(percentage_left) over() and
		percentage_left < lead(percentage_left,2) over() then 'mid'
	when percentage_left > lag(percentage_left) over() and
		percentage_left > lag(percentage_left,2) over() then 'max'
else null end as min_max
from t3)
select name,percentage_left,min_max
from t4
where min_max in ('min','max');

-- question 4
-- WHICH CAR CONTRIBUTED TO THE MINIMUM SALES FOR EACH SALES MANAGER AND WHAT IS THE AMOUNT?
--(WE WANT THE SALES MANAGER'S NAME, THE NAME OF THE CAR WHICH CONTRIBUTED TO THE LEAST SALES BY CAR PRICE FOR THAT MANAGER, TOTOAL AMOUNT 
--(TOTAL OF CAR PRICE) FOR THAT CAR SOLD FOR THAT MANAGER)

with t1 as
	(select *, extract(month from "sold_on") as "month"
	from "sales_data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "car_data" cd
on cd.car_code = t1.customer_car_code
join "sales_team" st
on st.sales_manager_id = t1.sales_manager_id),
t3 as
(select name,car_name,sum(car_price) as "total_car_sum"
,row_number() over (partition by name order by sum(car_price))  as rn
from t2
group by name,car_name
order by name,"total_car_sum")
select name,car_name,total_car_sum
from t3
where rn < 2;

-- question 5
--WHAT IS THE AVERAGE  NUMBER OF DAYS BETWEEN CAR SOLD?(WE WANT TO FIND THE AVERAAGE NUMBER OF DAYS FROM ONE SALES TO THE NEXT)

select round(avg(s2.sold_on - s1.sold_on),2) as avg_diff
from "sales_data" s1
join "sales_data" s2 on s1.customer_car_code = s2.customer_car_code
and s1.sold_on < s2.sold_on;

