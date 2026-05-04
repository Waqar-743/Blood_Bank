const express   = require('express');
const cors      = require('cors');
const helmet    = require('helmet');
const morgan    = require('morgan');
const path      = require('path');

const db = require('./database');
const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────────
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(morgan('dev'));

// Serve frontend files
app.use(express.static(path.join(__dirname, '..', 'frontend')));
// Serve root landing page
app.use(express.static(path.join(__dirname, '..')));
// Explicit landing page route
app.get('/', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'Landing Page.html'));
});

// ── Helper ───────────────────────────────────────────────────
const ok  = (res, data)    => res.json({ success: true, data });
const err = (res, msg, code = 400) => res.status(code).json({ success: false, error: msg });

// ── BLOOD GROUPS ─────────────────────────────────────────────
app.get('/api/blood-groups', (_req, res) => {
  ok(res, db.prepare('SELECT * FROM blood_groups ORDER BY group_name').all());
});

// ── BLOOD BANKS ──────────────────────────────────────────────
app.get('/api/blood-banks', (_req, res) => {
  ok(res, db.prepare('SELECT * FROM blood_banks WHERE is_active=1 ORDER BY name').all());
});

// ── HOSPITALS ────────────────────────────────────────────────
app.get('/api/hospitals', (_req, res) => {
  ok(res, db.prepare('SELECT * FROM hospitals ORDER BY name').all());
});

// ── STAFF ────────────────────────────────────────────────────
app.get('/api/staff', (_req, res) => {
  ok(res, db.prepare(`
    SELECT s.*, bb.name AS bank_name
    FROM staff s JOIN blood_banks bb ON s.bank_id = bb.bank_id
    WHERE s.is_active=1 ORDER BY s.first_name`).all());
});

