-- 1.Retrieve the total number of orders placed.
select* from orders;
select count(order_id) as total_orders from orders;

-- 2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price),
            2) AS total_sales
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id;
    
-- 3.Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;    

-- 4.Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1               #(p.size)#
ORDER BY 2 DESC;         #(order_count)#

-- 5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS quantities
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantities DESC
LIMIT 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS quantities
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantities DESC;

-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour,
    COUNT(order_id)
FROM
    orders AS order_count
GROUP BY 1;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- 10.Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id)) * 100,2) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- 12.Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue 
from 
(select o.order_date,
sum(od.quantity*p.price) as revenue
from order_details od join pizzas p 
on od.pizza_id = p.pizza_id
join orders o on o.order_id=od.order_id
group by o.order_date) 
as sales;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category

SELECT name,revenue from 
(SELECT category,name,revenue,
rank() over (partition by category order by revenue desc) as rn
from 
(SELECT pt.category,pt.name,
sum(od.quantity*p.price) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od 
on od.pizza_id=p.pizza_id
group by pt.category,pt.name) as A) as B
where rn<=3;











