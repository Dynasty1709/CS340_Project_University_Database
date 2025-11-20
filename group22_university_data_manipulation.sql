-- Grader notes: we are leveraging displaying information about institutions
-- to help ulfill the select requirements. 

-- Select universities (dropdown)
DROP PROCEDURE IF EXISTS select_universities;
DELIMITER //
CREATE PROCEDURE select_universities()
BEGIN
    SELECT universityID, universityName 
    FROM UNIVERSITIES;
END //
DELIMITER 

-- Select majors by institution
DROP PROCEDURE IF EXISTS select_majors_by_institution;
DELIMITER //
CREATE PROCEDURE select_majors_by_institution(
    IN p_universityID INT
)
BEGIN
  SELECT M.program, M.level
  FROM MAJORS M
  JOIN UNIVERSITIES_HAS_MAJORS UM ON M.majorID = UM.majorID
  WHERE UM.universityID = p_universityID;
END //
DELIMITER ;

-- Add a major to an institution
DROP PROCEDURE IF EXISTS add_major_to_institution;
DELIMITER //
CREATE PROCEDURE add_major_to_institution(
    IN p_universityID INT,
    IN p_majorID INT
)
BEGIN
    INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID)
    VALUES (p_universityID, p_majorID);
END //
DELIMITER ;

-- Change major name
DROP PROCEDURE IF EXISTS change_major_name;
DELIMITER //
CREATE PROCEDURE change_major_name(
    IN p_newProgramNameInput VARCHAR (50),
    IN p_majorIDInput INT
)
BEGIN
    UPDATE MAJORS
    SET program = p_newProgramNameInput
    WHERE majorID = p_majorIDInput;
END //
DELIMITER ;


-- remove a major from an institution
DROP PROCEDURE IF EXISTS remove_major_from_institution;
DELIMITER //
CREATE PROCEDURE remove_major_from_institution(
    IN p_universityIDInput INT,
    IN p_majorIDInput INT
)
BEGIN
  DELETE FROM UNIVERSITIES_HAS_MAJORS
  WHERE universityID = p_universityIDInput AND majorID = p_majorIDInput;
END //
DELIMITER ;

-- display sports by institution
DROP PROCEDURE IF EXISTS display_sports_by_institution;
DELIMITER //
CREATE PROCEDURE display_sports_by_institution(
     IN p_universityIDInput INT
)
BEGIN
  SELECT A.sportName, A.sportType
  FROM ATHLETICS A
  JOIN UNIVERSITIES_HAS_ATHLETICS UA ON A.sportID = UA.sportID
  WHERE UA.universityID = p_universityIDInput;
END //
DELIMITER ;

-- add a sport to an institution
DROP PROCEDURE IF EXISTS add_sport_to_institution;
DELIMITER //
CREATE PROCEDURE add_sport_to_institution(
    IN p_universityIDInput INT,
    IN p_sportIDInput      INT
)
BEGIN
    INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
    VALUES (p_universityIDInput, p_sportIDInput);
END //
DELIMITER ;


-- remove a sport from an institution
DROP PROCEDURE IF EXISTS remove_sport_from_institution;
DELIMITER //
CREATE PROCEDURE remove_sport_from_institution(
    IN p_universityIDInput INT,
    IN p_sportIDInput      INT
)
BEGIN
    DELETE FROM UNIVERSITIES_HAS_ATHLETICS
    WHERE universityID = p_universityIDInput AND sportID = p_sportIDInput;
END //
DELIMITER ;

-- select cost details by institution
DROP PROCEDURE IF EXISTS select_cost_by_institution;
DELIMITER //
CREATE PROCEDURE select_cost_by_institution(
    IN p_universityIDInput INT
)
BEGIN
    SELECT C.fees, C.boarding, C.meals, C.books, T.currentInStateTuition, T.currentOutOfStateTuition
    FROM COSTS C
    JOIN TUITION T ON C.costID = T.costsID
    WHERE C.universityID = p_universityIDInput ;
END //
DELIMITER ;


-- update cost details
DROP PROCEDURE IF EXISTS update_cost_details;
DELIMITER //
CREATE PROCEDURE update_cost_details(
    IN p_feesInput     DECIMAL(7,2),
    IN p_boardingInput DECIMAL(7,2),
    IN p_mealsInput    DECIMAL(7,2),
    IN p_booksInput    DECIMAL(6,2),
    IN p_universityIDInput INT
)
BEGIN
    UPDATE COSTS
    SET fees = p_feesInput, boarding = p_boardingInput, meals = p_mealsInput, books = p_booksInput
    WHERE universityID = p_universityIDInput;
