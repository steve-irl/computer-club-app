--#1
--додавання нового клієнта
INSERT INTO clients (full_name)
VALUES ('Іванов І.І.');

--робочого місця
INSERT INTO seats (number, hall_id, pc_id)
VALUES (101, 1, 1);

INSERT INTO seats (number, hall_id, pc_id, status)
VALUES (201, 2, 3, 'occupied');

--тарифу
INSERT INTO tariffs (name, price)
VALUES ('погодинний', 200.0);

--відкриття нової сесії
INSERT INTO sessions (seat_id, tariff_id, client_id) 
VALUES (3, 1, 1);

INSERT INTO sessions (start_time, end_time, status, seat_id, tariff_id, client_id) 
VALUES ('2026-11-10 10:00:00', '2026-11-10 12:00:00', 'completed', 3, 1, 1);

INSERT INTO sessions (status, seat_id, tariff_id, client_id)
VALUES ('cancelled', 1, 3, 2);

--#2
--пошуку вільних ПК у вибраній зоні залу на певний момент 
SELECT seats.id, seats.number, halls.name FROM seats 
INNER JOIN halls ON seats.hall_id = halls.id
WHERE  halls.name='VIP Zone' and seats.status = 'available' and seats.id not in(SELECT seat_id FROM sessions WHERE status = 'active')


--№3
--поповнення балансу клієнта 
UPDATE clients SET deposit_balance = deposit_balance+100.0
WHERE id=1;
