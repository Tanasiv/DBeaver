WITH facebook_google AS (
SELECT  
ad_date,
url_parameters,
campaign_name, 
adset_name,
COALESCE(spend, 0) AS spend,
COALESCE(impressions, 0) AS impressions,
COALESCE(reach, 0) AS reach,
COALESCE(clicks, 0) AS clicks,
COALESCE(leads, 0) AS leads,
COALESCE(value, 0) AS value,
'google' AS medium_source
FROM public.google_ads_basic_daily

UNION ALL 
SELECT 
ad_date,
url_parameters,
campaign_id, 
adset_id,
COALESCE(spend, 0) AS spend,
COALESCE(impressions, 0) AS impressions,
COALESCE(reach, 0) AS reach,
COALESCE(clicks, 0) AS clicks,
COALESCE(leads, 0) AS leads,
COALESCE(value, 0) AS value,
'facebook' AS medium_source
FROM public.facebook_ads_basic_daily
),

ad_month_g_f AS (
SELECT 
date_trunc('month', ad_date)::date AS ad_month,
lower (
CASE 
	WHEN substring(url_parameters, 'utm_campaign=([^&#]+)') = 'nan'
	THEN NULL
	ELSE stmy_urldecode(substring(url_parameters, 'utm_campaign=([^&#]+)'))
END
) AS utm_campaign,
sum(impressions) AS total_impressions,
sum(spend) AS total_spend,
sum(clicks) AS total_clicks,
sum(value) AS total_value,
CASE WHEN sum(impressions) > 0
THEN 1.00 * sum(clicks)/sum(impressions)
END AS ctr, 
CASE WHEN sum(clicks) > 0
THEN 1.00 * sum(spend)/sum(clicks)
END AS cpc,
CASE WHEN sum(impressions) > 0
THEN 1.00 * (sum(spend)/sum(impressions))*1000
END AS cpm, 
CASE WHEN sum(spend) > 0
THEN 1.00 * (sum(value)-sum(spend))/sum(spend)
END AS romi
FROM facebook_google
GROUP BY 1, 2
),

montly_data_w_langs AS (
SELECT *,
lag(cpm) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS monat_cpm,
lag(ctr) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS monat_ctr,
lag(romi) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS monat_romi,
lag(cpc) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS monat_cpc
FROM ad_month_g_f
ORDER BY ad_month, utm_campaign
)

SELECT 
ad_month,
utm_campaign,
monat_cpm,
monat_ctr,
monat_romi,
monat_cpc,
CASE WHEN  monat_cpm > 0 THEN 100.00 * (cpm - monat_cpm)/monat_cpm END AS prev_cpm,
CASE WHEN  monat_ctr > 0 THEN 100.00 * (ctr - monat_ctr)/monat_ctr END AS prev_ctr,
CASE WHEN  monat_romi > 0 THEN 100.00 * (romi - monat_romi)/monat_romi END AS prev_romi,
CASE WHEN  monat_cpc > 0 THEN 100.00 * (cpc - monat_cpc)/monat_cpc END AS prev_cpc
FROM montly_data_w_langs 
ORDER BY 1, 2