#!/usr/bin/env bash

set -e

# create the user, the database and set up the access
echo "Creating database: $POSTGRES_DATABANK_DB and user: $POSTGRES_USER"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL

CREATE DATABASE $POSTGRES_DATABANK_DB;
ALTER ROLE $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD'; 
ALTER ROLE $POSTGRES_USER WITH LOGIN;
GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DATABANK_DB TO $POSTGRES_USER;

EOSQL

# create tables for the MIMIC NOTEEVENTS csv records
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DATABANK_DB"<<-EOSQL

--------------------------------------------------------
--  DDL for Table ADMISSIONS
--------------------------------------------------------

DROP TABLE IF EXISTS ADMISSIONS CASCADE;
CREATE TABLE ADMISSIONS
(
  ROW_ID INT NOT NULL,
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  ADMITTIME TIMESTAMP(0) NOT NULL,
  DISCHTIME TIMESTAMP(0) NOT NULL,
  DEATHTIME TIMESTAMP(0),
  ADMISSION_TYPE VARCHAR(50) NOT NULL,
  ADMISSION_LOCATION VARCHAR(50) NOT NULL,
  DISCHARGE_LOCATION VARCHAR(50) NOT NULL,
  INSURANCE VARCHAR(255) NOT NULL,
  LANGUAGE VARCHAR(10),
  RELIGION VARCHAR(50),
  MARITAL_STATUS VARCHAR(50),
  ETHNICITY VARCHAR(200) NOT NULL,
  EDREGTIME TIMESTAMP(0),
  EDOUTTIME TIMESTAMP(0),
  DIAGNOSIS VARCHAR(255),
  HOSPITAL_EXPIRE_FLAG SMALLINT,
  HAS_CHARTEVENTS_DATA SMALLINT NOT NULL,
  CONSTRAINT adm_rowid_pk PRIMARY KEY (ROW_ID),
  CONSTRAINT adm_hadm_unique UNIQUE (HADM_ID)
);

--------------------------------------------------------
--  DDL for Table LABEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS LABEVENTS CASCADE;
CREATE TABLE LABEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ITEMID INT NOT NULL,
	CHARTTIME TIMESTAMP(0),
	VALUE VARCHAR(200),
	VALUENUM DOUBLE PRECISION,
	VALUEUOM VARCHAR(20),
	FLAG VARCHAR(20),
	CONSTRAINT labevents_rowid_pk PRIMARY KEY (ROW_ID)
);

--------------------------------------------------------
--  DDL for Table NOTEEVENTS
--------------------------------------------------------

DROP TABLE IF EXISTS NOTEEVENTS CASCADE;
CREATE TABLE NOTEEVENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	CHARTDATE TIMESTAMP(0),
	CHARTTIME TIMESTAMP(0),
	STORETIME TIMESTAMP(0),
	CATEGORY VARCHAR(50),
	DESCRIPTION VARCHAR(255),
	CGID INT,
	ISERROR CHAR(1),
	TEXT TEXT,
	CONSTRAINT noteevents_rowid_pk PRIMARY KEY (ROW_ID)
);

--------------------------------------------------------
--  DDL for Table PATIENTS
--------------------------------------------------------

DROP TABLE IF EXISTS PATIENTS CASCADE;
CREATE TABLE PATIENTS
(
  ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	GENDER VARCHAR(5) NOT NULL,
	DOB TIMESTAMP(0) NOT NULL,
	DOD TIMESTAMP(0),
	DOD_HOSP TIMESTAMP(0),
	DOD_SSN TIMESTAMP(0),
	EXPIRE_FLAG INT NOT NULL,
	CONSTRAINT pat_subid_unique UNIQUE (SUBJECT_ID),
	CONSTRAINT pat_rowid_pk PRIMARY KEY (ROW_ID)
) ;

--------------------------------------------------------
/*

CREATE TABLE medical_reports (
	cid INTEGER PRIMARY KEY,
	sampleid INTEGER NOT NULL,
	typeid INTEGER NOT NULL,
	dct TIMESTAMP NOT NULL,
	filename VARCHAR(256) NOT NULL,
	binarydoc BYTEA NOT NULL
) ;

CREATE TABLE medical_reports_processed (
	cid INTEGER REFERENCES medical_reports,
	dct TIMESTAMP NOT NULL,
	output TEXT
) ;


/*  Create views for CogStack */

CREATE VIEW reports_processed_view AS
	SELECT 
		cid,
		dct,
		output::JSON ->> 'X-PDFPREPROC-OCR-APPLIED' AS ocr_status,
		output::JSON ->> 'tika_output' AS tika_output
	FROM
		medical_reports_processed
	;

*/

EOSQL

# create the observations view so that we can look only at data of interest form multiple columns (used for kibana, elasticsearch, medcat etc.)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DATABANK_DB"<<-EOSQL

--
-- Name: observations_view; Type: VIEW; Schema: public;
--

create view public.observations_view as
select  patient.subject_id,
       admission.diagnosis,
       admission.admission_type,
       noteevent.text,
       noteevent.row_id,
       noteevent.storetime,
       noteevent.charttime,
       admission.admittime,
       labevent.valuenum,
       labevent.valueuom,
       labevent.flag
from public.admissions as admission,
     public.patients as patient,
     public.noteevents as noteevent,
     public.labevents as labevent
where (
       patient.subject_id = noteevent.subject_id
       and patient.subject_id = admission.subject_id
       and patient.subject_id = labevent.subject_id
    );

EOSQL

# Load date from csv files into the previously created tables.
echo "Loading data from CSV files."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DATABANK_DB"<<-EOSQL

	\copy NOTEEVENTS from '/data/NOTEEVENTS.csv' delimiter ',' csv header NULL ''; 
	\copy ADMISSIONS from '/data/ADMISSIONS.csv' delimiter ',' csv header NULL '';
	\copy LABEVENTS from '/data/LABEVENTS.csv' delimiter ',' csv header NULL ''; 
	\copy PATIENTS from '/data/PATIENTS.csv' delimiter ',' csv header NULL ''; 
 
EOSQL


echo "Restoring DB from dump" 

# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DATABANK_DB" -a -f "/data/db_samples-pdf-img-small.sql"

# cleanup
echo "Done with initializing the sample data."

