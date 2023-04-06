---Create User AccountAdmin ---
CREATE USER somdutta password = '12345' DEFAULT_ROLE = ACCOUNTADMIN MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE ACCOUNTADMIN TO USER somdutta;

---Create User SecurityAdmin ---
CREATE USER nitai password = '12345' DEFAULT_ROLE = SECURITYADMIN MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE SECURITYADMIN TO USER nitai;

---Create User SysAdmin ---
CREATE USER puja password = '12345' DEFAULT_ROLE = SYSADMIN MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE SYSADMIN TO USER puja;


--- Grant access to Warehouse --
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE SECURITYADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE USERADMIN;

-- Logged in as SecurityAdmin --

/*
Create four role

TEAM_LEAD (All privilege)
    DEVELOPER (DDL DML and Select privilege)
    TESTER (DML and Select privilege)
    PRODUCTION_SUPPORT (Select privilege)

*/

--- Creating Role ---
CREATE ROLE TEAM_LEAD;
CREATE ROLE DEVELOPER;
CREATE ROLE TESTER;
CREATE ROLE PRODUCTION_SUPPORT;


--- Creating Hierarchy ---
GRANT ROLE PRODUCTION_SUPPORT TO ROLE TESTER;
GRANT ROLE TESTER TO ROLE DEVELOPER;
GRANT ROLE DEVELOPER TO ROLE TEAM_LEAD;
GRANT ROLE TEAM_LEAD TO ROLE SYSADMIN;



---Create User PRODUCTION_SUPPORT ---
--- santu
--- sanjay
--- swarup
--- surojit

CREATE USER santu password = '12345' DEFAULT_ROLE = PRODUCTION_SUPPORT MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE PRODUCTION_SUPPORT TO USER santu;

CREATE USER sanjay password = '12345' DEFAULT_ROLE = PRODUCTION_SUPPORT MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE PRODUCTION_SUPPORT TO USER sanjay;

CREATE USER swarup password = '12345' DEFAULT_ROLE = PRODUCTION_SUPPORT MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE PRODUCTION_SUPPORT TO USER swarup;

CREATE USER surojit password = '12345' DEFAULT_ROLE = PRODUCTION_SUPPORT MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE PRODUCTION_SUPPORT TO USER surojit;


---Create User Tester ---
--- jina
--- goja
--- joydeep

CREATE USER jina password = '12345' DEFAULT_ROLE = TESTER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE TESTER TO USER jina;

CREATE USER goja password = '12345' DEFAULT_ROLE = TESTER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE TESTER TO USER goja;

CREATE USER joydeep password = '12345' DEFAULT_ROLE = TESTER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE TESTER TO USER joydeep;

---Create User DEVELOPER ---
--- ankit
--- pranshu

CREATE USER ankit password = '12345' DEFAULT_ROLE = DEVELOPER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE DEVELOPER TO USER ankit;

CREATE USER pranshu password = '12345' DEFAULT_ROLE = DEVELOPER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE DEVELOPER TO USER pranshu;

---Create User TEAM_LEAD ---
--- anik

CREATE USER anik password = '12345' DEFAULT_ROLE = TEAM_LEAD MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE TEAM_LEAD TO USER anik;


--- Creating Role ---
CREATE ROLE SENIOR_MANAGER;
CREATE ROLE MANAGER;

--- Creating Hierarchy ---
--- This time we are not assigning to SYSADMIN role ---
GRANT ROLE MANAGER TO ROLE SENIOR_MANAGER;

---Create User MANAGER ---
--- injamam
--- soumen

CREATE USER injamam password = '12345' DEFAULT_ROLE = MANAGER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE MANAGER TO USER injamam;

CREATE USER soumen password = '12345' DEFAULT_ROLE = MANAGER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE MANAGER TO USER soumen;


---Create User SENIOR_MANAGER ---
--- gourab

CREATE USER gourab password = '12345' DEFAULT_ROLE = SENIOR_MANAGER MUST_CHANGE_PASSWORD = TRUE; 
GRANT ROLE SENIOR_MANAGER TO USER gourab;


--- Logged in as SYSADMIN ---

--- Create a Warehouse with small size ---
CREATE OR REPLACE WAREHOUSE PUBLIC_WH
    WITH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

--- Grant to all user to access the Warehouse ---
GRANT USAGE ON WAREHOUSE PUBLIC_WH TO ROLE PUBLIC;

