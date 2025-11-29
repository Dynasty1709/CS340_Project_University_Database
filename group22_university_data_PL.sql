-- Grader notes: we are leveraging displaying information about institutions
-- to help ulfill the select requirements. 

-- Select universities  
 
DROP PROCEDURE IF EXISTS select_universities;
DELIMITER //

CREATE PROCEDURE select_universities()
BEGIN
  SELECT 
    universityID,
    universityName,
    location,
    campusType,
    acceptanceRate,
    athleticClassification
  FROM UNIVERSITIES;
END //

DELIMITER ;
DROP PROCEDURE IF EXISTS create_tuition_record;
DELIMITER //
CREATE PROCEDURE create_tuition_record(
    IN p_costID INT,
    IN p_inState DECIMAL(10,2),
    IN p_outState DECIMAL(10,2)
)
BEGIN
    INSERT INTO TUITION (currentInStateTuition, currentOutOfStateTuition, costID)
    VALUES (p_inState, p_outState, p_costID);
END //
DELIMITER ;

-- Select majors by institution
DROP PROCEDURE IF EXISTS select_majors_by_institution;
DELIMITER //
CREATE PROCEDURE select_majors_by_institution(IN p_universityID INT)
BEGIN
  SELECT 
    M.majorID,          -- primary key
    M.program, 
    M.level,
    U.universityID,     -- foreign key
    U.universityName
  FROM MAJORS M
  JOIN UNIVERSITIES_HAS_MAJORS UM ON M.majorID = UM.majorID
  JOIN UNIVERSITIES U ON UM.universityID = U.universityID
  WHERE UM.universityID = p_universityID;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS update_major_assignment;
DELIMITER //
CREATE PROCEDURE update_major_assignment(
    IN p_universityID INT,
    IN p_originalMajorID INT,
    IN p_newMajorID INT
)
BEGIN
    DELETE FROM UNIVERSITIES_HAS_MAJORS
    WHERE universityID = p_universityID AND majorID = p_originalMajorID;

    INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID)
    VALUES (p_universityID, p_newMajorID);
END //
DELIMITER ;
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

-- select major
DROP PROCEDURE IF EXISTS select_universities_has_majors;
DELIMITER //
CREATE PROCEDURE select_universities_has_majors()
BEGIN
  SELECT 
    U.universityID,
    U.universityName,
    M.majorID,
    M.program,
    M.level
  FROM UNIVERSITIES_HAS_MAJORS UM
  JOIN UNIVERSITIES U ON UM.universityID = U.universityID
  JOIN MAJORS M ON UM.majorID = M.majorID
  ORDER BY U.universityID ASC, M.program ASC;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS add_major;
DELIMITER //
CREATE PROCEDURE add_major(
    IN p_program VARCHAR(50),
    IN p_level ENUM('Undergraduate','Graduate','Certificate')
)
BEGIN
    INSERT INTO MAJORS (program, level)
    VALUES (p_program, p_level);
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS update_major;
DELIMITER //
CREATE PROCEDURE update_major(
    IN p_majorID INT,
    IN p_program VARCHAR(50),
    IN p_level ENUM('Undergraduate','Graduate','Certificate')
)
BEGIN
    UPDATE MAJORS
    SET program = p_program,
        level = p_level
    WHERE majorID = p_majorID;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS remove_major;
DELIMITER //
CREATE PROCEDURE remove_major(
    IN p_majorID INT
)
BEGIN
    DELETE FROM MAJORS WHERE majorID = p_majorID;
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
DROP PROCEDURE IF EXISTS remove_sport;
DELIMITER //
CREATE PROCEDURE remove_sport(
    IN p_sportID INT
)
BEGIN
    DELETE FROM ATHLETICS WHERE sportID = p_sportID;
END //
DELIMITER ;
-- display sports by institution
DROP PROCEDURE IF EXISTS display_sports_by_institution;
DELIMITER //
CREATE PROCEDURE display_sports_by_institution(IN p_universityID INT)
BEGIN
  SELECT 
    A.sportID,          -- primary key
    A.sportName, 
    A.sportType,
    U.universityID,     -- foreign key
    U.universityName
  FROM ATHLETICS A
  JOIN UNIVERSITIES_HAS_ATHLETICS UA ON A.sportID = UA.sportID
  JOIN UNIVERSITIES U ON UA.universityID = U.universityID
  WHERE UA.universityID = p_universityID;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS update_sport_assignment;
