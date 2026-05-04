-- ============================================================
--  NUTECH BLOOD BANK — Seed Data
--  Realistic Pakistani data — max 20 records per table
-- ============================================================

PRAGMA foreign_keys = ON;

-- ── 1. BLOOD GROUPS ─────────────────────────────────────────
INSERT INTO blood_groups (group_name, rh_factor, abo_type, description) VALUES
('A+',  '+', 'A',  'Most common after O+. Can donate to A+ and AB+.'),
('A-',  '-', 'A',  'Universal plasma donor. Can donate to all A and AB types.'),
('B+',  '+', 'B',  'Second most common. Can donate to B+ and AB+.'),
('B-',  '-', 'B',  'Rare type. Can donate to all B and AB types.'),
('O+',  '+', 'O',  'Most common blood type. Universal red cell donor for + types.'),
('O-',  '-', 'O',  'Universal donor — safest for emergency transfusions.'),
('AB+', '+', 'AB', 'Universal recipient. Can receive from all types.'),
('AB-', '-', 'AB', 'Rarest type. Universal plasma donor.');

-- ── 2. BLOOD BANKS ──────────────────────────────────────────
INSERT INTO blood_banks (name, address, city, phone, email, license_no, established_date) VALUES
('NUTech National Blood Centre',   'Sector I-12, Main IJP Road', 'Islamabad', '0519283456', 'info@nutechblood.org',     'BB-ISB-001', '2018-03-15'),
('Punjab Blood Service Lahore',    'Mall Road, Near Mayo Hospital', 'Lahore', '0429871234', 'pbs@lahore.gov.pk',        'BB-LHR-002', '2010-06-01'),
('Karachi Voluntary Blood Service','M.A. Jinnah Road, Saddar', 'Karachi',   '02135614416', 'kvbs@karachi.net',         'BB-KHI-003', '2005-09-20'),
('Islamabad Safe Blood Centre',    'Blue Area, Jinnah Avenue',   'Islamabad', '0519912233', 'isbc@pha.gov.pk',          'BB-ISB-004', '2015-01-10'),
('Peshawar Blood Foundation',      'Cantonment, GT Road',        'Peshawar',  '0919256789', 'pbf@peshawar.org',         'BB-PEW-005', '2012-07-22');

-- ── 3. HOSPITALS ────────────────────────────────────────────
INSERT INTO hospitals (name, address, city, phone, email, license_no, hospital_type) VALUES
('PIMS Islamabad',                 'G-8/3, Islamabad',              'Islamabad', '0519246000', 'info@pims.gov.pk',    'HS-ISB-001', 'Teaching'),
('Shaukat Khanum Memorial',        'Johar Town, Lahore',            'Lahore',    '0429201600', 'info@shaukat.org.pk', 'HS-LHR-002', 'Specialty'),
('Aga Khan University Hospital',   'Stadium Road, Karachi',         'Karachi',   '02134864000','info@aku.edu',        'HS-KHI-003', 'Teaching'),
('Mayo Hospital Lahore',           'Nila Gumbad, Anarkali',         'Lahore',    '0429921032', 'mayo@pgmi.edu.pk',    'HS-LHR-004', 'Teaching'),
('Shifa International Islamabad',  'H-8/4, Islamabad',              'Islamabad', '0519032000', 'info@shifa.com.pk',   'HS-ISB-005', 'General'),
('Liaquat National Hospital',      'National Stadium Road, Karachi','Karachi',   '02134412000','info@lnh.edu.pk',     'HS-KHI-006', 'Teaching'),
('Services Hospital Lahore',       'Jail Road, Lahore',             'Lahore',    '0424205600', 'services@sh.edu.pk',  'HS-LHR-007', 'General'),
('Lady Reading Hospital',          'Phase 4, Peshawar',             'Peshawar',  '0919211300', 'info@lrh.gov.pk',     'HS-PEW-008', 'Teaching'),
('Jinnah Postgraduate',            'Rafiqui H.J. Shaheed Rd, KHI',  'Karachi',   '02199201300','admin@jpmc.edu.pk',   'HS-KHI-009', 'Teaching'),
('Indus Hospital Karachi',         'Korangi Crossing, Karachi',     'Karachi',   '02135112709','info@indus.edu.pk',   'HS-KHI-010', 'General');

