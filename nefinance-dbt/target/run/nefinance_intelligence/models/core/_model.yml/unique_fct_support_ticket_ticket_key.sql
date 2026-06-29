select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    ticket_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_support_ticket
where ticket_key is not null
group by ticket_key
having count(*) > 1



      
    ) dbt_internal_test