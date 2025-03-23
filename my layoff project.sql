-- Removing the duplicates

select *
from layoffs;

CREATE TABLE `layoffs_copy` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert layoffs_copy
select *
from layoffs;

select *
from layoffs_copy;

select *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) number_rows
from layoffs_copy;

with duplicate_cte as
(
select *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) number_rows
from layoffs_copy
)
select *
from duplicate_cte
where number_rows>1;

CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `number_rows` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert layoffs_copy2
select *,
row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) number_rows
from layoffs_copy;

select *
from layoffs_copy2
where number_rows>1;

delete
from layoffs_copy2
where number_rows>1;

select *
from layoffs_copy2;

-- standardizing the data and removing blanks

select distinct company, trim(company)
from layoffs_copy2
order by 1;

update layoffs_copy2
set company = trim(company);

select distinct industry
from layoffs_copy2
order by 1;

select *
from layoffs_copy2
where industry like 'crypto%'
order by 1;

update layoffs_copy2
set industry = 'crypto'
where industry like 'crypto%';

select distinct country
from layoffs_copy2
order by 1;

select distinct country, trim(trailing '.' from country)
from layoffs_copy2
order by 1;

update layoffs_copy2
set country = trim(trailing '.' from country);

select distinct `date`
from layoffs_copy2
order by 1;

select distinct `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_copy2
order by 1;

update layoffs_copy2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select *
from layoffs_copy2
order by 1;

-- REMOVING THE BLANKS

select *
from layoffs_copy2
where industry='';

select *
from layoffs_copy2
where company = 'airbnb';

update layoffs_copy2
set industry = null
where industry ='';

select *
from layoffs_copy2 T1
join layoffs_copy2 T2
	on T1.company=T2.company
where T1.industry is null
and T2.industry is not null;

update layoffs_copy2 T1
join layoffs_copy2 T2
	on T1.company=T2.company
set T1.industry=T2.industry
where T1.industry is null
and T2.industry is not null;

select *
from layoffs_copy2
where company = 'airbnb';

select *
from layoffs_copy2 
order by 1;

select *
from layoffs_copy2
where total_laid_off is null and percentage_laid_off is null;

delete
from layoffs_copy2
where total_laid_off is null and percentage_laid_off is null;

select *
from layoffs_copy2 
order by 1;

-- NOW WE ARE DONE WITH DATA CLEANING, WE DELETE THE COLUMN THAT'S NOT ADDED (FROM THE RAW DATA)

alter table layoffs_copy2
drop column number_rows;

-- NOW WE CHANGE THE DATE(TEXT FORMAT) TO DATE (DATE FORMAT)

alter table layoffs_copy2
modify column `date` date;

select *
from layoffs_copy2;


-- exploratory to the data by looking at total_laid_off from each column using mostly the max,min and sum

select company, max(total_laid_off), min(total_laid_off), sum(total_laid_off)
from layoffs_copy2
where industry is not null
group by company
order by 1;

select industry, max(total_laid_off), min(total_laid_off), sum(total_laid_off)
from layoffs_copy2
where industry is not null
group by industry
order by 1;

select location, max(total_laid_off), min(total_laid_off), sum(total_laid_off)
from layoffs_copy2
where location is not null
group by location
order by 1;

select percentage_laid_off, max(total_laid_off), min(total_laid_off), sum(total_laid_off)
from layoffs_copy2
group by percentage_laid_off
order by 1;

-- now we look at the date by year and also by month-year

select year(`date`), max(total_laid_off), min(total_laid_off), sum(total_laid_off)
from layoffs_copy2
where year(`date`) is not null
group by year(`date`)
order by year(`date`);

select `date`, max(total_laid_off), min(total_laid_off), sum(total_laid_off)
from layoffs_copy2
where `date` is not null
group by `date`
order by `date`;

select substring(`date`, 1,7) as `yy/mm`, max(total_laid_off), min(total_laid_off), sum(total_laid_off) as total_sentoff
from layoffs_copy2
where substring(`date`, 1,7) is not null
group by `yy/mm`
order by 1;

-- we can also calculate the rolling total for the sum(total_laid_off) only by using the date(year/month)

select substring(`date`, 1,7) as `yy/mm`,  sum(total_laid_off) as total_sentoff
from layoffs_copy2
where substring(`date`, 1,7) is not null
group by `yy/mm`
order by 1;

With Rolling_Total as
(select substring(`date`, 1,7) as `yy/mm`,  sum(total_laid_off) as total_sentoff
from layoffs_copy2
where substring(`date`, 1,7) is not null
group by `yy/mm`
order by 1)
select `yy/mm`,total_sentoff, sum(total_sentoff) over (order by `yy/mm`) as rolling_total
from Rolling_Total;



