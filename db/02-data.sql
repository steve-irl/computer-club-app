SET NAMES utf8mb4;

-- 1. halls (price_coefficient: Standard=1.0, VIP=1.3 as in the task)
INSERT INTO halls (id, name, price_coefficient) VALUES
(1, 'Standard', 1.0),
(2, 'VIP', 1.3),
(3, 'Boot-camp', 1.1),
(4, 'Simulators', 1.5),
(5, 'Console', 1.2);

-- 2. pc_specs
INSERT INTO pc_specs (id, cpu, gpu, ram_gb, storage) VALUES
(1, 'Intel i3-12100F', 'GTX 1650', 16, '512GB SSD'),
(2, 'Intel i5-12400F', 'RTX 3060', 16, '1TB SSD'),
(3, 'Intel i5-13400F', 'RTX 4060', 32, '1TB SSD'),
(4, 'Intel i7-13700K', 'RTX 4070', 32, '2TB SSD'),
(5, 'Ryzen 5 5600', 'RTX 3050', 16, '512GB SSD'),
(6, 'Ryzen 7 7800X3D', 'RTX 4080', 64, '2TB SSD');

-- 3. tariffs (price = base hourly rate or fixed package price)
INSERT INTO tariffs (id, name, price) VALUES
(1, 'Hourly', 60.00),
(2, 'Night package', 250.00),
(3, '3 hours package', 150.00),
(4, 'Morning', 40.00);

-- 4. clients
INSERT INTO clients (id, full_name, deposit_balance, level) VALUES
(1, 'Ivan Petrenko', 350.00, 2),
(2, 'Oleksandr Kovalenko', 120.50, 1),
(3, 'Maria Shevchenko', 0.00, 0),
(4, 'Dmytro Bondarenko', 780.00, 4),
(5, 'Anna Melnyk', 45.00, 1),
(6, 'Andrii Tkachenko', 1500.00, 5),
(7, 'Sofia Kravchenko', 220.00, 3),
(8, 'Yurii Savchenko', 90.00, 0);

-- 5. products
INSERT INTO products (id, name, category, price, stock_quantity) VALUES
(1, 'Cola 0.5L', 'Drinks', 35.00, 50),
(2, 'Energy drink', 'Drinks', 55.00, 40),
(3, 'Water 0.5L', 'Drinks', 20.00, 80),
(4, 'Chips', 'Snacks', 45.00, 30),
(5, 'Sandwich', 'Snacks', 70.00, 15),
(6, 'Chocolate bar', 'Snacks', 30.00, 60),
(7, 'Pizza slice', 'Food', 65.00, 20),
(8, 'Coffee', 'Drinks', 40.00, 100);

-- 6. seats (status: available / occupied / reserved / maintenance)
INSERT INTO seats (id, number, hall_id, pc_id, status) VALUES
(1, 1, 1, 1, 'available'),
(2, 2, 1, 1, 'occupied'),
(3, 3, 1, 5, 'reserved'),
(4, 4, 1, 2, 'maintenance'),
(5, 5, 2, 4, 'occupied'),
(6, 6, 2, 4, 'available'),
(7, 7, 2, 6, 'reserved'),
(8, 8, 3, 3, 'available'),
(9, 9, 3, 3, 'occupied');

-- 7. sessions (3 active ones match the 'occupied' seats 2, 5, 9)
INSERT INTO sessions (id, start_time, end_time, status, seat_id, tariff_id, client_id) VALUES
(1, '2026-11-09 10:00:00', NULL, 'active', 2, 1, 1),
(2, '2026-11-09 11:30:00', NULL, 'active', 5, 3, 4),
(3, '2026-11-09 12:00:00', NULL, 'active', 9, 1, 7),
(4, '2026-11-08 20:00:00', '2026-11-08 23:00:00', 'finished', 1, 1, 2),
(5, '2026-11-08 22:00:00', '2026-11-09 06:00:00', 'finished', 6, 2, 6),
(6, '2026-11-08 09:00:00', '2026-11-08 12:00:00', 'finished', 8, 4, 5),
(7, '2026-11-07 15:00:00', '2026-11-07 18:00:00', 'finished', 10, 3, 4),
(8, '2026-11-07 19:00:00', '2026-11-07 21:30:00', 'finished', 1, 5, 8),
(9, '2026-11-06 18:00:00', '2026-11-06 20:00:00', 'finished', 3, 1, 1);

-- 8. reservations
INSERT INTO reservations (id, client_id, seat_id, start_time, end_time, date) VALUES
(1, 3, 3, '2026-11-09 18:00:00', '2026-11-09 20:00:00', '2026-11-09'),
(2, 6, 7, '2026-11-09 19:00:00', '2026-11-09 22:00:00', '2026-11-09'),
(3, 2, 3, '2026-11-10 16:00:00', '2026-11-10 18:00:00', '2026-11-10'),
(4, 5, 6, '2026-11-10 14:00:00', '2026-11-10 16:00:00', '2026-11-10'),
(5, 8, 8, '2026-11-11 20:00:00', '2026-11-11 23:00:00', '2026-11-11'),
(6, 1, 10, '2026-11-12 17:00:00', '2026-11-12 19:00:00', '2026-11-12');

-- 9. orders (total_price = quantity * product price)
INSERT INTO orders (id, quantity, total_price, session_id, product_id) VALUES
(1, 2, 70.00, 1, 1),
(2, 1, 45.00, 1, 4),
(3, 1, 55.00, 2, 2),
(4, 2, 130.00, 2, 7),
(5, 3, 60.00, 3, 3),
(6, 1, 40.00, 4, 8),
(7, 2, 60.00, 5, 6),
(8, 1, 70.00, 7, 5);
