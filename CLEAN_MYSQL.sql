SELECT * FROM wold_layoff.layoffs;

create TABLE Layoffs_staging
like layoffs;

select * from Layoffs_staging;

insert Layoffs_staging 
select * from layoffs;

-- 1. Remove duplicates 
# check duplicates 

select *, 
row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from Layoffs_staging;

select *
from 
	(select *, 
	row_number() over(partition by company, location, industry, total_laid_off, 
	percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from Layoffs_staging) duplicates 	
where row_num >1;

select *
from layoffs_staging
where company = 'Casper';

-- delete doplicates
select * from Layoffs_staging;
alter table layoffs_staging add row_num int;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
select company,
       location,
       industry,
       total_laid_off,
       percentage_laid_off,
       `date`,
       stage,
       country,
       funds_raised_millions, 
row_number() over(
partition by company, location, industry, total_laid_off, 
	percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete 
from layoffs_staging2 
where row_num >= 2;

select * 
from layoffs_staging2 
where row_num >= 2;


-----------------------------------------------------------------
-- 2. standizing data 

 select * 
from layoffs_staging2 ;

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company =  trim(company);

-- look for blank 
select distinct industry 
from layoffs_staging2
order by industry;

select industry 
from layoffs_staging2
where industry is null
or industry = ''
order by industry;

-- set the blank to null

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 lay1
join layoffs_staging2 lay2 
	on lay1.company = lay2.company
set lay1.industry = lay2.industry
where lay1.industry is null
and lay2.industry is not null;


select * 
from layoffs_staging2
where industry is null
or industry = ''
order by industry;

--------------
select * 
from layoffs_staging2 ;

select distinct industry
from layoffs_staging2 
order by 1;

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

---------------------
select * from layoffs_staging2;

select distinct country 
from layoffs_staging2 
order by 1;

select distinct country , trim(trailing '.' from country)
from layoffs_staging2 
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country );

------------------------------------------
-- fix the date columns
select distinct `date`
from layoffs_staging2;

select `date` ,STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2;


update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

alter table layoffs_staging2 modify `date` date;

----------------------------------------------------

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

alter table layoffs_staging2
drop column row_num;

SELECT *
FROM layoffs_staging2;

delete from layoffs_staging2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- EDA
-- LOOK AT THE PERCENTAGE TO SEE HOW BIG THESE LAYOFFS WERE

select * 
from layoffs_staging2 ;

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM wold_layoff.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- These are mostly startups it looks like who all went out of business during this time
select *
FROM wold_layoff.layoffs_staging2 
where percentage_laid_off = 1
order by funds_raised_millions desc;

select *
FROM wold_layoff.layoffs_staging2 
where percentage_laid_off = 1
order by total_laid_off desc;

-- companies with the biggest laid off

select * 
from layoffs_staging2 ;

select company, total_laid_off
from wold_layoff.layoffs_staging2 
order by 2 desc
limit 10;


select company, sum(total_laid_off)
from wold_layoff.layoffs_staging2 
group by company
order by 2 desc
limit 10;

select location, sum(total_laid_off)
from wold_layoff.layoffs_staging2 
group by location
order by 2 desc
limit 10;

select year(date), sum(total_laid_off)
from wold_layoff.layoffs_staging2
group by year(date)
order by 2 desc;

-----------------
select * 
from layoffs_staging2 ;

select *
from layoffs_staging2 
where date is null;

with rolling_total as (
select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as tatal_laid_off 
from  layoffs_staging2
group by substring(`date`,1,7)
order by 1,2 asc
)
select `MONTH`, tatal_laid_off 
from rolling_total
where `MONTH` is not null;


with Company_Year as (
 SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
  )
  ,comparny_total_rank as (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year)
  select *
  from comparny_total_rank
  where ranking <= 3 and years is not null
  ORDER BY years ASC, total_laid_off DESC;
  