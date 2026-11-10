-- #1 ДОДАВАННЯ ТА МОДИФІКАЦІЯ ДАНИХ (INSERT)

-- додавання нового клієнта (з базовим нульовим балансом та рівнем лояльності)
INSERT INTO clients (full_name, deposit_balance, level)
VALUES ('Іванов І.І.', 0.00, 0);

-- робочого місця (звичайне додавання в зал Standard)
INSERT INTO seats (number, hall_id, pc_id, status)
VALUES (101, 1, 1, 'available');

-- робочого місця (додавання із явним статусом occupied в VIP зал)
INSERT INTO seats (number, hall_id, pc_id, status)
VALUES (201, 2, 3, 'occupied');

-- тарифу
INSERT INTO tariffs (name, price)
VALUES ('погодинний', 200.00);

-- відкриття нової сесії (активна сесія на поточний момент, замовчування полів)
INSERT INTO sessions (start_time, end_time, status, seat_id, tariff_id, client_id) 
VALUES (NOW(), NULL, 'active', 3, 1, 1);

-- фіксація завершеної сесії (замість 'completed' використовується статус 'finished')
INSERT INTO sessions (start_time, end_time, status, seat_id, tariff_id, client_id) 
VALUES ('2026-11-10 10:00:00', '2026-11-10 12:00:00', 'finished', 3, 1, 1);

-- скасована сесія
INSERT INTO sessions (start_time, end_time, status, seat_id, tariff_id, client_id)
VALUES (NOW(), NOW(), 'cancelled', 1, 3, 2);


-- #2 ПОШУК ВІЛЬНИХ ПК У ВИБРАНІЙ ЗОНІ ЗАЛУ НА ПЕВНИЙ МОМЕНТ
-- Назва залу адаптована під структуру ('VIP' замість 'VIP Zone')
-- Додатково перевіряється, щоб на ПК не було активної сесії

SELECT seats.id, seats.number, halls.name 
FROM seats 
INNER JOIN halls ON seats.hall_id = halls.id
WHERE halls.name = 'VIP' 
  AND seats.status = 'available' 
  AND seats.id NOT IN (
      SELECT seat_id 
      FROM sessions 
      WHERE status = 'active'
  );


-- #3 ПОПОВНЕННЯ БАЛАНСУ КЛІЄНТА ТА СПИСАННЯ КОШТІВ

-- Поповнення балансу клієнта
UPDATE clients 
SET deposit_balance = deposit_balance + 100.00
WHERE id = 1;

-- Списання коштів за проведену сесію (на прикладі завершеної сесії id=4)
-- Вираховує фінальну вартість часу з коефіцієнтом та товари, і знімає з балансу клієнта
UPDATE clients c
SET c.deposit_balance = c.deposit_balance - (
    SELECT 
        (t.price * COALESCE(h.price_coefficient, 1.0) * 
         CEIL(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time) / 60.0)) + 
        COALESCE(SUM(o.total_price), 0)
    FROM sessions s
    JOIN tariffs t ON s.tariff_id = t.id
    JOIN seats st ON s.seat_id = st.id
    JOIN halls h ON st.hall_id = h.id
    LEFT JOIN orders o ON s.id = o.session_id
    WHERE s.id = 4 AND s.client_id = c.id
    GROUP BY s.id, t.price, h.price_coefficient, s.start_time, s.end_time
)
WHERE c.id = (SELECT client_id FROM sessions WHERE id = 4);


-- #4 ІСТОРІЯ СЕСІЙ КОНКРЕТНОГО КОРИСТУВАЧА ІЗ СУМАРНИМИ ВИТРАТАМИ
-- Розрахунок вартості часу «на льоту»: базова ставка * коефіцієнт залу
-- Загальна вартість сесії вираховується як: total = вартість часу + бар

SELECT 
    s.id AS session_id,
    s.start_time,
    s.end_time,
    s.status,
    st.number AS seat_number,
    h.name AS hall_name,
    t.name AS tariff_name,
    -- Вартість ігрового часу (округлення до годин вгору для прикладу розрахунку)
    (t.price * h.price_coefficient * CEIL(TIMESTAMPDIFF(MINUTE, s.start_time, COALESCE(s.end_time, NOW())) / 60.0)) AS time_cost,
    -- Вартість замовлень з бару
    COALESCE(SUM(o.total_price), 0) AS bar_cost,
    -- Загальна вартість (total)
    ((t.price * h.price_coefficient * CEIL(TIMESTAMPDIFF(MINUTE, s.start_time, COALESCE(s.end_time, NOW())) / 60.0)) + COALESCE(SUM(o.total_price), 0)) AS total_session_cost
FROM sessions s
JOIN tariffs t ON s.tariff_id = t.id
JOIN seats st ON s.seat_id = st.id
JOIN halls h ON st.hall_id = h.id
LEFT JOIN orders o ON s.id = o.session_id
WHERE s.client_id = 4 -- приклад для клієнта з id=4 (Dmytro Bondarenko)
GROUP BY s.id, s.start_time, s.end_time, s.status, st.number, h.name, t.name, t.price, h.price_coefficient;


-- #5 АНАЛІТИЧНИЙ ЗАПИТ: ПЕРЕВІРКА НА "ПОВНУ ПОСАДКУ"
-- Повертає 'Повна посадка', якщо вільних місць у залі немає, і 'Є вільні місця', якщо вони є.
-- Оцінюється аналітично на стороні СКБД, а не коду.

SELECT 
    h.name AS hall_name,
    CASE 
        WHEN COUNT(CASE WHEN s.status = 'available' AND s.id NOT IN (SELECT seat_id FROM sessions WHERE status = 'active') THEN 1 END) = 0 
        THEN 'Повна посадка'
        ELSE 'Є вільні місця'
    END AS capacity_status
FROM halls h
LEFT JOIN seats s ON h.id = s.hall_id
WHERE h.name = 'VIP' -- приклад перевірки для VIP залу
GROUP BY h.id, h.name;
