use blinkit
select * from  blinkit_delivery_performance$
select * from  blinkit_customer_feedback$
select * from blinkit_customers$
select * from  blinkit_inventory$
select * from  blinkit_inventoryNew$
select * from blinkit_marketing_performance$
select * from blinkit_order_items$
select * from  blinkit_orders$
select * from  blinkit_products$
/* total revenue */
select sum(order_total) as total_revenue from blinkit_orders$

/* average order value */
select avg(order_total) as AOV from blinkit_orders$

/* order status */
select delivery_status, count(*) from  blinkit_orders$
group by delivery_status

/* payment method */
select payment_method , count(*) from blinkit_orders$
group by payment_method

/* Revenue and Order Trend */

/* monthly revenue */
select  datepart(MONTH , order_date) as order_month,sum(order_total) as monthly_revenue,count(order_id) as total_orders from blinkit_orders$
group by DATEPART(month, order_date)
order by order_month asc

/*yearly revenue*/
select  datepart(year , order_date) as order_year,sum(order_total) as yearly_revenue,count(order_id) as total_orders from blinkit_orders$
group by DATEPART(year, order_date)
order by order_year asc


/*category wise performance*/

/* item content vs rating */
SELECT  category,
case 
	when category in ('Fruits & Vegetables','Pharmacy','Baby Care') then 'Healthy'
	when category in ('Snacks & Munchies','Instant & Frozen Food','Cold Drinks & Juices ') then 'Indulgence'
	when category in ('Dairy & Breakfast','Grocery & Staples','Household Care','Pet Care') then 'Daily Essentials'
	else 'Personal & Other'
end as item_content, sum (oi.quantity*oi.unit_price) as total_calculated_sales
FROM blinkit_orders$ AS o
join blinkit_order_items$ as oi on o.order_id = oi.order_id
join blinkit_products$ as p on oi.product_id=p.product_id
group by p.category


/*total spend vs total revenue in marketing */
select  campaign_name,
sum(spend ) as total_spend, sum(revenue_generated)as campaign_revenue
from blinkit_marketing_performance$
group by campaign_name


/* roas analysis */
select campaign_name,SUM(Revenue_Generated) / SUM(Spend) AS ROAS
from blinkit_marketing_performance$
group by campaign_name

/*wasteful spend*/

SELECT 
    Campaign_Name,
    SUM(Spend) AS Total_Spend,
    SUM(Revenue_Generated) AS Total_Revenue,
    SUM(Revenue_Generated) / SUM(Spend) AS ROAS
FROM blinkit_marketing_performance$
GROUP BY Campaign_Name
HAVING (SUM(Revenue_Generated) / SUM(Spend)) < 2  -- Filtering wasteful campaigns
ORDER BY Total_Spend DESC;

/* delivery delay analysis */

select delivery_status,
count(order_id ) as total_orders, 
round(count(order_id)*100.0/ sum(count(order_id)) over(),2) as percentage
from blinkit_delivery_performance$
group by delivery_status

/* delivery partner ranking */
select delivery_partner_id,
avg(delivery_time_minutes)as avg_time,
count(case when delivery_status= 'significantly delayed ' then 1 end) as critical_delays,
count(case when delivery_status= 'slightly delayed ' then 1 end) as minor_delays,
avg(distance_km) as average_distance
from blinkit_delivery_performance$
group by delivery_partner_id
order by  avg_time asc

/* overall satisfaction score */
select  avg (rating)as avg_rating,
count(order_id) as feedback
from blinkit_customer_feedback$

/* category  wise performance*/
select feedback_category,
avg (rating) as avg_rating,
count(*) as total_comments 
from blinkit_customer_feedback$
group by feedback_category
order by avg_rating asc

/*churn analysis */
SELECT 
    Customer_ID,
    MAX(Order_Date) AS Last_Order_Date,
    DATEDIFF(day, MAX(Order_Date), GETDATE()) AS Days_Since_Last_Order,
    CASE 
        WHEN DATEDIFF(day, MAX(Order_Date), GETDATE()) > 30 THEN 'Churned'
        ELSE 'Active'
    END AS Customer_Status
FROM blinkit_orders$
GROUP BY Customer_ID

/*RATING*/
SELECT DISTINCT rating,COUNT(rating)as count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
from blinkit_customer_feedback$
group by rating 
order by rating asc


/*feedback and rating*/

select category , 
ROUND(AVG(Rating), 2) AS Average_Rating,
count (*) as total_reviews
from blinkit_customer_feedback$ as f
join blinkit_order_items$ as oi on f.order_id = oi.order_id
join blinkit_products$ as p on oi.product_id=p.product_id
group by p.category
order by Average_Rating 