END //
DELIMITER ;

-- update tuition details
DROP PROCEDURE IF EXISTS update_tuition_details;
DELIMITER //
CREATE PROCEDURE update_tuition_details(
    IN p_inStateInput  DECIMAL(8,2),
    IN p_outStateInput DECIMAL(8,2),
    IN p_costsIDInput  INT
)
BEGIN
    UPDATE TUITION
    SET currentInStateTuition = p_inStateInput, currentOutOfStateTuition = p_outStateInput
    WHERE costsID = p_costsIDInput;
END //
DELIMITER ;

-- reset database
DROP PROCEDURE IF EXISTS sp_reset_schema_and_data;
DELIMITER //

CREATE PROCEDURE sp_reset_schema_and_data()
BEGIN
    -- 1. Drop existing tables (order matters because of FKs)
    DROP TABLE IF EXISTS UNIVERSITIES_HAS_ATHLETICS;
    DROP TABLE IF EXISTS UNIVERSITIES_HAS_MAJORS;
    DROP TABLE IF EXISTS TUITION;
    DROP TABLE IF EXISTS COSTS;
    DROP TABLE IF EXISTS ATHLETICS;
    DROP TABLE IF EXISTS MAJORS;
    DROP TABLE IF EXISTS UNIVERSITIES;

    -- 2. Recreate schema
    
