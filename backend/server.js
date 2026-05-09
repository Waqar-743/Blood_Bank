require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const helmet  = require('helmet');
const morgan  = require('morgan');
const path    = require('path');

const supabase = require('./supabase');
const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────────
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(morgan('dev'));

// Serve frontend files
app.use(express.static(path.join(__dirname, '..', 'frontend')));
app.use(express.static(path.join(__dirname, '..')));
app.get('/', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'Landing Page.html'));
});

// ── Helpers ───────────────────────────────────────────────────
const ok  = (res, data)          => res.json({ success: true, data });
const err = (res, msg, code=400) => res.status(code).json({ success: false, error: msg });

// Throw on Supabase error helper
function check(error, res) {
  if (error) { err(res, error.message); return false; }
  return true;
}

// ── BLOOD GROUPS ─────────────────────────────────────────────
app.get('/api/blood-groups', async (_req, res) => {
  const { data, error } = await supabase
    .from('blood_groups').select('*').order('group_name');
  if (!check(error, res)) return;
  ok(res, data);
});

// ── BLOOD BANKS ──────────────────────────────────────────────
app.get('/api/blood-banks', async (_req, res) => {
  const { data, error } = await supabase
    .from('blood_banks').select('*').eq('is_active', true).order('name');
  if (!check(error, res)) return;
  ok(res, data);
});

// ── HOSPITALS ────────────────────────────────────────────────
app.get('/api/hospitals', async (_req, res) => {
  const { data, error } = await supabase
    .from('hospitals').select('*').order('name');
  if (!check(error, res)) return;
  ok(res, data);
});

// ── STAFF ────────────────────────────────────────────────────
app.get('/api/staff', async (_req, res) => {
  const { data, error } = await supabase
    .from('staff')
    .select('*, blood_banks(name)')
    .eq('is_active', true)
    .order('first_name');
  if (!check(error, res)) return;
  ok(res, data.map(s => ({ ...s, bank_name: s.blood_banks?.name, blood_banks: undefined })));
});

// ── DONORS ───────────────────────────────────────────────────
app.get('/api/donors', async (req, res) => {
  const { search, blood_group, city, active } = req.query;
  let q = supabase
    .from('v_donors_detail')
    .select('*');

  if (search) {
    q = q.or(`first_name.ilike.%${search}%,last_name.ilike.%${search}%,phone.ilike.%${search}%`);
  }
  if (blood_group) q = q.eq('blood_group_id', blood_group);
  if (city)        q = q.ilike('city', city);
  if (active !== undefined && active !== '') q = q.eq('is_active', active === '1' || active === 'true');

  q = q.order('registration_date', { ascending: false });
  const { data, error } = await q;
  if (!check(error, res)) return;
  ok(res, data);
});

app.get('/api/donors/:id', async (req, res) => {
  const { data: donor, error: de } = await supabase
    .from('v_donors_detail').select('*').eq('donor_id', req.params.id).single();
  if (de) return err(res, 'Donor not found', 404);

  const { data: donations } = await supabase
    .from('v_donations_detail').select('*')
    .eq('donor_id', req.params.id)
    .order('donation_date', { ascending: false });

  ok(res, { ...donor, donations: donations || [] });
});

app.post('/api/donors', async (req, res) => {
  const { first_name, last_name, dob, gender, phone, email, address, city,
          blood_group_id, weight_kg, emergency_contact } = req.body;
  if (!first_name || !last_name || !dob || !gender || !phone || !blood_group_id)
    return err(res, 'Missing required fields');

  const { data, error } = await supabase.from('donors').insert({
    first_name, last_name, dob, gender, phone,
    email: email || null, address: address || null, city: city || null,
    blood_group_id, weight_kg: weight_kg || null,
    emergency_contact: emergency_contact || null
  }).select('donor_id').single();
  if (!check(error, res)) return;
  ok(res, { donor_id: data.donor_id });
});

app.put('/api/donors/:id', async (req, res) => {
  const { first_name, last_name, dob, gender, phone, email, address, city,
          blood_group_id, weight_kg, is_active, emergency_contact } = req.body;
  const { error } = await supabase.from('donors').update({
    first_name, last_name, dob, gender, phone,
    email: email || null, address: address || null, city: city || null,
    blood_group_id, weight_kg: weight_kg || null,
    is_active: is_active ?? true,
    emergency_contact: emergency_contact || null
  }).eq('donor_id', req.params.id);
  if (!check(error, res)) return;
  ok(res, { updated: true });
});

app.delete('/api/donors/:id', async (req, res) => {
  const { error } = await supabase.from('donors')
    .update({ is_active: false }).eq('donor_id', req.params.id);
  if (!check(error, res)) return;
  ok(res, { deleted: true });
});

