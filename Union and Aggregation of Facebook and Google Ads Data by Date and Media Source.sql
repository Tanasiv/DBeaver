with facebook_google  as (
select
ad_date, campaign_id, adset_id, spend, impressions, reach, clicks, leads, value, url_parameters,
'facebook_ads ' as media_source
from public.facebook_ads_basic_daily
where facebook_ads_basic_daily.ad_date is not null

union all 
select 
ad_date, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value, url_parameters,
'google_ads' as media_source
from public.google_ads_basic_daily
where google_ads_basic_daily.ad_date is not null
)

select 
"ad_date",
"media_source",
avg (impressions) as avg_impressions,
avg (spend) as avg_spend,
avg (clicks) as avg_clicks,
avg (value) as avg_value
from facebook_google  
group by 1, 2
 