-- ── 4. STAFF ────────────────────────────────────────────────
INSERT INTO staff (first_name, last_name, role, phone, email, bank_id, hire_date) VALUES
('Amina',    'Rizvi',    'Doctor',       '03335001001', 'amina.rizvi@nutechblood.org',    1, '2018-04-01'),
('Hassan',   'Qureshi',  'Technician',   '03215002002', 'h.qureshi@nutechblood.org',      1, '2019-07-15'),
('Saba',     'Noor',     'Phlebotomist', '03025003003', 'saba.noor@nutechblood.org',      1, '2020-02-10'),
('Tariq',    'Mehmood',  'Coordinator',  '03445004004', 'tariq.m@pbs.gov.pk',             2, '2015-09-01'),
('Zainab',   'Aslam',    'Nurse',        '03115005005', 'z.aslam@kvbs.net',               3, '2017-03-20'),
('Bilal',    'Sheikh',   'Doctor',       '03215006006', 'bilal.sheikh@isbc.pk',           4, '2021-01-05'),
('Farida',   'Hussain',  'Coordinator',  '03335007007', 'f.hussain@pbf.org',              5, '2013-11-12'),
('Imran',    'Ali',      'Technician',   '03025008008', 'imran.ali@nutechblood.org',      1, '2022-06-30'),
('Nadia',    'Butt',     'Admin',        '03445009009', 'nadia.butt@nutechblood.org',     1, '2018-04-01'),
('Kamran',   'Javed',    'Phlebotomist', '03115010010', 'k.javed@pbs.gov.pk',             2, '2016-08-15');

