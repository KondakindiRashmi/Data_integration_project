use HAP720

--------------- PHASE 1
--- Merging SEER data with MPI data

select x.member_id,x.diagnosis_year,x.diagnosis_age,x.sex,x.race,x.c_diagnosis,y.patient_id into #temporary
from dbo.hap720_seer x FULL JOIN dbo.hap720_mpi y
on x.member_id=y.member_id
select * from #temporary

--- joining SEER data and claims_dgns_demo_dx_rnd_removed tables

SELECT x.patient_id,x.claim_year,x.claim_date,x.death_date,x.sex,x.age,x.race,x.diagnosis9,x.diagnosis10,claim_number,
y.member_id INTO #temporary1
FROM dbo.HAP720_claims_dgns_demo_dx_rnd_removed x FULL JOIN #temporary y
ON x.patient_id=y.patient_id
select * from #temporary1

---How many patients in the SEER do not have matched records in the Claims?

SELECT COUNT(DISTINCT member_id) FROM #temporary WHERE patient_id is null and member_id is not null

---How many patients in the Claims do not have matched records in the SEER?

SELECT COUNT(DISTINCT patient_id) FROM #temporary1 WHERE member_id is null and patient_id is not null


----------------  PHASE 2
USE HAP720

SELECT * FROM dbo.HAP720_icd9_to_icd10
SELECT * FROM #temporary1

SELECT a.* INTO #temporary2 FROM #temporary1 a JOIN dbo.HAP720_icd9_to_icd10 b ON a.diagnosis9=b.icd9
SELECT * FROM #temporary2

SELECT a.*,b.icd10 into #temporary3 FROM #temporary2 a JOIN dbo.HAP720_icd9_to_icd10 b ON a.diagnosis9=b.icd9
SELECT * FROM #temporary3

-------------- PHASE 3

USE HAP720

---- Merging tables based on patient records since

SELECT a.patient_id,a.claim_year,a.claim_date,a.death_date,a.sex,a.age,a.race,a.diagnosis9,
a.diagnosis10,a.claim_number,b.member_id INTO dbo.HAP720_FINAL_Merged
FROM dbo.HAP720_claims_dgn_demo_distorted a FULL JOIN dbo.HAP720_seer_distorted b ON a.claim_year = b.diagnosis_year AND
a.age = b.diagnosis_age AND a.sex = b.sex AND a.race = b.race AND a.diagnosis9 = b.c_diagnosis
SELECT * FROM dbo.HAP720_FINAL_Merged

--- Compare the performance (e.g., number of matched or mismatched) between MPI and patient matching.

SELECT COUNT (DISTINCT patient_id) FROM dbo.HAP720_FINAL_Merged
