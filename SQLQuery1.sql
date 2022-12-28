create database zomato;

use zomato;

create table goldusers_signup(userid int,gold_signup_Date date);

insert into goldusers_signup values(1,'09-22-2017'),(3,'04-21-2017');


create table users(useid int,signup_date date);

insert into users values (1,'09-02-2014'),(2,'01-15-2015'),(3,'04-11-2014');


create table sales(userid int,created_date date ,product_id int);


insert into sales (userid,created_date,product_id) values(1,'04-19-2017',2),(3,'12-18-2019',1),(2,'07-20-2020',3),(1,'10-23-2019',2),(1,'03-19-2018',3),(3,'12-20-2016',2),
(1,'11-09-2016',1),(1,'05-20-2016',3),(2,'09-24-2017',1),(1,'03-11-2017',2),(1,'03-11-2016',1),(3,'11-10-2016',1),(3,'12-07-2017',2),(3,'12-15-2016',2),
(2,'11-08-2017',2),(2,'09-10-2018',3);


create table product(product_id int,product_name text,price int);

insert into product(product_id,product_name,price)values(1,'p1',980),(2,'p2',870),(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

drop table sales;
drop table product;
drop table goldusers_signup;
drop table users;


1) What is the total amount from  each customer spent on zomato?

select sales.userid,sum(product.price) as total_amount_customer from sales inner join product on sales.product_id=product.product_id
group by userid;


2) how many days has each customer visited zomato?

select userid,count(created_date) as  distinct_customer from sales group by userid;


3)what was the first product purchased by each customer?

select * from(select *,rank() over(partition by userid order by created_date) as rnk from sales) a where rnk=1; 


4)What is the most purchased item on the menu and how many time was it purchased by all customers?

select userid,count(product_id) from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid;


5)Which item was the most popular for each customer?

select * from 
(select *,rank() over(partition by userid order by cnt desc) rnk from  
(select userid,product_id,count(product_id) as cnt from sales group by userid,product_id)a)b
where rnk=1;

6)which item was purchased first by the customer after they become a member?

select * from 
(select c.*,rank() over(partition by userid order by created_date) as rnk from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b 
on a.userid=b.userid and created_date>=gold_signup_Date)c)d where rnk=1;


7)which item was purchased just before the customer become a member?

select * from
(select c.*,rank() over(partition by userid order by created_date desc )as rnk from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_Date from sales a inner join goldusers_signup b 
on a.userid=b.userid and created_date<=gold_signup_date)c)d where rnk=1;


8)what is the total orders and amount spent for each member before they become a member?

select userid,count(created_date) as order_purchased,sum(price) as total_amt_spent from 
(select c.*,d.price from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_Date from sales a inner join goldusers_signup b 
on a.userid=b.userid and created_date<=gold_signup_Date)c inner join product d on c.product_id=d.product_id)e
group by userid;


9)if buying each product generates points for eg 5rs=2 zomato point and each product has different purchasing points
for eg for p1 5rs=1 zomato point , for p2 10rs=5zomato point and p3 5rs=1 zomato point 2rs=1 zomato point,
calculate pointds collected byeach customers and for which product most points have been given till now.?

select * from 
(select *,rank() over(order by total_point_earned desc)rnk from 
(select product_id,sum(Total_points) as total_point_earned from 
(select e.*,amt/points as Total_points from 
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) as amt from 
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by product_id)f)g where rnk=1;


10)in the first one year after a customer joins the gold program (including their join date)irrespective
of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3
and what was their points earnings in their first year?

select c.*,d.price*0.5 total_points_earned from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b on
a.userid=b.userid and created_date >=gold_signup_date and created_date <=DATEADD(year,1,gold_signup_date))c
inner join product d on c.product_id=d.product_id;


11)rank all the transaction of the customers?

select *,rank() over(partition by userid order by created_date) as rnk from sales;


12)rank all the transaction for each member whenever they are a zomato gold member for every non gold member transaction mark as na?

select e.*,case when rnk=0 then 'na' else rnk end as rnk from 
(select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc)end)as varchar) as rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a left join goldusers_signup b on
a.userid=b.userid and created_date>=gold_signup_date)c)e;




















