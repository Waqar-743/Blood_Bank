# NUTech Blood Bank Management System

**Live site:** https://waqar-743.github.io/Blood_Bank/

NUTech Blood Bank is a full-stack blood bank management project with:
- a public-facing landing page,
- an admin dashboard for operations,
- a REST API backed by SQLite,
- seeded sample data for immediate demo usage.

The platform is designed for donor management, inventory tracking, hospital requests, and operational monitoring from a single interface.

## Core capabilities

- Donor registry with search/filter, profile updates, and status management
- Blood donations logging with automatic donor statistics updates
- Inventory monitoring with low/critical stock visibility
- Patient records and hospital-linked blood request workflows
- Dashboard analytics (donors, donations, stock, urgent requests)
- SQL schema, seed, and analytical query scripts included

## Tech stack

- **Backend:** Node.js, Express, SQLite (`node:sqlite`)
- **Frontend:** HTML, Tailwind CSS (CDN), Chart.js
- **Database:** Local SQLite file (`data/bloodbank.db`) with auto-seeding
- **CI/CD:** GitHub Actions (smoke checks + GitHub Pages deployment)

## Project structure

```text
.
├── backend/
│   ├── server.js
│   ├── database.js
│   └── package.json
├── frontend/
│   ├── admin/
│   │   ├── login.html
│   │   └── index.html
│   └── assets/
├── image/
├── sql/
│   ├── schema.sql
│   ├── seed.sql
│   └── queries.sql
├── Landing Page.html
└── start.bat
```

## Getting started

### Prerequisites

- Node.js **22+**
- npm **10+**

### Option 1 (Windows quick start)

Run:

```bat
start.bat
```

This installs dependencies and starts the API + frontend at:
- `http://localhost:3000/`
- `http://localhost:3000/admin/login.html`

### Option 2 (manual)

```bash
cd backend
npm ci
npm start
```

## Demo admin access

- Username: `admin` (or `admin@nutechblood.org`)
- Password: `admin123`

## API overview

Base URL (local): `http://localhost:3000/api`

| Area | Endpoints |
|---|---|
| Reference Data | `GET /blood-groups`, `GET /blood-banks`, `GET /hospitals`, `GET /staff` |
| Donors | `GET /donors`, `GET /donors/:id`, `POST /donors`, `PUT /donors/:id`, `DELETE /donors/:id` |
| Donations | `GET /donations`, `POST /donations` |
| Inventory | `GET /inventory`, `GET /inventory/summary`, `PUT /inventory/:id` |
| Patients | `GET /patients`, `GET /patients/:id`, `POST /patients`, `PUT /patients/:id` |
| Requests | `GET /requests`, `POST /requests`, `PUT /requests/:id` |
| Dashboard | `GET /stats` |

## SQL artifacts

The `sql/` folder includes:
- **schema.sql**: normalized schema (3NF) with keys and indexes
- **seed.sql**: sample dataset
- **queries.sql**: analytical and reporting queries

The runtime API uses `backend/database.js` to initialize and seed SQLite automatically for local/demo use.

## CI/CD pipeline

Workflow file: `.github/workflows/ci-cd.yml`

Pipeline behavior:
1. Runs on push/PR to `main` and `master`
2. Installs backend dependencies with Node 22
3. Starts the API and performs smoke checks on:
   - `GET /api/stats`
   - `GET /api/blood-groups`
4. On push, deploys the static site to GitHub Pages

## Frontend API base configuration

The admin panel resolves its API base in this order:
1. `?apiBase=<url>` query parameter
2. `localStorage.NB_API_BASE`
3. Current origin + `/api`

Examples:
- `https://waqar-743.github.io/Blood_Bank/frontend/admin/index.html?apiBase=https://your-api-domain.com/api`
- In browser console:
  `localStorage.setItem('NB_API_BASE', 'https://your-api-domain.com/api')`

## License

MIT
