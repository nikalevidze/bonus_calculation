The job is to calculate bonus for employees based on different criteria.

**Criteria:** 
	Quality - Evaluation scores
        Total Hours - Actual hours worked + vacation and sick leave hours
        Productivity - Tickets processed per hour
        False Escalations - Percentage of incorrectly escalated tickets vs total escalated tickets
        Requalification - Score of an agent in the quarterly re-qualification test
        Tenure - Number of months spent on the current position

We have 2 tables to work with: _cs_productivity_march_new_ which contains information on Productivity and _cs_bonus_march_ which contains everything else that we need.
The criteria listed above are not readily present in our tables, therefore, we need to do some calculations for some of them. Let's break each of them down.

**Quality**
The evaluation score present in the table is formatted as a string with the % sign at the end (e.g. '95%'). For calculations we're going to need an integer or float, therefore, we'll drop the % sign and format the result as Double.

_SELECT CAST(LEFT(quality, char_length(quality) -1) AS double) AS quality_formatted
FROM cs_bonus_march;
_

**Total Hours**
Both, worked_hours and vacation_sick_leave have correct formatting, therefore, we're just going to sum them up

_SELECT worked_hours + vacation_sick_leave AS total_hours
FROM cs_bonus_march;_

**False Escalations**
With false escalations we're facing the same issue as with Quality. Therefore, we'll drop the % sign and format the result as Double.

_SELECT false_escalations, CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) AS false_escalations_formatted
FROM cs_bonus_march;
_
**Requalification**
Requalification score is formatted as we need it, therefore, we won't manipulate it.

**Tenure**
To calculate the tenure we're going to need to calculate the difference between the start_date_formatted and bonus_submission_date_formatted. 
To do this, first we need to format these as date values (DATETIME) and then determine the difference (in months) between these dates.

_SELECT  cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME),
timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) AS tenure_months
FROM    cs_bonus_march;
_

**Productivity**
Productivity is something that we need to determin using data from the second table, _cs_productivity_march_new_. The key metric that we're looking for is Tickets Per Hour which is Total Tickets divided by Total Hours. However, we're going to need the Tickets Per Hour metric for each shift, to account for different workload demands for each shift. Let's first calculate the Total Tickets. The formula for this is _GPIs + Risks + Subs/2._

_SELECT full_name, GPIs, RISKs, Subs, Round((GPIs + Risks + Subs/2), 0) AS total_tickets
FROM  cs_productivity_march_new;
_
**Let's now divide the Total Tickets by Total Hours**

_SELECT full_name, Shift, GPIs, RISKs, Subs, Round((GPIs + Risks + Subs/2), 0) AS total_tickets,
total_hours,
ROUND(total_tickets/total_hours, 2) AS tickets_per_hour
FROM cs_productivity_march_new;
_
Let's now calculate the Tickets Per Hour for each shift. For this we're going to need Window functions.
While we're at it let's also compare each agent's Tickets Per Hour metric with the shift average, and if their individual metric equals or is greater than the shift average, it means they have qualified.

_SELECT full_name, Shift, GPIs, RISKs, Subs, Round((GPIs + Risks + Subs/2), 0) AS total_tickets,
total_hours,
ROUND(total_tickets/total_hours, 2) AS tickets_per_hour,
AVG(total_tickets/total_hours) Over(partition by Shift) AS shift_average,
CASE
	WHEN total_tickets/total_hours >= AVG(total_tickets/total_hours) Over(partition by Shift) THEN 'Yes'
    ELSE 'No'
END AS 'Qualified'
FROM cs_productivity_march_new;
_

We'll need to join the newly-calculated table above with the cs_bonus_march table to include "Qualified" column into the whole table.


Let's bring it all together and add the below criteria for 30%, 20% and 10% bonuses. 
We'll join ON _cs_bonus_march.agent = new_table.full_name_.
The bonus criteria below will be represented in the code as follows:

_WHEN (CAST(LEFT(quality, char_length(quality) -1) AS double) >= 95 AND CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) <= 3 AND requalification >= 80 AND timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) >= 9 AND qualified = 'Yes' ) THEN '30%'

WHEN (CAST(LEFT(quality, char_length(quality) -1) AS double) >= 93 AND CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) <= 5 AND requalification >= 80 AND timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) >= 6 AND qualified = 'Yes' ) THEN '20%'

WHEN (CAST(LEFT(quality, char_length(quality) -1) AS double) >= 87 AND CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) <= 7 AND requalification >= 80 AND timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) >= 3 AND qualified = 'Yes' ) THEN '10%'_

**Bonus Criteria:**

**Bonus for 10%
**
Quality >= 87
Total Hours >= 120
Productivity = Yes
False Escalations  <= 7
Requalification >= 80
Tenure >= 3 Months

**Bonus for 20%
**
Quality >= 93
Total Hours >= 136
Productivity = Yes
False Escalations  <= 5
Requalification >= 80
Tenure >= 6 Months

**Bonus for 30%
**
Quality >= 95
Total Hours >= 136
Productivity = Yes
False Escalations  <= 3
Requalification >= 80
Tenure >= 9 Months


_SELECT Agent, cast(start_date_formatted AS DATETIME) AS employee_start, cast(bonus_submission_date_formatted AS DATETIME) AS submission_date, 
	CAST(LEFT(quality, char_length(quality) -1) AS double) AS quality_formatted,
    worked_hours + vacation_sick_leave AS total_hours,
    requalification,
CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) AS false_escalations_formatted,
new_table.qualified,
timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) AS tenure_months,
CASE
	    WHEN (CAST(LEFT(quality, char_length(quality) -1) AS double) >= 95 AND CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) <= 3 AND requalification >= 80 AND timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) >= 9 AND qualified = 'Yes' ) THEN '30%'
        WHEN (CAST(LEFT(quality, char_length(quality) -1) AS double) >= 93 AND CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) <= 5 AND requalification >= 80 AND timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) >= 6 AND qualified = 'Yes' ) THEN '20%'
        WHEN (CAST(LEFT(quality, char_length(quality) -1) AS double) >= 87 AND CAST(LEFT(false_escalations, char_length(false_escalations) -1) AS Double) <= 7 AND requalification >= 80 AND timestampdiff(MONTH, cast(start_date_formatted AS DATETIME), cast(bonus_submission_date_formatted AS DATETIME)) >= 3 AND qualified = 'Yes' ) THEN '10%'
	ELSE 0
END 'Bonus'
FROM cs_bonus_march
JOIN (SELECT full_name, Shift, GPIs, RISKs, Subs, Round((GPIs + Risks + Subs/2), 0) AS total_tickets,
total_hours,
ROUND(total_tickets/total_hours, 2) AS tickets_per_hour,
AVG(total_tickets/total_hours) Over(partition by Shift) AS shift_average,
CASE
	WHEN total_tickets/total_hours >= AVG(total_tickets/total_hours) Over(partition by Shift) THEN 'Yes'
    ELSE 'No'
END AS 'qualified'
FROM cs_productivity_march_new) AS new_table
	ON cs_bonus_march.agent = new_table.full_name
ORDER BY Bonus DESC
;_
