
# Hospital Management SQL Project  
### Schema Build, Data Cleaning, and Analytical Reporting

This project showcases the full development of a structured SQL database for hospital operations, including schema standardisation, data integrity enforcement, and analytical insights across operational, clinical, and financial dimensions.

It includes:  
- **A complete SQL script** for schema refinement, constraints, transformations, and analytics.  
- **A full project presentation** (PDF & PPTX) explaining the logic, diagrams, and insights.  
- **End‑to‑end analysis**, from database design to actionable performance metrics.

---

## Project Files

- `Hospital_management.sql`  
  Full SQL pipeline including schema setup, data typing, constraints, transformations, and performance queries.  

- `Hospital_SQL_Project_Full_Presentation_Smaragdi_Albu.pdf`  
  Detailed presentation of the schema, diagrams, transformations, and insights.  

- `Hospital_SQL_Project_Full_Presentation_Smaragdi_Albu.pptx`  
  Editable slide deck version of the project presentation.

---

# Database Design & Schema Build

### 🔧 **Raw Schema Issues Identified**
- All ID fields imported as **TEXT** limiting indexing and performance.  
- No **primary keys** → duplicates risk.  
- No **foreign keys** → no relational integrity.  
- Potential **orphan records** affecting reliability.  

---

## Primary Keys & Constraints

- Added **PRIMARY KEY** to:  
  `patients`, `doctors`, `appointments`, `treatments`, `billing`.  
- Converted all ID fields to `VARCHAR(50)` for consistency.  
- Linked tables using **FOREIGN KEYS** to enforce relationships (e.g. appointments → patients & doctors).  

---

#  Data Standardisation & Cleaning

###  Standardisation Process
- Converted date columns to proper **DATE** type (`STR_TO_DATE`).  
- Converted currency to **DECIMAL(10,2)** to prevent rounding issues.  
- Added timestamp fields like `created_at` for auditability.  

### Final ERD  
The Entity‑Relationship Diagram (ERD) shows a full relational model linking:  
Patients → Appointments → Treatments → Billing + Doctors.  
This ensures accurate joins and robust analytics.  

---

#  Analytical Insights

The SQL script includes a collection of analytical queries to support hospital decision‑making.

##  Operational Insights

### **Peak Busy Days**
Identifies which weekdays have the highest appointment volume to optimise staffing and room allocation.  

### **Doctor Workload**
Shows appointment volumes per doctor to identify workload imbalance and support recruitment.  

### **No‑Show Rates**
Measures missed appointments per doctor, highlighting revenue loss and inefficiency.  

### **Departmental Performance**
Compares completed vs cancelled visits per specialisation.  

---

#  Financial & Insurance Metrics

### **Insurance Revenue Streams**
Ranks insurers based on number of invoices and total paid revenue.  

### **Aging Accounts Receivable**
Identifies unpaid bills older than 30 days for collection prioritisation.  


### **Treatment Profitability**
Calculates revenue per treatment type and identifies high‑margin procedures.  

---

# Patient & Clinical Analytics

### **Patient Retention (Loyalty)**
Finds frequent‑visit patients to target with personalised care management.  

### **Age Group Segmentation**
Categorises patients into paediatric, adult, and senior groups for clinical planning.  

### **Gender Distribution**
Ensures equitable staffing and department planning.  

### **Treatment Recurrence**
Identifies repeat treatment patterns, useful for protocol improvement.  

---

## If you find this project useful or insightful, feel free to ⭐ star the repository!