DELIMITER //
CREATE PROCEDURE update_sport_assignment(
    IN p_universityID INT,
    IN p_originalSportID INT,
    IN p_newSportID INT
)
BEGIN
    DELETE FROM UNIVERSITIES_HAS_ATHLETICS
    WHERE universityID = p_universityID AND sportID = p_originalSportID;

    INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
    VALUES (p_universityID, p_newSportID);
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

-- select sport
DROP PROCEDURE IF EXISTS select_universities_has_athletics;
DELIMITER //
CREATE PROCEDURE select_universities_has_athletics()
BEGIN
  SELECT 
    U.universityID,
    U.universityName,
    A.sportID,
    A.sportName,
    A.sportType
  FROM UNIVERSITIES_HAS_ATHLETICS UA
  JOIN UNIVERSITIES U ON UA.universityID = U.universityID
  JOIN ATHLETICS A ON UA.sportID = A.sportID;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS add_sport;
DELIMITER //
CREATE PROCEDURE add_sport(
    IN p_sportName VARCHAR(50),
    IN p_sportType ENUM('Individual','Team')
)
BEGIN
    INSERT INTO ATHLETICS (sportName, sportType)
    VALUES (p_sportName, p_sportType);
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS update_sport;
DELIMITER //
CREATE PROCEDURE update_sport(
    IN p_sportID INT,
    IN p_sportName VARCHAR(50),
    IN p_sportType ENUM('Individual','Team')
)
BEGIN
    UPDATE ATHLETICS
    SET sportName = p_sportName,
        sportType = p_sportType
    WHERE sportID = p_sportID;
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
CREATE PROCEDURE select_cost_by_institution(IN p_universityID INT)
BEGIN
  SELECT 
    C.costID,                 
    U.universityName,         -- for university name
    C.fees, 
    C.boarding, 
    C.meals, 
    C.books, 
    T.tuitionID,
    T.currentInStateTuition, 
    T.currentOutOfStateTuition
  FROM COSTS C
  JOIN TUITION T ON C.costID = T.costID
  JOIN UNIVERSITIES U ON C.universityID = U.universityID   -- **for university name
  WHERE p_universityID IS NULL 
        OR p_universityID = 0
        OR C.universityID = p_universityID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS add_cost;
DELIMITER //
CREATE PROCEDURE add_cost(
    IN p_universityID INT,
    IN p_fees DECIMAL(7,2),
    IN p_boarding DECIMAL(7,2),
    IN p_meals DECIMAL(7,2),
    IN p_books DECIMAL(6,2)
)
BEGIN
    DECLARE new_costID INT;

    INSERT INTO COSTS (fees, boarding, meals, books, universityID)
    VALUES (p_fees, p_boarding, p_meals, p_books, p_universityID);
    
    SET new_costID = LAST_INSERT_ID();
  INSERT INTO TUITION (currentInStateTuition, currentOutOfStateTuition, costID)
    VALUES (0.00, 0.00, new_costID);
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS create_tuition_record;
DELIMITER //
CREATE PROCEDURE create_tuition_record(
    IN p_costID INT,
    IN p_inState DECIMAL(10,2),
    IN p_outState DECIMAL(10,2)
)
BEGIN
    INSERT INTO TUITION (currentInStateTuition, currentOutOfStateTuition, costID)
    VALUES (p_inState, p_outState, p_costID);
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS update_cost;
DELIMITER //
CREATE PROCEDURE update_cost(
    IN p_costID INT,
    IN p_feesInput DECIMAL(7,2),
    IN p_boardingInput DECIMAL(7,2),
    IN p_mealsInput DECIMAL(7,2),
    IN p_booksInput DECIMAL(6,2)
)
BEGIN
    UPDATE COSTS
    SET fees = p_feesInput,
        boarding = p_boardingInput,
        meals = p_mealsInput,
        books = p_booksInput
    WHERE costID = p_costID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS remove_cost;
DELIMITER //
CREATE PROCEDURE remove_cost(
    IN p_costID INT
)
BEGIN
    DELETE FROM COSTS WHERE costID = p_costID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS remove_tuition;
DELIMITER //
CREATE PROCEDURE remove_tuition(
    IN p_tuitionID INT
)
BEGIN
    DELETE FROM TUITION WHERE tuitionID = p_tuitionID;
