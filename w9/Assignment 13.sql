#Add a new schema called `weight`
CREATE SCHEMA weight;

#Write a statement that applies all subsequent code to the weighin schema
USE weight;


/*CREATE THE FOLLOWING TABLES IN AN APPROPRIATE ORDER TO ALLOW CREATION OF FOREIGN KEYS IN THE CREATE TABLE STATEMENT.
  ADD THE RELEVANT SQL CODE TO CREATE EACH TABLE (AND INDEXES) UNDER EACH COMMENT*/

#Participants table and index
CREATE TABLE participants(
    PRIMARY KEY(participants_id),
    participants_id SMALLINT(5) UNSIGNED AUTO_INCREMENT,
    tx_group TINYINT(1) UNSIGNED,
    age TINYINT(2) UNSIGNED,
    height FLOAT(3,2) UNSIGNED,
    prediabetes TINYINT(1) UNSIGNED
    );

CREATE INDEX tx_group
    ON participants(tx_group);

#Visits table and indexes
CREATE TABLE visits(
    PRIMARY KEY(visit_id),
    visit_id MEDIUMINT(7) UNSIGNED AUTO_INCREMENT,
    participants_id SMALLINT(5) UNSIGNED,
    visit_type TINYINT(1) UNSIGNED,
    weight FLOAT(5,2) UNSIGNED
);
ALTER TABLE visits
    ADD FOREIGN KEY(participants_id) REFERENCES participants(participants_id)
        ON UPDATE CASCADE;

CREATE INDEX visit_type
    ON visits(visit_type);

CREATE INDEX weight
    ON visits(weight);
    
#Adverse Events lookup table
CREATE TABLE adverse_events(
    PRIMARY KEY(adverse_event_id),
    adverse_event_id TINYINT(1) UNSIGNED AUTO_INCREMENT,
    adverse_event_type VARCHAR(255)
    );

#Adverse Event Log table and indexes
CREATE TABLE adverse_event_log(
    PRIMARY KEY(event_log_id),
    event_log_id MEDIUMINT(7) UNSIGNED AUTO_INCREMENT,
    visit_id MEDIUMINT(7) UNSIGNED,
    adverse_event_id TINYINT(1) UNSIGNED,
    event_date DATE,
    FOREIGN KEY(visit_id) REFERENCES visits(visit_id) ON UPDATE CASCADE,
    FOREIGN KEY(adverse_event_id) REFERENCES adverse_events(adverse_event_id) ON UPDATE CASCADE
    );
    
CREATE UNIQUE INDEX unique_index_ael
    ON adverse_event_log(visit_id, adverse_event_id, event_date);

CREATE INDEX adverse_event_id
    ON adverse_event_log(adverse_event_id);
    
CREATE INDEX event_date
    ON adverse_event_log(event_date); 
  
 #Medications lookup table
 CREATE TABLE medications(
    PRIMARY KEY(medications_id),
    medications_id SMALLINT(5) UNSIGNED AUTO_INCREMENT,
    medication_name VARCHAR(255)
    );

#Current Meds table and indexes
CREATE TABLE current_meds(
    PRIMARY KEY(current_med_id),
    current_med_id MEDIUMINT(7) UNSIGNED AUTO_INCREMENT,
    visit_id MEDIUMINT(7) UNSIGNED,
    medications_id SMALLINT(5) UNSIGNED,
    FOREIGN KEY(visit_id) REFERENCES visits(visit_id) ON UPDATE CASCADE,
    FOREIGN KEY(medications_id) REFERENCES medications(medications_id) ON UPDATE CASCADE
    );
    
CREATE UNIQUE INDEX unique_index_meds
    ON current_meds(visit_id, medications_id);

CREATE INDEX medications_id
    ON current_meds(medications_id);
     

#Diagnoses lookup table
 CREATE TABLE diagnoses(
    PRIMARY KEY(diagnoses_code),
    diagnoses_code SMALLINT(5) UNSIGNED AUTO_INCREMENT,
    diagnoses_name VARCHAR(255)
    );

#Current Diagnoses table and indexes
CREATE TABLE current_dxs(
    PRIMARY KEY(current_dx_id),
   current_dx_id MEDIUMINT(7) UNSIGNED AUTO_INCREMENT,
    visit_id MEDIUMINT(7) UNSIGNED,
    diagnoses_code SMALLINT(5) UNSIGNED,
    FOREIGN KEY(visit_id) REFERENCES visits(visit_id) ON UPDATE CASCADE,
    FOREIGN KEY(diagnoses_code) REFERENCES diagnoses(diagnoses_code) ON UPDATE CASCADE
    );

CREATE UNIQUE INDEX unique_index_dxs
    ON current_dxs(visit_id, diagnoses_code);

CREATE INDEX diagnoses_code
    ON current_dxs(diagnoses_code);


/*REMEMBER TO CREATE AND SUBMIT THE RESULTING EER DIAGRAM ONCE TABLES HAVE BEEN CREATED*/


    




    