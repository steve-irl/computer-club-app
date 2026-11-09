-- Adminer 6.2.0 MariaDB 10.3.32-MariaDB-1:10.3.32+maria~focal dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `deposit_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `level` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  CONSTRAINT `chk_level` CHECK (`level` between 0 and 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `halls`;
CREATE TABLE `halls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price_coefficient` float NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `total_price` decimal(10,2) NOT NULL,
  `session_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `session_id` (`session_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `pc_specs`;
CREATE TABLE `pc_specs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cpu` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gpu` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ram_gb` int(11) NOT NULL,
  `storage` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `reservations`;
CREATE TABLE `reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  KEY `seat_id` (`seat_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `seats`;
CREATE TABLE `seats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` int(11) NOT NULL,
  `hall_id` int(11) NOT NULL,
  `pc_id` int(11) NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  PRIMARY KEY (`id`),
  KEY `hall_id` (`hall_id`),
  KEY `pc_id` (`pc_id`),
  CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`hall_id`) REFERENCES `halls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `seats_ibfk_2` FOREIGN KEY (`pc_id`) REFERENCES `pc_specs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_time` datetime NOT NULL DEFAULT current_timestamp(),
  `end_time` datetime DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `seat_id` int(11) NOT NULL,
  `tariff_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `seat_id` (`seat_id`),
  KEY `tariff_id` (`tariff_id`),
  KEY `client_id` (`client_id`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sessions_ibfk_2` FOREIGN KEY (`tariff_id`) REFERENCES `tariffs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sessions_ibfk_3` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `tariffs`;
CREATE TABLE `tariffs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 2026-11-09 13:07:32 UTC
