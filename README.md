# APEX + Google + Facebook + ORDS Self-Service Demo

This repository contains a compact working case for Oracle APEX on Autonomous Database:

- Custom Login with local username/password
- Google Social Sign-In
- Facebook Social Sign-In
- a profile completion step after the first social login
- self-service provisioning of standard ORDS OAuth2 `client_credentials`
- a protected `GET /api/v1/me` endpoint that returns the authenticated client's own data

The practical goal is simple: let a user sign in, finish onboarding, receive a valid ORDS client, and call a protected API without adding extra moving parts.

Related post on APEX from the Field:
- https://apexfromthefield.com/?p=297

## What Is Included

- a ready-to-import APEX application export in [apex/f100/install.sql](apex/f100/install.sql)
- Supporting Objects embedded in the APEX export for all database objects the app needs
- standalone SQL scripts in `sql/` for manual installation
- Google and Facebook setup notes
- a documented multi-login configuration with Custom, Google, and Facebook authentication
- curl and Postman examples for end-to-end validation

## Recommended Install Path

If you want the fastest path, import Application 100 and install its Supporting Objects.

### Prerequisites

- Oracle APEX workspace
- Autonomous Database schema named `APP_DEMO`
- ORDS available for that database
- the `APP_DEMO` schema REST-enabled
- permission for `APP_DEMO` to use the `ORDS` and `OAUTH` packages
- a Google Cloud OAuth client for Social Sign-In
- a Meta/Facebook app for Facebook Login

### Install with the APEX Export

1. Import [apex/f100/install.sql](apex/f100/install.sql) into your workspace.
2. During import or right after import, install the application's Supporting Objects.
3. Confirm that the application parsing schema is `APP_DEMO`.
4. Create the Google and Facebook Web Credentials in the workspace.
5. Review the authentication scheme settings in:
   - [docs/05a_apex_google_config.md](docs/05a_apex_google_config.md)
   - [docs/09_multi_login_evolution.md](docs/09_multi_login_evolution.md)
   - [docs/10_facebook_setup.md](docs/10_facebook_setup.md)
6. Run the app and complete the login flow.

The embedded Supporting Objects install these same artifacts:

- `sql/01_tables.sql`
- `sql/02_packages.sql`
- `sql/03_ords_rest.sql`
- `sql/04_apex_helpers.sql`
- `sql/08_multi_login_evolution.sql`

## Manual Install Path

If you prefer to build or review everything step by step:

1. Read [docs/01_case_overview.md](docs/01_case_overview.md)
2. Run the SQL scripts in this order:
   - [sql/01_tables.sql](sql/01_tables.sql)
   - [sql/02_packages.sql](sql/02_packages.sql)
   - [sql/03_ords_rest.sql](sql/03_ords_rest.sql)
   - [sql/04_apex_helpers.sql](sql/04_apex_helpers.sql)
   - [sql/08_multi_login_evolution.sql](sql/08_multi_login_evolution.sql)
3. Build or review the APEX application using:
   - [docs/04_apex_build_steps.md](docs/04_apex_build_steps.md)
   - [docs/09_multi_login_evolution.md](docs/09_multi_login_evolution.md)
4. Configure Google Cloud using [docs/05_google_setup.md](docs/05_google_setup.md)
5. Configure Google in APEX using [docs/05a_apex_google_config.md](docs/05a_apex_google_config.md)
6. Configure Facebook using [docs/10_facebook_setup.md](docs/10_facebook_setup.md)

## How to Use the Demo

1. Open the APEX application.
2. Sign in with Custom Login, Google, or Facebook.
3. On the first social login, complete the profile form.
4. Submit the form and copy the generated `client_id` and `client_secret`.
5. Exchange the credentials for an access token.
6. Call `GET /api/v1/me`.
7. Confirm that the JSON returned by ORDS matches the authenticated client.

Use these references for testing:

- [docs/07_curl_examples.md](docs/07_curl_examples.md)
- [sql/06_test_calls.sql](sql/06_test_calls.sql)
- [postman/APEX_ORDS_Self_Service_Demo.postman_collection.json](postman/APEX_ORDS_Self_Service_Demo.postman_collection.json)

## Local SQLcl Setup

If you want to run the scripts locally with SQLcl:

1. Copy `.env.local.example` to `.env.local`
2. Fill in:
   - `DB_USER`
   - `DB_PASSWORD`
   - `DB_TNS_ALIAS`
   - wallet path
   - SQLcl path
3. Extract the wallet into `.wallet/`
4. Run:

```bash
chmod +x run_sqlcl.sh
./run_sqlcl.sh test
./run_sqlcl.sh all
./run_sqlcl.sh multi-login
```

Useful commands:

```bash
./run_sqlcl.sh checks
./run_sqlcl.sh reset-demo
```

`.env.local` is ignored by git and should remain local only.

## Project Structure

```text
.
├── README.md
├── apex/
│   └── f100/
│       └── install.sql
├── docs/
│   ├── 01_case_overview.md
│   ├── 04_apex_build_steps.md
│   ├── 05_google_setup.md
│   ├── 05a_apex_google_config.md
│   ├── 07_curl_examples.md
│   ├── 08_notes_and_known_limits.md
│   ├── 09_multi_login_evolution.md
│   └── 10_facebook_setup.md
├── postman/
│   └── APEX_ORDS_Self_Service_Demo.postman_collection.json
├── run_sqlcl.sh
└── sql/
    ├── 01_tables.sql
    ├── 02_packages.sql
    ├── 03_ords_rest.sql
    ├── 04_apex_helpers.sql
    ├── 06_test_calls.sql
    ├── 07_reset_demo_data.sql
    └── 08_multi_login_evolution.sql
```

## Key Design Choices

- `(auth_provider, external_subject)` is the stable identity key for social login users.
- custom login users are identified by their normalized email username.
- `email` is unique across providers to prevent duplicate accounts for the same person.
- application data stays in custom tables owned by `APP_DEMO`.
- each application user can have only one active ORDS OAuth client.
- the client secret is shown only once, at creation time.
- returning users go directly to Page 20 after authentication.
- first-time social users complete Page 10 before receiving ORDS credentials.
