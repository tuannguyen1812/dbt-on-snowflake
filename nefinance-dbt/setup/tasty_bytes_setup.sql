-- =============================================================================
-- Tasty Bytes dbt Demo: Environment Setup & Source Data
-- Source: https://docs.snowflake.com/en/user-guide/tutorials/dbt-projects-on-snowflake-getting-started-tutorial
--
-- This script sets up the complete environment for the Tasty Bytes dbt project:
--   1. Warehouse for executing workspace actions
--   2. Database and schemas for integrations and model materializations
--   3. Logging, tracing, and metrics for observability
--   4. GitHub secret and API integration for connecting to your repository
--   5. Network rule and external access integration for dbt dependencies
--   6. Source data: Tasty Bytes foundational data model (raw zone tables + data load)
--
-- NOTE: Before running this script in a workspace, comment out any CREATE statements
-- for objects you already created during the "Set up your environment" steps:
--   CREATE OR REPLACE WAREHOUSE ...
--   CREATE OR REPLACE API INTEGRATION ...
--   CREATE OR REPLACE NETWORK RULE ...
--   CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION ...
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- STEP 1: Create a warehouse for executing workspace actions
-- A dedicated warehouse assigned to your workspace helps you log, trace,
-- and identify actions initiated from within that workspace.
-- The Tasty Bytes data model is fairly large, so an XL warehouse is recommended.
-- Alternatively, you can use an existing warehouse in your account.
-- =============================================================================

CREATE WAREHOUSE nefinance_dbt_wh WAREHOUSE_SIZE = XLARGE;

-- =============================================================================
-- STEP 2: Create a database and schemas for integrations and model materializations
-- The INTEGRATIONS schema stores objects Snowflake needs for GitHub integration.
-- The DEV and PROD schemas store materialized objects that your dbt project creates.
-- The RAW schema holds the Tasty Bytes foundational source data.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS NEFINANCE_DB;
CREATE SCHEMA IF NOT EXISTS NEFINANCE_DB.dev;
CREATE SCHEMA IF NOT EXISTS NEFINANCE_DB.prod;
-- Used for storing objects Snowflake needs for GitHub integration (secrets, etc.)
CREATE SCHEMA IF NOT EXISTS NEFINANCE_DB.integrations;
-- Used for the Tasty Bytes foundational source data loaded from S3
CREATE SCHEMA IF NOT EXISTS NEFINANCE_DB.raw;

-- =============================================================================
-- STEP 3: Enable logging, tracing, and metrics
-- You can capture logging and tracing events for a dbt project object and for
-- the task that runs it on a schedule. These settings must be applied to the
-- schemas where the dbt project object and task are deployed.
-- See: https://docs.snowflake.com/en/user-guide/data-engineering/dbt-projects-on-snowflake-monitoring-observability
-- =============================================================================

ALTER SCHEMA NEFINANCE_DB.dev SET LOG_LEVEL = 'INFO';
ALTER SCHEMA NEFINANCE_DB.dev SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA NEFINANCE_DB.dev SET METRIC_LEVEL = 'ALL';

ALTER SCHEMA NEFINANCE_DB.prod SET LOG_LEVEL = 'INFO';
ALTER SCHEMA NEFINANCE_DB.prod SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA NEFINANCE_DB.prod SET METRIC_LEVEL = 'ALL';

-- =============================================================================
-- STEP 4: Create a GitHub secret and API integration
-- Snowflake needs an API integration to interact with GitHub.
-- If your repository is private, you must also create a secret to store GitHub
-- credentials. You then reference the secret in the API integration definition
-- and when creating the workspace for your dbt project.
--
-- Creating a secret requires a personal access token for your repository.
-- See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
--
-- Alternatively, your admin can set up one OAuth2 integration for the team instead of managing personal access tokens.
-- See: https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git
-- =============================================================================

USE NEFINANCE_DB.integrations;
CREATE OR REPLACE SECRET NEFINANCE_DB.integrations.tb_dbt_git_secret
  TYPE = password
  USERNAME = 'your-gh-username'
  PASSWORD = 'YOUR_PERSONAL_ACCESS_TOKEN';

-- Replace 'https://github.com/my-github-account' with the URL of the GitHub
-- account for your forked repository.
-- This API integration is used when creating a workspace in Snowsight (Projects > Workspaces)
-- to connect Snowflake to your forked GitHub repository.
CREATE OR REPLACE API INTEGRATION tb_dbt_git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/my-github-account')
  -- Comment out the following line if your forked repository is public
  ALLOWED_AUTHENTICATION_SECRETS = (NEFINANCE_DB.integrations.tb_dbt_git_secret)
  ENABLED = TRUE;

-- =============================================================================
-- STEP 5: (Optional) Create a network rule and external access integration
-- If you plan to run 'dbt deps' in a workspace, dbt will need to access remote
-- URLs to download dependencies (e.g. packages from the dbt Package Hub or
-- from GitHub). Most dbt projects specify dependencies in their packages.yml
-- file, which must be installed in the workspace before other commands will work.
-- See: https://docs.snowflake.com/en/developer-guide/external-network-access/creating-using-external-network-access
-- =============================================================================

-- Create NETWORK RULE for external access integration
-- CREATE OR REPLACE NETWORK RULE dbt_network_rule
--   MODE = EGRESS
--   TYPE = HOST_PORT
--   -- Minimal URL allowlist that is required for dbt deps
--   VALUE_LIST = (
--     'hub.getdbt.com',
--     'codeload.github.com'
--     );

-- Create EXTERNAL ACCESS INTEGRATION for dbt access to external dbt package locations
-- CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION dbt_ext_access
--   ALLOWED_NETWORK_RULES = (dbt_network_rule)
--   ENABLED = TRUE;

-- =============================================================================
-- STEP 6: Set up source data - Tasty Bytes foundational data model
-- The dbt project uses the foundational data model for the fictitious Tasty Bytes
-- food truck brand as its source data for transformations.
-- This section creates a file format and external stage pointing to S3, builds
-- the raw zone tables, and loads data into them.
-- =============================================================================

-- =============================================================================
-- Setup complete
-- =============================================================================

SELECT 'NEFINANCE_DB setup is now complete' AS note;
