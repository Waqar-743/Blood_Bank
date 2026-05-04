-- ============================================================
--  NUTECH BLOOD BANK — SQL Query Tasks
--  CS160 Database Systems PBL — All Required Query Types
--  Instructor: Ms. Sumera Aslam  |  Batch: AI-25 B
-- ============================================================

PRAGMA foreign_keys = ON;

-- ════════════════════════════════════════════════════════════
--  SECTION A: DDL — CREATE, ALTER, DROP
-- ════════════════════════════════════════════════════════════

-- A1. Create an audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    log_id      INTEGER   PRIMARY KEY AUTOINCREMENT,
    action_type VARCHAR(10) NOT NULL CHECK(action_type IN ('INSERT','UPDATE','DELETE')),
    table_name  VARCHAR(50) NOT NULL,
    record_id   INTEGER,
    changed_by  VARCHAR(50),
    change_time DATETIME  NOT NULL DEFAULT (datetime('now')),
    description TEXT
);

-- A2. Alter: add an emergency_contact column to donors
ALTER TABLE donors ADD COLUMN emergency_contact VARCHAR(20);

-- A3. Create a temporary view for reporting (virtual table)
CREATE VIEW IF NOT EXISTS vw_donor_summary AS
SELECT
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    bg.group_name                       AS blood_group,
    d.city,
    d.total_donations,
    d.last_donation_date,
    CASE
        WHEN d.last_donation_date IS NULL THEN 'Never donated'
        WHEN d.last_donation_date <= date('now','-4 months') THEN 'Eligible'
        ELSE 'On cooldown'
    END AS eligibility_status
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
WHERE d.is_active = 1;

-- A4. Drop the view when no longer needed (demonstration)
-- DROP VIEW IF EXISTS vw_donor_summary;


-- ════════════════════════════════════════════════════════════
--  SECTION B: DML — INSERT, UPDATE, DELETE
-- ════════════════════════════════════════════════════════════

-- B1. Insert a new donor
INSERT INTO donors (first_name, last_name, dob, gender, phone, email, city, blood_group_id, weight_kg)
VALUES ('Ali', 'Hassan', '1995-03-15', 'Male', '03001999001', 'ali.h@example.com', 'Islamabad', 5, 70.0);

-- B2. Update inventory after a donation (parameterized — safe from injection)
UPDATE blood_inventory
SET    units_available = units_available + 1.0,
       last_updated    = datetime('now')
WHERE  bank_id = 1 AND blood_group_id = 5 AND component_type = 'Whole Blood';

-- B3. Update request status to fulfilled
UPDATE blood_requests
SET    status        = 'fulfilled',
       approved_date = datetime('now')
WHERE  request_id = 6 AND status = 'approved';

-- B4. Mark inactive donors who have not donated in 2+ years
UPDATE donors
SET    is_active = 0
WHERE  last_donation_date < date('now','-2 years')
   OR  last_donation_date IS NULL;

-- B5. Delete a cancelled request (safe — only cancellations)
DELETE FROM blood_requests
WHERE  status = 'cancelled'
  AND  request_date < date('now','-1 year');


-- ════════════════════════════════════════════════════════════
--  SECTION C: SELECT — WHERE, ORDER BY, GROUP BY
-- ════════════════════════════════════════════════════════════

-- C1. All active donors ordered by total donations DESC
SELECT
    donor_id,
    first_name || ' ' || last_name AS donor_name,
    city,
    total_donations,
    last_donation_date
FROM donors
WHERE is_active = 1
ORDER BY total_donations DESC;

-- C2. Donors eligible to donate (last donation > 4 months ago or never donated)
SELECT
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    bg.group_name                       AS blood_group,
    d.phone,
    d.city,
    d.last_donation_date
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
WHERE d.is_active = 1
  AND (d.last_donation_date IS NULL OR d.last_donation_date <= date('now','-4 months'))
ORDER BY bg.group_name, d.last_donation_date;

-- C3. Inventory levels grouped by blood group (all banks combined)
SELECT
    bg.group_name,
    SUM(bi.units_available)         AS total_units,
    SUM(bi.units_reserved)          AS reserved,
    SUM(bi.units_available - bi.units_reserved) AS net_available,
    CASE
        WHEN SUM(bi.units_available) < 30  THEN 'CRITICAL'
        WHEN SUM(bi.units_available) < 100 THEN 'LOW'
        ELSE 'STABLE'
    END AS stock_status
