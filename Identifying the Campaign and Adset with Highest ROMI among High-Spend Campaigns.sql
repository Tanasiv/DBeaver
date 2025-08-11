WITH romi AS (   
SELECT 
ad_date,
campaign_name,
adset_name,
SUM(spend) AS total_spend,
SUM(value) AS total_value,
SUM(value)::numeric / NULLIF(SUM(spend)::numeric, 0) AS romi 
FROM public.google_ads_basic_daily AS pg
WHERE pg.ad_date IS NOT NULL
GROUP BY 1, 2, 3
HAVING SUM(pg.spend) > 0


UNION ALL
SELECT 
pf.ad_date, 
pfc.campaign_name, 
pfa.adset_name,
SUM(pf.spend)::numeric AS sum_spend,
SUM(pf.value)::numeric AS sum_value,
SUM(pf.value)::numeric / NULLIF(SUM(pf.spend)::numeric, 0) AS romi 
FROM public.facebook_ads_basic_daily AS pf
LEFT JOIN public.facebook_adset AS pfa 
ON pfa.adset_id = pf.adset_id 
LEFT JOIN public.facebook_campaign AS pfc
ON pfc.campaign_id = pf.campaign_id 
WHERE pf.ad_date IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY romi DESC
)

SELECT 
"adset_name",
MAX(romi) AS max_romi
FROM romi 
GROUP BY 1