-- ── 5. DONORS ───────────────────────────────────────────────
INSERT INTO donors (first_name, last_name, dob, gender, phone, email, address, city, blood_group_id, registration_date, last_donation_date, total_donations, weight_kg) VALUES
('Sara',       'Khan',     '1990-05-12', 'Female', '03001101001', 'sara.khan@gmail.com',    '14-B Gulshan-e-Iqbal', 'Karachi',    5,  '2020-01-15', '2025-12-01', 19, 55.0),
('Ahmed',      'Raza',     '1988-11-03', 'Male',   '03211101002', 'ahmed.raza@yahoo.com',   'Street 4, F-7/2',      'Islamabad',  1,  '2019-06-20', '2025-11-15', 12, 72.5),
('Fatima',     'Malik',    '1995-07-22', 'Female', '03031101003', 'fatima.m@hotmail.com',   '22 Garden Town',       'Lahore',     3,  '2021-03-10', '2025-10-20', 7,  60.0),
('Usman',      'Butt',     '1985-02-14', 'Male',   '03451101004', 'usman.butt@gmail.com',   '9 Clifton Block 5',    'Karachi',    6,  '2018-09-05', '2025-09-10', 22, 80.0),
('Hira',       'Iqbal',    '1993-09-30', 'Female', '03111101005', 'hira.iqbal@gmail.com',   'A-12 Johar Town',      'Lahore',     2,  '2022-05-01', '2025-08-25', 5,  53.0),
('Zubair',     'Mirza',    '1991-04-18', 'Male',   '03221101006', 'zubair.m@gmail.com',     'H-3 Hayatabad Ph-2',   'Peshawar',   7,  '2020-11-11', '2025-07-14', 9,  75.0),
('Ayesha',     'Siddiqui', '1987-12-25', 'Female', '03001101007', 'ayesha.s@gmail.com',     '7 Defence Ph-6',       'Karachi',    4,  '2017-07-30', '2025-11-01', 28, 58.0),
('Omar',       'Sheikh',   '1994-06-08', 'Male',   '03421101008', 'omar.sh@gmail.com',      'Street 2, G-11/2',     'Islamabad',  5,  '2023-01-14', '2025-10-05', 4,  68.0),
('Sana',       'Ahmad',    '1996-01-17', 'Female', '03311101009', 'sana.a@outlook.com',     '3 Model Town',         'Lahore',     8,  '2021-08-22', '2025-09-30', 6,  52.0),
('Khalid',     'Nawaz',    '1980-08-09', 'Male',   '03001101010', 'khalid.n@gmail.com',     '18 Gulberg II',        'Lahore',     1,  '2015-04-17', '2025-11-20', 35, 88.0),
('Lubna',      'Farooq',   '1992-03-05', 'Female', '03211101011', 'lubna.f@gmail.com',      '5 Satellite Town',     'Rawalpindi', 3,  '2020-09-03', '2025-08-10', 8,  57.0),
('Asad',       'Tariq',    '1997-10-21', 'Male',   '03031101012', 'asad.t@gmail.com',       '21 Askari-10',         'Lahore',     6,  '2022-12-01', '2025-10-18', 3,  74.0),
('Maryam',     'Javed',    '1989-07-14', 'Female', '03451101013', 'maryam.j@gmail.com',     '8 Nazimabad No.3',     'Karachi',    5,  '2019-02-28', '2025-11-05', 14, 61.0),
('Shoaib',     'Hassan',   '1986-11-29', 'Male',   '03111101014', 'shoaib.h@yahoo.com',     '11 Korangi Township',  'Karachi',    2,  '2016-10-10', '2025-07-28', 26, 82.0),
('Rabia',      'Zafar',    '1998-04-03', 'Female', '03221101015', 'rabia.z@gmail.com',      'House 33, F-8/4',      'Islamabad',  4,  '2023-06-15', '2025-10-01', 2,  54.0),
('Naeem',      'Akhtar',   '1983-09-19', 'Male',   '03001101016', 'naeem.a@gmail.com',      '7 Gulshanabad Ph-1',   'Peshawar',   7,  '2014-11-22', '2025-09-15', 40, 90.0),
('Amna',       'Sohail',   '1999-12-07', 'Female', '03421101017', 'amna.s@gmail.com',       'B-14 North Nazimabad', 'Karachi',    1,  '2024-01-09', '2025-08-22', 2,  50.5),
('Faisal',     'Rehman',   '1990-06-26', 'Male',   '03311101018', 'faisal.r@gmail.com',     '19 Phase-4 Bahria',    'Islamabad',  3,  '2020-05-14', '2025-11-10', 11, 78.0),
('Nadia',      'Waheed',   '1994-02-11', 'Female', '03001101019', 'nadia.w@gmail.com',      '6 Wapda Town Ph-1',    'Lahore',     6,  '2021-10-30', '2025-10-25', 6,  56.0),
('Waheed',     'Alam',     '1982-08-30', 'Male',   '03211101020', 'waheed.a@gmail.com',     '3 Arbab Road',         'Peshawar',   5,  '2013-03-18', '2025-11-28', 48, 85.0);

