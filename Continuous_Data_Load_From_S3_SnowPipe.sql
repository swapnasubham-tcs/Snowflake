/* 
Snowpipe enables loading data from files as soon as they’re available in a stage. 
This means you can load data from files in micro-batches, making it available to users within minutes, rather than manually executing COPY statements on a schedule to load larger batches.
*/

-- Continuous CSV Data Loading Using Snowpipe --
-- Creating Table --
CREATE OR REPLACE TABLE "COMPANY"."HR"."EMPLOYEES_CSV_PIPE" (
    employee_id     NUMBER,
    first_name      VARCHAR(255),
    last_name       VARCHAR(255),	
    email           VARCHAR(255),	
    phone_number    VARCHAR(255),	
    hire_date       DATE,	
    job_id          VARCHAR(255),	
    salary          NUMBER,	
    commission_pct  NUMBER,	
    manager_id      NUMBER,	
    department_id   NUMBER
    );
    
--Create integration object for external stage -- (No need to run if already created)
create or replace storage integration s3_integration_employee
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::430470204953:role/snowflake-role-hr'
  storage_allowed_locations = ('s3://rtb-snowflake/employee/');
  
  
  -- Create a file format (No need to run if already created)--
CREATE OR REPLACE file format "COMPANY"."HR".csv_format
		type = csv
		field_delimiter = ','
		skip_header = 1
		null_if = ('NULL', 'null')
		empty_field_as_null = true;
        
        
-- Create a stage --
CREATE OR REPLACE stage "COMPANY"."HR".ext_csv_stage_employee_pipe
  URL = 's3://rtb-snowflake/employee/snowpipe/csv'
  STORAGE_INTEGRATION = s3_integration_employee
  file_format = "COMPANY"."HR".csv_format;        
        
--create pipe to automate data ingestion from s3 to snowflake
create or replace pipe employee_csv_pipe auto_ingest=true as
copy into "COMPANY"."HR"."EMPLOYEES_CSV_PIPE"
from @"COMPANY"."HR".ext_csv_stage_employee_pipe 
on_error = CONTINUE;        

-- Get the Notification Channel --
SHOW PIPES;        
-- arn:aws:sqs:us-east-1:022404466729:sf-snowpipe-AIDAQKN3JBAUYJFJTGKB2-wY7Ahi6E9YSb-3uSarhj4A  -- 

-- Create a Event under S3 bucket --
-- snowpipe-csv-notification --
-- add the above notification channel in SQS queue in S3 under Event notification --

SELECT * FROM "COMPANY"."HR"."EMPLOYEES_CSV_PIPE";
SELECT SYSTEM$PIPE_STATUS('employee_csv_pipe');  

-- Showing Data from Stage --
SELECT 
    $1  as "EMPLOYEE_ID",
    $2  as "FIRST_NAME",
    $3  as "LAST_NAME",
    $4  as "EMAIL",
    $5  as "PHONE_NO",
    $6  as "HIRE_DATE",
    $7  as "JOB_ID",
    $8  as "SALARY",
    $9  as "COMMISSION_PCT",
    $10 as "MANAGER_ID",
    $11 as "DEPARTMENT_ID"
FROM 
    @"COMPANY"."HR".ext_csv_stage_employee_pipe;       


-- Continuous Parquet Data Loading Using Snowpipe --
-- Creating Table --
CREATE OR REPLACE TABLE "COMPANY"."HR"."EMPLOYEES_PARQUET_PIPE" (
    employee_id     NUMBER,
    first_name      VARCHAR(255),
    last_name       VARCHAR(255),	
    email           VARCHAR(255),	
    phone_number    VARCHAR(255),	
    hire_date       DATE,	
    job_id          VARCHAR(255),	
    salary          NUMBER,	
    commission_pct  NUMBER,	
    manager_id      NUMBER,	
    department_id   NUMBER
    );
    
--Create integration object for external stage -- (No need to run if already created)
create or replace storage integration s3_integration_employee
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::430470204953:role/snowflake-role-hr'
  storage_allowed_locations = ('s3://rtb-snowflake/employee/');
        
-- Create a file format for PARQUET -- (No need to run if already created)
CREATE OR REPLACE FILE FORMAT "COMPANY"."HR".PARQUET_FORMAT 
    TYPE = 'PARQUET' 
    COMPRESSION = 'AUTO'
    BINARY_AS_TEXT = TRUE;        
        
--Create external stage object
CREATE or REPLACE stage "COMPANY"."HR".ext_parquet_stage_employee_pipe
  URL = 's3://rtb-snowflake/employee/snowpipe/parquet'
  STORAGE_INTEGRATION = s3_integration_employee
  file_format = "COMPANY"."HR".PARQUET_FORMAT;        

-- Select Data from Stage --
SELECT 
    $1:"EMPLOYEE_ID"::STRING    AS EMPLOYEE_ID,
    $1:"FIRST_NAME"::STRING     AS FIRST_NAME,
    $1:"LAST_NAME"::STRING      AS LAST_NAME,
    $1:"EMAIL"::STRING          AS EMAIL,
    $1:"PHONE_NUMBER"::STRING   AS PHONE_NUMBER,
    $1:"HIRE_DATE"::STRING      AS HIRE_DATE,
    $1:"JOB_ID"::STRING         AS JOB_ID,
    $1:"SALARY"::STRING         AS SALARY,
    $1:"COMMISSION_PCT"::STRING AS COMMISSION_PCT,
    $1:"MANAGER_ID"::STRING     AS MANAGER_ID,
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID
FROM
  @"COMPANY"."HR".ext_parquet_stage_employee_pipe;

