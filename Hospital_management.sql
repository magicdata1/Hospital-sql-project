SET SQL_SAFE_UPDATES = 0;

USE hospital_management;

-- 1. Patients: patient_id is the PK
ALTER TABLE patients 
MODIFY COLUMN patient_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (patient_id);

-- 2. Doctors: doctor_id is the PK
ALTER TABLE doctors 
MODIFY COLUMN doctor_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (doctor_id);

-- 3. Appointments: appointment_id is the PK
ALTER TABLE appointments 
MODIFY COLUMN appointment_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (appointment_id);

-- 4. Treatments: treatment_id is the PK
ALTER TABLE treatments 
MODIFY COLUMN treatment_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (treatment_id);

-- 5. Billing: bill_id is the PK
ALTER TABLE billing 
MODIFY COLUMN bill_id VARCHAR(50) NOT NULL,
ADD PRIMARY KEY (bill_id);

-- DATA STANDARDIZATION & CLEANING
-- CSV imports often default to 'TEXT'. We convert IDs to 'VARCHAR(50)'
ALTER TABLE patients MODIFY patient_id VARCHAR(50);
ALTER TABLE doctors MODIFY doctor_id VARCHAR(50);
ALTER TABLE appointments MODIFY appointment_id VARCHAR(50), MODIFY patient_id VARCHAR(50), MODIFY doctor_id VARCHAR(50);
ALTER TABLE treatments MODIFY treatment_id VARCHAR(50), MODIFY appointment_id VARCHAR(50);
ALTER TABLE billing MODIFY bill_id VARCHAR(50), MODIFY patient_id VARCHAR(50), MODIFY treatment_id VARCHAR(50);

-- ESTABLISHING PRIMARY KEYS
ALTER TABLE patients ADD PRIMARY KEY (patient_id);
ALTER TABLE doctors ADD PRIMARY KEY (doctor_id);
ALTER TABLE appointments ADD PRIMARY KEY (appointment_id);
ALTER TABLE treatments ADD PRIMARY KEY (treatment_id);
ALTER TABLE billing ADD PRIMARY KEY (bill_id);

-- CREATING REFERENTIAL INTEGRITY (FOREIGN KEYS)
-- This ensures that every appointment, treatment, and bill is tied to a valid patient and doctor record.

-- Linking Appointments to Patients and Doctors
ALTER TABLE appointments
ADD CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
ADD CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id);

-- Linking Treatments to Appointments
ALTER TABLE treatments
ADD CONSTRAINT fk_treat_appt FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id);

-- Linking Billing to Patients and Treatments
ALTER TABLE billing
ADD CONSTRAINT fk_bill_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
ADD CONSTRAINT fk_bill_treatment FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id);

-- DATA TRANSFORMATION
-- Converting text-based date columns into proper SQL DATE types.

UPDATE patients SET date_of_birth = STR_TO_DATE(date_of_birth, '%Y-%m-%d');
ALTER TABLE patients MODIFY COLUMN date_of_birth DATE;

UPDATE appointments SET appointment_date = STR_TO_DATE(appointment_date, '%Y-%m-%d');
ALTER TABLE appointments MODIFY COLUMN appointment_date DATE;

UPDATE billing SET bill_date = STR_TO_DATE(bill_date, '%Y-%m-%d');
ALTER TABLE billing MODIFY COLUMN bill_date DATE;

UPDATE treatments SET treatment_date = STR_TO_DATE(treatment_date, '%Y-%m-%d');
ALTER TABLE treatments MODIFY COLUMN treatment_date DATE;

-- Converting currency columns from generic types to DECIMAL(10,2).

-- Update Billing table
ALTER TABLE billing 
MODIFY COLUMN amount DECIMAL(10,2);

-- Update Treatments table
ALTER TABLE treatments 
MODIFY COLUMN cost DECIMAL(10,2);

-- Adding a timestamp to the patients table that automatically records when a new record is created.

