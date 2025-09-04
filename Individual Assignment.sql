## Name			: Arif Farhan Bukhori
## Assignment	: Individual Assignment

## Q1. baristacoffeesalestbl
## How many product categories? Show count per category.

SELECT product_category, COUNT(product_category) AS number_of_records
FROM an6004_ia.baristacoffeesalestbl
GROUP BY product_category;

## Q2. baristacoffeesalestbl
## For each (customer_gender, loyalty_member) show record counts,
## and inside each of those, break down by is_repeat_customer.

SELECT DISTINCT 
customer_gender, loyalty_member, COUNT(*) OVER (PARTITION BY customer_gender, loyalty_member) records, is_repeat_customer, COUNT(*) OVER (PARTITION BY customer_gender, loyalty_member, is_repeat_customer) records 
FROM an6004_ia.baristacoffeesalestbl
order by customer_gender ASC, is_repeat_customer DESC;

## Q3. baristacoffeesalestbl
## For each (product_category, customer_discovery_source),
## show SUM(total_amount).
## Two versions required: A (rounded) and B (exact).
## NOTE: The correct numeric answer is B (exact SUM).

## A) Rounded presentation (not strictly correct for numeric accuracy)
SELECT product_category, customer_discovery_source, ROUND(SUM(total_amount))
FROM an6004_ia.baristacoffeesalestbl
GROUP BY product_category, customer_discovery_source
order by product_category;

## B) Exact totals (CORRECT)

SELECT product_category, customer_discovery_source, SUM(total_amount)
FROM an6004_ia.baristacoffeesalestbl
GROUP BY product_category, customer_discovery_source
order by product_category;

## The difference is that Version A rounds off the totals and is only useful for display, 
## while Version B keeps the precise numeric values. The correct version is B, 
## because financial data should always be summed with full accuracy and without premature rounding.

##   Q4) caffeine_intake_tracker
##   “Consider consuming coffee as the beverage.” For each time_of_day and gender,
##   show AVG(focus_level), AVG(sleep_quality).
##   The dataset exposes booleans like time_of_day_afternoon/evening and
##   gender_female/gender_male. We derive categorical values from those flags.

SELECT 
	CASE 
		WHEN(time_of_day_afternoon = 'TRUE') THEN 'afternoon'
		WHEN(time_of_day_evening = 'TRUE') then 'evening'
		ELSE 'morning'
	END AS time_of_day,
	CASE
		WHEN(gender_female ='TRUE') then 'female'
        WHEN(gender_male = 'TRUE') then 'male'
	END AS gender,
	AVG(focus_level) AS avg_focus_level,
	AVG(sleep_quality) AS avg_sleep_quality
FROM an6004_ia.caffeine_intake_tracker
GROUP BY time_of_day, gender;

##   Q5) list_coffee_shops_in_kota_bogor
##   “There are problems with the data. List the problematic records.”

-- Ans: Found out that the likely issue is datas having duplicates
SELECT  url_id, link, location_name, category, address, COUNT(*) AS dup_count
FROM an6004_ia.list_coffee_shops_in_kota_bogor
GROUP BY location_name, url_id, category, address, link
HAVING COUNT(*) > 1;

##   Q6) coffeesales
##   List the amount of spending (money) recorded before 12 and after 12.

-- Ans:
 /*  Definitions:
   • before 12: hour in [0,12)
   • after 12 : hour in [12,24)
   Data issue observed: the 'datetime' field sometimes contains hours ≥ 24
   (e.g., '46:33.0'). To keep within a 24-hour day, I filter HOUR(datetime) < 24.
*/
SELECT
  CASE
    WHEN HOUR(`datetime`) < 12 THEN 'before 12'
    ELSE 'after 12'
  END AS period,
  SUM(money) AS amt
FROM an6004_ia.coffeesales
WHERE HOUR(`datetime`) < 24 #The filtering
GROUP BY period
ORDER BY period desc;

## Q7) Consider 7 categories of Ph values
## -	pH >= 0.0 && pH < 1.0
## -	pH >= 1.0 && pH < 2.0
## -	pH >= 2.0 && pH < 3.0
## -	pH >= 3.0 && pH < 4.0
## -	pH >= 4.0 && pH < 5.0
## -	pH >= 5.0 && pH < 6.0
## -	pH >= 6.0 && pH < 7.0
## For each category of Ph values, 
## show the average Liking, FlavorIntensity, Acidity, and Mouthfeel. 

