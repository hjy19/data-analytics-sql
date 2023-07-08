
/**********************************************************/
/**********    DATA PREPARATION AND UNDERSDANDING  ********/
/**********************************************************/



/*********************************************************/

-- THERE IS A PROBLEM WITH DATASET

-- THERE IS NO POSSIBILITY OF SUPERKEY

-- THE DATA SET HAVE 13 ROWS DUPLICATE

-- BUT I WAS SAID NOT TO EDIT THE DATA SET 



SELECT transaction_id,Cust_id,tran_date,prod_subcat_code,qty,rate,tax,total_amt,store_type, COUNT(*) FROM transactions
GROUP BY transaction_id,Cust_id,tran_date,prod_subcat_code,qty,rate,tax,total_amt,store_type
HAVING COUNT(*)>1


select * from Transactions where transaction_id=426787191 

-- EXAMPLE ID 426787191 HAVE 4 RECORDS , IN THAT 4 RECORDS 2 RECORDS WHERE HAVE SIMIALR VALUES FOR EVERT COLUMN



























/* 1. What is the total number of rows in each of the 3 tables in the database ? */

SELECT COUNT(*) AS total_no_of_rows, 'customer' AS table_name FROM customer
UNION
SELECT COUNT(*) AS total_no_of_rows, 'transactions' AS table_name FROM Transactions
UNION
SELECT COUNT(*) AS total_no_of_rows, 'prod_cat_info' AS table_name FROM prod_cat_info

/* 2. What is the total number of transactions that have a return ? */


select COUNT(*) as No_of_returns from Transactions where total_amt < 0

/* 3. dates conversion */

/* I HAD CONVERTED DATES WHEN IMPORTING THE DATA ONLY */

/* 4. What is the time range of the transaction data available for analysis ? show the output in number 
of days , months and years simulataneously in different columns */

select DATEDIFF(year,MIN(tran_date),max(tran_date)) as [time_range_in_years],
DATEDIFF(MONTH,MIN(tran_date),max(tran_date)) as [time_range_in_months],
DATEDIFF(DAY,MIN(tran_date),max(tran_date)) as [time_range_in_days]
from transactions

/*5. Which product subcategory does the "diy" belong to */

select prod_cat as product_category,prod_subcat as product_sub_category from prod_cat_info
where prod_subcat = 'diy'

/**********************************************************/
/********************* DATA ANALYSIS **********************/
/**********************************************************/

/* 1. which channel is most frequently used for transaction? */

select top 1 count(transaction_id) as totalcount,Store_type from Transactions
group by Store_type order by totalcount desc;

/* 2 . what is the count of male and female customers in the database */

select count(*) as total ,'male' as tablename from customer where gender = 'm'
union
select count(*) as total,'female' as tablename from customer where gender = 'f'

/* 3. From which city do we have the maximum number of customers and how many ? */

select top 1 count(*) as number_of_customers,city_code from Customer group by city_code 
order by number_of_customers desc ;

/* 4. How many sub-categories are there  under  the  books category ? */

select count(*) as no_of_subcategories,category = 'books' from prod_cat_info where prod_cat = 'books';

/* 5. What is the maximum quantity of products ever ordered ? */

--  maximum quantity order in single transaction of product 

select MAX(qty) as maximum_quantity_of_products_ever_ordered from Transactions;




/* 6. What is the net total revenue generated in categories electronics and books ? */
/* net total revenue taxes are deducted and returns are deducted */

/***********************************************solution if taxes deducted ************/
select round(SUM(total_amt-(
case 
	when total_amt > 0 then tax
	else -tax
	end
)),3) as total_amount , prod_cat_info.prod_cat from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where prod_cat_info.prod_cat in ('books','electronics')
group by prod_cat_info.prod_cat

/************************* according to walk through video format *****************/

select round(SUM(total_amt),2) as total_amount , prod_cat_info.prod_cat from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where prod_cat_info.prod_cat in ('books','electronics')
group by prod_cat_info.prod_cat

/* 7. how many customers have > 10 transactions with us, excluding returns ? */

select count(distinct cust_id) as no_of_customers from transactions 
where cust_id in (select cust_id from Transactions where Qty > 0
group by cust_id having COUNT(transaction_id)>10);

/* 8. What is the combined revenue earned from the  "electronics" and "clothing" categories , from "flagship stores" ?*/

select round(sum(Transactions.total_amt),2) as combined_revenue from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
where prod_cat_info.prod_cat in ('electronics','clothing') and  Transactions.Store_type = 'flagship store'

/* 9. What is the total revenue generated from 'male' customers in 'electronics' category ? output should	display 
total revenue by prod sub-cat . */

select round(SUM(Transactions.total_amt),2) as total_revenue ,prod_cat_info.prod_subcat as 'electronics' from Transactions 
join Customer on Transactions.cust_id = Customer.customer_Id 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where Customer.Gender = 'm' and prod_cat_info.prod_cat='electronics' group by prod_cat_info.prod_subcat;


/* 10 What is the percentage of sales and returns by product sub category ; display only top 
5 sub  categories in terms of sales ? */

/*** note question is not clear wheather it is percentage by individual subcategory or category or total ,
i followed what is been said in walk through ****/

select top 5 
round((SUM(Transactions.total_amt)*100)/(select sum(total_amt) from Transactions),2) as [sales_percentage], 
round((SUM(case when transactions.Qty < 0 then total_amt else 0 end)*100)/(select sum(total_amt) from Transactions),2)*(-1) as [return_percentage], 
prod_cat_info.prod_subcat from Transactions 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
group by prod_cat_info.prod_subcat order by SUM(total_amt) desc;

/* 11. for all the customers aged between 25 and 35 years find what is the net total revenue  generated by these customers 
in last 30days of transactions from max transaction date availdable in the data? */

 select round(sum(total_amt),2) as total_revenue from Transactions
join Customer on Transactions.cust_id = Customer.customer_Id 
where (DATEDIFF(year,customer.dob,GETDATE()) between 25 and 35 ) 
and ( datediff(day,tran_date,(select max(tran_date) from transactions))<=30)

/* 12 . which product category has seen the max value of return in the last 3 months of transaction */

select top 1 round(SUM(transactions.total_amt),2) as return_value,prod_cat_info.prod_cat
from Transactions 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where Transactions.total_amt < 0  and tran_date>(select DATEADD(MONTH,-3,MAX(tran_date)) from Transactions)
group by  prod_cat_info.prod_cat
order by SUM(transactions.total_amt) asc



/* q 13 which store-type sells the maximum products ; by value of sales amount and quality sold? */
select top 1 round(sum(total_amt),2) as sales_amount,SUM(Qty) as quantity,store_type
from Transactions group by Store_type order by sum(total_amt) desc;

/* q14  What are the categories for which the average revenue is above the overall average */

select prod_cat_info.prod_cat from Transactions
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
group by transactions.prod_cat_code,prod_cat_info.prod_cat
having AVG(total_amt)>(select AVG(total_amt) from Transactions)

/* q15 find the average and total revenue by each subcategory for the categories which are among top 5	
categories in terms of quantity sold */

select round(sum(Transactions.total_amt),2)as total_revenue,round(avg(transactions.total_amt),2)as average_revenue,prod_cat_info.prod_subcat
,prod_cat_info.prod_cat from Transactions 
join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
where Transactions.prod_cat_code in (select top 5 prod_cat_code from Transactions group by prod_cat_code order by COUNT(qty)desc)
group by  prod_cat_info.prod_cat,prod_cat_info.prod_subcat
order by prod_cat_info.prod_cat
, prod_cat_info.prod_subcat














