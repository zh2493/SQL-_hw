
#QUESTION 1 - LARGEST WEIGHT CHANGE BETWEEN TWO CONSECUTIVE VISITS
USE weight;

SELECT v1.participant_id, v1.visit_type, v1.weight, v2.visit_type, v2.weight, (v1.weight - v2.weight) AS diff
FROM visits AS v1
INNER JOIN visits AS v2
    USING (participant_id)
WHERE v1.visit_type < v2.visit_type AND v2.visit_type = v1.visit_type + 4
ORDER BY diff DESC;

#####################################
# USE THE DATA BELOW FOR QUESTION 2 #
#####################################

CREATE SCHEMA clinics;

USE clinics;

CREATE TABLE clinics (
	clinic_id VARCHAR(6), 
    location_cat VARCHAR(8)
);

INSERT INTO clinics 
	VALUES
	('ABC','rural'),
	('DEFG','suburban'),
	('HIJKL','urban'),
	('MNOPQR','suburban'),
	('STUV','rural'),
	('WXYZA','rural'),
	('BCDEF','urban'),
	('GHIJK','suburban'),
	('LMN',	'suburban'),
	('OPQ',	'rural'),
    ('RSTNLE', 'urban');

CREATE TABLE participants (
	partic_id TINYINT(3), 
	clinic_id VARCHAR(6)
);

INSERT INTO participants
VALUES
('70','ABC'),
('46','HIJKL'),
('15','MNOPQR'),
('6','STUV'),
('6','STUV'),
('82','STUV'),
('9','DEFG'),
('52','WXYZA'),
('29','STUV'),
('3','GHIJK'),
('60','LMN'),
('88','DEFG'),
('1','HIJKL'),
('69','HIJKL'),
('59','STUV'),
('36','WXYZA'),
('24','ABC'),
('67','MNOPQR'),
('71','HIJKL'),
('19','STUV'),
('34','LMN'),
('25','LMN'),
('45','OPQ'),
('49','HIJKL'),
('31','LMN'),
('13','DEFG'),
('83','WXYZA'),
('18','WXYZA'),
('73','WXYZA'),
('22','STUV'),
('61','OPQ'),
('90','GHIJK'),
('78','MNOPQR'),
('80','LMN'),
('91','ABC'),
('33','HIJKL'),
('16','OPQ'),
('14','WXYZA'),
('77','WXYZA'),
('50','WXYZA'),
('32','WXYZA'),
('54','RSTUVW'),
('97','ABC'),
('99','DEFG'),
('55','STUV'),
('7','OPQ'),
('66','GHIJK'),
('96','HIJKL'),
('44','RSTUVW'),
('10','MNOPQR'),
('98','STUV'),
('11','GHIJK'),
('40','STUV'),
('2','HIJKL'),
('47','MNOPQR'),
('26','LMN'),
('95','OPQ'),
('68','OPQ'),
('76','OPQ'),
('94','MNOPQR'),
('35','RSTUVW'),
('62','RSTUVW'),
('17','HIJKL'),
('4','GHIJK'),
('30','GHIJK'),
('39','OPQ'),
('89','LMN'),
('87','HIJKL'),
('57','HIJKL'),
('74','MNOPQR'),
('85','HIJKL'),
('100','STUV'),
('53','STUV'),
('43','HIJKL'),
('92','ABC'),
('56','GHIJK'),
('58','LMN'),
('23','OPQ'),
('64','LMN'),
('75','LMN'),
('79','MNOPQR'),
('8','DEFG'),
('84','DEFG'),
('37','DEFG'),
('5','RSTUVW'),
('86','HIJKL'),
('28','GHIJK'),
('48','LMN'),
('27','WXYZA'),
('12','STUV'),
('63','DEFG'),
('20','STUV'),
('81','STUV'),
('38','ABC'),
('72','OPQ'),
('21','WXYZA'),
('42', NULL),
('51','HIJKL'),
('41','LMN'),
('95','OPQ'),
('93','DEFG');

###############################################



#QUESTION 2 - ACHIEVING A FULL JOIN IN MYSQL
SELECT c.clinic_id, c.location_cat, p.clinic_id, p.partic_id
FROM clinics AS c
	LEFT JOIN participants AS p
	USING (clinic_id)
    WHERE p.clinic_id IS NULL

UNION

SELECT c.clinic_id, c.location_cat, p.clinic_id, p.partic_id
FROM clinics AS c
	RIGHT JOIN participants AS p
	USING (clinic_id)
    WHERE (c.clinic_id IS NULL AND p.clinic_id IS NOT NULL) OR (p.partic_id IS NOT NULL AND p.clinic_id IS NULL);

#####################################
# USE THE DATA BELOW FOR QUESTION 3 #
#####################################

CREATE SCHEMA class;

USE class;

CREATE TABLE teaching_team (
	teacher_name VARCHAR(8)
);

INSERT INTO teaching_team
	VALUES
    ('Anjile'),
    ('Ifrah'),
    ('Charlene');

CREATE TABLE student (
	student_name VARCHAR(15)
);

INSERT INTO student
	VALUES
    ('Jessica'),
    ('Jiaqi'),
    ('Qixiang'),
    ('Xuanhe'),
    ('Ling'),
    ('Kaiyu'),
    ('Ziqian'),
    ('Fiona'),
    ('Yanhao'),
    ('Yiyao'),
    ('Yujia'),
    ('Yuechen'),
    ('Mengfan'),
    ('Jing'),
    ('Anna'),
    ('Caroline'),
    ('Yuan'),
    ('Amanda'),
    ('Daniel'),
    ('Saryu'),
    ('Suhani'),
    ('Zichen'),
    ('Jocelyn'),
    ('Weize'),
    ('Sze Pui'),
    ('Eric'),
    ('Rona'),
    ('Chaoqi'),
    ('Ke'),
    ('Lydia'),
    ('Wenyu'),
    ('Yiwen'),
    ('Qing');
    
#QUESTION 3 - TEACHING TEAM GRADING ROSTER
WITH grading_list AS
(
SELECT student_name, teacher_name
FROM student 
    CROSS JOIN teaching_team
WHERE (student_name REGEXP '^[A-H]' AND teacher_name = 'Anjile')
OR (student_name REGEXP '^[I-P]' AND teacher_name = 'Ifrah')  
OR (student_name REGEXP '^[Q-Z]' AND teacher_name = 'Charlene')
ORDER BY teacher_name   
   )

SELECT *, COUNT(student_name) AS student_count 
FROM grading_list
GROUP BY teacher_name;
