# COVID-19 Data Analysis

## Project Overview
This project aims to analyze COVID-19 data using SQL queries. The analysis focuses on understanding the spread and impact of the virus across different continents and countries. The primary goal is to derive insights into infection rates, death rates, and vaccination progress, which can inform public health strategies and policy decisions.

## Libraries and Tools Used
- SQL: Structured Query Language was used for querying and manipulating the data stored in relational databases.

## Steps Performed

### Data Loading and Initial Exploration
- Query: Selected all records from the CovidDeaths table where the continent is not null, ensuring the data is relevant for analysis.
- Purpose: This step provided a foundational understanding of the dataset's structure and content.
  
### Total Cases vs Total Deaths
- Query: Calculated the death percentage by dividing total deaths by total cases for each location and date.
- Insight: This analysis revealed the likelihood of dying if infected with COVID-19, highlighting regions with higher mortality rates.
  
### Total Cases vs Population
- Query: Calculated the percentage of the population infected by dividing total cases by the population for each location and date.
- Insight: This step provided a clear picture of the virus's penetration in different regions, identifying areas with higher infection rates.

### Highest Infection Rate by Country
- Query: Identified countries with the highest infection rates relative to their population by calculating and ranking the percentage of the population infected.
- Insight: This analysis pinpointed countries that were most affected by the virus, offering critical information for targeted interventions.

### Analysis by Continent
- Query: Aggregated total death counts by continent to show which continents had the highest death tolls.
- Insight: This broader view highlighted the continents most impacted by the pandemic, guiding global health responses.

### Global Numbers

#### Daily Aggregation:
- Query: Summed new cases and new deaths by date, calculating the daily death percentage.
- Insight: This provided a daily snapshot of the pandemic's progression, useful for tracking trends over time.

#### Overall Aggregation:
- Query: Summed new cases and new deaths across all dates to calculate the overall death percentage.
- Insight: This comprehensive summary offered a global perspective on the pandemic's impact.

### Population vs Vaccinations
- Query: Joined the CovidDeaths and CovidVaccinations tables to analyze the relationship between total population and vaccinations.
- Insight: This analysis revealed vaccination progress across different locations, essential for understanding the effectiveness of vaccination campaigns.

### Common Table Expressions (CTE)
- Query: Used a CTE to calculate the rolling number of people vaccinated over time for each location.
- Insight: This dynamic analysis provided insights into vaccination trends, helping to identify regions with accelerating or lagging vaccination rates.

### Temporary Tables
- Query: Created a temporary table to store the percentage of the population vaccinated.
- Insight: This facilitated further analysis and visualization, making it easier to access and manipulate the data.

### Creating Views
- Query: Created a view to store data on the percentage of the population vaccinated for later visualization.
- Insight: This ensured easy access to vaccination data for future analyses, streamlining the process of generating insights.

### Data Sources
The data was sourced from the CovidDeaths and CovidVaccinations tables, which contain comprehensive information on COVID-19 cases, deaths, and vaccinations across different locations and dates.

## Conclusion
This analysis provides valuable insights into the spread and impact of COVID-19, highlighting critical areas for intervention and policy-making. By understanding infection rates, death rates, and vaccination progress, public health officials can make informed decisions to mitigate the effects of the pandemic and protect public health.
