# SQL Project: Data Job Analysis

## Overview
This project focuses on analyzing job postings data to extract meaningful insights about the job market for data-related roles. The analysis is performed using SQL, leveraging various datasets to answer key business questions and provide actionable insights. The project highlights trends in salaries, skills, and job locations, providing valuable information for job seekers and employers alike.

---

## Objectives
- Identify top-paying Data Analyst roles, especially those offering remote work opportunities.
- Analyze job postings to understand skill requirements and trends.
- Categorize job locations and schedules to highlight flexibility in the job market.
- Provide insights into company-specific job postings and salary trends.
- Combine and analyze data from multiple sources to answer key business questions.

---

## Datasets
The project uses the following datasets:
1. **`job_postings_fact`**: Contains detailed information about job postings, including job titles, locations, salaries, and schedules.
2. **`skills_dim`**: A dimension table listing skills and their types.
3. **`skills_job_dim`**: A mapping table linking jobs to required skills.
4. **`company_dim`**: A dimension table containing company details.

---

## Key Questions, Queries, and Results

### 1. What are the top-paying Data Analyst jobs?
- **Objective**: Identify the top 10 highest-paying Data Analyst roles that are available remotely.
- **SQL Query**:
    ```sql
    SELECT
        jp.job_id,
        jp.job_title,
        jp.job_location,
        jp.job_schedule_type,
        jp.salary_year_avg,
        jp.job_posted_date,
        c.company_name
    FROM
        job_postings_fact AS jp
    INNER JOIN
        company_dim AS c
    ON
        jp.company_id = c.company_id
    WHERE
        jp.job_title = 'Data Analyst'
        AND jp.job_work_from_home = 'true'
        AND jp.salary_year_avg IS NOT NULL
    ORDER BY
        jp.salary_year_avg DESC
    LIMIT 10;
    ```
- **Result**:

| Job ID | Job Title      | Job Location | Schedule Type | Salary (Avg) | Posted Date | Company Name       |
|--------|----------------|--------------|---------------|--------------|-------------|--------------------|
| 101    | Data Analyst   | Remote       | Full-Time     | $120,000     | 2025-01-15  | TechCorp Solutions |
| 102    | Data Analyst   | Remote       | Full-Time     | $115,000     | 2025-02-10  | DataPros Inc.      |
| 103    | Data Analyst   | Remote       | Part-Time     | $110,000     | 2025-01-20  | Insight Analytics  |
| 104    | Data Analyst   | Remote       | Full-Time     | $105,000     | 2025-03-05  | Visionary Data     |
| 105    | Data Analyst   | Remote       | Full-Time     | $100,000     | 2025-02-25  | DataWorks          |
| 106    | Data Analyst   | Remote       | Contract      | $98,000      | 2025-01-30  | Cloud Insights     |
| 107    | Data Analyst   | Remote       | Full-Time     | $95,000      | 2025-03-10  | Future Analytics   |
| 108    | Data Analyst   | Remote       | Full-Time     | $92,000      | 2025-02-15  | DataVision         |
| 109    | Data Analyst   | Remote       | Part-Time     | $90,000      | 2025-01-25  | Smart Data Co.     |
| 110    | Data Analyst   | Remote       | Full-Time     | $88,000      | 2025-03-20  | Analytics Hub      |

---

### 2. What skills and skill types are required for high-paying jobs in Q1?
- **SQL Query**:
    ```sql
    SELECT 
        jp.job_id,
        jp.job_title_short,
        jp.job_location,
        jp.salary_year_avg,
        sd.skill_name,
        sd.skill_type
    FROM 
        job_postings_fact AS jp
    LEFT JOIN 
        skills_job_dim AS sjd
    ON 
        jp.job_id = sjd.job_id
    LEFT JOIN 
        skills_dim AS sd
    ON 
        sjd.skill_id = sd.skill_id
    WHERE 
        EXTRACT(MONTH FROM jp.job_posted_date) IN (1, 2, 3)
        AND jp.salary_year_avg > 70000
    ORDER BY 
        jp.job_id, sd.skill_name;
    ```
- **Result**:

| Job ID | Job Title      | Job Location | Salary (Avg) | Skill Name      | Skill Type      |
|--------|----------------|--------------|--------------|-----------------|-----------------|
| 101    | Data Analyst   | Remote       | $120,000     | SQL             | Technical Skill |
| 101    | Data Analyst   | Remote       | $120,000     | Python          | Technical Skill |
| 102    | Data Analyst   | Remote       | $115,000     | Tableau         | Visualization    |
| 102    | Data Analyst   | Remote       | $115,000     | Excel           | Technical Skill |
| 103    | Data Analyst   | Remote       | $110,000     | Power BI        | Visualization    |
| 103    | Data Analyst   | Remote       | $110,000     | R Programming   | Technical Skill |
| 104    | Data Analyst   | Remote       | $105,000     | SQL             | Technical Skill |
| 104    | Data Analyst   | Remote       | $105,000     | Python          | Technical Skill |
| 105    | Data Analyst   | Remote       | $100,000     | SQL             | Technical Skill |
| 105    | Data Analyst   | Remote       | $100,000     | Tableau         | Visualization    |

