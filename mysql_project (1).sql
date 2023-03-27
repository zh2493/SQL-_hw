CREATE SCHEMA covid_pj;

USE covid_pj;

    
#state lookup table
CREATE TABLE state (
	PRIMARY KEY (state_id),
    state_id TINYINT(2) UNSIGNED AUTO_INCREMENT,
    state_name VARCHAR(255)
);

#Patient table and index
CREATE TABLE patient (
	PRIMARY KEY (patient_id),
    patient_id SMALLINT(5) UNSIGNED,
    age TINYINT(2) UNSIGNED,
    weight FLOAT(4,1) UNSIGNED,
    state TINYINT(2) UNSIGNED,
    dietary TINYINT(1) UNSIGNED,
    vc_type TINYINT(1) UNSIGNED,
    FOREIGN KEY (state) REFERENCES state(state_id) ON UPDATE CASCADE
);

CREATE INDEX age
	ON patient(age);
    
CREATE INDEX weight
	ON patient(weight);
    
DELIMITER //   
CREATE TRIGGER trigger_patient
	BEFORE INSERT ON patient
	FOR EACH ROW
BEGIN
	/*Limit age range: >18*/
    IF NEW.age < 18 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Age must bigger than 18';
	END IF;
    
END//
 
 
  
#Visit table and indexes
CREATE TABLE visit (
	PRIMARY KEY (patient_id,visit_date),
    patient_id SMALLINT(5) UNSIGNED,
    visit_date DATE,
    pcr_test TINYINT(1) UNSIGNED,
    fever TINYINT(1) UNSIGNED,
    short_breath TINYINT(1) UNSIGNED,
    cough TINYINT(1) UNSIGNED,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON UPDATE CASCADE
);

CREATE INDEX visit_date
	ON visit(visit_date);
    
CREATE INDEX pcr_test
	ON visit(pcr_test);

#Trigger for visit table
DELIMITER //

CREATE TRIGGER trigger_visit_date
	BEFORE INSERT ON visit
	FOR EACH ROW
BEGIN
	/*Limit visit_date to dates between 1/21/2020 and today*/
	IF NEW.visit_date < '2020-01-21' OR NEW.visit_date > CURDATE() THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Invalid Event Date: Please enter a date between 1/21/2020 and today';
	END IF;

END//


#Enter data into state table
INSERT INTO state (state_id, state_name) 
VALUES
(1, 'Alabama'),
(2, 'Alaska'),
(3, 'Arizona'),
(4, 'Arkansas'),
(5, 'California'),
(6, 'Colorado'),
(7, 'Connecticut'),
(8, 'Delaware'),
(9, 'District of Columbia'),
(10, 'Florida'),
(11, 'Georgia'),
(12, 'Hawaii'),
(13, 'Idaho'),
(14, 'Illinois'),
(15, 'Indiana'),
(16, 'Iowa'),
(17, 'Kansas'),
(18, 'Kentucky'),
(19, 'Louisiana'),
(20, 'Maine'),
(21, 'Maryland'),
(22, 'Massachusetts'),
(23, 'Michigan'),
(24, 'Minnesota'),
(25, 'Mississippi'),
(26, 'Missouri'),
(27, 'Montana'),
(28, 'Nebraska'),
(29, 'Nevada'),
(30, 'New Hampshire'),
(31, 'New Jersey'),
(32, 'New Mexico'),
(33, 'New York'),
(34, 'North Carolina'),
(35, 'North Dakota'),
(36, 'Ohio'),
(37, 'Oklahoma'),
(38, 'Oregon'),
(39, 'Pennsylvania'),
(40, 'Rhode Island'),
(41, 'South Carolina'),
(42, 'South Dakota'),
(43, 'Tennessee'),
(44, 'Texas'),
(45, 'Utah'),
(46, 'Vermont'),
(47, 'Virginia'),
(48, 'Washington'),
(49, 'West Virginia'),
(50, 'Wisconsin'),
(51, 'Wyoming');

#Enter data into patient table
INSERT INTO patient (patient_id, age, weight, state,dietary,vc_type)
	VALUES
	(1,	28,	110.5, 33, 1, 1),
	(2,	40,	140.0, 10, 1, 2),
	(3,	35,	100.5, 5, 2, 1);

#Enter data into visit table
INSERT INTO visit (patient_id, visit_date, pcr_test, fever, short_breath, cough)
	VALUES
    (1, '2021-02-01', 1, 1, 0, 1),
    (2, '2021-10-05', 1, 0, 0, 0);

#########
# QUERY #
#########

# VIEW

CREATE VIEW age_by_result AS 
	SELECT v.pcr_test, AVG(p.age) OVER() AS avg_age,
    CASE
			WHEN v.pcr_test = 0 THEN 'Negative'
			WHEN v.pcr_test = 1 THEN 'Positive'
			ELSE NULL
		END AS test_result
	FROM patient AS p
    INNER JOIN visit AS v 
        USING (patient_id)
    GROUP BY v.pcr_test;

#TEMPORARY TABLE
CREATE TEMPORARY TABLE patients_confirmed AS
(
	SELECT p.patient_id, p.age, p.weight, p.vc_type
	FROM patient AS p
	LEFT JOIN visit AS v
		USING (patient_id)
	WHERE v.patient_id IS NULL 
);

SELECT *
FROM patients_confirmed;

#CTE
WITH new_case_inf AS
(
	SELECT p.patient_id, p.age, p.weight, p.state, p.dietary, p.vc_type, v.pcr_test, v.visit_date, v.fever, v.short_breath, v.cough
	FROM patient AS p 
	LEFT JOIN visit AS v 
		USING (patient_id)
)

SELECT patient_id,age,dietary,pcr_test
FROM new_case_inf
WHERE pcr_test = 1;