FROM blood_inventory bi
JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
GROUP BY bi.blood_group_id
ORDER BY total_units ASC;

-- C4. Requests by urgency level — count and percentage
SELECT
    urgency_level,
    COUNT(*)                                    AS total_requests,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM blood_requests), 1) AS pct
FROM blood_requests
GROUP BY urgency_level
ORDER BY
    CASE urgency_level
        WHEN 'critical' THEN 1
        WHEN 'high'     THEN 2
        WHEN 'medium'   THEN 3
        WHEN 'low'      THEN 4
    END;

-- C5. Blood banks with total inventory value
SELECT
    bb.name       AS bank_name,
    bb.city,
    COUNT(bi.inventory_id)       AS inventory_lines,
    SUM(bi.units_available)      AS total_units,
    ROUND(AVG(bi.units_available), 2) AS avg_units_per_group
FROM blood_banks bb
LEFT JOIN blood_inventory bi ON bb.bank_id = bi.bank_id
WHERE bb.is_active = 1
GROUP BY bb.bank_id
ORDER BY total_units DESC;

-- C6. Find O- and AB- critical stock entries
SELECT
    bb.name AS bank,
    bg.group_name,
    bi.units_available,
    bi.expiry_date
FROM blood_inventory bi
JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
JOIN blood_banks  bb ON bi.bank_id = bb.bank_id
WHERE bg.group_name IN ('O-','AB-')
ORDER BY bi.units_available ASC;


-- ════════════════════════════════════════════════════════════
--  SECTION D: AGGREGATE FUNCTIONS — SUM, AVG, COUNT, MIN, MAX
-- ════════════════════════════════════════════════════════════

-- D1. Total units donated per blood group (SUM + GROUP BY)
SELECT
    bg.group_name,
    COUNT(don.donation_id)                    AS total_donations,
    SUM(don.units_donated)                    AS total_units,
    ROUND(AVG(don.hemoglobin_level), 1)       AS avg_hemoglobin,
    MIN(don.donation_date)                    AS first_donation,
    MAX(don.donation_date)                    AS latest_donation
FROM donations don
JOIN blood_groups bg ON don.blood_group_id = bg.blood_group_id
WHERE don.status = 'completed'
GROUP BY don.blood_group_id
ORDER BY total_units DESC;

-- D2. Donor leaderboard — top 10 by lifetime contributions
SELECT
    ROW_NUMBER() OVER (ORDER BY d.total_donations DESC) AS rank,
    d.first_name || ' ' || d.last_name AS donor_name,
    bg.group_name,
    d.city,
    d.total_donations,
    ROUND(d.total_donations * 0.45, 2) AS litres_donated
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
WHERE d.is_active = 1
ORDER BY d.total_donations DESC
LIMIT 10;

-- D3. Monthly donation trend (last 12 months)
SELECT
    strftime('%Y-%m', donation_date) AS month,
    COUNT(*)                          AS num_donations,
    SUM(units_donated)                AS units_collected,
    ROUND(AVG(hemoglobin_level), 1)   AS avg_haemoglobin
FROM donations
WHERE donation_date >= date('now','-12 months')
  AND status = 'completed'
GROUP BY month
ORDER BY month;

-- D4. Hospital demand analysis
SELECT
    h.name         AS hospital,
    h.city,
    COUNT(br.request_id)              AS total_requests,
    SUM(br.units_requested)           AS total_units_requested,
    SUM(CASE WHEN br.urgency_level = 'critical' THEN 1 ELSE 0 END) AS critical_requests,
    ROUND(AVG(br.units_requested), 2) AS avg_units_per_request
FROM hospitals h
JOIN blood_requests br ON h.hospital_id = br.hospital_id
GROUP BY h.hospital_id
ORDER BY total_requests DESC;

-- D5. Staff performance — requests approved by each doctor/coordinator
SELECT
    s.first_name || ' ' || s.last_name AS staff_name,
    s.role,
    COUNT(br.request_id)               AS requests_approved,
    SUM(CASE WHEN br.urgency_level = 'critical' THEN 1 ELSE 0 END) AS critical_handled