// ── DONORS ───────────────────────────────────────────────────
app.get('/api/donors', (req, res) => {
  const { search, blood_group, city, active } = req.query;
  let sql = `
    SELECT d.*, bg.group_name AS blood_group_name
    FROM donors d JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
    WHERE 1=1`;
  const params = [];
  if (search) {
    sql += ` AND (d.first_name LIKE ? OR d.last_name LIKE ? OR d.phone LIKE ?)`;
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  if (blood_group) { sql += ` AND d.blood_group_id = ?`; params.push(blood_group); }
  if (city)        { sql += ` AND LOWER(d.city) = LOWER(?)`; params.push(city); }
  if (active !== undefined && active !== '') { sql += ` AND d.is_active = ?`; params.push(parseInt(active)); }
  sql += ` ORDER BY d.registration_date DESC`;
  ok(res, db.prepare(sql).all(...params));
});

app.get('/api/donors/:id', (req, res) => {
  const donor = db.prepare(`
    SELECT d.*, bg.group_name AS blood_group_name
    FROM donors d JOIN blood_groups bg ON d.blood_group_id = bg.blood_group_id
    WHERE d.donor_id = ?`).get(req.params.id);
  if (!donor) return err(res, 'Donor not found', 404);
  const donations = db.prepare(`
    SELECT dn.*, bg.group_name, bb.name AS bank_name
    FROM donations dn
    JOIN blood_groups bg ON dn.blood_group_id = bg.blood_group_id
    JOIN blood_banks  bb ON dn.bank_id = bb.bank_id
    WHERE dn.donor_id = ? ORDER BY dn.donation_date DESC`).all(req.params.id);
  ok(res, { ...donor, donations });
});

app.post('/api/donors', (req, res) => {
  const { first_name, last_name, dob, gender, phone, email, address, city,
          blood_group_id, weight_kg, emergency_contact } = req.body;
  if (!first_name || !last_name || !dob || !gender || !phone || !blood_group_id)
    return err(res, 'Missing required fields');
  try {
    const info = db.prepare(`
      INSERT INTO donors (first_name,last_name,dob,gender,phone,email,address,city,
        blood_group_id,weight_kg,emergency_contact)
      VALUES (?,?,?,?,?,?,?,?,?,?,?)`).run(
      first_name, last_name, dob, gender, phone, email||null, address||null,
      city||null, blood_group_id, weight_kg||null, emergency_contact||null);
    ok(res, { donor_id: info.lastInsertRowid });
  } catch (e) {
    err(res, e.message);
  }
});

app.put('/api/donors/:id', (req, res) => {
  const { first_name, last_name, dob, gender, phone, email, address, city,
          blood_group_id, weight_kg, is_active, emergency_contact } = req.body;
  try {
    db.prepare(`
      UPDATE donors SET first_name=?,last_name=?,dob=?,gender=?,phone=?,email=?,
        address=?,city=?,blood_group_id=?,weight_kg=?,is_active=?,emergency_contact=?
      WHERE donor_id=?`).run(
      first_name, last_name, dob, gender, phone, email||null, address||null,
      city||null, blood_group_id, weight_kg||null, is_active??1, emergency_contact||null,
      req.params.id);
    ok(res, { updated: true });
  } catch (e) { err(res, e.message); }
});

app.delete('/api/donors/:id', (req, res) => {
  db.prepare('UPDATE donors SET is_active=0 WHERE donor_id=?').run(req.params.id);
  ok(res, { deleted: true });
});

// ── DONATIONS ────────────────────────────────────────────────
app.get('/api/donations', (req, res) => {
  const { donor_id, status, limit = 50 } = req.query;
  let sql = `
    SELECT dn.*, d.first_name||' '||d.last_name AS donor_name,
           bg.group_name, bb.name AS bank_name
    FROM donations dn
    JOIN donors d      ON dn.donor_id = d.donor_id
    JOIN blood_groups bg ON dn.blood_group_id = bg.blood_group_id
    JOIN blood_banks  bb ON dn.bank_id = bb.bank_id
    WHERE 1=1`;
  const params = [];
  if (donor_id) { sql += ' AND dn.donor_id=?'; params.push(donor_id); }
  if (status)   { sql += ' AND dn.status=?';   params.push(status); }
  sql += ` ORDER BY dn.donation_date DESC LIMIT ?`;
  params.push(parseInt(limit));
  ok(res, db.prepare(sql).all(...params));
});

app.post('/api/donations', (req, res) => {
  const { donor_id, bank_id, staff_id, blood_group_id, donation_date,
          units_donated, hemoglobin_level, blood_pressure, notes } = req.body;
  if (!donor_id || !bank_id || !blood_group_id)
    return err(res, 'donor_id, bank_id, blood_group_id required');
  try {
    const info = db.prepare(`
      INSERT INTO donations (donor_id,bank_id,staff_id,blood_group_id,donation_date,
        units_donated,hemoglobin_level,blood_pressure,notes,status)
      VALUES (?,?,?,?,?,?,?,?,?,'completed')`).run(
      donor_id, bank_id, staff_id||null, blood_group_id,
      donation_date||new Date().toISOString(),
      units_donated||1.0, hemoglobin_level||null, blood_pressure||null, notes||null);

    // Update donor stats
    db.prepare(`
      UPDATE donors SET total_donations=total_donations+1,
        last_donation_date=date(?) WHERE donor_id=?`
    ).run(donation_date||new Date().toISOString(), donor_id);

    // Update inventory
    db.prepare(`
      UPDATE blood_inventory SET units_available=units_available+?,
        last_updated=datetime('now')
      WHERE bank_id=? AND blood_group_id=? AND component_type='Whole Blood'`
    ).run(units_donated||1.0, bank_id, blood_group_id);

    ok(res, { donation_id: info.lastInsertRowid });
  } catch (e) { err(res, e.message); }
});

// ── INVENTORY ────────────────────────────────────────────────
app.get('/api/inventory', (req, res) => {
  const { bank_id } = req.query;
  let sql = `
    SELECT bi.*, bg.group_name, bg.rh_factor, bg.abo_type, bb.name AS bank_name, bb.city
    FROM blood_inventory bi
    JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
    JOIN blood_banks  bb ON bi.bank_id = bb.bank_id
    WHERE 1=1`;
  const params = [];
  if (bank_id) { sql += ' AND bi.bank_id=?'; params.push(bank_id); }
  sql += ' ORDER BY bi.units_available ASC';
  ok(res, db.prepare(sql).all(...params));
});

app.get('/api/inventory/summary', (_req, res) => {
  ok(res, db.prepare(`
    SELECT bg.group_name, bg.blood_group_id,
      SUM(bi.units_available) AS total_units,
      SUM(bi.units_reserved)  AS reserved,
      SUM(bi.units_available - bi.units_reserved) AS net_available,
      CASE WHEN SUM(bi.units_available) < 30 THEN 'critical'
           WHEN SUM(bi.units_available) < 100 THEN 'low'
           ELSE 'stable' END AS status
    FROM blood_inventory bi
    JOIN blood_groups bg ON bi.blood_group_id = bg.blood_group_id
    WHERE bi.component_type = 'Whole Blood'
    GROUP BY bi.blood_group_id ORDER BY total_units ASC`).all());
});

app.put('/api/inventory/:id', (req, res) => {
  const { units_available, units_reserved, expiry_date } = req.body;
  try {
    db.prepare(`
      UPDATE blood_inventory
      SET units_available=?, units_reserved=?, expiry_date=?, last_updated=datetime('now')
      WHERE inventory_id=?`
    ).run(units_available, units_reserved||0, expiry_date||null, req.params.id);
    ok(res, { updated: true });
  } catch (e) { err(res, e.message); }
});

// ── PATIENTS ─────────────────────────────────────────────────
app.get('/api/patients', (req, res) => {
  const { search, hospital_id } = req.query;
  let sql = `
    SELECT p.*, bg.group_name AS blood_group_name, h.name AS hospital_name
    FROM patients p
    LEFT JOIN blood_groups bg ON p.blood_group_id = bg.blood_group_id
    LEFT JOIN hospitals    h  ON p.hospital_id = h.hospital_id
    WHERE 1=1`;
  const params = [];
  if (search) {
    sql += ` AND (p.first_name LIKE ? OR p.last_name LIKE ? OR p.medical_record_no LIKE ?)`;
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  if (hospital_id) { sql += ' AND p.hospital_id=?'; params.push(hospital_id); }
  sql += ' ORDER BY p.registered_date DESC';
  ok(res, db.prepare(sql).all(...params));
});

app.get('/api/patients/:id', (req, res) => {
  const patient = db.prepare(`
    SELECT p.*, bg.group_name AS blood_group_name, h.name AS hospital_name
    FROM patients p
    LEFT JOIN blood_groups bg ON p.blood_group_id = bg.blood_group_id
    LEFT JOIN hospitals    h  ON p.hospital_id = h.hospital_id
    WHERE p.patient_id = ?`).get(req.params.id);
  if (!patient) return err(res, 'Patient not found', 404);
  ok(res, patient);
});

app.post('/api/patients', (req, res) => {
  const { first_name, last_name, dob, gender, phone, address,
          blood_group_id, hospital_id, medical_record_no, diagnosis } = req.body;
  if (!first_name || !last_name) return err(res, 'Name required');
  try {
    const info = db.prepare(`
      INSERT INTO patients (first_name,last_name,dob,gender,phone,address,
        blood_group_id,hospital_id,medical_record_no,diagnosis)
      VALUES (?,?,?,?,?,?,?,?,?,?)`).run(
      first_name, last_name, dob||null, gender||null, phone||null, address||null,
      blood_group_id||null, hospital_id||null,
      medical_record_no||`MRN-${Date.now()}`, diagnosis||null);
    ok(res, { patient_id: info.lastInsertRowid });
  } catch (e) { err(res, e.message); }
});

app.put('/api/patients/:id', (req, res) => {
  const { first_name, last_name, dob, gender, phone, address,
          blood_group_id, hospital_id, diagnosis } = req.body;
  try {
    db.prepare(`
      UPDATE patients SET first_name=?,last_name=?,dob=?,gender=?,phone=?,
        address=?,blood_group_id=?,hospital_id=?,diagnosis=?
      WHERE patient_id=?`).run(
      first_name, last_name, dob||null, gender||null, phone||null, address||null,
      blood_group_id||null, hospital_id||null, diagnosis||null, req.params.id);
    ok(res, { updated: true });
  } catch (e) { err(res, e.message); }
});

// ── BLOOD REQUESTS ───────────────────────────────────────────
app.get('/api/requests', (req, res) => {
  const { status, urgency, hospital_id } = req.query;
  let sql = `
    SELECT br.*, bg.group_name,
           p.first_name||' '||p.last_name AS patient_name,
           h.name AS hospital_name,
           s.first_name||' '||s.last_name AS approved_by_name
    FROM blood_requests br
    JOIN blood_groups bg ON br.blood_group_id = bg.blood_group_id
    JOIN hospitals    h  ON br.hospital_id    = h.hospital_id
    LEFT JOIN patients p ON br.patient_id     = p.patient_id
    LEFT JOIN staff    s ON br.approved_by    = s.staff_id
    WHERE 1=1`;
  const params = [];
  if (status)      { sql += ' AND br.status=?';        params.push(status); }
  if (urgency)     { sql += ' AND br.urgency_level=?';  params.push(urgency); }
  if (hospital_id) { sql += ' AND br.hospital_id=?';   params.push(hospital_id); }
  sql += ` ORDER BY
    CASE br.urgency_level WHEN 'critical' THEN 1 WHEN 'high' THEN 2
      WHEN 'medium' THEN 3 ELSE 4 END, br.request_date DESC`;
  ok(res, db.prepare(sql).all(...params));
});

app.post('/api/requests', (req, res) => {
  const { patient_id, hospital_id, blood_group_id, units_requested,
          urgency_level, notes } = req.body;
  if (!hospital_id || !blood_group_id || !units_requested)
    return err(res, 'hospital_id, blood_group_id, units_requested required');
  try {
    const info = db.prepare(`
      INSERT INTO blood_requests
        (patient_id,hospital_id,blood_group_id,units_requested,urgency_level,notes)
      VALUES (?,?,?,?,?,?)`).run(
      patient_id||null, hospital_id, blood_group_id,
      units_requested, urgency_level||'medium', notes||null);
    ok(res, { request_id: info.lastInsertRowid });
  } catch (e) { err(res, e.message); }
});

app.put('/api/requests/:id', (req, res) => {
  const { status, approved_by, units_requested, urgency_level, notes } = req.body;
  try {
    db.prepare(`
      UPDATE blood_requests SET status=?, approved_by=?,
        units_requested=?, urgency_level=?, notes=?,
        approved_date=CASE WHEN ? IN ('approved','fulfilled') THEN datetime('now') ELSE approved_date END
      WHERE request_id=?`).run(
      status, approved_by||null, units_requested, urgency_level, notes||null,
      status, req.params.id);
    ok(res, { updated: true });
  } catch (e) { err(res, e.message); }
});

// ── DASHBOARD STATS ──────────────────────────────────────────
app.get('/api/stats', (_req, res) => {
  const totalDonors       = db.prepare("SELECT COUNT(*) AS c FROM donors WHERE is_active=1").get().c;
  const totalDonations    = db.prepare("SELECT COUNT(*) AS c FROM donations WHERE status='completed'").get().c;
  const pendingRequests   = db.prepare("SELECT COUNT(*) AS c FROM blood_requests WHERE status='pending'").get().c;
  const criticalRequests  = db.prepare("SELECT COUNT(*) AS c FROM blood_requests WHERE urgency_level='critical' AND status NOT IN ('fulfilled','rejected','cancelled')").get().c;
  const totalUnits        = db.prepare("SELECT COALESCE(SUM(units_available),0) AS u FROM blood_inventory WHERE component_type='Whole Blood'").get().u;
  const donationsToday    = db.prepare("SELECT COUNT(*) AS c FROM donations WHERE date(donation_date)=date('now')").get().c;
  const inventory         = db.prepare(`
    SELECT bg.group_name, SUM(bi.units_available) AS units,
      CASE WHEN SUM(bi.units_available) < 30 THEN 'critical'
           WHEN SUM(bi.units_available) < 100 THEN 'low' ELSE 'stable' END AS status
    FROM blood_inventory bi JOIN blood_groups bg ON bi.blood_group_id=bg.blood_group_id
    WHERE bi.component_type='Whole Blood' GROUP BY bi.blood_group_id`).all();
  const recentDonations = db.prepare(`
    SELECT d.first_name||' '||d.last_name AS donor_name, bg.group_name, dn.donation_date, dn.units_donated
    FROM donations dn JOIN donors d ON dn.donor_id=d.donor_id
    JOIN blood_groups bg ON dn.blood_group_id=bg.blood_group_id
    ORDER BY dn.donation_date DESC LIMIT 5`).all();
  const urgentRequests = db.prepare(`
    SELECT br.request_id, h.name AS hospital, bg.group_name, br.urgency_level, br.units_requested, br.request_date
    FROM blood_requests br JOIN hospitals h ON br.hospital_id=h.hospital_id
    JOIN blood_groups bg ON br.blood_group_id=bg.blood_group_id
    WHERE br.status='pending' ORDER BY
      CASE br.urgency_level WHEN 'critical' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 ELSE 4 END
    LIMIT 5`).all();

  ok(res, {
    totalDonors, totalDonations, pendingRequests,
    criticalRequests, totalUnits, donationsToday,
    inventory, recentDonations, urgentRequests
  });
});

// ── SPA fallback for /admin/* ────────────────────────────────
app.get('/admin', (_req, res) => res.redirect('/admin/index.html'));
app.get('/admin/*', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'admin', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`\n🩸 Nutech Blood Bank API running → http://localhost:${PORT}`);
  console.log(`📊 Admin Panel → http://localhost:${PORT}/admin/index.html\n`);
});
