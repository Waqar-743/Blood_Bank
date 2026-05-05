# NUTech Blood Bank Management System

A full-stack Blood Bank Management System built for the CS160 Database Systems Project-Based Learning module at the National University of Technology (NUTech). The system combines a public landing page, an administrative dashboard, and a RESTful API backed by a normalized SQLite database to coordinate donors, donations, hospital requests, and inventory in a single workflow.


## Highlights

- Donor registry with search, filters, profile updates, and eligibility tracking
- Donation logging with automatic donor statistics and inventory updates
- Real-time inventory monitoring with low-stock and critical-stock indicators
- Patient records and hospital-linked blood request workflow with status transitions
- Operational analytics dashboard for donors, donations, inventory, and urgent requests
- Normalized SQL schema (3NF), realistic seed data, and reporting queries included
- Continuous integration with backend smoke tests and automated GitHub Pages deployment

## Technology Stack

| Layer | Technology |
| --- | --- |
| Backend | Node.js 22+, Express 4 |
| Database | SQLite via the built-in `node:sqlite` module |
| Frontend | HTML5, Tailwind CSS (CDN), Chart.js |
| Security | Helmet, CORS, structured request logging via Morgan |
| CI/CD | GitHub Actions, GitHub Pages |

## Repository Structure

```text
.
├── backend/
│   ├── server.js             Express application and route definitions
│   ├── database.js           Schema initialization, seed data, query helpers
│   ├── package.json          Backend manifest and scripts
│   └── package-lock.json
├── frontend/
│   ├── admin/
│   │   ├── login.html        Admin authentication page
│   │   └── index.html        Admin dashboard (donors, donations, inventory, requests, analytics)
│   └── assets/               Shared frontend assets
├── image/                    Landing page imagery
├── sql/
│   ├── schema.sql            DDL for the full normalized schema
│   ├── seed.sql              Reference and demonstration data
│   └── queries.sql           Reporting and analytical queries
├── data/                     Local SQLite database file (created at runtime)
├── Landing Page.html         Public landing page
├── start.bat                 Windows convenience launcher
├── smoke_test.bat            Local smoke test script
└── .github/workflows/ci-cd.yml  Continuous integration and deployment pipeline
```

## Getting Started

### Prerequisites

- Node.js 22 or newer
- npm 10 or newer
- A modern browser (Chrome, Edge, Firefox, or Safari)

### Windows quick start

```bat
start.bat
```

The launcher installs dependencies, starts the API on port 3000, and opens the landing page in the default browser.

### Manual start

```bash
cd backend
npm ci
npm start
```

Once the server is running:

- Public landing page: http://localhost:3000/
- Admin login: http://localhost:3000/admin/login.html
- API base URL: http://localhost:3000/api

## Demo Administrator Credentials

| Field | Value |
| --- | --- |
| Username | admin (or admin@nutechblood.org) |
| Password | admin123 |

These credentials are intended for evaluation and demonstration only and should be replaced before any production use.

## REST API Reference

Base URL (local development): `http://localhost:3000/api`

| Domain | Method and Path | Description |
| --- | --- | --- |
| Reference | GET /blood-groups | List all blood groups |
| Reference | GET /blood-banks | List blood banks |
| Reference | GET /hospitals | List hospitals |
| Reference | GET /staff | List staff members |
| Donors | GET /donors | List donors with optional filters |
| Donors | GET /donors/:id | Retrieve a single donor |
| Donors | POST /donors | Register a new donor |
| Donors | PUT /donors/:id | Update donor information |
| Donors | DELETE /donors/:id | Remove a donor |
| Donations | GET /donations | List donations |
| Donations | POST /donations | Record a donation |
| Inventory | GET /inventory | Detailed inventory rows |
| Inventory | GET /inventory/summary | Aggregated inventory by blood group |
| Inventory | PUT /inventory/:id | Adjust an inventory record |
| Patients | GET /patients | List patients |
| Patients | GET /patients/:id | Retrieve a single patient |
| Patients | POST /patients | Register a patient |
| Patients | PUT /patients/:id | Update patient information |
| Requests | GET /requests | List blood requests |
| Requests | POST /requests | Create a new blood request |
| Requests | PUT /requests/:id | Update request status |
| Dashboard | GET /stats | Aggregate statistics for the dashboard |

All responses follow the shape `{ "success": boolean, "data": ... }` and use standard HTTP status codes for error reporting.

## Connecting the Hosted Frontend to a Live API

The admin panel resolves its API base URL in the following order:

1. `?apiBase=<url>` query string parameter
2. `localStorage.NB_API_BASE`
3. The page origin with the `/api` suffix appended

Examples:

```text
https://waqar-743.github.io/Blood_Bank/frontend/admin/index.html?apiBase=https://your-api-host.example.com/api
```

```js
localStorage.setItem('NB_API_BASE', 'https://your-api-host.example.com/api');
```

For evaluators running the API locally, the default origin-based resolution works without any configuration.

## Database and SQL Artifacts

The `sql/` directory contains the deliverables required for the database systems module:

- `schema.sql` — Data definition language for ten normalized tables with primary keys, foreign keys, and indexes
- `seed.sql` — Twenty representative records per table covering Pakistani locales and realistic operational data
- `queries.sql` — Data manipulation, aggregation, multi-table joins, and common table expressions used across the reports

At runtime, `backend/database.js` recreates and seeds the SQLite database under `data/bloodbank.db` so that the system is immediately usable for demonstrations.

The schema covers ten entities: `blood_groups`, `blood_banks`, `hospitals`, `staff`, `donors`, `donations`, `blood_inventory`, `patients`, `blood_requests`, and `transfusions`.

## Continuous Integration and Deployment

The workflow defined in `.github/workflows/ci-cd.yml` runs on every push and pull request targeting `main` or `master`, and can also be triggered manually via the GitHub Actions interface.

Pipeline stages:

1. Repository checkout and Node.js 22 setup with npm caching.
2. Static asset validation to ensure the landing page, admin pages, and image directory are present before deployment.
3. Backend dependency installation with `npm ci` from the locked manifest.
4. Backend smoke tests that boot the Express API, wait for readiness, and validate the structure of the `/api/stats` and `/api/blood-groups` endpoints.
5. SQL artifact validation that confirms `schema.sql`, `seed.sql`, and `queries.sql` exist and are non-empty.
6. Static site packaging into a `dist/` artifact containing the landing page (also copied to `index.html`), the `frontend/` directory, and the `image/` directory.
7. Deployment to GitHub Pages via the official `actions/deploy-pages` action. Deployment is gated on the smoke and validation jobs and is skipped for pull requests.

The deployed URL is exposed as the workflow environment URL and is also available at https://waqar-743.github.io/Blood_Bank/.

### Enabling GitHub Pages for the repository

This is a one-time configuration step performed in the repository settings:

1. Open the repository on GitHub.
2. Navigate to **Settings → Pages**.
3. Under **Build and deployment → Source**, select **GitHub Actions**.
4. Push to `main` (or trigger the workflow manually) to publish the site.

## Local Smoke Test

A Windows convenience script is provided to reproduce the CI smoke checks locally:

```bat
smoke_test.bat
```

The script installs dependencies, starts the API, exercises `/api/stats` and `/api/blood-groups`, and shuts the process down on completion.

## Authors and Acknowledgements

Developed by the AI-25B cohort at the National University of Technology under the supervision of Ms. Sumera Aslam for the CS160 Database Systems module.

## License

This project is released under the MIT License. See the `LICENSE` file for the full text.
