CREATE OR REPLACE FUNCTION pg_temp.decode_url_part(p varchar) RETURNS varchar AS $$
SELECT convert_from(CAST(E'\\x' || string_agg(CASE WHEN length(r.m[1]) = 1 THEN encode(convert_to(r.m[1], 'SQL_ASCII'), 'hex') ELSE substring(r.m[1] from 2 for 2) END, '') AS bytea), 'UTF8')
FROM regexp_matches($1, '%[0-9a-f][0-9a-f]|.', 'gi') AS r(m);
$$ LANGUAGE SQL IMMUTABLE STRICT;
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
)
SELECT 
ad_date,
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


 

