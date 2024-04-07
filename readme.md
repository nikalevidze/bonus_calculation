# Bonus Calculation SQL Script

This SQL script is designed to calculate bonuses for employees based on various criteria including Quality, Total Hours, Productivity, False Escalations, Requalification, and Tenure. It utilizes two tables: `cs_bonus_march` and `cs_productivity_march_new`. Below is a breakdown of the script:

## Criteria:

1. **Quality**: Evaluation scores.
2. **Total Hours**: Actual hours worked plus vacation and sick leave hours.
3. **Productivity**: Tickets processed per hour.
4. **False Escalations**: Percentage of incorrectly escalated tickets vs total escalated tickets.
5. **Requalification**: Score of an agent in the quarterly re-qualification test.
6. **Tenure**: Number of months spent on the current position.

## Tables:

- `cs_bonus_march`: Contains information on most criteria.
- `cs_productivity_march_new`: Contains productivity data needed for bonus calculation.

## SQL Code Explanation:

1. **Quality Calculation**: Extracts and formats quality scores.
2. **Total Hours Calculation**: Sums up actual hours worked and vacation/sick leave hours.
3. **False Escalations Calculation**: Extracts and formats false escalation percentages.
4. **Requalification**: Retains requalification scores as is.
5. **Tenure Calculation**: Calculates the difference in months between start date and bonus submission date.
6. **Productivity Calculation**: Calculates tickets per hour for each shift and determines if an agent's productivity qualifies.
7. **Bonus Calculation**: Applies bonus criteria based on specified thresholds for 10%, 20%, and 30% bonuses.

## Bonus Criteria:

### Bonus for 10%:
- Quality >= 87
- Total Hours >= 120
- Productivity = Yes
- False Escalations <= 7
- Requalification >= 80
- Tenure >= 3 Months

### Bonus for 20%:
- Quality >= 93
- Total Hours >= 136
- Productivity = Yes
- False Escalations <= 5
- Requalification >= 80
- Tenure >= 6 Months

### Bonus for 30%:
- Quality >= 95
- Total Hours >= 136
- Productivity = Yes
- False Escalations <= 3
- Requalification >= 80
- Tenure >= 9 Months

## Usage:

Execute the provided SQL script against the relevant databases containing `cs_bonus_march` and `cs_productivity_march_new` tables to calculate bonuses for employees.
