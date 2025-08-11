SELECT 
    ad_date,  
    campaign_id, 
    SUM(spend)::numeric AS sum_spend,
    SUM(impressions)::numeric AS sum_impressions,
    SUM(clicks)::numeric AS sum_clicks,
    SUM(value)::numeric AS sum_value,
    SUM(spend)::numeric / NULLIF(SUM(clicks)::numeric, 0) AS CPC,
    (SUM(spend)::numeric / NULLIF(SUM(impressions)::numeric, 0)) * 1000 AS CPM,
    (SUM(clicks)::numeric * 100.0) / NULLIF(SUM(impressions)::numeric, 0) AS CTR,
    SUM(value)::numeric / NULLIF(SUM(spend)::numeric, 0) AS ROMI
FROM public.facebook_ads_basic_daily
GROUP BY ad_date, campaign_id
HAVING 
    SUM(impressions) > 0 
    AND SUM(clicks) > 0 
    AND SUM(spend) > 0
    AND SUM(spend) > 500000
ORDER BY ad_date, campaign_id;

SELECT SUM(value)::numeric / NULLIF(SUM(spend)::numeric, 0) AS ROMI
FROM public.facebook_ads_basic_daily
ORDER BY ROMI DESC;