END //
DELIMITER ;
-- update tuition details
DROP PROCEDURE IF EXISTS update_tuition_by_id;
DELIMITER //
CREATE PROCEDURE update_tuition_by_id(
    IN p_tuitionID INT,
    IN p_inStateInput DECIMAL(8,2),
    IN p_outStateInput DECIMAL(8,2)
)
BEGIN
    UPDATE TUITION
    SET currentInStateTuition = p_inStateInput,
        currentOutOfStateTuition = p_outStateInput
    WHERE tuitionID = p_tuitionID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS add_university;
DELIMITER //

CREATE PROCEDURE add_university(
    IN p_universityName VARCHAR(50),
    IN p_location VARCHAR(50),
    IN p_campusType ENUM('Urban','Suburban','Rural'),
    IN p_acceptanceRate DECIMAL(5,2),
    IN p_athleticClassification ENUM('NCAA Division I','NCAA Division II','NCAA Division III','NAIA')
)
BEGIN
    DECLARE new_universityID INT;
    INSERT INTO UNIVERSITIES (universityName, location, campusType, acceptanceRate, athleticClassification)
    VALUES (p_universityName, p_location, p_campusType, p_acceptanceRate, p_athleticClassification);
    SET new_universityID = LAST_INSERT_ID();
END //
DELIMITER ;

-- added cost and tuition options for inserting a university- will use defaults for majors and athletics. 

DROP PROCEDURE IF EXISTS add_university_OLD;
DELIMITER //
CREATE PROCEDURE add_university_OLD(
    IN p_universityName VARCHAR(50),
    IN p_location VARCHAR(50),
    IN p_campusType ENUM('Urban','Suburban','Rural'),
    IN p_acceptanceRate DECIMAL(5,2),
    IN p_athleticClassification ENUM('NCAA Division I','NCAA Division II','NCAA Division III','NAIA'),
    IN p_fees DECIMAL(7,2),
    IN p_boarding DECIMAL(7,2),
    IN p_meals DECIMAL(7,2),
    IN p_books DECIMAL(6,2),
    IN p_inStateTuition DECIMAL(8,2),
    IN p_outOfStateTuition DECIMAL(8,2)
    -- **add sports, majors later- maybe use a default set 
)
BEGIN
    DECLARE new_universityID INT;
    DECLARE new_costID INT;
     INSERT INTO UNIVERSITIES (universityName, location, campusType, acceptanceRate, athleticClassification)
    VALUES (p_universityName, p_location, p_campusType, p_acceptanceRate, p_athleticClassification);

    SET new_universityID = LAST_INSERT_ID();

    -- Insert into the costs table
    INSERT INTO COSTS (fees, boarding, meals, books, universityID)
    VALUES (p_fees, p_boarding, p_meals, p_books, new_universityID);

    SET new_costID = LAST_INSERT_ID();

    -- Insert into tuition table linked to the new costs record
    INSERT INTO TUITION (currentInStateTuition, currentOutOfStateTuition, costID)
    VALUES (p_inStateTuition, p_outOfStateTuition, new_costID);

     -- Default majors (IDs 1, 2, 5) Computer Science, BA, Psychology
    INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID) VALUES (new_universityID, 1);
    INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID) VALUES (new_universityID, 2);
    INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID) VALUES (new_universityID, 5);

    -- Default sports (IDs 1, 2, 3, 10) - Football, M Basketball, W Basketball, Coed Swimmming
    INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID) VALUES (new_universityID, 1);
    INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID) VALUES (new_universityID, 2);
    INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID) VALUES (new_universityID, 3);
    INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID) VALUES (new_universityID, 10);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS update_university;
DELIMITER //
CREATE PROCEDURE update_university(
    IN p_universityID INT,
    IN p_universityName VARCHAR(50),
    IN p_location VARCHAR(50),
    IN p_campusType ENUM('Urban','Suburban','Rural'),
    IN p_acceptanceRate DECIMAL(5,2),
    IN p_athleticClassification ENUM('NCAA Division I','NCAA Division II','NCAA Division III','NAIA')
)
BEGIN
    UPDATE UNIVERSITIES
    SET universityName = p_universityName,
        location = p_location,
        campusType = p_campusType,
        acceptanceRate = p_acceptanceRate,
        athleticClassification = p_athleticClassification
    WHERE universityID = p_universityID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS remove_university;
DELIMITER //
CREATE PROCEDURE remove_university(IN p_universityID INT)
BEGIN
    DELETE FROM UNIVERSITIES WHERE universityID = p_universityID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS select_majors;