-- ── 6. DONATIONS ────────────────────────────────────────────
INSERT INTO donations (donor_id, bank_id, staff_id, blood_group_id, donation_date, units_donated, hemoglobin_level, blood_pressure, status, notes) VALUES
(1,  1, 3, 5, '2025-12-01 09:30:00', 1.0, 13.2, '118/76', 'completed', 'Regular donation — no adverse effects'),
(2,  1, 3, 1, '2025-11-15 10:15:00', 1.0, 14.8, '122/80', 'completed', 'Blood pressure slightly elevated, cleared'),
(3,  2, 4, 3, '2025-10-20 11:00:00', 1.0, 12.9, '115/75', 'completed', NULL),
(4,  3, 5, 6, '2025-09-10 08:45:00', 1.0, 15.1, '120/78', 'completed', 'O- donor — critical reserve contribution'),
(5,  2, 4, 2, '2025-08-25 14:30:00', 1.0, 13.5, '112/72', 'completed', NULL),
(6,  5, 7, 7, '2025-07-14 09:00:00', 1.0, 14.2, '124/82', 'completed', NULL),
(7,  3, 5, 4, '2025-11-01 10:45:00', 1.0, 13.8, '118/76', 'completed', 'B- rare type donation'),
(8,  1, 3, 5, '2025-10-05 11:30:00', 1.0, 14.0, '120/80', 'completed', NULL),
(9,  2, 4, 8, '2025-09-30 09:15:00', 1.0, 12.7, '110/70', 'completed', 'AB- — directed to inventory'),
(10, 2, 4, 1, '2025-11-20 10:00:00', 1.0, 15.6, '126/84', 'completed', 'Experienced donor — 35th pint'),
(11, 1, 3, 3, '2025-08-10 13:45:00', 1.0, 13.1, '116/74', 'completed', NULL),
(12, 2, 4, 6, '2025-10-18 08:30:00', 1.0, 14.5, '122/80', 'completed', 'O- critical reserve'),
(13, 3, 5, 5, '2025-11-05 11:00:00', 1.0, 13.6, '119/77', 'completed', NULL),
(14, 3, 5, 2, '2025-07-28 09:30:00', 1.0, 14.9, '124/82', 'completed', 'Thalassemia programme support'),
(15, 4, 6, 4, '2025-10-01 10:15:00', 1.0, 13.3, '115/75', 'pending',   'Screening in progress'),
(16, 5, 7, 7, '2025-09-15 08:00:00', 1.0, 15.0, '128/84', 'completed', '40th donation — certificate issued'),
(17, 3, 5, 1, '2025-08-22 14:00:00', 1.0, 13.0, '113/73', 'completed', NULL),
(18, 1, 3, 3, '2025-11-10 11:45:00', 1.0, 14.3, '120/78', 'completed', NULL),
(19, 2, 4, 6, '2025-10-25 09:00:00', 1.0, 13.7, '117/75', 'completed', NULL),
(20, 1, 3, 5, '2025-11-28 10:30:00', 1.0, 15.4, '122/80', 'completed', '48th donation — lifetime achievement');

-- ── 7. BLOOD INVENTORY ──────────────────────────────────────
INSERT INTO blood_inventory (bank_id, blood_group_id, units_available, units_reserved, component_type, collection_date, expiry_date) VALUES
(1, 5, 280.5, 20.0, 'Whole Blood',  '2026-04-01', '2026-05-29'),
(1, 1, 210.0, 15.0, 'Whole Blood',  '2026-04-05', '2026-06-02'),
(1, 3, 180.0, 10.0, 'Whole Blood',  '2026-04-10', '2026-06-07'),
(1, 6, 42.0,   8.0, 'Whole Blood',  '2026-04-15', '2026-06-12'),
(2, 5, 320.0, 25.0, 'Whole Blood',  '2026-04-03', '2026-06-01'),
(2, 1, 190.0, 12.0, 'Whole Blood',  '2026-04-07', '2026-06-04'),
(2, 2, 65.0,   5.0, 'Whole Blood',  '2026-04-12', '2026-06-09'),
(2, 4, 38.0,   3.0, 'Whole Blood',  '2026-04-18', '2026-06-15'),
(3, 5, 410.0, 30.0, 'Whole Blood',  '2026-04-02', '2026-05-31'),
(3, 7, 125.0, 10.0, 'Whole Blood',  '2026-04-06', '2026-06-03'),
(3, 8, 22.0,   5.0, 'Whole Blood',  '2026-04-20', '2026-06-17'),
(4, 6, 18.0,   2.0, 'Whole Blood',  '2026-04-22', '2026-06-19'),
(4, 3, 145.0, 10.0, 'Whole Blood',  '2026-04-11', '2026-06-08'),
(5, 5, 175.0, 15.0, 'Whole Blood',  '2026-04-08', '2026-06-05'),
(5, 7, 88.0,   8.0, 'Whole Blood',  '2026-04-14', '2026-06-11'),
(1, 5, 95.0,  10.0, 'Platelets',    '2026-04-28', '2026-05-03'),
(2, 1, 60.0,   5.0, 'Plasma',       '2026-04-15', '2027-04-15'),
(3, 6, 30.0,   5.0, 'Red Cells',    '2026-04-10', '2026-07-08'),
(4, 5, 50.0,   5.0, 'Plasma',       '2026-04-20', '2027-04-20'),
(5, 3, 40.0,   4.0, 'Platelets',    '2026-04-29', '2026-05-04');

