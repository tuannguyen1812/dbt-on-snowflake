
  create or replace   view NEFINANCE_DB.DEV.financial_news
  
   as (
    with cnbc as (

    select
        'cnbc' as source,
        headlines as headline,
        description,

        -- extract only: Tue, 14 Aug 2018
        try_to_date(
            regexp_substr(time, '[A-Za-z]{3},\\s*[0-9]{1,2}\\s*[A-Za-z]{3}\\s*[0-9]{4}'),
            'DY, DD MON YYYY'
        ) as published_date,

        _fivetran_synced as loaded_at

    from PC_FIVETRAN_DB.GOOGLE_DRIVE.CNBC_HEADLINES
    where time is not null 

),

reuters as (

    select
        'reuters' as source,
        headlines as headline,
        description,

        try_to_date(trim(time), 'MON DD YYYY') as published_date,

        _fivetran_synced as loaded_at

    from PC_FIVETRAN_DB.GOOGLE_DRIVE.REUTERS_HEADLINES

),

guardian as (

    select
        'guardian' as source,
        headlines as headline,
        null as description,

        try_to_date(trim(time), 'DD-MON-YY') as published_date,

        _fivetran_synced as loaded_at

    from PC_FIVETRAN_DB.GOOGLE_DRIVE.GUARDIAN_HEADLINES
    where time is not null

),
data_union as (
select * from cnbc
union all
select * from reuters
union all
select * from guardian) 
SELECT *
, SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-70b',
        CONCAT(
            'Classify this financial news as Positive, Neutral, or Negative. Return only one word. News: ',
            CONCAT(headline, '. ', description)
        )
    ) AS sentiment
    
    
FROM data_union
WHERE published_date is not null
  );