DELIMITER //
CREATE PROCEDURE select_majors()
BEGIN
    SELECT majorID, program, level FROM MAJORS;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS select_sports;
DELIMITER //
CREATE PROCEDURE select_sports()
BEGIN
    SELECT sportID, sportName, sportType FROM ATHLETICS;
END //
DELIMITER ;


-- reset database
DROP PROCEDURE IF EXISTS sp_reset_schema_and_data;
DELIMITER //

CREATE PROCEDURE sp_reset_schema_and_data()
BEGIN
-- drop in FK-safe order
  DROP TABLE IF EXISTS UNIVERSITIES_HAS_ATHLETICS;
  DROP TABLE IF EXISTS UNIVERSITIES_HAS_MAJORS;
  DROP TABLE IF EXISTS TUITION;
  DROP TABLE IF EXISTS COSTS;
  DROP TABLE IF EXISTS ATHLETICS;
  DROP TABLE IF EXISTS MAJORS;
  DROP TABLE IF EXISTS UNIVERSITIES;

  -- recreate each table 
  CREATE TABLE UNIVERSITIES (
    universityID INT AUTO_INCREMENT PRIMARY KEY,
    universityName VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    campusType VARCHAR(50) NOT NULL,
    acceptanceRate DECIMAL(5,2) NOT NULL,
    athleticClassification VARCHAR(50) NOT NULL
  );

  CREATE TABLE MAJORS (
    majorID INT AUTO_INCREMENT PRIMARY KEY,
    level VARCHAR(50) NOT NULL,
    program VARCHAR(255) NOT NULL
  );

  CREATE TABLE ATHLETICS (
    sportID INT AUTO_INCREMENT PRIMARY KEY,
    sportName VARCHAR(100) NOT NULL,
    sportType VARCHAR(50) NOT NULL
  );

  CREATE TABLE COSTS (
    costID INT AUTO_INCREMENT PRIMARY KEY,
    fees DECIMAL(10,2) NOT NULL,
    boarding DECIMAL(10,2) NOT NULL,
    meals DECIMAL(10,2) NOT NULL,
    books DECIMAL(10,2) NOT NULL,
    universityID INT NOT NULL,
    FOREIGN KEY (universityID) REFERENCES UNIVERSITIES(universityID)
      ON DELETE CASCADE
  );

  CREATE TABLE TUITION (
    tuitionID INT AUTO_INCREMENT PRIMARY KEY,
    currentInStateTuition DECIMAL(10,2) NOT NULL,
    currentOutOfStateTuition DECIMAL(10,2) NOT NULL,
    costID INT NOT NULL,
    FOREIGN KEY (costID) REFERENCES COSTS(costID)
      ON DELETE CASCADE
  );

  CREATE TABLE UNIVERSITIES_HAS_MAJORS (
    universityID INT NOT NULL,
    majorID INT NOT NULL,
    PRIMARY KEY (universityID, majorID),
    FOREIGN KEY (universityID) REFERENCES UNIVERSITIES(universityID)
      ON DELETE CASCADE,
    FOREIGN KEY (majorID) REFERENCES MAJORS(majorID)
      ON DELETE CASCADE
  );

  CREATE TABLE UNIVERSITIES_HAS_ATHLETICS (
    universityID INT NOT NULL,
    sportID INT NOT NULL,
    PRIMARY KEY (universityID, sportID),
    FOREIGN KEY (universityID) REFERENCES UNIVERSITIES(universityID)
      ON DELETE CASCADE,
    FOREIGN KEY (sportID) REFERENCES ATHLETICS(sportID)
      ON DELETE CASCADE
  );

    -- recreate schema
 INSERT INTO UNIVERSITIES
(universityName, location, campusType, acceptanceRate, athleticClassification)
VALUES
('Oregon State University', 'Corvallis, OR', 'Suburban', 79.00, 'NCAA Division I'),
('University of California, Los Angeles', 'Los Angeles, CA', 'Urban', 9.00, 'NCAA Division I'),
('Washington University in St. Louis', 'St. Louis, MO', 'Suburban', 11.00, 'NCAA Division III'),
('New York University', 'New York, NY', 'Urban', 13.00, 'NCAA Division III'),
('Howard University', 'Washington, DC', 'Urban', 35.00, 'NCAA Division I'),
('Florida A&M University', 'Tallahassee, FL', 'Urban', 33.00, 'NCAA Division I'),
('Dartmouth College', 'Hanover, NH', 'Rural', 6.00, 'NCAA Division I');
 