--- Create a database which is accessible to everyone ---
CREATE OR REPLACE DATABASE PUBLIC_DB;
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE PUBLIC;


--- Create a Project database ---
CREATE OR REPLACE DATABASE CREDIT_ANALYSIS_TOOL;
--- Grant ownership to TEAM_LEAD to we created using SECURITYADMIN ---
GRANT OWNERSHIP ON DATABASE CREDIT_ANALYSIS_TOOL TO ROLE TEAM_LEAD;
--- Now ownership of the database is TEAM_LEAD which is assign to SYSADMIN---
GRANT OWNERSHIP ON SCHEMA PUBLIC TO ROLE TEAM_LEAD;


--- Create another Project database ---
CREATE OR REPLACE DATABASE CREDIT_FINANCIAL;
--- Grant ownership to TEAM_LEAD to we created using SECURITYADMIN ---
GRANT OWNERSHIP ON DATABASE CREDIT_FINANCIAL TO ROLE SENIOR_MANAGER;
--- Now ownership of the database is TEAM_LEAD which is assign to SYSADMIN---
GRANT OWNERSHIP ON SCHEMA PUBLIC TO ROLE SENIOR_MANAGER;

--- Droping the database ---
DROP DATABASE CREDIT_FINANCIAL;
--- We can't drop because the Ownership got changed ---



--- Using Role,Database and Warehouse ---
USE ROLE TEAM_LEAD;
USE DATABASE CREDIT_ANALYSIS_TOOL;
USE WAREHOUSE PUBLIC_WH;

--- Creating Schema ---
CREATE OR REPLACE SCHEMA CREDIT_ANALYSIS_CORE;

--- Creating Table ---
CREATE OR REPLACE TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES
    ( employee_id        NUMBER PRIMARY KEY
    , first_name         VARCHAR(255)
    , last_name          VARCHAR(255)     NOT NULL
    , email              VARCHAR(255)     NOT NULL
    , phone_number       VARCHAR(255)
    , hire_date          TIMESTAMP        NOT NULL
    , job_id             VARCHAR(255)     NOT NULL
    , salary             NUMBER
    , commission_pct     NUMBER
    , manager_id         NUMBER
    , department_id      NUMBER 
    ) ;
    
