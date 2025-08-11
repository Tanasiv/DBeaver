WITH all_ads_data AS (
SELECT 
pf.ad_date, 
fc.campaign_name, 
fa.adset_name, 
pf.impressions,
'Facebook' AS ad_source
FROM public.facebook_ads_basic_daily pf
LEFT JOIN public.facebook_campaign fc ON fc.campaign_id = pf.campaign_id
LEFT JOIN public.facebook_adset fa ON fa.adset_id = pf.adset_id

UNION ALL

SELECT 
ad_date, 
campaign_name, 
adset_name, 
impressions,
'Google' AS ad_source
FROM public.google_ads_basic_daily
),
ad_set_days AS (
SELECT 
ad_date, 
campaign_name, 
adset_name, 
ad_source
FROM all_ads_data
WHERE ad_date IS NOT NULL AND impressions > 0
GROUP BY ad_date, campaign_name, adset_name, ad_source
),
ranked_ad_set_days AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY campaign_name, adset_name, ad_source ORDER BY ad_date) AS rn
FROM ad_set_days
),
grouped_data AS (
SELECT 
ad_date, 
campaign_name, 
adset_name, 
ad_source,
ad_date - INTERVAL '1 day' * rn AS group_id
FROM ranked_ad_set_days
),
all_streaks AS (
SELECT 
campaign_name, 
adset_name, 
ad_source,
MIN(ad_date) AS start_day,
MAX(ad_date) AS end_day,
COUNT(*) AS continuous_days
FROM grouped_data
GROUP BY campaign_name, adset_name, ad_source, group_id
)
SELECT *
FROM all_streaks
ORDER BY continuous_days DESC
LIMIT 1;