-- -----------------------------------------------------
-- Table `UNIVERSITIES`
-- -----------------------------------------------------
CREATE TABLE `UNIVERSITIES` (
  `universityID` INT NOT NULL AUTO_INCREMENT,
  `universityName` VARCHAR(50) NOT NULL,
  `location` VARCHAR(50) NOT NULL,
  `campusType` ENUM('Urban', 'Suburban', 'Rural') NOT NULL,
  `acceptanceRate` DECIMAL(5,2) NOT NULL,
  `athleticClassification` ENUM('NCAA Division I', 'NCAA Division II', 'NCAA Division III', 'NAIA') NOT NULL,
  PRIMARY KEY (`universityID`),
  UNIQUE INDEX `UniversityID_UNIQUE` (`universityID` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table COSTS`
-- -----------------------------------------------------
CREATE TABLE `COSTS` (
  `costID` INT NOT NULL AUTO_INCREMENT,
  `fees` DECIMAL(7,2) NOT NULL,
  `boarding` DECIMAL(7,2) NOT NULL,
  `meals` DECIMAL(7,2) NOT NULL,
  `books` DECIMAL(6,2) NOT NULL,
  `universityID` INT NOT NULL,
  PRIMARY KEY (`costID`),
  UNIQUE INDEX `CostsID_UNIQUE` (`costID` ASC) VISIBLE,
  INDEX `universityID_idx` (`universityID` ASC) VISIBLE,
  UNIQUE INDEX `UniversityID_UNIQUE` (`universityID` ASC) VISIBLE,
  CONSTRAINT `universityID`
    FOREIGN KEY (`universityID`)
    REFERENCES `UNIVERSITIES` (`universityID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ATHLETICS`
-- -----------------------------------------------------
CREATE TABLE `ATHLETICS` (
  `sportID` INT NOT NULL AUTO_INCREMENT,
  `sportName` VARCHAR(50) NOT NULL,
  `sportType` ENUM('Individual', 'Team') NOT NULL,
  PRIMARY KEY (`sportID`),
  UNIQUE INDEX `SportID_UNIQUE` (`sportID` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `MAJORS`
-- -----------------------------------------------------
CREATE TABLE `MAJORS` (
  `majorID` INT NOT NULL AUTO_INCREMENT,
  `level` ENUM('Undergraduate', 'Graduate', 'Certificate') NOT NULL,
  `program` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`majorID`),
  UNIQUE INDEX `MajorID_UNIQUE` (`majorID` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UNIVERSITIES_HAS_MAJORS`
-- -----------------------------------------------------
CREATE TABLE `UNIVERSITIES_HAS_MAJORS` (
  `universityHasMajorsID` INT NOT NULL AUTO_INCREMENT,
  `universityID` INT NOT NULL,
  `majorID` INT NOT NULL,
  PRIMARY KEY (`universityHasMajorsID`),
  INDEX `fk_Universities_has_Majors_Majors1_idx` (`majorID` ASC) VISIBLE,
  INDEX `fk_Universities_has_Majors_Universities1_idx` (`universityID` ASC) VISIBLE,
  CONSTRAINT `fk_Universities_has_Majors_Universities1`
    FOREIGN KEY (`universityID`)
    REFERENCES `UNIVERSITIES` (`universityID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Universities_has_Majors_Majors1`
    FOREIGN KEY (`majorID`)
    REFERENCES `MAJORS` (`majorID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UNIVERSITIES_HAS_ATHLETICS`
-- -----------------------------------------------------
CREATE TABLE `UNIVERSITIES_HAS_ATHLETICS` (
  `universityHasAthleticsID` INT NOT NULL AUTO_INCREMENT,
  `universityID` INT NOT NULL,
  `sportID` INT NOT NULL,
  PRIMARY KEY (`universityHasAthleticsID`),
  INDEX `fk_Universities_has_Athletics_Athletics1_idx` (`sportID` ASC) VISIBLE,
  INDEX `fk_Universities_has_Athletics_Universities1_idx` (`universityID` ASC) VISIBLE,
  CONSTRAINT `fk_Universities_has_Athletics_Universities1`
    FOREIGN KEY (`universityID`)
    REFERENCES `UNIVERSITIES` (`universityID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Universities_has_Athletics_Athletics1`
    FOREIGN KEY (`sportID`)
    REFERENCES `ATHLETICS` (`sportID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TUITION`
-- -----------------------------------------------------
CREATE TABLE `TUITION` (
  `tuitionID` INT NOT NULL AUTO_INCREMENT,
  `currentInStateTuition` DECIMAL(8,2) NOT NULL,
  `currentOutOfStateTuition` DECIMAL(8,2) NOT NULL,
  `costsID` INT NOT NULL,
  PRIMARY KEY (`tuitionID`),
  UNIQUE INDEX `idTUITION_UNIQUE` (`tuitionID` ASC) VISIBLE,
  UNIQUE INDEX `fk_TUITION_COSTS1_idx` (`costsID` ASC) VISIBLE,
  CONSTRAINT `fk_TUITION_COSTS1`
    FOREIGN KEY (`costsID`)
    REFERENCES `COSTS` (`costID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

INSERT INTO `UNIVERSITIES`
(`universityID`, `universityName`, `location`, `campusType`, `acceptanceRate`, `athleticClassification`)
VALUES
(1, 'Oregon State University', 'Corvallis, OR', 'Suburban', 79.00, 'NCAA Division I'),
(2, 'University of California, Los Angeles', 'Los Angeles, CA', 'Urban', 9.00, 'NCAA Division I'),
(3, 'Washington University in St. Louis', 'St. Louis, MO', 'Suburban', 11.00, 'NCAA Division III'),
(4, 'New York University', 'New York, NY', 'Urban', 13.00, 'NCAA Division III'),
(5, 'Howard University', 'Washington, DC', 'Urban', 35.00, 'NCAA Division I'),
(6, 'Florida A&M University', 'Tallahassee, FL', 'Urban', 33.00, 'NCAA Division I'),
(7, 'Dartmouth College', 'Hanover, NH', 'Rural', 6.00, 'NCAA Division I');


INSERT INTO `COSTS`
(`costID`, `fees`, `boarding`, `meals`, `books`, `universityID`)
VALUES
(1, 2300.00, 13200.00, 6400.00, 1200.00, 1),  -- OSU
(2, 1500.00, 17600.00, 6900.00, 1641.00, 2),  -- UCLA  
(3, 1350.00, 14500.00, 7700.00, 1304.00, 3),  -- WashU  
(4, 2000.00, 18200.00, 7600.00, 1470.00, 4),  -- NYU  
(5, 1900.00, 14200.00, 6660.00, 1360.00, 5),  -- Howard
(6, 1200.00, 18100.00, 6400.00, 1138.00, 6),  -- FAMU
(7, 2318.00, 12579.00, 8341.00, 1005.00, 7);  -- Dartmouth  

INSERT INTO `TUITION`
(`tuitionID`, `currentInStateTuition`, `currentOutOfStateTuition`, `costsID`)
VALUES
-- Oregon State University (OSU)
(1, 15246.00, 33798.00, 1),

-- University of California, Los Angeles (UCLA)
(2, 15700.00, 37602.00, 2),

-- Washington University in St. Louis (WashU)
(3, 68240.00, 68240.00, 3),

-- New York University (NYU)
(4, 62796.00, 62796.00, 4),

-- Howard University
(5, 37996.00, 37996.00, 5),

-- Florida A&M University (FAMU)
(6, 5697.30, 17585.40, 6),

-- Dartmouth College
(7, 69207.00, 69207.00, 7);

INSERT INTO `ATHLETICS`
(`sportID`, `sportName`, `sportType`)
VALUES
-- Football (Men only at NCAA level)
(1, 'Football (Men)', 'Team'),

-- Basketball (Men’s and Women’s)
(2, 'Basketball (Men)', 'Team'),
(3, 'Basketball (Women)', 'Team'),

-- Track and Field (Men’s and Women’s)
(4, 'Track and Field (Men)', 'Individual'),
(5, 'Track and Field (Women)', 'Individual'),

-- Soccer (Men’s and Women’s)
(6, 'Soccer (Men)', 'Team'),
(7, 'Soccer (Women)', 'Team'),

-- Swimming (Men’s, Women’s, and Coed relays/diving exist at some schools)
(8, 'Swimming (Men)', 'Individual'),
(9, 'Swimming (Women)', 'Individual'),
(10, 'Swimming (Coed)', 'Individual');


INSERT INTO `MAJORS`
(`majorID`, `level`, `program`)
VALUES
(1, 'Undergraduate', 'Computer Science'),
(2, 'Undergraduate', 'Business Administration'),
(3, 'Graduate', 'Public Health'),
(4, 'Graduate', 'Mechanical Engineering'),
(5, 'Undergraduate', 'Psychology');

INSERT INTO `UNIVERSITIES_HAS_MAJORS`
(`universityHasMajorsID`, `universityID`, `majorID`)
VALUES
(1, 1, 1), -- OSU - Computer Science
(2, 1, 2), -- OSU - Business
(3, 2, 1), -- UCLA - Computer Science
(4, 2, 5), -- UCLA - Psychology
(5, 3, 4), -- WashU - Mechanical Engineering
(6, 3, 3), -- WashU - Public Health
(7, 4, 2), -- NYU - Business
(8, 4, 5), -- NYU - Psychology
(9, 5, 3), -- Howard - Public Health
(10, 6, 1), -- FAMU - Computer Science
(11, 7, 1), -- Dartmouth - Computer Science
(12, 7, 5), -- Dartmouth - Psychology
(13, 7, 4); -- Dartmouth - Mechanical Engineering (Engineering Science)


INSERT INTO `UNIVERSITIES_HAS_ATHLETICS`
(`universityHasAthleticsID`, `universityID`, `sportID`)
VALUES
-- Oregon State University (OSU)
(1, 1, 1), -- Football
(2, 1, 2), -- Basketball
(3, 1, 4), -- Track and Field
(4, 1, 6), -- Soccer
(5, 1, 8), -- Swimming

-- UCLA
(6, 2, 1), -- Football
(7, 2, 2), -- Basketball
(8, 2, 4), -- Track and Field
(9, 2, 6), -- Soccer
(10, 2, 8), -- Swimming

-- Washington University in St. Louis (WashU)
(11, 3, 1), -- Football
(12, 3, 2), -- Basketball
(13, 3, 4), -- Track and Field
(14, 3, 6), -- Soccer
(15, 3, 8), -- Swimming

-- New York University (NYU)
(16, 4, 1), -- Football
(17, 4, 2), -- Basketball
(18, 4, 4), -- Track and Field
(19, 4, 6), -- Soccer
(20, 4, 8), -- Swimming

-- Howard University
(21, 5, 1), -- Football
(22, 5, 2), -- Basketball
(23, 5, 4), -- Track and Field
(24, 5, 6), -- Soccer
(25, 5, 8), -- Swimming

-- Florida A&M University (FAMU)
(26, 6, 1), -- Football
(27, 6, 2), -- Basketball
(28, 6, 4), -- Track and Field
(29, 6, 6), -- Soccer
(30, 6, 8), -- Swimming

-- Dartmouth College
(31, 7, 1), -- Football
(32, 7, 2), -- Basketball
(33, 7, 4), -- Track and Field
(34, 7, 6), -- Soccer
(35, 7, 8); -- Swimming


END //
DELIMITER ;

-- Curry, M. (2025). CS340: Introduction to Databases – Week 6 module. Canvas. Oregon State University.