WITH facebook AS (
SELECT 
ad_date, spend, value,
fc.campaign_name
FROM public.facebook_ads_basic_daily AS pf
LEFT JOIN public.facebook_campaign AS fc
ON fc.campaign_id = pf.campaign_id
),

facebook_google AS (
SELECT 
ad_date, campaign_name, spend, value
FROM facebook

UNION ALL  
SELECT 
ad_date, campaign_name, spend, value
FROM public.google_ads_basic_daily
)

SELECT  
ad_date, campaign_name, 
(SUM(value)-SUM(spend))/NULLIF(SUM(spend)::numeric, 0) AS romi
FROM facebook_google
WHERE ad_date IS NOT NULL 
AND value > 0 
GROUP BY 1, 2
HAVING sum(spend) > 0
ORDER BY 3 DESC
LIMIT 5