// ── DONATIONS ────────────────────────────────────────────────
app.get('/api/donations', async (req, res) => {
  const { donor_id, status, limit = 50 } = req.query;
  let q = supabase.from('v_donations_detail').select('*');
  if (donor_id) q = q.eq('donor_id', donor_id);
  if (status)   q = q.eq('status', status);
  q = q.order('donation_date', { ascending: false }).limit(parseInt(limit));
  const { data, error } = await q;
  if (!check(error, res)) return;
  ok(res, data);
});

app.post('/api/donations', async (req, res) => {
  const { donor_id, bank_id, staff_id, blood_group_id, donation_date,
          units_donated, hemoglobin_level, blood_pressure, notes } = req.body;
  if (!donor_id || !bank_id || !blood_group_id)
    return err(res, 'donor_id, bank_id, blood_group_id required');

  const { data, error } = await supabase.from('donations').insert({
    donor_id, bank_id, staff_id: staff_id || null, blood_group_id,
    donation_date: donation_date || new Date().toISOString(),
    units_donated: units_donated || 1.0,
    hemoglobin_level: hemoglobin_level || null,
    blood_pressure: blood_pressure || null,
    notes: notes || null, status: 'completed'
  }).select('donation_id').single();
  if (!check(error, res)) return;

  // Update donor stats
  await supabase.rpc('increment_donor_donations', {
    p_donor_id: donor_id,
    p_date: donation_date || new Date().toISOString()
  });

  // Update inventory
  await supabase.rpc('update_inventory_units', {
    p_bank_id: bank_id,
    p_blood_group_id: blood_group_id,
    p_units: units_donated || 1.0
  });

  ok(res, { donation_id: data.donation_id });
});

// ── INVENTORY ────────────────────────────────────────────────
app.get('/api/inventory', async (req, res) => {
  const { bank_id } = req.query;
  let q = supabase.from('v_inventory_detail').select('*');
  if (bank_id) q = q.eq('bank_id', bank_id);
  q = q.order('units_available', { ascending: true });
  const { data, error } = await q;
  if (!check(error, res)) return;
  ok(res, data);
});

app.get('/api/inventory/summary', async (_req, res) => {
  const { data, error } = await supabase.from('v_inventory_summary').select('*');
  if (!check(error, res)) return;
  ok(res, data);
});

app.put('/api/inventory/:id', async (req, res) => {
  const { units_available, units_reserved, expiry_date } = req.body;
  const { error } = await supabase.from('blood_inventory').update({
    units_available,
    units_reserved: units_reserved || 0,
    expiry_date: expiry_date || null,
    last_updated: new Date().toISOString()
  }).eq('inventory_id', req.params.id);
  if (!check(error, res)) return;
  ok(res, { updated: true });
});

// ── PATIENTS ─────────────────────────────────────────────────
app.get('/api/patients', async (req, res) => {
  const { search, hospital_id } = req.query;
  let q = supabase.from('v_patients_detail').select('*');
  if (search) {
    q = q.or(`first_name.ilike.%${search}%,last_name.ilike.%${search}%,medical_record_no.ilike.%${search}%`);
  }
  if (hospital_id) q = q.eq('hospital_id', hospital_id);
  q = q.order('registered_date', { ascending: false });
  const { data, error } = await q;
  if (!check(error, res)) return;
  ok(res, data);
});

app.get('/api/patients/:id', async (req, res) => {
  const { data, error } = await supabase
    .from('v_patients_detail').select('*').eq('patient_id', req.params.id).single();
  if (error) return err(res, 'Patient not found', 404);
  ok(res, data);
});

app.post('/api/patients', async (req, res) => {
  const { first_name, last_name, dob, gender, phone, address,
          blood_group_id, hospital_id, medical_record_no, diagnosis } = req.body;
  if (!first_name || !last_name) return err(res, 'Name required');

  const { data, error } = await supabase.from('patients').insert({
    first_name, last_name,
    dob: dob || null, gender: gender || null, phone: phone || null,
    address: address || null,
    blood_group_id: blood_group_id || null,
    hospital_id: hospital_id || null,
    medical_record_no: medical_record_no || `MRN-${Date.now()}`,
    diagnosis: diagnosis || null
  }).select('patient_id').single();
  if (!check(error, res)) return;
  ok(res, { patient_id: data.patient_id });
});

app.put('/api/patients/:id', async (req, res) => {
  const { first_name, last_name, dob, gender, phone, address,
          blood_group_id, hospital_id, diagnosis } = req.body;
  const { error } = await supabase.from('patients').update({
    first_name, last_name,
    dob: dob || null, gender: gender || null, phone: phone || null,
    address: address || null,
    blood_group_id: blood_group_id || null,
    hospital_id: hospital_id || null,
    diagnosis: diagnosis || null
  }).eq('patient_id', req.params.id);
  if (!check(error, res)) return;
  ok(res, { updated: true });
});

