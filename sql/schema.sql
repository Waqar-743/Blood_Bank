-- ============================================================
--  NUTECH BLOOD BANK MANAGEMENT SYSTEM
--  Database Schema — CS160 Database Systems PBL
--  Instructor: Ms. Sumera Aslam  |  Batch: AI-25 B
--  Normalized to Third Normal Form (3NF)
-- ============================================================

PRAGMA foreign_keys = ON;

-- ────────────────────────────────────────────────────────────
--  DROP existing tables (in dependency order)
-- ────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS transfusions;
DROP TABLE IF EXISTS blood_requests;
DROP TABLE IF EXISTS blood_inventory;
DROP TABLE IF EXISTS donations;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS donors;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS hospitals;
DROP TABLE IF EXISTS blood_banks;
DROP TABLE IF EXISTS blood_groups;

-- ────────────────────────────────────────────────────────────
--  1. BLOOD_GROUPS  (reference / lookup table)
--     PK: blood_group_id
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_groups (
    blood_group_id   INTEGER      PRIMARY KEY AUTOINCREMENT,
    group_name       VARCHAR(5)   NOT NULL UNIQUE,       -- A+, A-, B+, ...
    rh_factor        CHAR(1)      NOT NULL CHECK(rh_factor IN ('+','-')),
    abo_type         VARCHAR(3)   NOT NULL CHECK(abo_type IN ('A','B','AB','O')),
    description      TEXT
);

-- ────────────────────────────────────────────────────────────
--  2. BLOOD_BANKS
--     PK: bank_id
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_banks (
    bank_id          INTEGER      PRIMARY KEY AUTOINCREMENT,
    name             VARCHAR(100) NOT NULL,
    address          TEXT         NOT NULL,
    city             VARCHAR(50)  NOT NULL,
    phone            VARCHAR(20)  NOT NULL,
    email            VARCHAR(100),
    license_no       VARCHAR(50)  UNIQUE,
    established_date DATE,
    is_active        BOOLEAN      NOT NULL DEFAULT 1,
    CONSTRAINT chk_email CHECK(email IS NULL OR email LIKE '%@%.%')
);

-- ────────────────────────────────────────────────────────────
--  3. HOSPITALS
--     PK: hospital_id
-- ────────────────────────────────────────────────────────────
CREATE TABLE hospitals (
    hospital_id      INTEGER      PRIMARY KEY AUTOINCREMENT,
    name             VARCHAR(150) NOT NULL,
    address          TEXT         NOT NULL,
    city             VARCHAR(50)  NOT NULL,
    phone            VARCHAR(20)  NOT NULL,
    email            VARCHAR(100),
    license_no       VARCHAR(50)  UNIQUE,
    hospital_type    VARCHAR(30)  NOT NULL DEFAULT 'General'
                                  CHECK(hospital_type IN ('General','Specialty','Teaching','Clinic','Emergency')),
    is_partner       BOOLEAN      NOT NULL DEFAULT 1
);

-- ────────────────────────────────────────────────────────────
--  4. STAFF
--     PK: staff_id  |  FK: bank_id → blood_banks
-- ────────────────────────────────────────────────────────────
CREATE TABLE staff (
    staff_id         INTEGER      PRIMARY KEY AUTOINCREMENT,
    first_name       VARCHAR(50)  NOT NULL,
    last_name        VARCHAR(50)  NOT NULL,
    role             VARCHAR(40)  NOT NULL
                                  CHECK(role IN ('Doctor','Nurse','Technician','Coordinator','Admin','Phlebotomist')),
    phone            VARCHAR(20),
    email            VARCHAR(100) UNIQUE,
    bank_id          INTEGER      NOT NULL REFERENCES blood_banks(bank_id) ON UPDATE CASCADE,
    hire_date        DATE         NOT NULL,
    is_active        BOOLEAN      NOT NULL DEFAULT 1
);

-- ────────────────────────────────────────────────────────────
--  5. DONORS
--     PK: donor_id  |  FK: blood_group_id → blood_groups
--     Constraint: must be at least 18 years old
-- ────────────────────────────────────────────────────────────
CREATE TABLE donors (
    donor_id            INTEGER      PRIMARY KEY AUTOINCREMENT,
    first_name          VARCHAR(50)  NOT NULL,
    last_name           VARCHAR(50)  NOT NULL,
    dob                 DATE         NOT NULL,
    gender              VARCHAR(10)  NOT NULL CHECK(gender IN ('Male','Female','Other')),
    phone               VARCHAR(20)  NOT NULL,
    email               VARCHAR(100),
    address             TEXT,
    city                VARCHAR(50),
    blood_group_id      INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    registration_date   DATE         NOT NULL DEFAULT (date('now')),
    last_donation_date  DATE,
    total_donations     INTEGER      NOT NULL DEFAULT 0 CHECK(total_donations >= 0),
    weight_kg           DECIMAL(5,1) CHECK(weight_kg IS NULL OR weight_kg >= 50),
    is_active           BOOLEAN      NOT NULL DEFAULT 1,
    CONSTRAINT chk_age  CHECK(dob <= date('now','-18 years'))
);

