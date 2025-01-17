-- CTSA CLIC Metric 
-- CDM: i2b2/ACT 
-- RDB Dialect: Oracle
-- Creation Date: 4/1/2021
-- Ontology Version: 4.0

-- Caveats:  ACT does not support the following by default, placeholders have been provided if you support the domain locally
--           NLP, Notes, SNOMED Procedures or Diagnosis
-- Multifact table
-- Indexes

SELECT TO_CHAR (SYSDATE, 'MON DD HH24:MI:SS') FROM DUAL;

--select * from CTSA_CLIC_METRIC;
-- Create dest table
DROP TABLE CTSA_CLIC_METRIC;
CREATE TABLE CTSA_CLIC_METRIC (
	variable_name			VARCHAR(100)  NOT NULL,
    one_year            INT   NULL,
	five_year		    INT   NULL
);
COMMIT;

--  Variable: data_model
--  Acceptable values:  1=PCORNet, 2=OMOP, 3=TriNetX, 4=i2b2/ACT

INSERT INTO ctsa_clic_metric
SELECT 
	'data_model' as variable_name
	,'4' as one_year -- 4 = i2b2/ACT
	,'4' as five_year -- 4 = i2b2/ACT
FROM dual;

--Edit this for your site 
--change the edit_this_for_your_site to '0', '1' or null
-- this will error out if not modified
--Answers '0' your site does not have NLP /Notes capability, '1' your site does have NLP / Notes does  have NLP /Notes capability NULL if the model does not support  NLP
INSERT INTO ctsa_clic_metric
SELECT
	'nlp_any' as variable_name
	, edit_this_for_your_site as one_year
	, edit_this_for_your_site as five_year
FROM dual;

-- Unique ENCOUNTERS 
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'total_encounters' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM OBSERVATION_FACT OBS WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM OBSERVATION_FACT OBS WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;


-- Unique PATIENTS 
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'total_patients' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique PATIENTS with gender
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'uniq_pt_with_gender' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM AND (PAT.SEX_CD IS NULL OR PAT.SEX_CD <> 'DEM|SEX:NI')
        WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM AND (PAT.SEX_CD IS NULL OR PAT.SEX_CD <> 'DEM|SEX:NI')
        WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique PATIENTS WITH BIRTH DATES
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'uniq_pt_with_age' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM AND PAT.BIRTH_DATE IS NOT NULL
        WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM AND PAT.BIRTH_DATE IS NOT NULL
        WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- UNIQUE PATIENTS OVER 12
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'total_pt_gt_12' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM 
            AND PAT.BIRTH_DATE IS NOT NULL AND TO_DATE('31-DEC-2020', 'DD-MON-YYYY') - PAT.BIRTH_DATE > 12*365
        WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM 
            AND PAT.BIRTH_DATE IS NOT NULL AND TO_DATE('31-DEC-2020', 'DD-MON-YYYY') - PAT.BIRTH_DATE > 12*365
        WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- UNIQUE PATIENTS WITH IMPLAUSIBLE AGES (TOO YOUNG)
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'uniq_pt_birthdate_in_future' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM AND PAT.BIRTH_DATE > '31-DEC-2021'
        WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM AND PAT.BIRTH_DATE > '31-DEC-2021'
        WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- UNIQUE PATIENTS WITH IMPLAUSIBLE AGES (TOO OLD)
INSERT INTO CTSA_CLIC_METRIC
SELECT
  'uniq_pt_age_over_120' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM 
        AND ((PAT.DEATH_DATE IS NULL AND TO_DATE('31-DEC-2020', 'DD-MON-YYYY') - PAT.BIRTH_DATE > 120*365)
            OR (PAT.DEATH_DATE - PAT.BIRTH_DATE > 120*365))
        WHERE OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
       FROM OBSERVATION_FACT OBS
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM 
        AND ((PAT.DEATH_DATE IS NULL AND TO_DATE('31-DEC-2020', 'DD-MON-YYYY') - PAT.BIRTH_DATE > 120*365)
            OR (PAT.DEATH_DATE - PAT.BIRTH_DATE > 120*365))
        WHERE OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;



-- Unique patients with procedures mapped to SNOMED -- THIS IS NOT SUPPORTED BY ACT - IF YOU HAVE THEM MODIFY PATH ACCORDINGLY 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SNOMED\%'
)
SELECT
  'uniq_pt_snomed_proc' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with procedures mapped to SNOMED -- THIS IS NOT SUPPORTED BY ACT - IF YOU HAVE THEM MODIFY PATH ACCORDINGLY 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SNOMED\%'
)
SELECT
  'uniq_enc_snomed_proc' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with DIAGNOSIS mapped to SNOMED -- THIS IS NOT SUPPORTED BY ACT - IF YOU HAVE THEM MODIFY PATH ACCORDINGLY 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SNOMED\%'
)
SELECT
  'uniq_pt_snomed_dx' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with DIAGNOSIS mapped to SNOMED -- THIS IS NOT SUPPORTED BY ACT - IF YOU HAVE THEM MODIFY PATH ACCORDINGLY 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SNOMED\%'
)
SELECT
  'uniq_enc_snomed_dx' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with a Note -- Not supported by ACT - Change path if your site supports it 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Notes\%'
)
SELECT
  'uniq_pt_note' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with a Note -- Not supported by ACT - Change path if your site supports it 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Notes\%'
)
SELECT
  'uniq_enc_note' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;