-- ── 8. PATIENTS ─────────────────────────────────────────────
INSERT INTO patients (first_name, last_name, dob, gender, phone, address, blood_group_id, hospital_id, medical_record_no, diagnosis) VALUES
('Ayaan',    'Shah',     '2017-06-10', 'Male',   '03009001001', 'House 5, Nazimabad',         3, 3,  'MRN-20241001', 'Thalassaemia Major'),
('Zahra',    'Baig',     '1978-03-22', 'Female', '03219002002', '7 Gulshan Block 13',         5, 1,  'MRN-20241002', 'Anaemia — post-surgical'),
('Tariq',    'Gillani',  '1945-11-05', 'Male',   '03039003003', '3 Abpara Market',            1, 1,  'MRN-20241003', 'Chronic kidney disease — dialysis'),
('Bushra',   'Mirza',    '1990-07-18', 'Female', '03459004004', '22 Cavalry Ground',          6, 2,  'MRN-20241004', 'Road traffic accident — haemorrhage'),
('Hamza',    'Siddiq',   '2010-04-30', 'Male',   '03119005005', '14 DHA Phase-3',             2, 2,  'MRN-20241005', 'Aplastic anaemia'),
('Rubab',    'Naqvi',    '1965-09-12', 'Female', '03229006006', '6 Banni Chowk, Saddar',      4, 6,  'MRN-20241006', 'Hip replacement surgery'),
('Daoud',    'Farooqi',  '1958-01-27', 'Male',   '03009007007', '1 Hayatabad Ph-7',           5, 8,  'MRN-20241007', 'GI bleed — conservative management'),
('Kiran',    'Saeed',    '2000-12-03', 'Female', '03429008008', 'Flat 3, Goldcrest Mall',     7, 3,  'MRN-20241008', 'Sickle cell disease'),
('Imtiaz',   'Ul-Haq',   '1982-08-15', 'Male',   '03319009009', '11 Samanabad',              1, 4,  'MRN-20241009', 'Bone marrow transplant prep'),
('Shabnam',  'Wahidi',   '1972-05-29', 'Female', '03019010010', '8 Pechs Block 6',            3, 3,  'MRN-20241010', 'Liver cirrhosis — coagulopathy'),
('Noman',    'Latif',    '2018-02-14', 'Male',   '03219011011', 'House 9, Aashiana',          6, 7,  'MRN-20241011', 'Haemophilia A'),
('Shazia',   'Kamal',    '1987-10-06', 'Female', '03039012012', '4 Malir City',               5, 9,  'MRN-20241012', 'Post-partum haemorrhage'),
('Arif',     'Gondal',   '1975-06-20', 'Male',   '03459013013', '2 Faisal Town',              8, 2,  'MRN-20241013', 'Cardiac surgery — bypass'),
('Zara',     'Cheema',   '2015-08-09', 'Female', '03119014014', '17 Cavalry Ground',          2, 4,  'MRN-20241014', 'Thalassaemia Intermedia'),
('Mushtaq',  'Ghauri',   '1950-03-31', 'Male',   '03229015015', '5 Lal Kurti, Rawalpindi',    5, 1,  'MRN-20241015', 'Trauma — spleen rupture'),
('Neelam',   'Rauf',     '1994-11-17', 'Female', '03009016016', '9 F-10/2',                   1, 5,  'MRN-20241016', 'Obstetric complication'),
('Junaid',   'Pirzada',  '1968-07-04', 'Male',   '03429017017', '3 Gulshan-e-Hadeed',         3, 6,  'MRN-20241017', 'Myelodysplastic syndrome'),
('Iram',     'Awan',     '2001-01-22', 'Female', '03319018018', 'B-4 Askari-11',              4, 7,  'MRN-20241018', 'Autoimmune haemolytic anaemia'),
('Sajid',    'Pervez',   '1977-09-14', 'Male',   '03019019019', '7 Johar Town D-Block',       6, 2,  'MRN-20241019', 'Emergency surgery — vehicle trauma'),
('Mehwish',  'Yousaf',   '1999-04-25', 'Female', '03219020020', '12 Bahria Enclave Blk-B',    7, 5,  'MRN-20241020', 'Pregnancy — antepartum anaemia');

