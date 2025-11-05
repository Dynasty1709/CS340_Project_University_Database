-- for required procedures
DELIMITER //
CREATE PROCEDURE insertUniversityMajor(IN uniID INT, IN majID INT)
BEGIN
  INSERT INTO UNIVERSITIES_HAS_MAJORS (universityID, majorID)
  VALUES (uniID, majID);
END //
DELIMITER ;