-- Inserting Data --
INSERT INTO CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES
VALUES
    (100, 'Steven', 'King', 'steven.king@company.com', '515.123.4567', '2010-06-17 00:00:00', 'AD_PRES', 24000, 0, 0, 90),
    (101, 'Neena', 'Kochhar', 'neena.kochhar@company.com', '515.123.4568', '2010-06-18 00:00:00', 'AD_VP', 17000, 0, 100, 90),
    (102, 'Lex', 'De Haan', 'lex.de haan@company.com', '515.123.4569', '2010-06-19 00:00:00', 'AD_VP', 17000, 0, 100, 90),
    (103, 'Alexander', 'Hunold', 'alexander.hunold@company.com', '590.423.4567', '2010-06-20 00:00:00', 'IT_PROG', 9000, 0, 102, 60),
    (104, 'Bruce', 'Ernst', 'bruce.ernst@company.com', '590.423.4568', '2010-06-21 00:00:00', 'IT_PROG', 6000, 0, 103, 60),
    (105, 'David', 'Austin', 'david.austin@company.com', '590.423.4569', '2011-06-22 00:00:00', 'IT_PROG', 4800, 0, 103, 60),
    (106, 'Valli', 'Pataballa', 'valli.pataballa@company.com', '590.423.4560', '2011-06-23 00:00:00', 'IT_PROG', 4800, 0, 103, 60),
    (107, 'Diana', 'Lorentz', 'diana.lorentz@company.com', '590.423.5567', '2011-06-24 00:00:00', 'IT_PROG', 4200, 0, 103, 60),
    (114, 'Den', 'Raphaely', 'den.raphaely@company.com', '515.127.4561', '2011-07-01 00:00:00', 'PU_MAN', 11000, 0, 100, 30),
    (115, 'Alexander', 'Khoo', 'alexander.khoo@company.com', '515.127.4562', '2012-07-02 00:00:00', 'PU_CLERK', 3100, 0, 114, 30),
    (116, 'Shelli', 'Baida', 'shelli.baida@company.com', '515.127.4563', '2012-07-03 00:00:00', 'PU_CLERK', 2900, 0, 114, 30),
    (117, 'Sigal', 'Tobias', 'sigal.tobias@company.com', '515.127.4564', '2012-07-04 00:00:00', 'PU_CLERK', 2800, 0, 114, 30),
    (108, 'Nancy', 'Greenberg', 'nancy.greenberg@company.com', '515.999.4569', '2012-06-25 00:00:00', 'FI_MGR', 12000, 0, 101, 100),
    (109, 'Daniel', 'Faviet', 'daniel.faviet@company.com', '515.999.4169', '2012-06-26 00:00:00', 'FI_ACCOUNT', 9000, 0, 108, 100),
    (110, 'John', 'Chen', 'john.chen@company.com', '515.999.4269', '2012-06-27 00:00:00', 'FI_ACCOUNT', 8200, 0, 108, 100),
    (111, 'Ismael', 'Sciarra', 'ismael.sciarra@company.com', '515.999.4369', '2014-06-28 00:00:00', 'FI_ACCOUNT', 7700, 0, 108, 100),
    (112, 'Jose Manuel', 'Urman', 'jose manuel.urman@company.com', '515.999.4469', '2014-06-29 00:00:00', 'FI_ACCOUNT', 7800, 0, 108, 100),
    (113, 'Luis', 'Popp', 'luis.popp@company.com', '515.999.4567', '2014-06-30 00:00:00', 'FI_ACCOUNT', 6900, 0, 108, 100),
    (133, 'Jason', 'Mallin', 'jason.mallin@company.com', '650.127.1934', '2014-07-20 00:00:00', 'ST_CLERK', 3300, 0, 122, 50),
    (134, 'Michael', 'Rogers', 'michael.rogers@company.com', '650.127.1834', '2014-07-21 00:00:00', 'ST_CLERK', 2900, 0, 122, 50),
    (135, 'Ki', 'Gee', 'ki.gee@company.com', '650.127.1734', '2015-07-22 00:00:00', 'ST_CLERK', 2400, 0, 122, 50),
    (136, 'Hazel', 'Philtanker', 'hazel.philtanker@company.com', '650.127.1634', '2016-07-23 00:00:00', 'ST_CLERK', 2200, 0, 122, 50),
    (137, 'Renske', 'Ladwig', 'renske.ladwig@company.com', '650.121.1234', '2016-07-24 00:00:00', 'ST_CLERK', 3600, 0, 123, 50),
    (138, 'Stephen', 'Stiles', 'stephen.stiles@company.com', '650.121.2034', '2016-07-25 00:00:00', 'ST_CLERK', 3200, 0, 123, 50),
    (139, 'John', 'Seo', 'john.seo@company.com', '650.121.2019', '2016-07-26 00:00:00', 'ST_CLERK', 2700, 0, 123, 50),
    (140, 'Joshua', 'Patel', 'joshua.patel@company.com', '650.121.1834', '2016-07-27 00:00:00', 'ST_CLERK', 2500, 0, 123, 50),
    (129, 'Laura', 'Bissot', 'laura.bissot@company.com', '650.999.5234', '2017-07-16 00:00:00', 'ST_CLERK', 3300, 0, 121, 50),
    (130, 'Mozhe', 'Atkinson', 'mozhe.atkinson@company.com', '650.999.6234', '2017-07-17 00:00:00', 'ST_CLERK', 2800, 0, 121, 50),
    (131, 'James', 'Marlow', 'james.marlow@company.com', '650.999.7234', '2018-07-18 00:00:00', 'ST_CLERK', 2500, 0, 121, 50),
    (132, 'TJ', 'Olson', 'tj.olson@company.com', '650.999.8234', '2019-07-19 00:00:00', 'ST_CLERK', 2100, 0, 121, 50),
    (141, 'Trenna', 'Rajs', 'trenna.rajs@company.com', '650.121.8009', '2020-07-28 00:00:00', 'ST_CLERK', 3500, 0, 124, 50),
    (142, 'Curtis', 'Davies', 'curtis.davies@company.com', '650.121.2994', '2020-07-29 00:00:00', 'ST_CLERK', 3100, 0, 124, 50),
    (143, 'Randall', 'Matos', 'randall.matos@company.com', '650.121.2874', '2020-07-30 00:00:00', 'ST_CLERK', 2600, 0, 124, 50),
    (144, 'Peter', 'Vargas', 'peter.vargas@company.com', '650.121.2004', '2020-07-31 00:00:00', 'ST_CLERK', 2500, 0, 124, 50),
    (145, 'John', 'Russell', 'john.russell@company.com', '011.44.1344.429268', '2020-08-01 00:00:00', 'SA_MAN', 14000, 0.4, 100, 80),
    (146, 'Karen', 'Partners', 'karen.partners@company.com', '011.44.1344.467268', '2020-08-02 00:00:00', 'SA_MAN', 13500, 0.3, 100, 80),
    (147, 'Alberto', 'Errazuriz', 'alberto.errazuriz@company.com', '011.44.1344.429278', '2020-08-03 00:00:00', 'SA_MAN', 12000, 0.3, 100, 80),
    (148, 'Gerald', 'Cambrault', 'gerald.cambrault@company.com', '011.44.1344.619268', '2020-08-04 00:00:00', 'SA_MAN', 11000, 0.3, 100, 80),
    (149, 'Eleni', 'Zlotkey', 'eleni.zlotkey@company.com', '011.44.1344.429018', '2020-08-05 00:00:00', 'SA_MAN', 10500, 0.2, 100, 80),
    (150, 'Peter', 'Tucker', 'peter.tucker@company.com', '011.44.1344.129268', '2020-08-06 00:00:00', 'SA_REP', 10000, 0.3, 145, 80),
    (118, 'Guy', 'Himuro', 'guy.himuro@company.com', '515.127.4565', '2020-07-05 00:00:00', 'PU_CLERK', 2600, 0, 114, 30),
    (119, 'Karen', 'Colmenares', 'karen.colmenares@company.com', '515.127.4566', '2020-07-06 00:00:00', 'PU_CLERK', 2500, 0, 114, 30),
    (120, 'Matthew', 'Weiss', 'matthew.weiss@company.com', '650.123.1234', '2020-07-07 00:00:00', 'ST_MAN', 8000, 0, 100, 50),
    (121, 'Adam', 'Fripp', 'adam.fripp@company.com', '650.123.2234', '2020-07-08 00:00:00', 'ST_MAN', 8200, 0, 100, 50),
    (122, 'Payam', 'Kaufling', 'payam.kaufling@company.com', '650.123.3234', '2020-07-09 00:00:00', 'ST_MAN', 7900, 0, 100, 50),
    (123, 'Shanta', 'Vollman', 'shanta.vollman@company.com', '650.123.4234', '2020-07-10 00:00:00', 'ST_MAN', 6500, 0, 100, 50),
    (124, 'Kevin', 'Mourgos', 'kevin.mourgos@company.com', '650.123.5234', '2020-07-11 00:00:00', 'ST_MAN', 5800, 0, 100, 50),
    (151, 'David', 'Bernstein', 'david.bernstein@company.com', '011.44.1344.345268', '2020-08-07 00:00:00', 'SA_REP', 9500, 0.25, 145, 80),
    (152, 'Peter', 'Hall', 'peter.hall@company.com', '011.44.1344.478968', '2020-08-08 00:00:00', 'SA_REP', 9000, 0.25, 145, 80),
    (153, 'Christopher', 'Olsen', 'christopher.olsen@company.com', '011.44.1344.498718', '2020-08-09 00:00:00', 'SA_REP', 8000, 0.2, 145, 80),
    (154, 'Nanette', 'Cambrault', 'nanette.cambrault@company.com', '011.44.1344.987668', '2020-08-10 00:00:00', 'SA_REP', 7500, 0.2, 145, 80),
    (155, 'Oliver', 'Tuvault', 'oliver.tuvault@company.com', '011.44.1344.486508', '2020-08-11 00:00:00', 'SA_REP', 7000, 0.15, 145, 80),
    (156, 'Janette', 'King', 'janette.king@company.com', '011.44.1345.429268', '2020-08-12 00:00:00', 'SA_REP', 10000, 0.35, 146, 80),
    (157, 'Patrick', 'Sully', 'patrick.sully@company.com', '011.44.1345.929268', '2020-08-13 00:00:00', 'SA_REP', 9500, 0.35, 146, 80),
    (158, 'Allan', 'McEwen', 'allan.mcewen@company.com', '011.44.1345.829268', '2020-08-14 00:00:00', 'SA_REP', 9000, 0.35, 146, 80),
    (159, 'Lindsey', 'Smith', 'lindsey.smith@company.com', '011.44.1345.729268', '2020-08-15 00:00:00', 'SA_REP', 8000, 0.3, 146, 80),
    (125, 'Julia', 'Nayer', 'julia.nayer@company.com', '650.999.1214', '2020-07-12 00:00:00', 'ST_CLERK', 3200, 0, 120, 50),
    (126, 'Irene', 'Mikkilineni', 'irene.mikkilineni@company.com', '650.999.1224', '2020-07-13 00:00:00', 'ST_CLERK', 2700, 0, 120, 50),
    (127, 'James', 'Landry', 'james.landry@company.com', '650.999.1334', '2020-07-14 00:00:00', 'ST_CLERK', 2400, 0, 120, 50),
    (128, 'Steven', 'Markle', 'steven.markle@company.com', '650.999.1434', '2020-07-15 00:00:00', 'ST_CLERK', 2200, 0, 120, 50),
    (160, 'Louise', 'Doran', 'louise.doran@company.com', '011.44.1345.629268', '2020-08-16 00:00:00', 'SA_REP', 7500, 0.3, 146, 80),
    (161, 'Sarath', 'Sewall', 'sarath.sewall@company.com', '011.44.1345.529268', '2020-08-17 00:00:00', 'SA_REP', 7000, 0.25, 146, 80),
    (162, 'Clara', 'Vishney', 'clara.vishney@company.com', '011.44.1346.129268', '2020-08-18 00:00:00', 'SA_REP', 10500, 0.25, 147, 80),
    (163, 'Danielle', 'Greene', 'danielle.greene@company.com', '011.44.1346.229268', '2020-08-19 00:00:00', 'SA_REP', 9500, 0.15, 147, 80),
    (164, 'Mattea', 'Marvins', 'mattea.marvins@company.com', '011.44.1346.329268', '2020-08-20 00:00:00', 'SA_REP', 7200, 0.1, 147, 80),
    (165, 'David', 'Lee', 'david.lee@company.com', '011.44.1346.529268', '2020-08-21 00:00:00', 'SA_REP', 6800, 0.1, 147, 80),
    (166, 'Sundar', 'Ande', 'sundar.ande@company.com', '011.44.1346.629268', '2020-08-22 00:00:00', 'SA_REP', 6400, 0.1, 147, 80),
    (167, 'Amit', 'Banda', 'amit.banda@company.com', '011.44.1346.729268', '2020-08-23 00:00:00', 'SA_REP', 6200, 0.1, 147, 80),
    (168, 'Lisa', 'Ozer', 'lisa.ozer@company.com', '011.44.1343.929268', '2020-08-24 00:00:00', 'SA_REP', 11500, 0.25, 148, 80),
    (169, 'Harrison', 'Bloom', 'harrison.bloom@company.com', '011.44.1343.829268', '2020-08-25 00:00:00', 'SA_REP', 10000, 0.2, 148, 80),
    (170, 'Tayler', 'Fox', 'tayler.fox@company.com', '011.44.1343.729268', '2020-08-26 00:00:00', 'SA_REP', 9600, 0.2, 148, 80),
    (171, 'William', 'Smith', 'william.smith@company.com', '011.44.1343.629268', '2020-08-27 00:00:00', 'SA_REP', 7400, 0.15, 148, 80),
    (172, 'Elizabeth', 'Bates', 'elizabeth.bates@company.com', '011.44.1343.529268', '2020-08-28 00:00:00', 'SA_REP', 7300, 0.15, 148, 80),
    (173, 'Sundita', 'Kumar', 'sundita.kumar@company.com', '011.44.1343.329268', '2020-08-29 00:00:00', 'SA_REP', 6100, 0.1, 148, 80),
    (174, 'Ellen', 'Abel', 'ellen.abel@company.com', '011.44.1644.429267', '2020-08-30 00:00:00', 'SA_REP', 11000, 0.3, 149, 80),
    (175, 'Alyssa', 'Hutton', 'alyssa.hutton@company.com', '011.44.1644.429266', '2020-08-31 00:00:00', 'SA_REP', 8800, 0.25, 149, 80),
    (176, 'Jonathon', 'Taylor', 'jonathon.taylor@company.com', '011.44.1644.429265', '2020-09-01 00:00:00', 'SA_REP', 8600, 0.2, 149, 80),
    (177, 'Jack', 'Livingston', 'jack.livingston@company.com', '011.44.1644.429264', '2020-09-02 00:00:00', 'SA_REP', 8400, 0.2, 149, 80),
    (178, 'Kimberely', 'Grant', 'kimberely.grant@company.com', '011.44.1644.429263', '2020-09-03 00:00:00', 'SA_REP', 7000, 0.15, 149, 0),
    (179, 'Charles', 'Johnson', 'charles.johnson@company.com', '011.44.1644.429262', '2020-09-04 00:00:00', 'SA_REP', 6200, 0.1, 149, 80),
    (180, 'Winston', 'Taylor', 'winston.taylor@company.com', '650.507.9876', '2020-09-05 00:00:00', 'SH_CLERK', 3200, 0, 120, 50),
    (181, 'Jean', 'Fleaur', 'jean.fleaur@company.com', '650.507.9877', '2020-09-06 00:00:00', 'SH_CLERK', 3100, 0, 120, 50),
    (182, 'Martha', 'Sullivan', 'martha.sullivan@company.com', '650.507.9878', '2020-09-07 00:00:00', 'SH_CLERK', 2500, 0, 120, 50),
    (183, 'Girard', 'Geoni', 'girard.geoni@company.com', '650.507.9879', '2020-09-08 00:00:00', 'SH_CLERK', 2800, 0, 120, 50),
    (184, 'Nandita', 'Sarchand', 'nandita.sarchand@company.com', '650.509.1876', '2020-09-09 00:00:00', 'SH_CLERK', 4200, 0, 121, 50),
    (185, 'Alexis', 'Bull', 'alexis.bull@company.com', '650.509.2876', '2020-09-10 00:00:00', 'SH_CLERK', 4100, 0, 121, 50),
    (186, 'Julia', 'Dellinger', 'julia.dellinger@company.com', '650.509.3876', '2020-09-11 00:00:00', 'SH_CLERK', 3400, 0, 121, 50),
    (187, 'Anthony', 'Cabrio', 'anthony.cabrio@company.com', '650.509.4876', '2020-09-12 00:00:00', 'SH_CLERK', 3000, 0, 121, 50),
    (188, 'Kelly', 'Chung', 'kelly.chung@company.com', '650.505.1876', '2020-09-13 00:00:00', 'SH_CLERK', 3800, 0, 122, 50),
    (189, 'Jennifer', 'Dilly', 'jennifer.dilly@company.com', '650.505.2876', '2020-09-14 00:00:00', 'SH_CLERK', 3600, 0, 122, 50),
    (190, 'Timothy', 'Gates', 'timothy.gates@company.com', '650.505.3876', '2020-09-15 00:00:00', 'SH_CLERK', 2900, 0, 122, 50),
    (191, 'Randall', 'Perkins', 'randall.perkins@company.com', '650.505.4876', '2020-09-16 00:00:00', 'SH_CLERK', 2500, 0, 122, 50),
    (192, 'Sarah', 'Bell', 'sarah.bell@company.com', '650.501.1876', '2020-09-17 00:00:00', 'SH_CLERK', 4000, 0, 123, 50),
    (193, 'Britney', 'Everett', 'britney.everett@company.com', '650.501.2876', '2020-09-18 00:00:00', 'SH_CLERK', 3900, 0, 123, 50),
    (194, 'Samuel', 'McCain', 'samuel.mccain@company.com', '650.501.3876', '2020-09-19 00:00:00', 'SH_CLERK', 3200, 0, 123, 50),
    (195, 'Vance', 'Jones', 'vance.jones@company.com', '650.501.4876', '2020-09-20 00:00:00', 'SH_CLERK', 2800, 0, 123, 50),
    (196, 'Alana', 'Walsh', 'alana.walsh@company.com', '650.507.9811', '2020-09-21 00:00:00', 'SH_CLERK', 3100, 0, 124, 50),
    (197, 'Kevin', 'Feeney', 'kevin.feeney@company.com', '650.507.9822', '2020-09-22 00:00:00', 'SH_CLERK', 3000, 0, 124, 50),
    (198, 'Donald', 'OConnell', 'donald.oconnell@company.com', '650.507.9833', '2020-09-23 00:00:00', 'SH_CLERK', 2600, 0, 124, 50),
    (199, 'Douglas', 'Grant', 'douglas.grant@company.com', '650.507.9844', '2020-09-24 00:00:00', 'SH_CLERK', 2600, 0, 124, 50),
    (200, 'Jennifer', 'Whalen', 'jennifer.whalen@company.com', '515.123.4444', '2020-09-25 00:00:00', 'AD_ASST', 4400, 0, 101, 10),
    (201, 'Michael', 'Hartstein', 'michael.hartstein@company.com', '515.123.5555', '2020-09-26 00:00:00', 'MK_MAN', 13000, 0, 100, 20),
    (202, 'Pat', 'Fay', 'pat.fay@company.com', '603.123.6666', '2020-09-27 00:00:00', 'MK_REP', 6000, 0, 201, 20),
    (203, 'Susan', 'Mavris', 'susan.mavris@company.com', '515.123.7777', '2020-09-28 00:00:00', 'HR_REP', 6500, 0, 101, 40),
    (204, 'Hermann', 'Baer', 'hermann.baer@company.com', '515.123.8888', '2020-09-29 00:00:00', 'PR_REP', 10000, 0, 101, 70),
    (205, 'Shelley', 'Higgins', 'shelley.higgins@company.com', '515.123.8080', '2020-09-30 00:00:00', 'AC_MGR', 12000, 0, 101, 110),
    (206, 'William', 'Gietz', 'william.gietz@company.com', '515.123.8181', '2020-10-01 00:00:00', 'AC_ACCOUNT', 8300, 0, 205, 110)