-- ── 9. BLOOD REQUESTS ───────────────────────────────────────
INSERT INTO blood_requests (patient_id, hospital_id, blood_group_id, units_requested, request_date, urgency_level, status, notes, approved_by, approved_date) VALUES
(1,  3, 3, 2.0, '2026-04-28 08:00:00', 'high',     'fulfilled', 'Monthly thalassaemia transfusion',                     5, '2026-04-28 08:45:00'),
(2,  1, 5, 1.5, '2026-04-27 14:30:00', 'medium',   'fulfilled', 'Post-op anaemia correction',                           1, '2026-04-27 15:00:00'),
(3,  1, 1, 2.0, '2026-04-26 10:00:00', 'medium',   'approved',  'Dialysis patient — scheduled transfusion',             1, '2026-04-26 10:30:00'),
(4,  2, 6, 3.0, '2026-04-25 02:15:00', 'critical', 'fulfilled', 'RTA with severe haemorrhage — EMERGENCY',              1, '2026-04-25 02:20:00'),
(5,  2, 2, 2.0, '2026-04-24 11:45:00', 'high',     'approved',  'Aplastic anaemia protocol',                            1, '2026-04-24 12:00:00'),
(6,  6, 4, 1.0, '2026-04-23 09:30:00', 'low',      'pending',   'Pre-surgical crossmatch',                              NULL, NULL),
(7,  8, 5, 1.5, '2026-04-22 16:00:00', 'medium',   'fulfilled', 'GI bleed — stabilisation',                             7, '2026-04-22 16:30:00'),
(8,  3, 7, 2.0, '2026-04-21 09:00:00', 'high',     'approved',  'Sickle cell vaso-occlusive crisis',                    5, '2026-04-21 09:15:00'),
(9,  4, 1, 3.0, '2026-04-20 11:00:00', 'high',     'approved',  'BMT conditioning — transfusion support',               1, '2026-04-20 11:30:00'),
(10, 3, 3, 2.0, '2026-04-19 08:30:00', 'medium',   'fulfilled', 'Coagulopathy correction',                              5, '2026-04-19 09:00:00'),
(11, 7, 6, 1.0, '2026-04-18 13:00:00', 'high',     'fulfilled', 'Haemophilia A bleed episode',                          4, '2026-04-18 13:15:00'),
(12, 9, 5, 2.5, '2026-04-17 04:30:00', 'critical', 'fulfilled', 'PPH — maternity emergency',                            1, '2026-04-17 04:35:00'),
(13, 2, 8, 2.0, '2026-04-16 07:00:00', 'high',     'approved',  'Cardiac bypass prep — AB- required',                   1, '2026-04-16 07:30:00'),
(14, 4, 2, 1.5, '2026-04-15 10:30:00', 'high',     'fulfilled', 'Thalassaemia Intermedia — monthly cycle',              1, '2026-04-15 11:00:00'),
(15, 1, 5, 4.0, '2026-04-14 23:45:00', 'critical', 'fulfilled', 'Spleen rupture — intraop massive transfusion',         1, '2026-04-14 23:50:00'),
(16, 5, 1, 1.0, '2026-04-13 09:00:00', 'medium',   'approved',  'Obstetric anaemia — elective admission',               6, '2026-04-13 09:30:00'),
(17, 6, 3, 2.0, '2026-04-12 11:00:00', 'medium',   'pending',   'MDS support — regular protocol',                       NULL, NULL),
(18, 7, 4, 1.0, '2026-04-11 15:00:00', 'low',      'rejected',  'AIHA — crossmatch incompatible, reassessing',          4, '2026-04-11 16:00:00'),
(19, 2, 6, 5.0, '2026-04-10 01:00:00', 'critical', 'fulfilled', 'Polytrauma MVA — massive transfusion protocol',        1, '2026-04-10 01:05:00'),
(20, 5, 7, 1.0, '2026-04-09 12:00:00', 'low',      'approved',  'Antepartum anaemia — elective top-up',                 6, '2026-04-09 12:30:00');

