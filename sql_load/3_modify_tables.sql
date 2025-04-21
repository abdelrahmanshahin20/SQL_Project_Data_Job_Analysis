/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
 Database Load Issues (follow if receiving permission denied when running SQL code below)
 
 Possible Errors: 
 - ERROR >>  duplicate key value violates unique constraint "company_dim_pkey"
 - ERROR >> could not open file "C:\Users\...\company_dim.csv" for reading: Permission denied
 
 1. Drop the Database 
 DROP DATABASE IF EXISTS sql_course;
 2. Repeat steps to create database and load table schemas
 - 1_create_database.sql
 - 2_create_tables.sql
 3. Open pgAdmin
 4. In Object Explorer (left-hand pane), navigate to `sql_course` database
 5. Right-click `sql_course` and select `PSQL Tool`
 - This opens a terminal window to write the following code
 6. Get the absolute file path of your csv files
 1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
 7. Paste the following into `PSQL Tool`, (with the CORRECT file path)
 
 \copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 \copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 \copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 \copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
 */
-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'C:\Work\learing SQL\SQL_Project_Data_Job_Analysis\csv_files\company_dim.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

-- this code copy the data of the company dim from the csv file and load it to the database i have created.
-- the link after the from clause is the the path link i have copied from the files i have add to my workspace in VS Code.

COPY skills_dim
FROM 'C:\Work\learing SQL\SQL_Project_Data_Job_Analysis\csv_files\skills_dim.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

-- this code is the same as the pervious one and it copies and load the skills dim.

COPY job_postings_fact
FROM 'C:\Work\learing SQL\SQL_Project_Data_Job_Analysis\csv_files\job_postings_fact.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

-- this code is also as the same as the previous code and it copies and load the data of the main table which is job postings facts.


COPY skills_job_dim
FROM 'C:\Work\learing SQL\SQL_Project_Data_Job_Analysis\csv_files\skills_job_dim.csv' WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

-- this code as u see is the same as the pervious codes 

-- January_table
CREATE TABLE January_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- February_table
CREATE TABLE February_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

--March_table
CREATE TABLE March_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

-- this code is to create a table for each month and it selects the data from the main table which is job postings fact and filter the data by the month.


SELECT 
    COUNT(job_id) as NO_of_jobs,
    CASE
        when job_location = 'Anywhere' then 'Remote '
        when job_location = 'New York, NY' then 'Local'
        else 'Onsite'
    End as Location_category
FROM 
    job_postings_fact
where 
    job_title_short = 'Data Analyst'
GROUP BY
    Location_category;

-- this code is to count the number of jobs in each location category for the job title short 'Data Analyst'.



WITH remote_job_skills AS( -- CREATED CTE
    SELECT
        skill_id,
        COUNT(*) as skill_count
    FROM 
        skills_job_dim as skills_to_job
    INNER JOIN 
        job_postings_fact AS job_postings
    ON 
        job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = 'true' AND 
        job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
) -- end of CTE 
SELECT 
    skills.skill_id,
    skills AS skill_name,
    skill_count
FROM 
    remote_job_skills
INNER JOIN 
    skills_dim AS skills
ON 
    skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 10;

/*this code is to create a CTE which is a common table expression
and it selects the skill id and the count of the skills from the 
skills job dim and join it with the job postings fact and filter 
the data by the job title short 'Data Analyst' and 
job work from home = 'true' and group by skill id 
and then it uses the data from CTE and marge it with skills_dim table 
and shows the skill_id, skill_name and skill_count.
*/

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    January_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    February_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM  
    March_jobs

/*UNION IS USED TO COMBINE THE RESULTS OF TWO OR MORE SELECT STATEMENTS
UNION SELECTS ONLY DISTINCT VALUES BY DEFAULT
UNION REMOVES DUPLICATE ROWS*/

/* NOW THRER ARE UNION ALL AND THIS UNION IS USED TO COMBINES TWO OR MORE
SELECT STATEMENTS AND IT DON'T REMOVE THE DUPLICATE ROWS 
IT RETURN ALL THE ROWS FROM THE SELECT STATEMENTS.*/

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    January_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    February_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM  
    March_jobs


/* PROBLEM 8 
FIND JOB POSTINGS FROM THE FIRST QUARTER THAT HAVE A SALARY GREATER THAN $70,000
- COMBINE JOB POSTINGS TABLES FROM THE FIRST QURTER OF 2023 (JAN-MAR)
- GETS JOB POSTINGS WITH AN AVERAGE YEARLY SALARY >$70,000
*/

SELECT
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::DATE,
    quarter1_job_postings.salary_year_avg
FROM(
    SELECT *
    FROM 
        January_jobs
    UNION ALL
    SELECT *
    FROM 
        February_jobs
    UNION ALL
    SELECT *
    FROM 
        March_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000
    AND 
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quarter1_job_postings.salary_year_avg DESC;

