---1---
WITH facebook AS (
SELECT 
ad_date, 
fc.campaign_name,
fa.adset_name, 
'facebook_ads' AS media_source,
spend, impressions, reach, clicks, leads, value, url_parameters
FROM public.facebook_ads_basic_daily AS pf
LEFT JOIN public.facebook_campaign AS fc
ON fc.campaign_id = pf.campaign_id
LEFT JOIN public.facebook_adset AS fa
ON fa.adset_id = pf.adset_id 
),

facebook_google AS (
SELECT 
ad_date, 
campaign_name::text, adset_name::text, 
spend, impressions, reach, clicks, leads, value, url_parameters,
'facebook_ads' AS media_source
FROM facebook

UNION ALL  
SELECT 
ad_date, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value, url_parameters,
'google_ads' AS media_source
FROM public.google_ads_basic_daily
)

SELECT 
ad_date, media_source,
AVG(spend) AS avg_spend,
MAX(spend) AS max_spend,
MIN(spend) AS min_spend
FROM facebook_google
GROUP BY 1, 2 
ORDER BY 1, 2

