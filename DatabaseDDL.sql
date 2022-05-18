-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 25, 2022 at 01:36 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.1.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `flights`
--

-- --------------------------------------------------------

--
-- Table structure for table `airlines`
--

CREATE TABLE `airlines` (
  `carrier_id` char(2) NOT NULL,
  `name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `airports`
--

CREATE TABLE `airports` (
  `airport_id` char(20) NOT NULL,
  `name` varchar(30) NOT NULL,
  `timezone` varchar(30) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `latitude` decimal(9,7) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `baggage_fees`
--

CREATE TABLE `baggage_fees` (
  `baggage_type` varchar(30) NOT NULL,
  `baggage_price` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `class` varchar(20) NOT NULL,
  `additional_fee` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `employee_id` char(20) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `title` varchar(20) NOT NULL,
  `salary` decimal(10,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `employees_on_flight`
--

CREATE TABLE `employees_on_flight` (
  `employee_id` char(20) NOT NULL,
  `flight_id` char(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `flights`
--

CREATE TABLE `flights` (
  `flight_id` char(20) NOT NULL,
  `plane_id` char(6) NOT NULL,
  `dept_airport_id` char(3) NOT NULL,
  `arr_airport_id` char(3) NOT NULL,
  `distance` int(11) NOT NULL,
  `date` date NOT NULL,
  `arr_time` time NOT NULL,
  `dept_time` time NOT NULL,
  `passengers` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `passengers`
--

CREATE TABLE `passengers` (
  `passenger_email` varchar(30) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `address` varchar(20) NOT NULL,
  `city` varchar(20) NOT NULL,
  `state` varchar(20) NOT NULL,
  `zip_code` varchar(20) NOT NULL,
  `country` varchar(20) NOT NULL,
  `credit_card_num` int(11) NOT NULL,
  `card_exp_date` date NOT NULL,
  `card_sec_num` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `planes`
--

CREATE TABLE `planes` (
  `plane_id` char(6) NOT NULL,
  `manufacture_year` int(11) DEFAULT NULL,
  `type` varchar(20) NOT NULL,
  `manufacturer` varchar(20) NOT NULL,
  `model` varchar(20) NOT NULL,
  `economy` int(11) DEFAULT NULL,
  `premium_economy` int(11) DEFAULT NULL,
  `business` int(11) DEFAULT NULL,
  `first_class` int(11) DEFAULT NULL,
  `carrier_id` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `tx_id` decimal(20,0) NOT NULL,
  `passenger_email` varchar(30) NOT NULL,
  `flight_id` char(20) NOT NULL,
  `class` varchar(20) DEFAULT NULL,
  `baggage` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `transactions`
--
DELIMITER $$
CREATE TRIGGER `AddPassanger` BEFORE INSERT ON `transactions` FOR EACH ROW BEGIN
    update flights
    set flights.passengers = flights.passengers + 1
    WHERE flights.flight_id = NEW.flight_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `addTransactionNumber` BEFORE INSERT ON `transactions` FOR EACH ROW BEGIN
    declare newID numeric(20,0);
    declare itr int;
    set itr = 1;
    set newID = 0;
    
    Looper: LOOP
        set newID = newID + FLOOR(rand()*10);
        set NewID = NewId * 10;
        set itr = itr + 1;
        if itr = 20 Then
            LEAVE Looper;
        END if;
        
    END LOOP Looper ;
    
    
    set New.tx_id = newID;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dropPassenger` AFTER DELETE ON `transactions` FOR EACH ROW BEGIN
declare p_count integer;
delete from passengers where passengers.passenger_email not in (select passenger_email from transactions);
SELECT passengers into p_count
FROM flights
WHERE flights.flight_id = OLD.flight_id;
IF p_count <> 0 THEN
	UPDATE flights
    SET flights.passengers = flights.passengers- 1
    WHERE flights.flight_id = OLD.flight_id;
end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updateTransactions` BEFORE INSERT ON `transactions` FOR EACH ROW BEGIN
    declare exist bool;
    select exists(select * from transactions where flight_id = new.flight_id and passenger_email = new.passenger_email) into exist;
    if exist THEN
    	delete from transactions where passenger_email = new.passenger_email and flight_id = new.flight_id;
    end if;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `airlines`
--
ALTER TABLE `airlines`
  ADD PRIMARY KEY (`carrier_id`);

--
-- Indexes for table `airports`
--
ALTER TABLE `airports`
  ADD PRIMARY KEY (`airport_id`);

--
-- Indexes for table `baggage_fees`
--
ALTER TABLE `baggage_fees`
  ADD PRIMARY KEY (`baggage_type`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`class`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`employee_id`);

--
-- Indexes for table `employees_on_flight`
--
ALTER TABLE `employees_on_flight`
  ADD PRIMARY KEY (`employee_id`,`flight_id`),
  ADD KEY `flight_id` (`flight_id`);

--
-- Indexes for table `flights`
--
ALTER TABLE `flights`
  ADD PRIMARY KEY (`flight_id`),
  ADD KEY `plane_id` (`plane_id`),
  ADD KEY `dept_airport_id` (`dept_airport_id`),
  ADD KEY `arr_airport_id` (`arr_airport_id`),
  ADD KEY `flightDate` (`date`),
  ADD KEY `flightSearch` (`date`,`arr_airport_id`);

--
-- Indexes for table `passengers`
--
ALTER TABLE `passengers`
  ADD PRIMARY KEY (`passenger_email`);

--
-- Indexes for table `planes`
--
ALTER TABLE `planes`
  ADD PRIMARY KEY (`plane_id`),
  ADD KEY `carrier_id` (`carrier_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`tx_id`),
  ADD KEY `passenger_email` (`passenger_email`),
  ADD KEY `flight_id` (`flight_id`),
  ADD KEY `ClassNULL` (`class`),
  ADD KEY `baggageNULL` (`baggage`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `employees_on_flight`
--
ALTER TABLE `employees_on_flight`
  ADD CONSTRAINT `employees_on_flight_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  ADD CONSTRAINT `employees_on_flight_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`);

--
-- Constraints for table `flights`
--
ALTER TABLE `flights`
  ADD CONSTRAINT `autoDeleteArrivalFlights` FOREIGN KEY (`arr_airport_id`) REFERENCES `airports` (`airport_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `autoDeletedepartureFlights` FOREIGN KEY (`dept_airport_id`) REFERENCES `airports` (`airport_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `flights_ibfk_1` FOREIGN KEY (`plane_id`) REFERENCES `planes` (`plane_id`),
  ADD CONSTRAINT `flights_ibfk_2` FOREIGN KEY (`dept_airport_id`) REFERENCES `airports` (`airport_id`),
  ADD CONSTRAINT `flights_ibfk_3` FOREIGN KEY (`arr_airport_id`) REFERENCES `airports` (`airport_id`);

--
-- Constraints for table `planes`
--
ALTER TABLE `planes`
  ADD CONSTRAINT `autoDelete` FOREIGN KEY (`carrier_id`) REFERENCES `airlines` (`carrier_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `planes_ibfk_1` FOREIGN KEY (`carrier_id`) REFERENCES `airlines` (`carrier_id`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `ClassNULL` FOREIGN KEY (`class`) REFERENCES `classes` (`class`) ON DELETE SET NULL,
  ADD CONSTRAINT `baggageNULL` FOREIGN KEY (`baggage`) REFERENCES `baggage_fees` (`baggage_type`) ON DELETE SET NULL,
  ADD CONSTRAINT `deletion` FOREIGN KEY (`passenger_email`) REFERENCES `passengers` (`passenger_email`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`passenger_email`) REFERENCES `passengers` (`passenger_email`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flights` (`flight_id`);
COMMIT;