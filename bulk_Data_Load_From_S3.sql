/*
Step 1:-
Create a AWS Account

Step 2:-
Create a S3 Bucket
	Bucket Name : rtb-snowflake
		Folder Name : snowflake
		
Step 3:-
Create a Group in IAM
	Group Name : rtb-snowflake-policy
		Policy : AmazonS3FullAccess

Step 4:-
	Create a User in IAM
	User Name : snowflake
	Password  : Snowflake1993@
	Policy    : AmazonS3FullAccess

Step 5:-	
Create a Role in IAM
	Role Name : snowflake-role
	
Step 6:-
Create csv and parquet folder and upload the corresponding files

Step 7:-
Create integration object for external stage

--Create integration object for external stage --
create or replace storage integration s3_integration_employee
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::430470204953:role/snowflake-role-hr'
  storage_allowed_locations = ('s3://rtb-snowflake/employee/');
	  
Describe the integration object
	Get the STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from the list
	
	STORAGE_AWS_IAM_USER_ARN    arn:aws:iam::022404466729:user/1i850000-s
	STORAGE_AWS_EXTERNAL_ID     CG53556_SFCRole=2_52Tb/ketMnAKKdnVF2BnU3hb1Tw=

Update the trust policy in snowflake-role json file accordingly

*/

-- Creating Database --
CREATE OR REPLACE DATABASE COMPANY;
-- Creating Schema --
CREATE OR REPLACE SCHEMA HR;
-- Creating Table --
CREATE OR REPLACE TABLE "COMPANY"."HR"."EMPLOYEES" (
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

-- Check Employee Details --
SELECT * FROM "COMPANY"."HR"."EMPLOYEES";
-- Truncate Data --
TRUNCATE TABLE "COMPANY"."HR"."EMPLOYEES";
--Create integration object for external stage --
create or replace storage integration s3_integration_employee
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::430470204953:role/snowflake-role-hr'
  storage_allowed_locations = ('s3://rtb-snowflake/employee/');
  

-- describe the integration object --
desc integration s3_integration_employee;

/*
STORAGE_AWS_IAM_USER_ARN    arn:aws:iam::022404466729:user/1i850000-s
STORAGE_AWS_EXTERNAL_ID     CG53556_SFCRole=2_52Tb/ketMnAKKdnVF2BnU3hb1Tw=
*/

-- Create a file format --
CREATE OR REPLACE file format "COMPANY"."HR".csv_format
		type = csv
		field_delimiter = ','
		skip_header = 1
		null_if = ('NULL', 'null')
		empty_field_as_null = true;

-- Create a stage --
CREATE OR REPLACE stage "COMPANY"."HR".ext_csv_stage_employee
  URL = 's3://rtb-snowflake/employee/csv'
  STORAGE_INTEGRATION = s3_integration_employee
  file_format = "COMPANY"."HR".csv_format;

-- Use copy command to ingest data from S3 --
copy into "COMPANY"."HR"."EMPLOYEES"
	from @"COMPANY"."HR".ext_csv_stage_employee
	on_error = CONTINUE;

-- Check Employee Details --
SELECT * FROM "COMPANY"."HR"."EMPLOYEES" WHERE FIRST_NAME = 'Swapnasubham';
SELECT * FROM "COMPANY"."HR"."EMPLOYEES" WHERE FIRST_NAME = 'Jatin';

list @"COMPANY"."HR".ext_csv_stage_employee;


-- Load JSON data from S3 to Snowflake --
-- Create table to load JSON data --

CREATE OR REPLACE TABLE "COMPANY"."HR"."EMPLOYEES_JSON_DATA" (
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
    department_id   NUMBER,
    filename        VARCHAR(255),
    file_row_number VARCHAR(255),
    load_timestamp  timestamp default TO_TIMESTAMP_NTZ(current_timestamp)
);

-- Create a file format for JSON --
CREATE OR REPLACE FILE FORMAT "COMPANY"."HR".JSON_FORMAT 
    TYPE = 'JSON' 
    COMPRESSION = 'AUTO';

--Create external stage object
CREATE or REPLACE stage "COMPANY"."HR".ext_json_stage_employee
  URL = 's3://rtb-snowflake/employee/json'
  STORAGE_INTEGRATION = s3_integration_employee
  file_format = "COMPANY"."HR".JSON_FORMAT;

-- Select Data into stage --
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
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    TO_TIMESTAMP_NTZ(current_timestamp)
FROM  
    @"COMPANY"."HR".ext_json_stage_employee;

-- Copy from stage to Table --
copy into "COMPANY"."HR"."EMPLOYEES_JSON_DATA"
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
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    TO_TIMESTAMP_NTZ(current_timestamp)
FROM  
    @"COMPANY"."HR".ext_json_stage_employee 
);

-- Check Employee Details --
SELECT * FROM "COMPANY"."HR"."EMPLOYEES_JSON_DATA" WHERE FIRST_NAME = 'Swapnasubham';
SELECT * FROM "COMPANY"."HR"."EMPLOYEES_JSON_DATA" WHERE FIRST_NAME = 'Jatin';


-- Load PARQUET data from S3 to Snowflake --
-- Create table to load PARQUET data --

CREATE OR REPLACE TABLE "COMPANY"."HR"."EMPLOYEES_PARQUET_DATA" (
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
    department_id   NUMBER,
    filename        VARCHAR(255),
    file_row_number VARCHAR(255),
    load_timestamp  timestamp default TO_TIMESTAMP_NTZ(current_timestamp)
);

-- Create a file format for PARQUET --
CREATE OR REPLACE FILE FORMAT "COMPANY"."HR".PARQUET_FORMAT 
    TYPE = 'PARQUET' 
    COMPRESSION = 'AUTO'
    BINARY_AS_TEXT = TRUE;

--Create external stage object
CREATE or REPLACE stage "COMPANY"."HR".ext_parquet_stage_employee
  URL = 's3://rtb-snowflake/employee/parquet'
  STORAGE_INTEGRATION = s3_integration_employee
  file_format = "COMPANY"."HR".PARQUET_FORMAT;

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
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    TO_TIMESTAMP_NTZ(current_timestamp)
FROM  
    @"COMPANY"."HR".ext_parquet_stage_employee;


-- Copy from stage to Table --
copy into "COMPANY"."HR"."EMPLOYEES_PARQUET_DATA"
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
    $1:"DEPARTMENT_ID"::STRING  AS DEPARTMENT_ID,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    TO_TIMESTAMP_NTZ(current_timestamp)
FROM  
    @"COMPANY"."HR".ext_parquet_stage_employee 
);



-- Check Employee Details --
SELECT * FROM "COMPANY"."HR"."EMPLOYEES_PARQUET_DATA" WHERE FIRST_NAME = 'Pranshu';
SELECT * FROM "COMPANY"."HR"."EMPLOYEES_PARQUET_DATA" WHERE FIRST_NAME = 'Jatin';
