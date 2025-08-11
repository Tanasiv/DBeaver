---3---
WITH facebook AS (
SELECT 
ad_date, 
fc.campaign_name, 
value
FROM public.facebook_ads_basic_daily AS pf
LEFT JOIN public.facebook_campaign AS fc
ON fc.campaign_id = pf.campaign_id
),

facebook_google AS (
SELECT 
ad_date, 
campaign_name::text,
value,
'facebook' AS media_source
FROM facebook

UNION ALL  
SELECT 
ad_date, campaign_name, value,
'google' AS media_source
FROM public.google_ads_basic_daily
)

SELECT 
DATE_TRUNC('week', ad_date)::date AS week_start,
campaign_name, 
SUM(value) AS total_value
FROM facebook_google
WHERE value > 0
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1

