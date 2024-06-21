SELECT e.edu_level, COUNT(*) AS members
FROM education e
JOIN (
    SELECT a.email
    FROM advertisement a
    JOIN job_offer j ON a.advertisement_id = j.advertisement_id
    WHERE a.date_posted >= CURRENT_DATE - INTERVAL '6 months'
      AND j.from_age > 21
      AND j.from_age < 30
    GROUP BY a.email
    HAVING COUNT(j.advertisement_id) >= 2
) ads ON e.email = ads.email
JOIN msg msg ON e.email = msg.receiver_email
WHERE e.country = 'Canada'
AND msg.date_sent >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY e.edu_level
