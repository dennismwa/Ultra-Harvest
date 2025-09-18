-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 18, 2025 at 10:49 AM
-- Server version: 10.11.14-MariaDB
-- PHP Version: 8.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `zurihubc_Ultra Harvest`
--

-- --------------------------------------------------------

--
-- Table structure for table `active_packages`
--

CREATE TABLE `active_packages` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `investment_amount` decimal(15,2) NOT NULL,
  `expected_roi` decimal(15,2) NOT NULL,
  `roi_percentage` decimal(5,2) NOT NULL,
  `duration_hours` int(11) NOT NULL,
  `status` enum('active','completed','cancelled') DEFAULT 'active',
  `maturity_date` timestamp NOT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `admin_stats_overview`
-- (See below for the actual view)
--
CREATE TABLE `admin_stats_overview` (
`active_users` bigint(21)
,`total_users` bigint(21)
,`total_deposits` decimal(37,2)
,`total_withdrawals` decimal(37,2)
,`total_roi_paid` decimal(37,2)
,`active_packages` bigint(21)
,`total_user_balances` decimal(37,2)
,`pending_roi_obligations` decimal(37,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','success','warning','error') DEFAULT 'info',
  `is_read` tinyint(1) DEFAULT 0,
  `is_global` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `is_read`, `is_global`, `created_at`) VALUES
(1, 2, 'Welcome to Ultra Harvest!', 'Your account has been created successfully. Start trading now!', 'success', 0, 0, '2025-09-17 16:53:40'),
(2, 2, 'Deposit Initiated', 'M-Pesa payment request for KSh 20,000.00 sent to your phone.', 'info', 0, 0, '2025-09-17 16:55:17'),
(3, 3, 'Welcome to Ultra Harvest!', 'Your account has been created successfully. Start trading now!', 'success', 0, 0, '2025-09-17 16:57:29'),
(4, 1, 'Deposit Initiated', 'M-Pesa payment request for KSh 1,000.00 sent to your phone.', 'info', 0, 0, '2025-09-18 10:59:14');

-- --------------------------------------------------------

--
-- Table structure for table `packages`
--

CREATE TABLE `packages` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon` varchar(50) DEFAULT '?',
  `roi_percentage` decimal(5,2) NOT NULL,
  `duration_hours` int(11) NOT NULL DEFAULT 24,
  `min_investment` decimal(15,2) NOT NULL,
  `max_investment` decimal(15,2) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `packages`
--

INSERT INTO `packages` (`id`, `name`, `icon`, `roi_percentage`, `duration_hours`, `min_investment`, `max_investment`, `status`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Seed', '🌱', 10.00, 24, 300.00, NULL, 'active', 'Perfect for beginners - Start small and grow your wealth', '2025-09-17 13:06:24', '2025-09-17 13:06:24'),
(2, 'Sprout', '🌿', 12.00, 24, 30000.00, NULL, 'active', 'Intermediate package with better returns', '2025-09-17 13:06:24', '2025-09-17 13:06:24'),
(3, 'Growth', '🌳', 14.00, 24, 50000.00, NULL, 'active', 'Advanced package for serious traders', '2025-09-17 13:06:24', '2025-09-17 13:06:24'),
(4, 'Harvest', '🌾', 8.00, 12, 100000.00, NULL, 'active', 'Quick returns in just 12 hours', '2025-09-17 13:06:24', '2025-09-17 13:06:24'),
(5, 'Golden Yield', '🌟', 5.00, 6, 150000.00, NULL, 'active', 'Premium package with fastest turnaround', '2025-09-17 13:06:24', '2025-09-17 13:06:24'),
(6, 'Elite', '💎', 40.00, 72, 500000.00, NULL, 'active', 'Exclusive elite package for maximum returns', '2025-09-17 13:06:24', '2025-09-17 13:06:24');

-- --------------------------------------------------------

--
-- Table structure for table `referral_commissions`
--

CREATE TABLE `referral_commissions` (
  `id` int(11) NOT NULL,
  `referrer_id` int(11) NOT NULL,
  `referred_user_id` int(11) NOT NULL,
  `transaction_id` int(11) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 1,
  `commission_rate` decimal(5,2) NOT NULL,
  `commission_amount` decimal(15,2) NOT NULL,
  `status` enum('pending','paid','cancelled') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `paid_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `status` enum('open','in_progress','resolved','closed') DEFAULT 'open',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `admin_response` text DEFAULT NULL,
  `responded_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_health_log`
--

CREATE TABLE `system_health_log` (
  `id` int(11) NOT NULL,
  `total_deposits` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_withdrawals` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_roi_paid` decimal(15,2) NOT NULL DEFAULT 0.00,
  `pending_roi_obligations` decimal(15,2) NOT NULL DEFAULT 0.00,
  `user_wallet_balances` decimal(15,2) NOT NULL DEFAULT 0.00,
  `platform_liquidity` decimal(15,2) NOT NULL DEFAULT 0.00,
  `coverage_ratio` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `active_users` int(11) DEFAULT 0,
  `active_packages_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_health_log`
--

INSERT INTO `system_health_log` (`id`, `total_deposits`, `total_withdrawals`, `total_roi_paid`, `pending_roi_obligations`, `user_wallet_balances`, `platform_liquidity`, `coverage_ratio`, `active_users`, `active_packages_count`, `created_at`) VALUES
(1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 13:35:54'),
(2, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 13:36:44'),
(3, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 13:50:36'),
(4, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 13:50:56'),
(5, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 13:51:22'),
(6, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 13:51:31'),
(7, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 14:13:53'),
(8, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 14:14:39'),
(9, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 1, 0, '2025-09-17 14:22:50'),
(10, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:05:11'),
(11, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:05:24'),
(12, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:06:24'),
(13, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:06:30'),
(14, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:07:03'),
(15, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:07:34'),
(16, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:08:05'),
(17, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:08:37'),
(18, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:09:19'),
(19, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:09:26'),
(20, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:09:58'),
(21, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:10:29'),
(22, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:11:00'),
(23, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:11:32'),
(24, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:12:04'),
(25, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:12:36'),
(26, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:13:07'),
(27, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:13:40'),
(28, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:14:11'),
(29, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:14:42'),
(30, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:15:13'),
(31, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:15:44'),
(32, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:16:15'),
(33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:16:46'),
(34, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:17:17'),
(35, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:17:49'),
(36, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:18:19'),
(37, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:18:50'),
(38, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:19:22'),
(39, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:19:53'),
(40, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:20:24'),
(41, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:20:55'),
(42, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-17 17:21:26'),
(43, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 08:52:28'),
(44, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 08:52:48'),
(45, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 09:46:25'),
(46, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 09:50:36'),
(47, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 09:51:35'),
(48, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 09:51:40'),
(49, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 09:51:44'),
(50, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 10:56:17'),
(51, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 10:56:49'),
(52, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 11:18:26'),
(53, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:20:17'),
(54, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:20:49'),
(55, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:21:20'),
(56, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:21:53'),
(57, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:22:24'),
(58, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:22:55'),
(59, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:23:26'),
(60, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:23:57'),
(61, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:24:28'),
(62, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:24:59'),
(63, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:25:30'),
(64, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:26:02'),
(65, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:26:34'),
(66, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:27:06'),
(67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:27:42'),
(68, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:28:14'),
(69, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:28:46'),
(70, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:29:18'),
(71, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:29:50'),
(72, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:30:22'),
(73, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:30:54'),
(74, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:45:04'),
(75, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:45:12'),
(76, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:45:36'),
(77, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:45:43'),
(78, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:46:08'),
(79, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:46:14'),
(80, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:46:40'),
(81, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:46:46'),
(82, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:47:12'),
(83, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:47:18'),
(84, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:47:44'),
(85, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:47:50'),
(86, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:48:16'),
(87, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:48:21'),
(88, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:48:48'),
(89, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:48:52'),
(90, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:49:20'),
(91, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1.0000, 3, 0, '2025-09-18 14:49:23');

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `setting_type` enum('string','number','boolean','json') DEFAULT 'string',
  `description` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `setting_type`, `description`, `updated_at`) VALUES
(1, 'mpesa_consumer_key', 'AIS8xBO29ij8U2HqG7YwuXNAkG5MG2V0MBq5x9MuNMykIOey', 'string', 'M-Pesa API Consumer Key', '2025-09-18 09:46:52'),
(2, 'mpesa_consumer_secret', 'vffObEIb3uHR8VXm2tYqKfzDxjwEgBizDFzaq3jLwJ79DEJt3N5UeGOFESn9m7HM', 'string', 'M-Pesa API Consumer Secret', '2025-09-18 09:46:52'),
(3, 'mpesa_shortcode', '174379', 'string', 'M-Pesa Business Shortcode', '2025-09-18 09:46:52'),
(4, 'mpesa_passkey', 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919', 'string', 'M-Pesa Online Passkey', '2025-09-18 09:46:52'),
(5, 'mpesa_environment', 'sandbox', 'string', 'M-Pesa Environment (sandbox/live)', '2025-09-17 13:06:24'),
(6, 'platform_fee_percentage', '0', 'number', 'Platform fee percentage on deposits', '2025-09-17 13:06:24'),
(7, 'min_withdrawal_amount', '100', 'number', 'Minimum withdrawal amount', '2025-09-17 13:06:24'),
(8, 'max_withdrawal_amount', '1000000', 'number', 'Maximum withdrawal amount', '2025-09-17 13:06:24'),
(9, 'withdrawal_processing_time', '24', 'number', 'Withdrawal processing time in hours', '2025-09-17 13:06:24'),
(10, 'referral_commission_l1', '10', 'number', 'Level 1 referral commission percentage', '2025-09-17 13:06:24'),
(11, 'referral_commission_l2', '5', 'number', 'Level 2 referral commission percentage', '2025-09-17 13:06:24'),
(12, 'site_maintenance', '0', 'boolean', 'Site maintenance mode', '2025-09-17 13:06:24'),
(13, 'auto_roi_processing', '1', 'boolean', 'Automatic ROI processing', '2025-09-17 13:06:24'),
(14, 'email_notifications', '1', 'boolean', 'Email notifications enabled', '2025-09-17 13:06:24'),
(15, 'sms_notifications', '1', 'boolean', 'SMS notifications enabled', '2025-09-17 13:06:24');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('deposit','withdrawal','roi_payment','referral_commission','package_investment') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'pending',
  `mpesa_receipt` varchar(100) DEFAULT NULL,
  `mpesa_request_id` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `type`, `amount`, `status`, `mpesa_receipt`, `mpesa_request_id`, `phone_number`, `description`, `admin_notes`, `processed_by`, `created_at`, `updated_at`) VALUES
(1, 2, 'deposit', 20000.00, 'pending', NULL, NULL, '254758256440', 'M-Pesa deposit request', NULL, NULL, '2025-09-17 16:55:17', '2025-09-17 16:55:17'),
(2, 1, 'deposit', 1000.00, 'pending', NULL, NULL, '254758256440', 'M-Pesa deposit request', NULL, NULL, '2025-09-18 10:59:14', '2025-09-18 10:59:14');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `wallet_balance` decimal(15,2) DEFAULT 0.00,
  `total_deposited` decimal(15,2) DEFAULT 0.00,
  `total_withdrawn` decimal(15,2) DEFAULT 0.00,
  `total_roi_earned` decimal(15,2) DEFAULT 0.00,
  `referral_code` varchar(10) NOT NULL,
  `referred_by` int(11) DEFAULT NULL,
  `referral_earnings` decimal(15,2) DEFAULT 0.00,
  `status` enum('active','suspended','banned') DEFAULT 'active',
  `is_admin` tinyint(1) DEFAULT 0,
  `email_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `phone`, `wallet_balance`, `total_deposited`, `total_withdrawn`, `total_roi_earned`, `referral_code`, `referred_by`, `referral_earnings`, `status`, `is_admin`, `email_verified`, `created_at`, `updated_at`) VALUES
(1, 'admin@ultraharvest.com', '$2y$10$CRXv2TdAyzHoU6uM55Tajey0XqhEeeb7l0rGj9qUnUHXjo2oXcvta', 'System Administrator', '+254700000000', 0.00, 0.00, 0.00, 0.00, 'ADMIN001', NULL, 0.00, 'active', 1, 1, '2025-09-17 13:06:24', '2025-09-18 14:20:17'),
(2, 'mwangidennis546@gmail.com', '$2y$10$Jx3.dAKRsftLDhr60ytGOOtyVXIjUN0822GA87MU14QWd2uhQejYS', 'Dennis', '254758256440', 0.00, 0.00, 0.00, 0.00, 'NM8FZ2BZ', NULL, 0.00, 'active', 0, 0, '2025-09-17 16:53:40', '2025-09-17 17:01:24'),
(3, 'juicemwangi7@gmail.com', '$2y$10$DiL3VGEcs8AEIjcH4sWe7.TxLzGs5o2pIYNbNyf1VzvDtvopZqoVK', 'Juice', '254101684840', 0.00, 0.00, 0.00, 0.00, 'EXH1UGHI', 2, 0.00, 'active', 0, 0, '2025-09-17 16:57:29', '2025-09-17 16:57:29');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `active_packages`
--
ALTER TABLE `active_packages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `package_id` (`package_id`),
  ADD KEY `status` (`status`),
  ADD KEY `maturity_date` (`maturity_date`),
  ADD KEY `idx_active_packages_maturity` (`status`,`maturity_date`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `is_global` (`is_global`),
  ADD KEY `is_read` (`is_read`);

--
-- Indexes for table `packages`
--
ALTER TABLE `packages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `referral_commissions`
--
ALTER TABLE `referral_commissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `referrer_id` (`referrer_id`),
  ADD KEY `referred_user_id` (`referred_user_id`),
  ADD KEY `transaction_id` (`transaction_id`),
  ADD KEY `idx_referral_commissions_status` (`status`,`referrer_id`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status` (`status`),
  ADD KEY `responded_by` (`responded_by`);

--
-- Indexes for table `system_health_log`
--
ALTER TABLE `system_health_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_at` (`created_at`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `type` (`type`),
  ADD KEY `status` (`status`),
  ADD KEY `processed_by` (`processed_by`),
  ADD KEY `idx_transactions_user_type` (`user_id`,`type`,`status`),
  ADD KEY `idx_mpesa_request_id` (`mpesa_request_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `referral_code` (`referral_code`),
  ADD KEY `referred_by` (`referred_by`),
  ADD KEY `idx_users_referral` (`referral_code`,`referred_by`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `active_packages`
--
ALTER TABLE `active_packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `packages`
--
ALTER TABLE `packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `referral_commissions`
--
ALTER TABLE `referral_commissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_health_log`
--
ALTER TABLE `system_health_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

-- --------------------------------------------------------

--
-- Structure for view `admin_stats_overview`
--
DROP TABLE IF EXISTS `admin_stats_overview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`zurihubc`@`localhost` SQL SECURITY DEFINER VIEW `admin_stats_overview`  AS SELECT (select count(0) from `users` where `users`.`status` = 'active') AS `active_users`, (select count(0) from `users`) AS `total_users`, (select coalesce(sum(`transactions`.`amount`),0) from `transactions` where `transactions`.`type` = 'deposit' and `transactions`.`status` = 'completed') AS `total_deposits`, (select coalesce(sum(`transactions`.`amount`),0) from `transactions` where `transactions`.`type` = 'withdrawal' and `transactions`.`status` = 'completed') AS `total_withdrawals`, (select coalesce(sum(`transactions`.`amount`),0) from `transactions` where `transactions`.`type` = 'roi_payment' and `transactions`.`status` = 'completed') AS `total_roi_paid`, (select count(0) from `active_packages` where `active_packages`.`status` = 'active') AS `active_packages`, (select coalesce(sum(`users`.`wallet_balance`),0) from `users`) AS `total_user_balances`, (select coalesce(sum(`active_packages`.`expected_roi`),0) from `active_packages` where `active_packages`.`status` = 'active') AS `pending_roi_obligations` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `active_packages`
--
ALTER TABLE `active_packages`
  ADD CONSTRAINT `active_packages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `active_packages_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `referral_commissions`
--
ALTER TABLE `referral_commissions`
  ADD CONSTRAINT `referral_commissions_ibfk_1` FOREIGN KEY (`referrer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `referral_commissions_ibfk_2` FOREIGN KEY (`referred_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `referral_commissions_ibfk_3` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `support_tickets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `support_tickets_ibfk_2` FOREIGN KEY (`responded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`referred_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
