-- ============================================================
--  NUTECH BLOOD BANK — Supabase / PostgreSQL Schema
--  CS160 Database Systems PBL
-- ============================================================

-- Drop in dependency order
DROP TABLE IF EXISTS transfusions       CASCADE;
DROP TABLE IF EXISTS blood_requests     CASCADE;
DROP TABLE IF EXISTS blood_inventory    CASCADE;
DROP TABLE IF EXISTS donations          CASCADE;
DROP TABLE IF EXISTS patients           CASCADE;
DROP TABLE IF EXISTS donors             CASCADE;
DROP TABLE IF EXISTS staff              CASCADE;
DROP TABLE IF EXISTS hospitals          CASCADE;
DROP TABLE IF EXISTS blood_banks        CASCADE;
DROP TABLE IF EXISTS blood_groups       CASCADE;

DROP VIEW IF EXISTS v_donations_detail;
DROP VIEW IF EXISTS v_donors_detail;
DROP VIEW IF EXISTS v_inventory_detail;
DROP VIEW IF EXISTS v_patients_detail;
DROP VIEW IF EXISTS v_requests_detail;
DROP VIEW IF EXISTS v_inventory_summary;
DROP VIEW IF EXISTS v_dashboard_stats;

-- ────────────────────────────────────────────────────────────
-- 1. BLOOD_GROUPS
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_groups (
    blood_group_id   SERIAL PRIMARY KEY,
    group_name       VARCHAR(5)   NOT NULL UNIQUE,
    rh_factor        CHAR(1)      NOT NULL CHECK(rh_factor IN ('+','-')),
    abo_type         VARCHAR(3)   NOT NULL CHECK(abo_type IN ('A','B','AB','O')),
    description      TEXT
);

