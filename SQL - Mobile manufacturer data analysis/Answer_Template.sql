--SQL Advance Case Study


--Q1--BEGIN 
	select distinct DIM_LOCATION.[State] from dim_location 
	join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDLocation = DIM_LOCATION.IDLocation 
    join DIM_DATE on DIM_DATE.DATE = FACT_TRANSACTIONS.date
    where DIM_DATE.YEAR >= 2005;





--Q1--END

--Q2--BEGIN
	select top 1 DIM_LOCATION.[state] from dim_location 
	join FACT_TRANSACTIONS on FACT_TRANSACTIONS.IDLocation = DIM_LOCATION.IDLocation 
	join DIM_MODEL on DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
	join DIM_MANUFACTURER on DIM_MODEL.IDManufacturer =  DIM_MANUFACTURER.IDManufacturer
	where DIM_MANUFACTURER.Manufacturer_Name = 'samsung' and DIM_LOCATION.Country = 'us'
	group by  DIM_LOCATION.[State]
	order by COUNT(fact_transactions.quantity) desc











--Q2--END

--Q3--BEGIN      
	
	select count(*) as no_of_transactions ,dim_model.idmodel,dim_location.zipcode,dim_location.[state] from fact_transactions
	join dim_location on FACT_TRANSACTIONS.IDLocation = DIM_LOCATION.IDLocation 
	join DIM_MODEL on DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
	group by dim_location.[state],dim_location.zipcode,dim_model.idmodel
	order by dim_location.[state],dim_location.zipcode,dim_model.idmodel











--Q3--END

--Q4--BEGIN

select top 1 Model_Name,Unit_price,Model_Name from dim_model 
order by Unit_price asc





--Q4--END

--Q5--BEGIN




select AVG(fact_transactions.totalprice) as avg_price,DIM_MANUFACTURER.Manufacturer_Name,
DIM_MODEL.IDModel,DIM_MODEL.Model_Name from fact_transactions
join DIM_MODEL on DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
join dim_manufacturer on dim_model.idmanufacturer = dim_manufacturer.idmanufacturer
where dim_manufacturer.manufacturer_name in (
select top 5 dim_manufacturer.manufacturer_name from fact_transactions
join DIM_MODEL on DIM_MODEL.IDModel= FACT_TRANSACTIONS.IDModel
join dim_manufacturer on dim_model.idmanufacturer = dim_manufacturer.idmanufacturer
group by dim_manufacturer.manufacturer_name
order by sum(fact_transactions.Quantity) desc
)
group by DIM_MANUFACTURER.Manufacturer_Name,DIM_MODEL.IDModel,DIM_MODEL.Model_Name
order by avg_price 












--Q5--END

--Q6--BEGIN

select avg(fact_transactions.totalprice) as average_spent,dim_customer.customer_name from dim_customer
join fact_transactions on fact_transactions.idcustomer = dim_customer.idcustomer
join dim_date on fact_transactions.[date] = dim_date.[date]
where dim_date.[year]=2009
group by dim_customer.idcustomer,dim_customer.customer_name
having avg(fact_transactions.totalprice) >500
order by average_spent desc










--Q6--END
	
--Q7--BEGIN  
	select t2.lisa,DIM_MODEL.Model_Name as model from (select sum(fact_transactions.quantity) as quantitytotal,fact_transactions.idmodel as lisa,dim_date.[year]  as falak,
	rank() over (partition by  dim_date.[year] order by sum(fact_transactions.quantity) desc) as lank
	from fact_transactions 
	join dim_date on fact_transactions.[date] = dim_date.[date]
	where dim_date.[year] in (2008,2009,2010) 
	group by dim_date.[year],fact_transactions.idmodel) t2
	join DIM_MODEL on DIM_MODEL.IDModel= t2.lisa
	where lank <= 5
	group by t2.lisa,DIM_MODEL.Model_Name
	having count(t2.quantitytotal) =3
















--Q7--END	
--Q8--BEGIN


select * from 
(
select t1.[year],t1.idmanufacturer,t1.manufacturer_name,sum(t1.totalsales) as total_sales,
rank() over (partition by  t1.[year] order by sum(t1.totalsales) desc) as [rank]
from (select dim_manufacturer.idmanufacturer,dim_date.[year],dim_manufacturer.manufacturer_name,dim_model.unit_price*fact_transactions.quantity  as totalsales
from 
fact_transactions
join dim_model on fact_transactions.idmodel = dim_model.idmodel
join dim_date on fact_transactions.[date] = dim_date.[date]
join dim_manufacturer on dim_model.idmanufacturer = dim_manufacturer.idmanufacturer
where dim_date.[year] in (2009,2010)
) t1
group by t1.[year],t1.idmanufacturer,t1.manufacturer_name
) t2
where t2.[rank] = 2
















--Q8--END
--Q9--BEGIN
	



select  * from (select distinct dim_manufacturer.idmanufacturer, dim_manufacturer.manufacturer_name from 
fact_transactions
join dim_model on fact_transactions.idmodel = dim_model.idmodel
join dim_date on fact_transactions.[date] = dim_date.[date]
join dim_manufacturer on dim_model.idmanufacturer = dim_manufacturer.idmanufacturer
where dim_date.[year] in (2010)) lamar
where lamar.idmanufacturer not in 
(select distinct dim_manufacturer.idmanufacturer from 
fact_transactions
join dim_model on fact_transactions.idmodel = dim_model.idmodel
join dim_date on fact_transactions.[date] = dim_date.[date]
join dim_manufacturer on dim_model.idmanufacturer = dim_manufacturer.idmanufacturer
where dim_date.[year] in (2009))














--Q9--END

--Q10--BEGIN


select t3.[year],avg(totalsa) avgerage_sales,avg(quanti)as average_quantity,
((sum(totalsa)-lag(sum(totalsa),1) over (order by t3.[year]))/(lag(sum(totalsa),1) over (order by t3.[year])))*100 as percentage_of_change from
(
select top 100 dim_date.[year],dc.idcustomer,dc.customer_name,count(fact_transactions.quantity) as quanti,sum(fact_transactions.totalprice) as totalsa from fact_transactions
join dim_customer as dc on fact_transactions.idcustomer = dc.idcustomer
join dim_date on fact_transactions.[date] = dim_date.[date]
group by dim_date.[year],dc.idcustomer,dc.customer_name
order by totalsa desc
) t3
group by t3.[year]

















--Q10--END
	