FROM staff s
LEFT JOIN blood_requests br ON s.staff_id = br.approved_by
GROUP BY s.staff_id
ORDER BY requests_approved DESC;


-- ════════════════════════════════════════════════════════════
--  SECTION E: JOINS — INNER, LEFT, MULTI-TABLE
-- ════════════════════════════════════════════════════════════

-- E1. INNER JOIN — Donations with donor name and blood group
SELECT
    don.donation_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    bg.group_name,
    bb.name      AS bank,
    don.donation_date,
    don.units_donated,
    don.status
FROM donations don
INNER JOIN donors       d  ON don.donor_id       = d.donor_id
INNER JOIN blood_groups bg ON don.blood_group_id = bg.blood_group_id
INNER JOIN blood_banks  bb ON don.bank_id        = bb.bank_id
ORDER BY don.donation_date DESC;

-- E2. LEFT JOIN — All donors with their donation count (include never-donated)
SELECT
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    bg.group_name,
    COUNT(don.donation_id)   AS recorded_donations,
    d.total_donations        AS cumulative_total
FROM donors d
LEFT JOIN blood_groups bg  ON d.blood_group_id = bg.blood_group_id
LEFT JOIN donations    don ON d.donor_id = don.donor_id AND don.status = 'completed'
WHERE d.is_active = 1
GROUP BY d.donor_id
ORDER BY recorded_donations DESC;

-- E3. Multi-table JOIN — Full blood request chain
SELECT
    br.request_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    h.name          AS hospital,
    bg.group_name   AS blood_group,
    br.units_requested,
    br.urgency_level,
    br.status,
    br.request_date,
    s.first_name || ' ' || s.last_name AS approved_by
FROM blood_requests br
JOIN hospitals    h  ON br.hospital_id    = h.hospital_id
JOIN blood_groups bg ON br.blood_group_id = bg.blood_group_id
LEFT JOIN patients p  ON br.patient_id    = p.patient_id
LEFT JOIN staff    s  ON br.approved_by   = s.staff_id
ORDER BY
    CASE br.urgency_level
        WHEN 'critical' THEN 1 WHEN 'high' THEN 2
        WHEN 'medium'   THEN 3 ELSE 4
    END, br.request_date DESC;

-- E4. Multi-table JOIN — Transfusion audit trail
SELECT
    t.transfusion_id,
    br.request_id,
    p.first_name || ' ' || p.last_name  AS patient,
    h.name                               AS hospital,
    bg.group_name                        AS blood_group,
    bi.component_type,
    t.units_transfused,
    t.transfusion_date,
    t.outcome,
    s.first_name || ' ' || s.last_name   AS transfused_by
FROM transfusions  t
JOIN blood_requests   br ON t.request_id   = br.request_id
JOIN hospitals        h  ON br.hospital_id = h.hospital_id
JOIN blood_groups     bg ON br.blood_group_id = bg.blood_group_id
LEFT JOIN blood_inventory bi ON t.inventory_id = bi.inventory_id
LEFT JOIN patients    p  ON br.patient_id  = p.patient_id
LEFT JOIN staff       s  ON t.staff_id     = s.staff_id
ORDER BY t.transfusion_date DESC;

-- E5. Self-referential analysis — Donors whose city matches a blood bank city
SELECT DISTINCT
    d.first_name || ' ' || d.last_name AS donor_name,
    d.city,
    bg.group_name,
    bb.name AS nearest_bank
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
JOIN blood_banks  bb ON LOWER(d.city) = LOWER(bb.city)
WHERE d.is_active = 1
ORDER BY d.city, bg.group_name;


-- ════════════════════════════════════════════════════════════
--  SECTION F: COMPLEX / ANALYTICAL QUERIES
-- ════════════════════════════════════════════════════════════

-- F1. Blood compatibility matching — find eligible donors for a request
--     (O- can donate to anyone; O+ to positive types; etc.)
--     Example: find all eligible donors for an AB+ request
SELECT
    d.donor_id,
    d.first_name || ' ' || d.last_name AS donor_name,
    bg.group_name AS donor_group,
    d.phone,
    d.city,
    d.last_donation_date,
    CASE
        WHEN d.last_donation_date IS NULL THEN 'Never donated'
        WHEN d.last_donation_date <= date('now','-4 months') THEN 'Eligible now'
        ELSE 'On cooldown until ' || date(d.last_donation_date, '+4 months')
    END AS status
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
WHERE d.is_active = 1
  AND bg.group_name IN ('O-','O+','A-','A+','B-','B+','AB-','AB+')  -- all can donate to AB+
