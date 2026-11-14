-- #1 
INSERT INTO clients (full_name, deposit_balance, level)
VALUES ('Ivan Ivanov', 0.00, 0);

INSERT INTO seats (number, hall_id, pc_id, status)
VALUES (10, 4, 6, 'available');

INSERT INTO seats (number, hall_id, pc_id, status)
VALUES (11, 5, 2, 'occupied');

INSERT INTO tariffs (name, price)
VALUES ('Weekend hourly', 70.00);

INSERT INTO sessions (start_time, seat_id, tariff_id, client_id) 
VALUES ('2026-11-10 10:00:00', 3, 1, 1);

INSERT INTO sessions (start_time, end_time, status, seat_id, tariff_id, client_id) 
VALUES ('2026-11-10 10:00:00', '2026-11-10 12:00:00', 'finished', 3, 1, 1);

INSERT INTO sessions (start_time, end_time, status, seat_id, tariff_id, client_id)
VALUES ('2026-10-13 18:00:00', '2026-10-13 18:00:00', 'cancelled', 1, 3, 2);


-- #2 
SELECT halls.name, seats.pc_id, seats.id  FROM seats 
INNER JOIN halls ON seats.hall_id = halls.id
WHERE seats.status != 'maintenance' and  halls.name='VIP' 
and seats.id not in(select seat_id from sessions  where sessions.status='active')
AND seats.id NOT IN (
    SELECT seat_id FROM reservations 
    WHERE '2026-11-09 18:30:00' BETWEEN start_time AND end_time
  );


-- #3
UPDATE clients 
SET deposit_balance = deposit_balance + 100.00
WHERE id = 1;



SELECT id, start_time, end_time, client_id FROM sessions
WHERE status='finished';

UPDATE clients
INNER JOIN sessions ON clients.id = sessions.client_id
INNER JOIN seats ON sessions.seat_id = seats.id
INNER JOIN halls ON seats.hall_id = halls.id
INNER JOIN tariffs ON sessions.tariff_id = tariffs.id
SET clients.deposit_balance = clients.deposit_balance - (
    TIMESTAMPDIFF(HOUR, sessions.start_time, sessions.end_time) * tariffs.price * halls.price_coefficient
)
where sessions.id=4;


-- #4

SELECT 
sessions.id, 
sessions.start_time, 
sessions.end_time, 
halls.name AS hall_name, 
tariffs.name AS tariff_name,
clients.full_name AS client, 
(TIMESTAMPDIFF(HOUR, sessions.start_time, sessions.end_time) * tariffs.price * halls.price_coefficient) AS time_cost
FROM sessions
INNER JOIN seats ON sessions.seat_id = seats.id
INNER JOIN halls ON seats.hall_id = halls.id
INNER JOIN tariffs ON sessions.tariff_id = tariffs.id
INNER JOIN clients ON sessions.client_id = clients.id
WHERE sessions.status = 'finished' and sessions.client_id=4;



-- #5
SELECT 
    h.name AS hall_name,
    CASE 
        WHEN COUNT(CASE WHEN s.status = 'available' AND s.id NOT IN (SELECT seat_id FROM sessions WHERE status = 'active') THEN 1 END) = 0 
        THEN 'Повна посадка'
        ELSE 'Є вільні місця'
    END AS capacity_status
FROM halls h
LEFT JOIN seats s ON h.id = s.hall_id
WHERE h.name = 'VIP'
GROUP BY h.id, h.name;
