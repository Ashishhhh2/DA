Create database Pizzahutdb;

-- Retrieve the total number of orders placed.
Select count(*) as Total_order from orders;

-- Calculate the total revenue generated from pizza sales.
Select 
round(sum(pizzas.price * orders_details.Quantity),2) as total_Revnue
from pizzas join orders_details
On pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest-priced pizza.
Select pizza_types.name, pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
Order by pizzas.price Desc
limit 1;

-- Identify the most common pizza size ordered.
Select 
size, 
count(quantity) as total_order_count_size
from Pizzas Join orders_details on pizzas.pizza_id = orders_details.Pizza_id
group by size
Order By total_order_count_size desc;

-- List the top 5 most ordered pizza types along with their quantities.
Select pizza_types.name, 
SUM(Quantity) as total_quantity
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details 
on pizzas.pizza_id = orders_details.Pizza_id
group by pizza_types.name Order by total_quantity desc Limit 5;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
Select category, 
count(quantity) as total_quantity
From pizza_types Join pizzas On pizza_types.pizza_type_id = pizzas.pizza_type_id
Join orders_details On pizzas.pizza_id = orders_details.Pizza_id
Group by category Order By total_quantity Desc;

-- Determine the distribution of orders by hour of the day.
Select Hour(order_time) As Hour_time, count(Order_id) As order_count
from orders 
Group by Hour_time;
-- Join relevant tables to find the category-wise distribution of pizzas.
Select Category, count(name) Pizza_name_category
from pizza_types
Group By category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
Select Round(avg(Quantity_Count),2) Avg_Quantity From 
(Select Date(order_date) As Order_date, SUM(quantity) As Quantity_Count
From Orders Join orders_details On Orders.order_id = orders_details.Order_id
Group By Order_date) As Quantity_order_data;

-- Determine the top 3 most ordered pizza types based on revenue.
Select pizza_types.name, Round(Sum((pizzas.price*orders_details.Quantity)),2) as Total_revenue 
from pizza_types Join Pizzas On pizza_types.pizza_type_id = Pizzas.pizza_type_id
Join orders_details On Pizzas.pizza_id = orders_details.Pizza_id
Group By pizza_types.name Order By Total_revenue Desc Limit 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
Select pizza_types.category,
round(SUM(Pizzas.price * orders_details.quantity)/( Select 
round(sum(pizzas.price * orders_details.Quantity),2)
from pizzas 
join orders_details
On Round(pizzas.pizza_id = orders_details.pizza_id)) * 100,2) as Revenue 
From pizza_types Join Pizzas
On pizza_types.pizza_type_id = Pizzas.pizza_type_id
Join Orders_details 
On Pizzas.pizza_id = Orders_details.Pizza_id
Group By pizza_types.category Order By Revenue Desc;

-- Analyze the cumulative revenue generated over time.

Select order_date, 
SUM(total_Revenue) Over(Order by Order_date) as Cumlative_revenue
From
(Select Order_date , SUM(price * Quantity) As total_Revenue
from Pizzas As P
Join orders_details As Od
On p.pizza_id = Od.Pizza_id
Join orders As O
On Od.Order_id = O.Order_id
Group By Order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select Name, category, Revenue
From 
(Select Category, Name, revenue,
Rank() Over(Partition By category Order By Revenue Desc) As Ranks
From 
(Select Category, name, 
SUM(pizzas.price * orders_details.quantity) as Revenue
From pizza_types
Join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
Join orders_details On pizzas.pizza_id = orders_details.Pizza_id
Group By Category, name) As A) As B
where Ranks <= 3;
