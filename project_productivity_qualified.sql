SELECT full_name, Shift, GPIs, RISKs, Subs, Round((GPIs + Risks + Subs/2), 0) AS total_tickets,
total_hours,
ROUND(total_tickets/total_hours, 2) AS tickets_per_hour,
AVG(total_tickets/total_hours) Over(partition by Shift) AS shift_average,
CASE
	WHEN total_tickets/total_hours >= AVG(total_tickets/total_hours) Over(partition by Shift) THEN 'Yes'
    ELSE 'No'
END AS 'Qualified'
FROM cs_productivity_march_new;