-- ── 10. TRANSFUSIONS ────────────────────────────────────────
INSERT INTO transfusions (request_id, inventory_id, transfusion_date, units_transfused, staff_id, outcome, notes) VALUES
(1,  3,  '2026-04-28 10:00:00', 2.0, 5, 'Successful',         'Pre-medications given; no reaction'),
(2,  1,  '2026-04-27 16:00:00', 1.5, 1, 'Successful',         'Haemoglobin post-transfusion 9.8 g/dL'),
(4,  4,  '2026-04-25 02:30:00', 3.0, 5, 'Successful',         'Massive transfusion — 3 units in 40 min, stabilised'),
(7,  10, '2026-04-22 17:30:00', 1.5, 7, 'Successful',         'Bleeding controlled; Hb 8.2 post-tx'),
(10, 3,  '2026-04-19 10:00:00', 2.0, 5, 'Successful',         'INR improved after FFP component'),
(11, 4,  '2026-04-18 14:00:00', 1.0, 4, 'Successful',         'Factor VIII infusion adjunct; no complications'),
(12, 9,  '2026-04-17 05:00:00', 2.5, 1, 'Successful',         'Emergency MTP activated; mother stable'),
(14, 7,  '2026-04-15 12:00:00', 1.5, 4, 'Successful',         'Scheduled transfusion complete'),
(15, 1,  '2026-04-15 00:10:00', 4.0, 1, 'Successful',         'Intraoperative — surgeon confirmed adequate field'),
(19, 4,  '2026-04-10 01:15:00', 5.0, 1, 'Successful',         'MTP — 5 units PRBCs + FFP + platelets protocol'),
(1,  16, '2026-03-28 10:00:00', 2.0, 5, 'Successful',         'Previous month cycle — platelets supplement'),
(12, 17, '2026-03-17 05:00:00', 1.0, 1, 'Successful',         'FFP for coagulation factor support'),
(4,  18, '2026-04-25 03:00:00', 1.0, 5, 'Successful',         'O- red cells — emergency crossmatch release'),
(7,  14, '2026-04-22 18:00:00', 0.5, 7, 'Successful',         'Top-up platelets following bleeding'),
(2,  5,  '2026-04-27 16:30:00', 0.5, 1, 'Adverse Reaction',   'Mild FNHTR — managed with antipyretics; completed'),
(15, 9,  '2026-04-15 00:30:00', 1.0, 1, 'Successful',         'Second unit intraop — no complications'),
(19, 4,  '2026-04-10 02:00:00', 1.0, 1, 'Successful',         'Continued MTP — haemostasis achieved'),
(10, 13, '2026-04-19 10:30:00', 0.5, 5, 'Successful',         'Additional FFP — INR target reached'),
(11, 4,  '2026-04-18 15:00:00', 0.5, 4, 'Discontinued',       'Patient requested stop — discomfort; reassessed next day'),
(1,  20, '2026-02-28 10:00:00', 2.0, 5, 'Successful',         'Feb cycle — platelets for thalassaemia support');