-- Unique patients with INSURANCE mapped to STANDARDIZED VALUES
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SDOH\76437-3\%'
)
SELECT
  'uniq_pt_insurance_value_set' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with INSURANCE - UNMAPPED INSURANCE IS NOT COUNTABLE AT THIS TIME
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SDOH\76437-3\%'
)
SELECT
  'uniq_pt_any_insurance_value' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with procedures mapped to ICD 10/9 -- 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\ICD9\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\ICD10\%'
)
SELECT
  'uniq_pt_icd_proc' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with procedures mapped to ICD 10/9 -- 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\ICD9\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\ICD10\%'
)
SELECT
  'uniq_enc_icd_proc' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with labs mapped to LOINC 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_LABS AS (
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Labs\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Lab\%'
)
SELECT
  'uniq_pt_loinc' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique ENCOUNTERS with labs mapped to LOINC 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_LABS AS (
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Labs\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Lab\%'
)
SELECT
  'uniq_enc_loinc' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;


-- Unique patients with medications mapped to RXNORM or NDC 
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_LABS AS (
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\%'
)
SELECT
  'uniq_pt_med_rxnorm' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with medications mapped to RXNORM or NDC
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_LABS AS (
    SELECT DISTINCT CONCEPT_CD as CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\%'
)
SELECT
  'uniq_enc_med_rxnorm' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_LABS MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with diagnosis and conditions mapped to ICD9/10
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Diagnosis\%'
)
SELECT
  'uniq_pt_icd_dx' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with diagnosis and conditions mapped to ICD9/10
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (
    SELECT DISTINCT CONCEPT_CD as CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Diagnosis\%'
)
SELECT
    'uniq_enc_icd_dx' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;


-- Unique patients with procedures mapped to HCPCS and CPT4
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\HCPCS\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\CPT4\%'
)
SELECT
  'uniq_pt_cpt' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique encounters with procedures mapped to CPT and HCPCS
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\CPT4\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Procedures\HCPCS\%'
)
SELECT
  'uniq_enc_cpt' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;


-- Unique patients with VITAL SIGN data mapped
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Vital Signs\%'
)
SELECT
  'uniq_enc_vital_sign' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.ENCOUNTER_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with smoking data mapped
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\SDOH\LP156992-2\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Diagnosis\ICD10\V2_2018AA\A20098492\A20160670\A18921523\A17812661\%'
)
SELECT
  'uniq_pt_smoking' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM 
            AND PAT.BIRTH_DATE IS NOT NULL AND OBS.START_DATE - PAT.BIRTH_DATE > 12*365
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
        JOIN PATIENT_DIMENSION PAT ON PAT.PATIENT_NUM = OBS.PATIENT_NUM 
            AND PAT.BIRTH_DATE IS NOT NULL AND OBS.START_DATE - PAT.BIRTH_DATE > 12*365
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;

-- Unique patients with opioid abuse disorder
INSERT INTO CTSA_CLIC_METRIC
WITH MAPPED_DOMAIN AS (      
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\BPreparations\1819\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\BPreparations\352364\%' 
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\MPreparations\6813\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\NPreparations\1007909\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\NPreparations\7242\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\BPreparations\352364\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\NPreparations\214721\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\NPreparations\1545902\%'
        UNION
    SELECT CONCEPT_CD FROM  CONCEPT_DIMENSION WHERE CONCEPT_PATH LIKE '\ACT\Diagnosis\ICD10\V2_2018AA\A20098492\A20160670\A18921523\A17774215\%' -- OPIOID DISORDER
)
SELECT
  'uniq_pt_opioid' AS VARIABLE_NAME,
  
   ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2020' AND '31-DEC-2020'
    ) AS ONE_YEAR,
    
    ( SELECT COUNT(DISTINCT OBS.PATIENT_NUM) CNT
        FROM MAPPED_DOMAIN MAP
        JOIN OBSERVATION_FACT OBS ON OBS.CONCEPT_CD = MAP.CONCEPT_CD AND OBS.START_DATE BETWEEN '01-JAN-2016' AND '31-DEC-2020'
    ) AS FIVE_YEAR
FROM DUAL;
COMMIT;


select TO_CHAR (sysdate, 'MON DD HH24:MI:SS') from dual;
