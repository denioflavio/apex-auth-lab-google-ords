# APEX + Google + ORDS Self-Service Demo

Lean technical case for Oracle APEX on Autonomous Database with:

- Google Social Sign-In for human login
- Self-service profile completion
- ORDS OAuth2 `client_credentials` provisioning
- Protected `GET /api/v1/me` endpoint returning the authenticated client's own data

## Project Structure

```text
.
├── README.md
├── docs
│   ├── 01_case_overview.md
│   ├── 04_apex_build_steps.md
│   ├── 05_google_setup.md
│   ├── 05a_apex_google_config.md
│   ├── 07_curl_examples.md
│   └── 08_notes_and_known_limits.md
└── sql
    ├── 01_tables.sql
    ├── 02_packages.sql
    ├── 03_ords_rest.sql
    ├── 04_apex_helpers.sql
    └── 06_test_calls.sql
```

## Start Here

1. Read [docs/01_case_overview.md](docs/01_case_overview.md)
2. Run the SQL scripts in order:
   - [sql/01_tables.sql](sql/01_tables.sql)
   - [sql/02_packages.sql](sql/02_packages.sql)
   - [sql/03_ords_rest.sql](sql/03_ords_rest.sql)
   - [sql/04_apex_helpers.sql](sql/04_apex_helpers.sql)
3. Build the APEX app using [docs/04_apex_build_steps.md](docs/04_apex_build_steps.md)
4. Configure Google Cloud using [docs/05_google_setup.md](docs/05_google_setup.md)
5. Configure Google in APEX using [docs/05a_apex_google_config.md](docs/05a_apex_google_config.md)
6. Validate with:
   - [docs/07_curl_examples.md](docs/07_curl_examples.md)
   - [sql/06_test_calls.sql](sql/06_test_calls.sql)

## Local SQLcl Setup

For local execution with SQLcl, this project includes:

- `.env.local.example` as the template
- `.env.local` for your local credentials
- `run_sqlcl.sh` to connect and run the scripts

Recommended usage:

1. Update `.env.local` with your database username and password
2. Make sure the wallet is extracted into `.wallet/`
3. Run:

```bash
chmod +x run_sqlcl.sh
./run_sqlcl.sh test
./run_sqlcl.sh all
```

`.env.local` is ignored by git and should remain local only.

`sql/04_apex_helpers.sql` is optional from a functional perspective, but useful if you want to use `APP_APEX_AUTH.POST_LOGIN` in the APEX authentication scheme's `Post-Authentication Procedure Name` field.

This project now uses a dedicated schema named `APP_DEMO`. Keep the APEX application parsing schema aligned with `APP_DEMO` to avoid cross-schema complexity.

## Core Design Decisions

- `google_sub` is the stable identity key
- application data is stored in custom tables
- each application user can have only one active ORDS OAuth client
- the client secret is shown only at creation time
- the endpoint resolves the authenticated client defensively and logs runtime diagnostics
