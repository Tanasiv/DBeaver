---4---
WITH facebook AS (
SELECT 
ad_date, 
fc.campaign_name,  
reach
FROM public.facebook_ads_basic_daily AS pf
LEFT JOIN public.facebook_campaign AS fc
ON fc.campaign_id = pf.campaign_id
),

facebook_google AS (
SELECT 
ad_date, 
campaign_name::text, 
reach
FROM facebook

UNION ALL  
SELECT 
ad_date, campaign_name, reach
FROM public.google_ads_basic_daily
),

monthy_reach AS (
SELECT 
DATE_TRUNC('month', ad_date)::date AS month_start,
campaign_name,
SUM(reach) AS total_reach
FROM facebook_google
GROUP BY 1,2
),

monthly_growth AS (
SELECT 
month_start,
campaign_name,
total_reach,
total_reach - LAG(total_reach) OVER (PARTITION BY campaign_name ORDER BY month_start) AS reach_growth
FROM monthy_reach
)

SELECT 
month_start,
reach_growth,
campaign_name
FROM monthly_growth
WHERE reach_growth IS NOT NULL 
AND reach_growth > 0
ORDER BY 2 DESC 
LIMIT 1
 