;

--- Selecting Data ---
SELECT * FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES;

--- Switch to Prod Support Role ---
USE ROLE PRODUCTION_SUPPORT;

--- Selecting Data ---
SELECT * FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES;
--- Database 'CREDIT_ANALYSIS_TOOL' does not exist or not authorized. ---


--- Switch role to TEAM_LEAD and provide the access ---
USE ROLE TEAM_LEAD;

GRANT USAGE ON DATABASE CREDIT_ANALYSIS_TOOL TO ROLE PRODUCTION_SUPPORT;
GRANT USAGE ON SCHEMA CREDIT_ANALYSIS_CORE TO ROLE PRODUCTION_SUPPORT;
GRANT SELECT ON TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES TO ROLE PRODUCTION_SUPPORT;
GRANT INSERT ON TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES TO ROLE TESTER;
GRANT UPDATE ON TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES TO ROLE TESTER;
GRANT DELETE ON TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES TO ROLE DEVELOPER;
GRANT ALL ON TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES TO ROLE DEVELOPER;
--- Selecting Data ---
USE ROLE PRODUCTION_SUPPORT;
SELECT * FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES;
-- Now able to read the table --

-- Login with Tester role --

SELECT * FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES WHERE EMPLOYEE_ID = 205;
INSERT INTO CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES VALUES (207, 'Dante', 'Das', 'das.dante@company.com', '515.123.8907', '2010-06-18 00:00:00', 'AD_VP', 16000, 0, 100, 90);
UPDATE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES SET LAST_NAME = 'West' WHERE EMPLOYEE_ID = 205;