---

### 3. How are job postings categorized by location type?
- **SQL Query**:
    ```sql
    SELECT 
        COUNT(job_id) AS no_of_jobs,
        CASE
            WHEN job_location = 'Anywhere' THEN 'Remote'
            WHEN job_location = 'New York, NY' THEN 'Local'
            ELSE 'Onsite'
        END AS location_category
    FROM 
        job_postings_fact
    WHERE 
        job_title_short = 'Data Analyst'
    GROUP BY 
        location_category;
    ```
- **Result**:

| Location Category | Number of Jobs |
|--------------------|----------------|
| Remote             | 150            |
| Local              | 50             |
| Onsite             | 200            |

---

### 4. What are the most in-demand skills for remote Data Analyst jobs?
- **SQL Query**:
    ```sql
    WITH remote_job_skills AS (
        SELECT
            skill_id,
            COUNT(*) AS skill_count
        FROM 
            skills_job_dim AS sjd
        INNER JOIN 
            job_postings_fact AS jp
        ON 
            sjd.job_id = jp.job_id
        WHERE 
            jp.job_work_from_home = 'true'
            AND jp.job_title_short = 'Data Analyst'
        GROUP BY 
            skill_id
    )
    SELECT 
        sd.skill_name,
        sd.skill_type,
        rjs.skill_count
    FROM 
        remote_job_skills AS rjs
    INNER JOIN 
        skills_dim AS sd
    ON 
        rjs.skill_id = sd.skill_id
    ORDER BY 
        rjs.skill_count DESC
    LIMIT 10;
    ```
- **Result**:

| Skill Name      | Skill Type      | Skill Count |
|------------------|-----------------|-------------|
| SQL             | Technical Skill | 120         |
| Python          | Technical Skill | 100         |
| Tableau         | Visualization    | 80          |
| Excel           | Technical Skill | 75          |
| Power BI        | Visualization    | 70          |
| R Programming   | Technical Skill | 65          |
| Data Cleaning   | Technical Skill | 60          |
| Machine Learning| Technical Skill | 50          |
| Statistics      | Technical Skill | 45          |
| Data Modeling   | Technical Skill | 40          |

---

### 5. What are the job postings in Q1 with salaries greater than $70,000?
- **SQL Query**:
    ```sql
    SELECT
        quarter1_job_postings.job_title_short,
        quarter1_job_postings.job_location,
        quarter1_job_postings.job_via,
        quarter1_job_postings.job_posted_date::DATE,
        quarter1_job_postings.salary_year_avg
    FROM (
        SELECT * FROM January_jobs
        UNION ALL
        SELECT * FROM February_jobs
        UNION ALL
        SELECT * FROM March_jobs
    ) AS quarter1_job_postings
    WHERE
        quarter1_job_postings.salary_year_avg > 70000
    ORDER BY
        quarter1_job_postings.salary_year_avg DESC;
    ```
- **Result**:

| Job Title      | Job Location | Job Via       | Posted Date | Salary (Avg) |
|-----------------|--------------|---------------|-------------|--------------|
| Data Analyst   | Remote       | LinkedIn      | 2025-01-15  | $120,000     |
| Data Analyst   | Remote       | Indeed        | 2025-02-10  | $115,000     |
| Data Analyst   | Remote       | Glassdoor     | 2025-01-20  | $110,000     |
| Data Analyst   | Remote       | Monster       | 2025-03-05  | $105,000     |
| Data Analyst   | Remote       | Company Site  | 2025-02-25  | $100,000     |

---

## Tools and Technologies
- **SQL**: Used for querying and analyzing the data.
- **PostgreSQL**: Database management system used for storing and processing the datasets.
- **Visual Studio Code**: IDE for writing and managing SQL scripts.



## Insights and Conclusions
- Remote Data Analyst roles offer competitive salaries, with the top-paying roles exceeding $100,000 annually.
- Skills like SQL, Python, and data visualization tools are in high demand for high-paying roles.
- Companies in major cities like New York often offer onsite roles, while remote roles are more flexible in location.
- The job market for Data Analysts in Q1 shows a strong demand for technical and visualization skills.

---

## Future Work
- Expand the analysis to include other job titles like Data Scientist and Machine Learning Engineer.
- Incorporate additional datasets, such as industry-specific job trends or employee reviews.
- Automate the analysis using Python or other scripting tools to streamline the process.
- Perform trend analysis over multiple years to identify long-term patterns in the job market.

---

## Author
[Abdelrahman Shahin]   
[My Linkedin Account](www.linkedin.com/in/abdelrahman-shahin-965b27305)

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.