INSERT INTO COSTS (fees, boarding, meals, books, universityID)
VALUES
(2300.00, 13200.00, 6400.00, 1200.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University')),
(1500.00, 17600.00, 6900.00, 1641.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles')),
(1350.00, 14500.00, 7700.00, 1304.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis')),
(2000.00, 18200.00, 7600.00, 1470.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University')),
(1900.00, 14200.00, 6660.00, 1360.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University')),
(1200.00, 18100.00, 6400.00, 1138.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University')),
(2318.00, 12579.00, 8341.00, 1005.00,
   (SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'));

INSERT INTO TUITION (currentInStateTuition, currentOutOfStateTuition, costID)
VALUES
(15246.00, 33798.00,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'))),
(15700.00, 37602.00,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'))),
(68240.00, 68240.00,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'))),
(62796.00, 62796.00,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'))),
(37996.00, 37996.00,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'))),
(5697.30, 17585.40,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'))),
(69207.00, 69207.00,
   (SELECT costID FROM COSTS WHERE universityID = 
       (SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College')));


-- sportID mapping
 
-- 1  = Football (Men)            | Team
-- 2  = Basketball (Men)          | Team
-- 3  = Basketball (Women)        | Team
-- 4  = Track and Field (Men)     | Individual
-- 5  = Track and Field (Women)   | Individual
-- 6  = Soccer (Men)              | Team
-- 7  = Soccer (Women)            | Team
-- 8  = Swimming (Men)            | Individual
-- 9  = Swimming (Women)          | Individual
-- 10 = Swimming (Coed)           | Individual


INSERT INTO ATHLETICS (sportName, sportType)
VALUES
('Football (Men)', 'Team'),
('Basketball (Men)', 'Team'),
('Basketball (Women)', 'Team'),
('Track and Field (Men)', 'Individual'),
('Track and Field (Women)', 'Individual'),
('Soccer (Men)', 'Team'),
('Soccer (Women)', 'Team'),
('Swimming (Men)', 'Individual'),
('Swimming (Women)', 'Individual'),
('Swimming (Coed)', 'Individual');


 
-- majorID mapping

-- 1  = Undergraduate | Computer Science
-- 2  = Undergraduate | Business Administration
-- 3  = Graduate      | Public Health
-- 4  = Graduate      | Mechanical Engineering
-- 5  = Undergraduate | Psychology

INSERT INTO MAJORS
(level, program)
VALUES
('Undergraduate', 'Computer Science'),
('Undergraduate', 'Business Administration'),
('Graduate', 'Public Health'),
('Graduate', 'Mechanical Engineering'),
('Undergraduate', 'Psychology');


INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT majorID FROM MAJORS WHERE program='Computer Science' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT majorID FROM MAJORS WHERE program='Business Administration' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT majorID FROM MAJORS WHERE program='Computer Science' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT majorID FROM MAJORS WHERE program='Psychology' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT majorID FROM MAJORS WHERE program='Mechanical Engineering' AND level='Graduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT majorID FROM MAJORS WHERE program='Public Health' AND level='Graduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT majorID FROM MAJORS WHERE program='Business Administration' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT majorID FROM MAJORS WHERE program='Psychology' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'),
 (SELECT majorID FROM MAJORS WHERE program='Public Health' AND level='Graduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'),
 (SELECT majorID FROM MAJORS WHERE program='Computer Science' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT majorID FROM MAJORS WHERE program='Computer Science' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT majorID FROM MAJORS WHERE program='Psychology' AND level='Undergraduate')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT majorID FROM MAJORS WHERE program='Mechanical Engineering' AND level='Graduate'));


-- Oregon State University (OSU)
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Oregon State University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));


-- UCLA
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='University of California, Los Angeles'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));


INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Washington University in St. Louis'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));

-- New York University (NYU)
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='New York University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));


-- Howard University
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Howard University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));

-- Florida A&M University (FAMU)
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Florida A&M University'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));

-- Dartmouth College
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES
((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Football (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Basketball (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Track and Field (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Soccer (Men)')),

((SELECT universityID FROM UNIVERSITIES WHERE universityName='Dartmouth College'),
 (SELECT sportID FROM ATHLETICS WHERE sportName='Swimming (Men)'));

END //
DELIMITER ;

-- Curry, M. (2025). CS340: Introduction to Databases – Week 6 module. Canvas. Oregon State University.