-- ────────────────────────────────────────────────────────────
--  6. DONATIONS  (weak entity — identified by donor + date)
--     PK: donation_id  |  FK: donor_id, bank_id, staff_id, blood_group_id
-- ────────────────────────────────────────────────────────────
CREATE TABLE donations (
    donation_id       INTEGER      PRIMARY KEY AUTOINCREMENT,
    donor_id          INTEGER      NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    bank_id           INTEGER      NOT NULL REFERENCES blood_banks(bank_id),
    staff_id          INTEGER               REFERENCES staff(staff_id),
    blood_group_id    INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    donation_date     DATETIME     NOT NULL DEFAULT (datetime('now')),
    units_donated     DECIMAL(4,2) NOT NULL DEFAULT 1.0 CHECK(units_donated > 0),
    hemoglobin_level  DECIMAL(4,1)          CHECK(hemoglobin_level IS NULL OR hemoglobin_level BETWEEN 7 AND 20),
    blood_pressure    VARCHAR(10),
    status            VARCHAR(20)  NOT NULL DEFAULT 'completed'
                                   CHECK(status IN ('pending','approved','completed','rejected')),
    notes             TEXT
);

-- ────────────────────────────────────────────────────────────
--  7. BLOOD_INVENTORY
--     PK: inventory_id  |  FK: bank_id, blood_group_id
--     Unique on (bank_id, blood_group_id, component_type)
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_inventory (
    inventory_id      INTEGER      PRIMARY KEY AUTOINCREMENT,
    bank_id           INTEGER      NOT NULL REFERENCES blood_banks(bank_id),
    blood_group_id    INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    units_available   DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK(units_available >= 0),
    units_reserved    DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK(units_reserved >= 0),
    component_type    VARCHAR(30)  NOT NULL DEFAULT 'Whole Blood'
                                   CHECK(component_type IN ('Whole Blood','Red Cells','Plasma','Platelets')),
    collection_date   DATE,
    expiry_date       DATE,
    last_updated      DATETIME     NOT NULL DEFAULT (datetime('now')),
    UNIQUE(bank_id, blood_group_id, component_type)
);

-- ────────────────────────────────────────────────────────────
--  8. PATIENTS
--     PK: patient_id  |  FK: blood_group_id, hospital_id
-- ────────────────────────────────────────────────────────────
CREATE TABLE patients (
    patient_id        INTEGER      PRIMARY KEY AUTOINCREMENT,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    dob               DATE,
    gender            VARCHAR(10)  CHECK(gender IN ('Male','Female','Other')),
    phone             VARCHAR(20),
    address           TEXT,
    blood_group_id    INTEGER               REFERENCES blood_groups(blood_group_id),
    hospital_id       INTEGER               REFERENCES hospitals(hospital_id),
    medical_record_no VARCHAR(50)  UNIQUE,
    diagnosis         TEXT,
    registered_date   DATE         NOT NULL DEFAULT (date('now'))
);

-- ────────────────────────────────────────────────────────────
--  9. BLOOD_REQUESTS  (associative entity)
--     PK: request_id  |  FK: patient_id, hospital_id, blood_group_id, approved_by
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_requests (
    request_id        INTEGER      PRIMARY KEY AUTOINCREMENT,
    patient_id        INTEGER               REFERENCES patients(patient_id),
    hospital_id       INTEGER      NOT NULL REFERENCES hospitals(hospital_id),
    blood_group_id    INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    units_requested   DECIMAL(5,2) NOT NULL CHECK(units_requested > 0),
    request_date      DATETIME     NOT NULL DEFAULT (datetime('now')),
    urgency_level     VARCHAR(10)  NOT NULL DEFAULT 'medium'
                                   CHECK(urgency_level IN ('low','medium','high','critical')),
    status            VARCHAR(20)  NOT NULL DEFAULT 'pending'
                                   CHECK(status IN ('pending','approved','fulfilled','rejected','cancelled')),
    notes             TEXT,
    approved_by       INTEGER               REFERENCES staff(staff_id),
    approved_date     DATETIME
);

-- ────────────────────────────────────────────────────────────
-- 10. TRANSFUSIONS  (weak entity — identified by request)
--     PK: transfusion_id  |  FK: request_id, inventory_id, staff_id
-- ────────────────────────────────────────────────────────────
CREATE TABLE transfusions (
    transfusion_id    INTEGER      PRIMARY KEY AUTOINCREMENT,
    request_id        INTEGER      NOT NULL REFERENCES blood_requests(request_id),
    inventory_id      INTEGER               REFERENCES blood_inventory(inventory_id),
    transfusion_date  DATETIME     NOT NULL DEFAULT (datetime('now')),
    units_transfused  DECIMAL(4,2) NOT NULL CHECK(units_transfused > 0),
    staff_id          INTEGER               REFERENCES staff(staff_id),
    outcome           VARCHAR(20)           CHECK(outcome IN ('Successful','Adverse Reaction','Discontinued')),
    notes             TEXT
);

-- ────────────────────────────────────────────────────────────
--  INDEXES for query performance
-- ────────────────────────────────────────────────────────────
CREATE INDEX idx_donors_blood_group    ON donors(blood_group_id);
CREATE INDEX idx_donors_city           ON donors(city);
CREATE INDEX idx_donations_donor       ON donations(donor_id);
CREATE INDEX idx_donations_date        ON donations(donation_date);
CREATE INDEX idx_inventory_bank_group  ON blood_inventory(bank_id, blood_group_id);
CREATE INDEX idx_requests_status       ON blood_requests(status);
CREATE INDEX idx_requests_urgency      ON blood_requests(urgency_level);
CREATE INDEX idx_requests_date         ON blood_requests(request_date);
CREATE INDEX idx_transfusions_request  ON transfusions(request_id);