ALTER TABLE patients 
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- OPERATIONAL EFFICIENCY & HOSPITAL PERFORMANCE

-- 1. PEAK BUSY DAYS

SELECT DAYNAME(appointment_date) AS day_of_week, 
COUNT(*) AS total_appointments
FROM appointments
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- 2. DOCTOR WORKLOAD
-- Measures total appointments per doctor to prevent burnout.
SELECT CONCAT('Dr. ', d.last_name) AS doctor_name, d.specialization,
COUNT(a.appointment_id) AS total_patients_seen
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id
ORDER BY total_patients_seen DESC;

-- 3. NO-SHOW IMPACT ANALYSIS
-- Calculates missed appointment percentages and potential revenue loss.
SELECT CONCAT('Dr. ', d.last_name) AS doctor_name,
COUNT(a.appointment_id) AS total_scheduled,
SUM(CASE WHEN a.status = 'No-show' THEN 1 ELSE 0 END) AS total_no_shows,
ROUND((SUM(CASE WHEN a.status = 'No-show' THEN 1 ELSE 0 END) / COUNT(a.appointment_id)) * 100, 2) AS no_show_rate_percent
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id
ORDER BY no_show_rate_percent DESC;

-- 4. DEPARTMENTAL SUCCESS RATES
-- Compares completed visits versus cancellations by specialization.
SELECT d.specialization,
SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) AS completed_visits,
SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
COUNT(a.appointment_id) AS total_volume
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY completed_visits DESC;

-- To implement these Financial & Insurance Insights, you will use the relationships you've built between the billing, patients, treatments, and doctors tables. Since you have already converted your amount and cost columns to DECIMAL, these calculations will be perfectly accurate.

Add this section to your SQL script:

STEP 11: Financial & Insurance Analysis
SQL

-- FINANCIAL & INSURANCE PERFORMANCE
-- These queries analyze the hospital's cash flow, insurance partnerships, and the profitability of medical services.

-- INSURANCE REVENUE STREAMS

SELECT p.insurance_provider,
COUNT(b.bill_id) AS total_invoices,
SUM(b.amount) AS total_paid_revenue
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
WHERE b.payment_status = 'Paid'
GROUP BY p.insurance_provider
ORDER BY total_paid_revenue DESC;

-- AGING ACCOUNTS RECEIVABLE

SELECT p.first_name, p.last_name, p.contact_number, b.amount AS pending_amount, 
DATE_FORMAT(b.bill_date, '%d-%m-%Y') AS bill_date
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
WHERE b.payment_status = 'Pending' 
  AND b.bill_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY b.bill_date ASC;

-- TREATMENT PROFITABILITY

SELECT t.treatment_type,
COUNT(t.treatment_id) AS frequency,
SUM(b.amount) AS total_revenue,
ROUND(AVG(b.amount), 2) AS avg_revenue_per_treatment
FROM treatments t
JOIN billing b ON t.treatment_id = b.treatment_id
WHERE b.payment_status = 'Paid'
GROUP BY t.treatment_type
ORDER BY total_revenue DESC;

-- REVENUE PER SPECIALIZATION

SELECT d.specialization,
COUNT(a.appointment_id) AS visit_count,
SUM(b.amount) AS total_department_revenue,
ROUND(SUM(b.amount) / COUNT(a.appointment_id), 2) AS avg_revenue_per_visit
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN billing b ON a.patient_id = b.patient_id
GROUP BY d.specialization
ORDER BY total_department_revenue DESC;

-- PATIENT & CLINICAL INSIGHTS
-- Focuses on patient demographics and long-term care needs to improve clinical outcomes and marketing.

-- PATIENT RETENTION

SELECT p.patient_id, 
CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
COUNT(a.appointment_id) AS visit_count, p.email
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id
HAVING visit_count > 3
ORDER BY visit_count DESC;

-- AGE GROUP DEMOGRAPHICS

