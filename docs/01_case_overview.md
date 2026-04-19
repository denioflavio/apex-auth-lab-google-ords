# Technical Case: APEX + Google Social Sign-In + ORDS OAuth2 Client Credentials

## Overview

This case demonstrates a lean self-service flow in Oracle APEX running on Autonomous Database with ORDS:

1. The user signs in to APEX using Google Social Sign-In.
2. On the first login, the user completes a minimal profile form.
3. After submission, the application provisions a standard ORDS OAuth2 `client_id` / `client_secret` using the `client_credentials` grant.
4. The user exchanges those credentials for an ORDS access token.
5. The user calls `GET /api/v1/me`.
6. The endpoint returns data for the authenticated client itself.

The design intentionally avoids unnecessary layers. APEX handles the human workflow. ORDS handles token issuance and endpoint protection. The database stores only simple profile and linkage tables.

## Architecture Summary

### Components

- Oracle APEX
- ORDS with the application schema REST-enabled
- Autonomous Database 26ai
- Google Identity / Google Cloud OAuth

### Authentication Flow

1. The user accesses the APEX application.
2. The authentication scheme uses Google Social Sign-In.
3. APEX receives the social identity on the standard callback `apex_authentication.callback` or `apex_authentication.callback2`.
4. A post-login process extracts identity attributes and stores them into application items:
   - `google_sub`
   - `email`
   - `full_name`
5. The application looks up `app_users` by `google_sub`.

### Registration Flow

1. If no user exists for that `google_sub`, APEX redirects to `Complete your profile`.
2. The form pre-fills `full_name` when it is available from Google.
3. The user submits:
   - full name
   - birth date
   - phone number
4. The page process calls `app_user_api.complete_registration`.
5. The procedure upserts the user and provisions the OAuth client only if no active client already exists.

### Client Credentials Provisioning Flow

1. The PL/SQL package calls `OAUTH.CREATE_CLIENT`.
2. It ensures the ORDS role exists with `ORDS.CREATE_ROLE`.
3. It grants that role to the client through `OAUTH.GRANT_CLIENT_ROLE`.
4. It reads `client_id` and `client_secret` from `USER_ORDS_CLIENTS`.
5. It stores only the application-to-ORDS linkage in `app_user_oauth_clients`.
6. The client secret is displayed only at creation time.

### Protected Endpoint Consumption Flow

1. The client submits `POST .../oauth/token` with `grant_type=client_credentials`.
2. ORDS issues the access token.
3. The client calls `GET /api/v1/me` with `Authorization: Bearer <token>`.
4. The ORDS handler resolves the authenticated OAuth client.
5. The endpoint returns a compact JSON payload with the linked user data.

### Relationship Between Social Login and OAuth Client

- The primary user identity is `google_sub`.
- The APEX registration flow creates or updates the row in `app_users`.
- Each application user can have at most one active OAuth client.
- The linkage is stored in `app_user_oauth_clients`.
- On later logins, if an active client already exists, the application reuses it and does not create a second one.

## Technical Choices

- Primary identity key: `google_sub`
- Email is informational only and not the sole identity key
- One active OAuth client per user
- No secret rotation in the core demo flow
- Endpoint protected by ORDS privilege and role
- Defensive client resolution in the endpoint using `SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')` first, then runtime fallbacks

## Project Files

- `sql/01_tables.sql`
- `sql/02_packages.sql`
- `sql/03_ords_rest.sql`
- `docs/04_apex_build_steps.md`
- `docs/05_google_setup.md`
- `docs/05a_apex_google_config.md`
- `sql/06_test_calls.sql`
- `docs/07_curl_examples.md`
- `docs/08_notes_and_known_limits.md`

## Suggested Execution Order

1. Run `sql/01_tables.sql`
2. Run `sql/02_packages.sql`
3. Run `sql/03_ords_rest.sql`
4. Build the APEX application using `docs/04_apex_build_steps.md`
5. Configure Google Cloud using `docs/05_google_setup.md`
6. Validate with `docs/07_curl_examples.md` and `sql/06_test_calls.sql`

## Main Objects

- Tables:
  - `app_users`
  - `app_user_oauth_clients`
  - `app_api_event_log`
- Packages:
  - `app_security_ctx`
  - `app_user_api`
- ORDS:
  - module `api`
  - template `v1/me`
  - handler `GET`
  - privilege `app.me.privilege`
  - role `app_me_role`

The data model uses identity columns, not custom sequences.

## Environment Assumptions

- The application schema must be REST-enabled in ORDS.
- The schema must be allowed to use the `ORDS` and `OAUTH` packages.
- APEX Social Sign-In must be available in the environment.
- The Google redirect URI must exactly match the callback URL shown by APEX.

## Validated Runtime Notes

This case was validated in a real environment with:

- schema mapping:
  - `app_demo`
- token endpoint:
  - `https://GD7949C88CCAFBD-APEXFROMTHEFIELD.adb.sa-saopaulo-1.oraclecloudapps.com/ords/app_demo/oauth/token`
- protected endpoint:
  - `https://GD7949C88CCAFBD-APEXFROMTHEFIELD.adb.sa-saopaulo-1.oraclecloudapps.com/ords/app_demo/api/v1/me`

Observed ORDS runtime behavior for `client_credentials`:

- `current_user` contained the `client_id`
- `remote_ident` contained the `client_id`
- `client_identifier` contained the `client_id`
- `session_user` was `APP_DEMO`
- `current_schema` was `APP_DEMO`

This confirms that the defensive lookup implemented in the package works in the target environment.