--create pipe to automate data ingestion from s3 to snowflake
create or replace pipe employee_parquet_pipe auto_ingest=true as
copy into "COMPANY"."HR"."EMPLOYEES_PARQUET_PIPE"
from
(
SELECT 
    $1:"EMPLOYEE_ID"::STRING    AS EMPLOYEE_ID,
    $1:"FIRST_NAME"::STRING     AS FIRST_NAME,
    $1:"LAST_NAME"::STRING      AS LAST_NAME,
    $1:"EMAIL"::STRING          AS EMAIL,
    $1:"PHONE_NUMBER"::STRING   AS PHONE_NUMBER,
    $1:"HIRE_DATE"::STRING      AS HIRE_DATE,
    $1:"JOB_ID"::STRING         AS JOB_ID,
    $1:"SALARY"::STRING         AS SALARY,
    $1:"COMMISSION_PCT"::STRING AS COMMISSION_PCT,
    $1:"MANAGER_ID"::STRING     AS MANAGER_ID,
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID
FROM
  @"COMPANY"."HR".ext_parquet_stage_employee_pipe
)
on_error = CONTINUE;          
        
-- Get the Notification Channel --
SHOW PIPES;         
-- arn:aws:sqs:us-east-1:022404466729:sf-snowpipe-AIDAQKN3JBAUYJFJTGKB2-wY7Ahi6E9YSb-3uSarhj4A --        
-- Create a Event under S3 bucket --
-- snowpipe-csv-notification --
-- add the above notification channel in SQS queue in S3 under Event notification --

SELECT * FROM "COMPANY"."HR"."EMPLOYEES_PARQUET_PIPE";
SELECT SYSTEM$PIPE_STATUS('employee_parquet_pipe');         
        
        
-- Continuous JSON Data Loading Using Snowpipe --
-- Creating Table --
CREATE OR REPLACE TABLE "COMPANY"."HR"."EMPLOYEES_JSON_PIPE" (
    employee_id     NUMBER,
    first_name      VARCHAR(255),
    last_name       VARCHAR(255),	
    email           VARCHAR(255),	
    phone_number    VARCHAR(255),	
    hire_date       DATE,	
    job_id          VARCHAR(255),	
    salary          NUMBER,	
    commission_pct  NUMBER,	
    manager_id      NUMBER,	
    department_id   NUMBER
    );
        
--Create integration object for external stage -- (No need to run if already created)
create or replace storage integration s3_integration_employee
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::430470204953:role/snowflake-role-hr'
  storage_allowed_locations = ('s3://rtb-snowflake/employee/');

-- Desc Stroage Integration --
DESC INTEGRATION s3_integration_employee;

-- Create a file format for JSON -- (No need to run if already created)
CREATE OR REPLACE FILE FORMAT "COMPANY"."HR".JSON_FORMAT 
    TYPE = 'JSON' 
    COMPRESSION = 'AUTO';


--Create external stage object
CREATE or REPLACE stage "COMPANY"."HR".ext_json_stage_employee_pipe
  URL = 's3://rtb-snowflake/employee/snowpipe/json'
  STORAGE_INTEGRATION = s3_integration_employee
  file_format = "COMPANY"."HR".JSON_FORMAT;

-- Select data from Stage --
SELECT 
    $1:"EMPLOYEE_ID"::STRING    AS EMPLOYEE_ID,
    $1:"FIRST_NAME"::STRING     AS FIRST_NAME,
    $1:"LAST_NAME"::STRING      AS LAST_NAME,
    $1:"EMAIL"::STRING          AS EMAIL,
    $1:"PHONE_NUMBER"::STRING   AS PHONE_NUMBER,
    $1:"HIRE_DATE"::STRING      AS HIRE_DATE,
    $1:"JOB_ID"::STRING         AS JOB_ID,
    $1:"SALARY"::STRING         AS SALARY,
    $1:"COMMISSION_PCT"::STRING AS COMMISSION_PCT,
    $1:"MANAGER_ID"::STRING     AS MANAGER_ID,
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID
FROM
  @"COMPANY"."HR".ext_json_stage_employee_pipe;

--create pipe to automate data ingestion from s3 to snowflake
create or replace pipe employee_json_pipe auto_ingest=true as
copy into "COMPANY"."HR"."EMPLOYEES_JSON_PIPE"
from
(
SELECT 
    $1:"EMPLOYEE_ID"::STRING    AS EMPLOYEE_ID,
    $1:"FIRST_NAME"::STRING     AS FIRST_NAME,
    $1:"LAST_NAME"::STRING      AS LAST_NAME,
    $1:"EMAIL"::STRING          AS EMAIL,
    $1:"PHONE_NUMBER"::STRING   AS PHONE_NUMBER,
    $1:"HIRE_DATE"::STRING      AS HIRE_DATE,
    $1:"JOB_ID"::STRING         AS JOB_ID,
    $1:"SALARY"::STRING         AS SALARY,
    $1:"COMMISSION_PCT"::STRING AS COMMISSION_PCT,
    $1:"MANAGER_ID"::STRING     AS MANAGER_ID,
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID
FROM
  @"COMPANY"."HR".ext_json_stage_employee_pipe
)
on_error = CONTINUE;        
        
-- Get the Notification Channel --
SHOW PIPES;         
-- arn:aws:sqs:us-east-1:022404466729:sf-snowpipe-AIDAQKN3JBAUYJFJTGKB2-wY7Ahi6E9YSb-3uSarhj4A --        
-- Create a Event under S3 bucket --
-- snowpipe-csv-notification --
-- add the above notification channel in SQS queue in S3 under Event notification --

SELECT * FROM "COMPANY"."HR"."EMPLOYEES_JSON_PIPE";
SELECT SYSTEM$PIPE_STATUS('employee_json_pipe');          
        
        
        
        
        