// ── BLOOD REQUESTS ───────────────────────────────────────────
app.get('/api/requests', async (req, res) => {
  const { status, urgency, hospital_id } = req.query;
  let q = supabase.from('v_requests_detail').select('*');
  if (status)      q = q.eq('status', status);
  if (urgency)     q = q.eq('urgency_level', urgency);
  if (hospital_id) q = q.eq('hospital_id', hospital_id);
  // Order by urgency priority then date
  q = q.order('request_date', { ascending: false });
  const { data, error } = await q;
  if (!check(error, res)) return;

  // Sort by urgency client-side (critical → high → medium → low)
  const priority = { critical: 1, high: 2, medium: 3, low: 4 };
  data.sort((a, b) => {
    const pa = priority[a.urgency_level] || 5;
    const pb = priority[b.urgency_level] || 5;
    return pa - pb;
  });
  ok(res, data);
});

app.post('/api/requests', async (req, res) => {
  const { patient_id, hospital_id, blood_group_id, units_requested,
          urgency_level, notes } = req.body;
  if (!hospital_id || !blood_group_id || !units_requested)
    return err(res, 'hospital_id, blood_group_id, units_requested required');

  const { data, error } = await supabase.from('blood_requests').insert({
    patient_id: patient_id || null,
    hospital_id, blood_group_id, units_requested,
    urgency_level: urgency_level || 'medium',
    notes: notes || null
  }).select('request_id').single();
  if (!check(error, res)) return;
  ok(res, { request_id: data.request_id });
});

app.put('/api/requests/:id', async (req, res) => {
  const { status, approved_by, units_requested, urgency_level, notes } = req.body;
  const update = { status, units_requested, urgency_level, notes: notes || null };
  if (approved_by) update.approved_by = approved_by;
  if (status === 'approved' || status === 'fulfilled') {
    update.approved_date = new Date().toISOString();
  }
  const { error } = await supabase.from('blood_requests')
    .update(update).eq('request_id', req.params.id);
  if (!check(error, res)) return;
  ok(res, { updated: true });
});

// ── DASHBOARD STATS ──────────────────────────────────────────
app.get('/api/stats', async (_req, res) => {
  const [
    { count: totalDonors },
    { count: totalDonations },
    { count: pendingRequests },
    { count: criticalRequests },
    invRes,
    summRes,
    recentDonRes,
    urgentReqRes
  ] = await Promise.all([
    supabase.from('donors').select('*', { count: 'exact', head: true }).eq('is_active', true),
    supabase.from('donations').select('*', { count: 'exact', head: true }).eq('status', 'completed'),
    supabase.from('blood_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('blood_requests').select('*', { count: 'exact', head: true })
      .eq('urgency_level', 'critical').not('status', 'in', '("fulfilled","rejected","cancelled")'),
    supabase.from('blood_inventory')
      .select('units_available').eq('component_type', 'Whole Blood'),
    supabase.from('v_inventory_summary').select('*'),
    supabase.from('v_donations_detail')
      .select('donor_name,group_name,donation_date,units_donated')
      .order('donation_date', { ascending: false }).limit(5),
    supabase.from('v_requests_detail')
      .select('request_id,hospital_name,group_name,urgency_level,units_requested,request_date')
      .eq('status', 'pending')
      .order('request_date', { ascending: false }).limit(5)
  ]);

  const totalUnits = (invRes.data || []).reduce((s, r) => s + parseFloat(r.units_available || 0), 0);

  // Donations today (client-side filter for simplicity)
  const today = new Date().toISOString().slice(0, 10);
  const { count: donationsToday } = await supabase
    .from('donations')
    .select('*', { count: 'exact', head: true })
    .gte('donation_date', today + 'T00:00:00')
    .lte('donation_date', today + 'T23:59:59');

  ok(res, {
    totalDonors, totalDonations, pendingRequests,
    criticalRequests, totalUnits, donationsToday,
    inventory: summRes.data || [],
    recentDonations: recentDonRes.data || [],
    urgentRequests: (urgentReqRes.data || []).map(r => ({
      ...r, hospital: r.hospital_name
    }))
  });
});

// ── SPA fallback ──────────────────────────────────────────────
app.get('/admin', (_req, res) => res.redirect('/admin/index.html'));
app.get('/admin/*', (_req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'admin', 'index.html'));
});

// Run directly (local dev) — Vercel uses the module.exports below instead
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`\n Blood Bank API → http://localhost:${PORT}`);
    console.log(` Admin Panel   → http://localhost:${PORT}/admin/index.html\n`);
  });
}

module.exports = app;