ORDER BY
    CASE WHEN d.last_donation_date <= date('now','-4 months') OR d.last_donation_date IS NULL THEN 0 ELSE 1 END,
    d.total_donations DESC;

-- F2. Critical shortage alert — groups below 50 units system-wide
SELECT
    bg.group_name,
    SUM(bi.units_available)  AS total_stock,
    COUNT(DISTINCT bi.bank_id) AS banks_carrying,
    'CRITICAL — DRIVE REQUIRED' AS alert_level
FROM blood_inventory bi
JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
WHERE bi.component_type = 'Whole Blood'
GROUP BY bi.blood_group_id
HAVING SUM(bi.units_available) < 50
ORDER BY total_stock;

-- F3. Subquery — Donors who have donated MORE than the average
SELECT
    d.first_name || ' ' || d.last_name AS donor_name,
    d.total_donations,
    bg.group_name
FROM donors d
JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
WHERE d.total_donations > (SELECT AVG(total_donations) FROM donors WHERE is_active = 1)
  AND d.is_active = 1
ORDER BY d.total_donations DESC;

-- F4. Correlated subquery — Hospitals with above-average request volume
SELECT
    h.name,
    h.city,
    (SELECT COUNT(*) FROM blood_requests br WHERE br.hospital_id = h.hospital_id) AS request_count
FROM hospitals h
WHERE (SELECT COUNT(*) FROM blood_requests br WHERE br.hospital_id = h.hospital_id)
      > (SELECT AVG(cnt) FROM (
            SELECT COUNT(*) AS cnt FROM blood_requests GROUP BY hospital_id
         ))
ORDER BY request_count DESC;

-- F5. CTE — Running total of donations per month
WITH monthly_totals AS (
    SELECT
        strftime('%Y-%m', donation_date) AS ym,
        COUNT(*)          AS monthly_count,
        SUM(units_donated) AS monthly_units
    FROM donations
    WHERE status = 'completed'
    GROUP BY ym
)
SELECT
    ym,
    monthly_count,
    monthly_units,
    SUM(monthly_units) OVER (ORDER BY ym ROWS UNBOUNDED PRECEDING) AS running_total_units
FROM monthly_totals
ORDER BY ym;

-- F6. Expiry alert — inventory expiring within 7 days
SELECT
    bb.name  AS bank,
    bg.group_name,
    bi.component_type,
    bi.units_available,
    bi.expiry_date,
    julianday(bi.expiry_date) - julianday('now') AS days_to_expiry
FROM blood_inventory bi
JOIN blood_banks  bb ON bi.bank_id        = bb.bank_id
JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
WHERE bi.expiry_date <= date('now', '+7 days')
  AND bi.units_available > 0
ORDER BY bi.expiry_date;

-- F7. Fulfilment rate by hospital
SELECT
    h.name AS hospital,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN br.status = 'fulfilled' THEN 1 ELSE 0 END) AS fulfilled,
    ROUND(
        100.0 * SUM(CASE WHEN br.status = 'fulfilled' THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS fulfilment_rate_pct
FROM blood_requests br
JOIN hospitals h ON br.hospital_id = h.hospital_id
GROUP BY br.hospital_id
HAVING COUNT(*) >= 1
ORDER BY fulfilment_rate_pct DESC;

-- F8. Donor retention cohort — repeat vs one-time donors
SELECT
    CASE
        WHEN total_donations = 0 THEN 'Never Donated'
        WHEN total_donations = 1 THEN 'First-time (1 pint)'
        WHEN total_donations BETWEEN 2 AND 5  THEN 'Regular (2–5 pints)'
        WHEN total_donations BETWEEN 6 AND 20 THEN 'Committed (6–20 pints)'
        ELSE 'Champion (20+ pints)'
    END AS donor_tier,
    COUNT(*) AS donor_count,
    ROUND(AVG(total_donations), 1) AS avg_donations,
    SUM(total_donations) AS total_pints_contributed
FROM donors
WHERE is_active = 1
GROUP BY donor_tier
ORDER BY avg_donations DESC;
