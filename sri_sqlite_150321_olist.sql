CREATE VIEW "products table with product category in  in english" AS SELECT *
From olist_products_dataset
inner join product_category_name_translation on olist_products_dataset.product_category_name = product_category_name_translation.product_category_name

ALTER TABLE olist_order_items_dataset(
	"order_id"	TEXT,
	"order_item_id"	INTEGER,
	"product_id"	TEXT,
	"seller_id"	TEXT,
	"shipping_limit_date"	TEXT,
	"price"	REAL,
	"freight_value"	REAL,
	FOREIGN KEY(order_id) REFERENCES olist_orders_dataset(order_id)
);

-- joining olist closed deals dataset with MQL dataset  -- shows the won MQL data is from 01/2018 to 12/2018
Select count(*), strftime('%Y',won_date) as Year_won_date, strftime('%m',won_date) as Month_won_date,origin
from olist_closed_deals_dataset 
inner join olist_marketing_qualified_leads_dataset on olist_closed_deals_dataset.mql_id = olist_marketing_qualified_leads_dataset.mql_id
group by Year_won_date, Month_won_date,origin
order by Year_won_date, Month_won_date, origin


-- how many sales dev reps and sales reps
Select count(DISTINCT(sdr_id)), count(DISTINCT(sr_id))
From olist_closed_deals_dataset

-- distinct sales dev representative and mqls closed meaning successful sellers
Select sdr_id, Count(seller_id) as total_sellers -- total successful sellers is same as mql_id counts as total_mqls
from olist_closed_deals_dataset
group by sdr_id
order by total_sellers desc -- total_successful_sellers DESC

-- distinct sales reps and mqls closed meaning successful sellers
Select sr_id, Count(seller_id) as total_sellers -- total successful sellers is same as mql_id counts as total_mqls
from olist_closed_deals_dataset
group by sr_id
order by total_sellers desc -- total_successful_sellers DESC


-- to see which origin mode has brought most mqls and based on that SEO and ad keywords need to be targeted by Olist sales development rep team for marketing because organic search and paid search then social and direct traffic bring high mqls 
 -- for each origin mode -- ranking origins by total mqls 
Select *, percent_rank() over(order by mql_count asc) as percent_rank_origin 
from (
	Select count(mql_id) as mql_count, origin
	from olist_marketing_qualified_leads_dataset
	group by origin
	order by mql_count DESC
) as mql_count_origin
order by percent_rank_origin desc

-- lead type from closed deals dataset-- ranking by total mqls closed
Select *, percent_rank() over(order by mql_count asc) as percent_rank_leadtype 
from (
	Select count(mql_id) as mql_count, lead_type
	from olist_closed_deals_dataset
	group by lead_type
	order by mql_count DESC
) as mql_count_leadtype
order by percent_rank_leadtype desc

--lead behaviour from closed deals dataset - ranking by total mqls closed
Select *, percent_rank() over(order by mql_count asc) as percent_rank_leadbehaviour 
from (
	Select count(mql_id) as mql_count, lead_behaviour_profile
	from olist_closed_deals_dataset
	where lead_behaviour_profile is NOT NULL
	group by lead_behaviour_profile
	order by mql_count DESC
) as mql_count_leadbehaviour
order by percent_rank_leadbehaviour desc

-- no. of mqls from each landing pages - total 495 landing pages  -- and also filtering those > 40 mqls
Select count(mql_id) as mqls, landing_page_id, origin
from olist_marketing_qualified_leads_dataset
group by landing_page_id, origin
having mqls > 40
order by mqls DESC

-- extracting year and month from first_contact_date for plotting line curve comparing month by year and count of mql_id
Select mql_id, landing_page_id, origin, first_contact_date, strftime('%Y',first_contact_date) as year_first_contact_date, strftime('%m',first_contact_date) as month_first_contact_date
from olist_marketing_qualified_leads_dataset
order by month_first_contact_date, year_first_contact_date asc

--counting mqls per month per year
--The MQL data is provided from 06/2017 to 05/2018. Whereas from query result above the won MQL data is from 01/2018 to 12/2018
Select strftime('%Y',first_contact_date) as year_first_contact_date, strftime('%m',first_contact_date) as month_first_contact_date, count(mql_id)
from olist_marketing_qualified_leads_dataset
group by year_first_contact_date, month_first_contact_date
order by year_first_contact_date, month_first_contact_date ASc

--to plot each orgin mode on multi line chart over time - first contact month/year  
Select count(*) as num_mql, strftime('%Y',first_contact_date) as year_first_contact_date, strftime('%m',first_contact_date) as month_first_contact_date, origin 
from olist_marketing_qualified_leads_dataset
--where origin == 'organic_search'   ---- took a closer look at organic_search
group by origin, year_first_contact_date, month_first_contact_date
order by year_first_contact_date, month_first_contact_date, origin ASC

-- to plot each lead type on multi line chart over time - won date month/year
Select count(*) as num_mql, strftime('%Y',won_date) as year_won_date, strftime('%m',won_date) as month_won_date, lead_type 
from olist_closed_deals_dataset
group by lead_type, year_won_date, month_won_date
order by year_won_date, month_won_date, lead_type ASC

-- to plot total mqls on multi line chart over time - first contact month/year
Select count(*) as num_mql, strftime('%Y',won_date) as year_won_date, strftime('%m',won_date) as month_won_date 
from olist_closed_deals_dataset
group by year_won_date, month_won_date
order by year_won_date, month_won_date ASC


-- to plot total mqls on multi line chart over time - first contact month/year  MQL data is  from 06/2017 to 05/2018
Select count(*) as total_mqls, strftime('%Y',first_contact_date) as year_first_contact_date, strftime('%m',first_contact_date) as month_first_contact_date 
from olist_marketing_qualified_leads_dataset
group by  year_first_contact_date, month_first_contact_date
--Order by  total_mqls, year_first_contact_date desc