WITH bins AS (
  SELECT 0.0 AS lo, 1.0 AS hi, '0 to 1' AS label UNION ALL
  SELECT 1.0, 2.0, '1 to 2' UNION ALL
  SELECT 2.0, 3.0, '2 to 3' UNION ALL
  SELECT 3.0, 4.0, '3 to 4' UNION ALL
  SELECT 4.0, 5.0, '4 to 5' UNION ALL
  SELECT 5.0, 6.0, '5 to 6' UNION ALL
  SELECT 6.0, 7.0, '6 to 7'
)
SELECT
  b.label AS Ph,
  AVG(cp.Liking)          AS avgLiking,
  AVG(cp.FlavorIntensity) AS avgFlavorIntensity,
  AVG(cp.Acidity)         AS avgAcidity,
  AVG(cp.Mouthfeel)       AS avgMouthfeel
FROM bins b
LEFT JOIN an6004_ia.consumerpreference cp
  ON cp.pH >= b.lo AND cp.pH < b.hi
GROUP BY b.label, b.lo
ORDER BY b.lo;

## Q8. 4-table join + Top-3 per month by SUM(money)
## Joins:
##   coffeesales.coffeeID = `top-rated-coffee`.ID
##   coffeesales.shopID   = list_coffee_shops_in_kota_bogor.no
##   coffeesales.customer_id (e.g. 1) matches baristacoffeesalestbl.customer_id (e.g. CUST_1)
##   -> We extract the digits after the last '_' to normalize: CUST_1 -> 1
##
## Output columns (like the sample):
##   trans_month (e.g., 'MAR'), store_id, store_location (category),
##   location_name, avg_agtron, trans_amt, total_money

SELECT
  ## show month as 3-letter text (JAN, FEB, ...)
  ELT(mn,'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC') AS trans_month,
  store_id,
  store_location,
  location_name,
  ROUND(avg_agtron, 6) AS avg_agtron,
  trans_amt,
  ROUND(total_money, 2) AS total_money
FROM (
  SELECT
    yr, mn, store_id, shopID, store_location, location_name, avg_agtron, trans_amt, total_money,
    ROW_NUMBER() OVER (PARTITION BY yr, mn ORDER BY total_money DESC, store_id, shopID) AS rn
  FROM (
    SELECT
      YEAR(dt)  AS yr,
      MONTH(dt) AS mn,
      b_norm.store_id,
      s.shopID,
      ## pick stable values per group using MAX()
      MAX(b_norm.store_location) AS store_location,
      MAX(c.location_name) AS location_name,
      AVG(t.agtron)        AS avg_agtron,
      COUNT(*)             AS trans_amt,
      SUM(s.money)         AS total_money
    FROM (
      SELECT
        s.*,
        STR_TO_DATE(s.`date`, '%e/%c/%Y') AS dt
      FROM an6004_ia.coffeesales s
    ) AS s
    LEFT JOIN an6004_ia.`top-rated-coffee` t
      ON CAST(s.coffeeID AS UNSIGNED) = CAST(t.ID AS UNSIGNED)
    LEFT JOIN an6004_ia.`list_coffee_shops_in_kota_bogor` c
      ON CAST(s.shopID AS UNSIGNED) = CAST(c.`no` AS UNSIGNED)
    LEFT JOIN (
      SELECT
        b.*,
        CAST(
          CASE
            WHEN INSTR(b.customer_id, '_') > 0
              THEN SUBSTRING_INDEX(b.customer_id, '_', -1)
            ELSE b.customer_id
          END AS UNSIGNED
        ) AS customer_id_num
      FROM an6004_ia.baristacoffeesalestbl b
    ) AS b_norm
      ON CAST(s.customer_id AS UNSIGNED) = b_norm.customer_id_num
    GROUP BY YEAR(dt), MONTH(dt), b_norm.store_id, s.shopID
  ) AS monthly_sums
) AS ranked
WHERE rn <= 3
ORDER BY yr, mn, rn;