SELECT CASE 
WHEN (YEAR(CURDATE()) - YEAR(date_of_birth)) < 18 THEN 'Pediatric (0-17)'
WHEN (YEAR(CURDATE()) - YEAR(date_of_birth)) BETWEEN 18 AND 60 THEN 'Adult (18-60)'
ELSE 'Senior (60+)' END AS age_category,
COUNT(*) AS patient_count
FROM patients
GROUP BY age_category;

-- TREATMENT RECURRENCE
-- Tracks the average number of visits per patient for specific treatments.
SELECT t.treatment_type,
COUNT(t.treatment_id) AS total_procedures,
COUNT(DISTINCT a.patient_id) AS unique_patients,
ROUND(COUNT(t.treatment_id) / COUNT(DISTINCT a.patient_id), 1) AS visits_per_patient
FROM treatments t
JOIN appointments a ON t.appointment_id = a.appointment_id
GROUP BY t.treatment_type
ORDER BY visits_per_patient DESC;

-- GENDER DISTRIBUTION BY SPECIALISATION
-- Helps determine if certain departments (like OBGYN or Urology) if need more gender-specific medical staff.

SELECT d.specialization, p.gender,
COUNT(*) AS patient_count
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialization, p.gender
ORDER BY d.specialization;

-- DEMOGRAPHIC REVENUE CONTRIBUTION
SELECT
  CASE
    WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) < 18 THEN 'Pediatric'
    WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) BETWEEN 18 AND 60 THEN 'Adult'
    ELSE 'Senior'
  END AS age_group,
  SUM(b.amount) AS total_revenue,
  ROUND(AVG(b.amount), 2) AS avg_bill_size
FROM patients p
JOIN billing b ON b.patient_id = p.patient_id
GROUP BY age_group
ORDER BY total_revenue DESC;


-- STRATEGIC PLANNING & QUALITY CONTROL
-- These queries focus on hospital growth, doctor-to-patient ratios, and potential revenue leakages.

-- DOCTOR-PATIENT RATIO BY SPECIALIZATION
-- Helps determine if you need to hire more doctors for a specific wing.
SELECT d.specialization,
COUNT(DISTINCT a.patient_id) AS unique_patients,
COUNT(DISTINCT d.doctor_id) AS total_doctors,
ROUND(COUNT(DISTINCT a.patient_id) / COUNT(DISTINCT d.doctor_id), 1) AS patients_per_doctor
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY patients_per_doctor DESC;

--  UNBILLED TREATMENTS
-- Finds treatments that were performed but do not have a corresponding bill.
-- This is critical for preventing revenue loss.
SELECT t.treatment_id, t.treatment_type, t.treatment_date, p.first_name, p.last_name
FROM treatments t
LEFT JOIN billing b ON t.treatment_id = b.treatment_id
JOIN appointments a ON t.appointment_id = a.appointment_id
JOIN patients p ON a.patient_id = p.patient_id
WHERE b.bill_id IS NULL;


-- EMERGENCY vs. ROUTINE VOLUME
-- Analyzes the 'reason_for_visit' to see if the clinic acts as an ER or a primary care.

SELECT
  reason_for_visit,
  COUNT(*) AS volume,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM appointments
GROUP BY reason_for_visit
ORDER BY volume DESC;


-- INSURANCE SETTLEMENT RELIABILITY (Paid vs Pending vs Other)
SELECT p.insurance_provider,
  COUNT(*) AS total_bills,
  ROUND(100 * SUM(CASE WHEN b.payment_status = 'Paid' THEN 1 ELSE 0 END) / COUNT(*), 2) AS paid_rate_percent,
  ROUND(100 * SUM(CASE WHEN b.payment_status = 'Pending' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pending_rate_percent,
  ROUND(100 * SUM(CASE WHEN b.payment_status NOT IN ('Paid','Pending') OR b.payment_status IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS other_rate_percent
FROM patients p
JOIN billing b ON b.patient_id = p.patient_id
GROUP BY p.insurance_provider
ORDER BY paid_rate_percent DESC;

