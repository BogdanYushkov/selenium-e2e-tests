# Tracks — UI E2E Test Automation (Selenium + Pytest)

End-to-end UI test suite for the **Projects** module of [Tracks](https://www.getontracks.org/) — an open-source Todo & productivity application (Ruby on Rails).
The suite is requirement-driven: each test maps to a documented Functional Requirement (FR-001 … FR-020).

> Built as a portfolio project demonstrating practical QA Automation skills:
> requirements traceability, Page-level UI testing with Selenium WebDriver,
> Pytest fixtures, dockerized SUT (System Under Test), and HTML reporting.

---

## Tech Stack

| Layer            | Tool                                                |
| ---------------- | --------------------------------------------------- |
| Language         | Python 3.11                                         |
| Test framework   | Pytest                                              |
| UI automation    | Selenium WebDriver (Chrome)                         |
| Reporting        | pytest-html (self-contained HTML report)            |
| SUT environment  | Docker Compose (Tracks app + MariaDB)               |
| Driver management| webdriver-manager                                   |

---

## Project Structure

```
.
├── db-init/                    # SQL scripts auto-executed on first DB start
│   ├── create-users.sql        # Creates DB users (admin / tracks)
│   └── init-tables.sql         # Schema initialization
├── docs/
│   └── pytest-report.png       # Screenshot of the latest pytest-html run
├── tests/
│   └── ui/
│       ├── pages/
│       │   └── projects_page.py  # Page Object: locators + actions for /projects
│       ├── conftest.py           # Fixtures: driver, base_url, login, unique names, projects_page
│       └── test_projects_ui.py   # 18 E2E tests mapped to FR-001…FR-020
├── docker-compose.yml          # Brings up Tracks app + MariaDB
├── pytest.ini                  # HTML report + verbose output
├── requirements.txt
└── README.md
```

---

## Test Coverage

Coverage of the **Projects** module is organized by functional requirement:

| Area              | Requirements              | Examples                                              |
| ----------------- | ------------------------- | ----------------------------------------------------- |
| Listing & access  | FR-001, FR-002, FR-003    | Project list visibility, status display, auth guard   |
| Creation          | FR-004 … FR-009           | Required fields, success flash, duplicates, max-length|
| Editing           | FR-011 … FR-015           | Edit name/description, save confirmation, uniqueness  |
| Deletion          | FR-017, FR-018, FR-020    | Confirmation prompt, list update, success message     |

Each test is named `test_FR_XXX_<description>` so traceability between
requirements and automation is one-to-one.

---

## Getting Started

### Prerequisites
- Python 3.11+
- Docker Desktop
- Google Chrome

### 1. Start the System Under Test

```bash
docker compose up -d
```

The Tracks app will be available at **http://localhost:3000**.
A default user is provisioned by `db-init/`:
- login: `admin`
- password: `1234567890`

### 2. Install test dependencies

```bash
python -m venv venv
# Windows
venv\Scripts\activate
# macOS / Linux
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Run the tests

```bash
pytest
```

An HTML report will be generated at `reports/report.html` (configured in `pytest.ini`).

### 4. Stop the environment

```bash
docker compose down -v
```

---

## Design Decisions

- **Page Object Model** — `ProjectsPage` (in `tests/ui/pages/`) encapsulates locators and high-level actions (`create`, `open_edit`, `click_delete`, `wait_for_flash`, …). Test bodies stay declarative and readable; locator changes are localized to a single file.
- **Fixtures over duplication** — `projects_page` composes `driver + base_url + login` and yields a ready-to-use Page Object; `unique_project_name` / `unique_name` factories guarantee test data isolation across runs without manual cleanup.
- **Session-scoped WebDriver** — one browser per run for speed; isolation is delivered by unique names, not by recreating the driver.
- **Explicit waits only** — every synchronization point uses `WebDriverWait` against an observable state (element value, flash message, alert presence). No `time.sleep`.
- **Headless toggle** — `--headless=new` flag is prepared in `conftest.py` for CI execution.
- **Requirement-based naming** — every test maps to an FR ID (`test_FR_001_…`), making coverage reviews and regression triage straightforward.
- **Dockerized SUT** — the application and DB run as containers (`SECRET_KEY_BASE`, `DATABASE_URL` pre-wired), so the suite is reproducible on any machine without manual setup.
