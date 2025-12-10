USE fleet_management;

DROP TABLE IF EXISTS fleet_combined;
DROP TABLE IF EXISTS service_reminders;
DROP TABLE IF EXISTS predicted_service_due;

SELECT 
    service_status,
    COUNT(*) AS unit_count
FROM service_reminders_clean
GROUP BY service_status
ORDER BY 
    CASE service_status
        WHEN 'Overdue' THEN 1
        WHEN 'Due Soon' THEN 2
        WHEN 'OK' THEN 3
    END;
    
SELECT
    u.unit_number,
    u.unit_type,
    u.year,
    s.service_type,
    s.service_status
FROM service_reminders_clean s
JOIN units_medium_improved u
    ON u.unit_id = s.unit_id
ORDER BY u.unit_number;


SELECT
    u.unit_number,
    u.unit_type,
    p.predicted_due_date,
    p.km_projected_at_due,
    p.risk_level,
    s.service_status
FROM predicted_service_due_clean p
JOIN units_medium_improved u
    ON u.unit_id = p.unit_id
JOIN service_reminders_clean s
    ON s.unit_id = u.unit_id
ORDER BY p.predicted_due_date ASC;

SELECT
    u.unit_number,
    s.service_status,
    p.predicted_due_date,
    CASE 
        WHEN s.service_status = 'Overdue' THEN 1
        WHEN s.service_status = 'Due Soon' THEN 2
        ELSE 3
    END AS priority_rank
FROM service_reminders_clean s
JOIN predicted_service_due_clean p
    ON s.unit_id = p.unit_id
JOIN units_medium_improved u
    ON u.unit_id = p.unit_id
ORDER BY priority_rank ASC, p.predicted_due_date ASC;

ALTER TABLE service_reminders_clean
ADD COLUMN last_service_date DATE,
ADD COLUMN next_due_date DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE service_reminders_clean
SET 
    last_service_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(380 + RAND()*120) DAY),
    next_due_date = DATE_ADD(last_service_date, INTERVAL 365 DAY)
WHERE service_status = 'Overdue';

UPDATE service_reminders_clean
SET 
    last_service_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(330 + RAND()*30) DAY),
    next_due_date = DATE_ADD(last_service_date, INTERVAL 365 DAY)
WHERE service_status = 'Due Soon';

UPDATE service_reminders_clean
SET 
    last_service_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(200 + RAND()*130) DAY),
    next_due_date = DATE_ADD(last_service_date, INTERVAL 365 DAY)
WHERE service_status = 'OK';

SET SQL_SAFE_UPDATES = 1;

SELECT unit_id, unit_number, service_status, last_service_date, next_due_date
FROM service_reminders_clean
ORDER BY next_due_date;