DELETE FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES WHERE EMPLOYEE_ID = 205;
-- Insufficient privileges to operate on table 'EMPLOYEES' --

-- Login with Developer role --

SELECT * FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES WHERE EMPLOYEE_ID = 203;
INSERT INTO CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES VALUES (208, 'Anik', 'De', 'de.anik@company.com', '515.123.7592', '2010-06-18 00:00:00', 'AD_VP', 15000, 0, 100, 90);
UPDATE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES SET FIRST_NAME = 'Sonia' WHERE EMPLOYEE_ID = 203;
DELETE FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES WHERE EMPLOYEE_ID = 202;

DROP TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES;
--- Insufficient privileges to operate on table 'EMPLOYEES' ---
--- You can't delete the all privilege, only owner can drop object ---

-- Login with TEAM_LEAD (Owner) role --

SELECT * FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES WHERE EMPLOYEE_ID = 106;
INSERT INTO CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES VALUES (209, 'Puja', 'Das', 'puja.das@company.com', '515.123.4890', '2010-06-18 00:00:00', 'AD_VP', 14000, 0, 100, 90);
UPDATE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES SET FIRST_NAME = 'Ria' WHERE EMPLOYEE_ID = 106;
DELETE FROM CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES WHERE EMPLOYEE_ID = 105;
DROP TABLE CREDIT_ANALYSIS_TOOL.CREDIT_ANALYSIS_CORE.EMPLOYEES;












