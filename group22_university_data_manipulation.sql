-- Grader notes: we are leveraging displaying information about institutions
-- to help ulfill the select requirements. 

-- Select universities (dropdown)
SELECT universityID, universityName FROM UNIVERSITIES;

-- Select majors by institution
SELECT M.program, M.level
FROM MAJORS M
JOIN UNIVERSITIES_HAS_MAJORS UM ON M.majorID = UM.majorID
WHERE UM.universityID = @universityIDInput;

-- Add a major to an institution
INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID)
VALUES (@universityIDInput, @majorIDInput);

-- Change major name
UPDATE MAJORS
SET program = @newProgramNameInput
WHERE majorID = @majorIDInput;

-- remove a major from an institution
DELETE FROM UNIVERSITIES_HAS_MAJORS
WHERE universityID = @universityIDInput AND majorID = @majorIDInput;

-- display sports by institution
SELECT A.sportName, A.sportType
FROM ATHLETICS A
JOIN UNIVERSITIES_HAS_ATHLETICS UA ON A.sportID = UA.sportID
WHERE UA.universityID = @universityIDInput;

-- add a sport to an institution
INSERT INTO UNIVERSITIES_HAS_ATHLETICS (universityID, sportID)
VALUES (@universityIDInput, @sportIDInput);

-- remove a sport from an institution
DELETE FROM UNIVERSITIES_HAS_ATHLETICS
WHERE universityID = @universityIDInput AND sportID = @sportIDInput;

-- select cost details by institution
SELECT C.fees, C.boarding, C.meals, C.books, T.currentInStateTuition, T.currentOutOfStateTuition
FROM COSTS C
JOIN TUITION T ON C.costID = T.costID
WHERE C.universityID = @universityIDInput;

-- update cost details
UPDATE COSTS
SET fees = @feesInput, boarding = @boardingInput, meals = @mealsInput, books = @booksInput
WHERE universityID = @universityIDInput;

-- update tuition details
UPDATE TUITION
SET currentInStateTuition = @inStateInput, currentOutOfStateTuition = @outStateInput
WHERE costID = @costIDInput;

-- Curry, M. (2025). CS340: Introduction to Databases – Week 6 module. Canvas. Oregon State University.