-- ────────────────────────────────────────────────────────────
-- 2. BLOOD_BANKS
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_banks (
    bank_id          SERIAL PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    address          TEXT         NOT NULL,
    city             VARCHAR(50)  NOT NULL,
    phone            VARCHAR(20)  NOT NULL,
    email            VARCHAR(100),
    license_no       VARCHAR(50)  UNIQUE,
    established_date DATE,
    is_active        BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ────────────────────────────────────────────────────────────
-- 3. HOSPITALS
-- ────────────────────────────────────────────────────────────
CREATE TABLE hospitals (
    hospital_id      SERIAL PRIMARY KEY,
    name             VARCHAR(150) NOT NULL,
    address          TEXT         NOT NULL,
    city             VARCHAR(50)  NOT NULL,
    phone            VARCHAR(20)  NOT NULL,
    email            VARCHAR(100),
    license_no       VARCHAR(50)  UNIQUE,
    hospital_type    VARCHAR(30)  NOT NULL DEFAULT 'General'
                                  CHECK(hospital_type IN ('General','Specialty','Teaching','Clinic','Emergency')),
    is_partner       BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ────────────────────────────────────────────────────────────
-- 4. STAFF
-- ────────────────────────────────────────────────────────────
CREATE TABLE staff (
    staff_id         SERIAL PRIMARY KEY,
    first_name       VARCHAR(50)  NOT NULL,
    last_name        VARCHAR(50)  NOT NULL,
    role             VARCHAR(40)  NOT NULL
                                  CHECK(role IN ('Doctor','Nurse','Technician','Coordinator','Admin','Phlebotomist')),
    phone            VARCHAR(20),
    email            VARCHAR(100) UNIQUE,
    bank_id          INTEGER      NOT NULL REFERENCES blood_banks(bank_id) ON UPDATE CASCADE,
    hire_date        DATE         NOT NULL,
    is_active        BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ────────────────────────────────────────────────────────────
-- 5. DONORS
-- ────────────────────────────────────────────────────────────
CREATE TABLE donors (
    donor_id            SERIAL PRIMARY KEY,
    first_name          VARCHAR(50)  NOT NULL,
    last_name           VARCHAR(50)  NOT NULL,
    dob                 DATE         NOT NULL,
    gender              VARCHAR(10)  NOT NULL CHECK(gender IN ('Male','Female','Other')),
    phone               VARCHAR(20)  NOT NULL,
    email               VARCHAR(100),
    address             TEXT,
    city                VARCHAR(50),
    blood_group_id      INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    registration_date   DATE         NOT NULL DEFAULT CURRENT_DATE,
    last_donation_date  DATE,
    total_donations     INTEGER      NOT NULL DEFAULT 0 CHECK(total_donations >= 0),
    weight_kg           NUMERIC(5,1) CHECK(weight_kg IS NULL OR weight_kg >= 50),
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    emergency_contact   TEXT,
    CONSTRAINT chk_age CHECK(dob <= CURRENT_DATE - INTERVAL '18 years')
);

-- ────────────────────────────────────────────────────────────
-- 6. DONATIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE donations (
    donation_id       SERIAL PRIMARY KEY,
    donor_id          INTEGER      NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    bank_id           INTEGER      NOT NULL REFERENCES blood_banks(bank_id),
    staff_id          INTEGER               REFERENCES staff(staff_id),
    blood_group_id    INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    donation_date     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    units_donated     NUMERIC(4,2) NOT NULL DEFAULT 1.0 CHECK(units_donated > 0),
    hemoglobin_level  NUMERIC(4,1)          CHECK(hemoglobin_level IS NULL OR hemoglobin_level BETWEEN 7 AND 20),
    blood_pressure    VARCHAR(10),
    status            VARCHAR(20)  NOT NULL DEFAULT 'completed'
                                   CHECK(status IN ('pending','approved','completed','rejected')),
    notes             TEXT
);

-- ────────────────────────────────────────────────────────────
-- 7. BLOOD_INVENTORY
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_inventory (
    inventory_id      SERIAL PRIMARY KEY,
    bank_id           INTEGER      NOT NULL REFERENCES blood_banks(bank_id),
    blood_group_id    INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    units_available   NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK(units_available >= 0),
    units_reserved    NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK(units_reserved >= 0),
    component_type    VARCHAR(30)  NOT NULL DEFAULT 'Whole Blood'
                                   CHECK(component_type IN ('Whole Blood','Red Cells','Plasma','Platelets')),
    collection_date   DATE,
    expiry_date       DATE,
    last_updated      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE(bank_id, blood_group_id, component_type)
);

-- ────────────────────────────────────────────────────────────
-- 8. PATIENTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE patients (
    patient_id        SERIAL PRIMARY KEY,
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
    registered_date   DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- ────────────────────────────────────────────────────────────
-- 9. BLOOD_REQUESTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE blood_requests (
    request_id        SERIAL PRIMARY KEY,
    patient_id        INTEGER               REFERENCES patients(patient_id),
    hospital_id       INTEGER      NOT NULL REFERENCES hospitals(hospital_id),
    blood_group_id    INTEGER      NOT NULL REFERENCES blood_groups(blood_group_id),
    units_requested   NUMERIC(5,2) NOT NULL CHECK(units_requested > 0),
    request_date      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    urgency_level     VARCHAR(10)  NOT NULL DEFAULT 'medium'
                                   CHECK(urgency_level IN ('low','medium','high','critical')),
    status            VARCHAR(20)  NOT NULL DEFAULT 'pending'
                                   CHECK(status IN ('pending','approved','fulfilled','rejected','cancelled')),
    notes             TEXT,
    approved_by       INTEGER               REFERENCES staff(staff_id),
    approved_date     TIMESTAMPTZ
);

-- ────────────────────────────────────────────────────────────
-- 10. TRANSFUSIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE transfusions (
    transfusion_id    SERIAL PRIMARY KEY,
    request_id        INTEGER      NOT NULL REFERENCES blood_requests(request_id),
    inventory_id      INTEGER               REFERENCES blood_inventory(inventory_id),
    transfusion_date  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    units_transfused  NUMERIC(4,2) NOT NULL CHECK(units_transfused > 0),
    staff_id          INTEGER               REFERENCES staff(staff_id),
    outcome           VARCHAR(20)           CHECK(outcome IN ('Successful','Adverse Reaction','Discontinued')),
    notes             TEXT
);

-- ────────────────────────────────────────────────────────────
-- INDEXES
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

-- ────────────────────────────────────────────────────────────
-- VIEWS  (used by the API for complex JOINs)
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_donors_detail AS
SELECT d.*,
       bg.group_name AS blood_group_name
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id;

CREATE OR REPLACE VIEW v_donations_detail AS
SELECT dn.*,
       d.first_name || ' ' || d.last_name AS donor_name,
       bg.group_name,
       bb.name AS bank_name
FROM donations dn
JOIN donors      d  ON dn.donor_id       = d.donor_id
JOIN blood_groups bg ON dn.blood_group_id = bg.blood_group_id
JOIN blood_banks  bb ON dn.bank_id        = bb.bank_id;

CREATE OR REPLACE VIEW v_inventory_detail AS
SELECT bi.*,
       bg.group_name, bg.rh_factor, bg.abo_type,
       bb.name AS bank_name, bb.city AS bank_city
FROM blood_inventory bi
JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
JOIN blood_banks  bb ON bi.bank_id        = bb.bank_id;

CREATE OR REPLACE VIEW v_inventory_summary AS
SELECT bg.group_name,
       bg.blood_group_id,
       SUM(bi.units_available)                       AS total_units,
       SUM(bi.units_reserved)                        AS reserved,
       SUM(bi.units_available - bi.units_reserved)   AS net_available,
       CASE WHEN SUM(bi.units_available) < 30  THEN 'critical'
            WHEN SUM(bi.units_available) < 100 THEN 'low'
            ELSE 'stable' END AS status
FROM blood_inventory bi
JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
WHERE bi.component_type = 'Whole Blood'
GROUP BY bg.blood_group_id, bg.group_name
ORDER BY total_units ASC;

CREATE OR REPLACE VIEW v_patients_detail AS
SELECT p.*,
       bg.group_name AS blood_group_name,
       h.name AS hospital_name
FROM patients p
LEFT JOIN blood_groups bg ON p.blood_group_id = bg.blood_group_id
LEFT JOIN hospitals    h  ON p.hospital_id    = h.hospital_id;

CREATE OR REPLACE VIEW v_requests_detail AS
SELECT br.*,
       bg.group_name,
       p.first_name || ' ' || p.last_name AS patient_name,
       h.name AS hospital_name,
       s.first_name || ' ' || s.last_name AS approved_by_name
FROM blood_requests br
JOIN blood_groups bg ON br.blood_group_id = bg.blood_group_id
JOIN hospitals    h  ON br.hospital_id    = h.hospital_id
LEFT JOIN patients p ON br.patient_id    = p.patient_id
LEFT JOIN staff    s ON br.approved_by   = s.staff_id;

-- ────────────────────────────────────────────────────────────
-- ENABLE REALTIME on all tables (run in Supabase dashboard or via SQL editor)
-- ────────────────────────────────────────────────────────────
ALTER PUBLICATION supabase_realtime ADD TABLE blood_groups;
ALTER PUBLICATION supabase_realtime ADD TABLE blood_banks;
ALTER PUBLICATION supabase_realtime ADD TABLE hospitals;
ALTER PUBLICATION supabase_realtime ADD TABLE staff;
ALTER PUBLICATION supabase_realtime ADD TABLE donors;
ALTER PUBLICATION supabase_realtime ADD TABLE donations;
ALTER PUBLICATION supabase_realtime ADD TABLE blood_inventory;
ALTER PUBLICATION supabase_realtime ADD TABLE patients;
ALTER PUBLICATION supabase_realtime ADD TABLE blood_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE transfusions;
