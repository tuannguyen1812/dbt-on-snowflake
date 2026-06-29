

select

    usage_id,

    subscription_id,

    feature_name,

    usage_count,

    usage_duration_secs,

    error_count,

    usage_date,

    is_beta_feature,

    ctid_fivetran_id as record_id,

    _fivetran_synced as loaded_at

from PC_FIVETRAN_DB.NEFINANCE_POSTGRES_PUBLIC.NEFINANCE_FEATURE_USAGE

where not coalesce(_fivetran_deleted,false)