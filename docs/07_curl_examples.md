# curl Examples

Replace the placeholders before running the commands.

Validated base values in this environment:

```bash
export HOST="https://GD7949C88CCAFBD-APEXFROMTHEFIELD.adb.sa-saopaulo-1.oraclecloudapps.com"
export SCHEMA_MAPPING="app_demo"
```

## 1. Get an Access Token

Expected token endpoint:

```text
https://<HOST>/ords/<SCHEMA_MAPPING>/oauth/token
```

Example:

```bash
curl -X POST "https://<HOST>/ords/<SCHEMA_MAPPING>/oauth/token" \
  -u "<CLIENT_ID>:<CLIENT_SECRET>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials"
```

Expected response:

```json
{
  "access_token": "<ACCESS_TOKEN>",
  "token_type": "bearer",
  "expires_in": 3600
}
```

## 2. Call the Protected `/api/v1/me` Endpoint

```bash
curl -X GET "https://<HOST>/ords/<SCHEMA_MAPPING>/api/v1/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Accept: application/json"
```

Expected response:

```json
{
  "app_user_id": 1,
  "email": "alice@example.com",
  "full_name": "Alice Doe",
  "phone_number": "+5511999990000",
  "ords_client_id": "ocidemo123",
  "ords_client_name": "APPUSR_1_676F6F676C655F535542",
  "created_at": "2026-04-19T10:15:00"
}
```

## 3. Call the Diagnostics Endpoint

Use this only to validate what ORDS propagates in your environment.

```bash
curl -X GET "https://<HOST>/ords/<SCHEMA_MAPPING>/api/v1/runtime-diagnostics" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Accept: application/json"
```

Typical response:

```json
{
  "current_user": "<CLIENT_ID>",
  "remote_ident": "<CLIENT_ID>",
  "client_identifier": "<CLIENT_ID>",
  "session_user": "APP_DEMO",
  "current_schema": "APP_DEMO"
}
```

## 4. End-to-End Test Script

1. Sign in to APEX with Google.
2. Confirm redirection to `Complete your profile` on the first access.
3. Enter full name, birth date, and phone number.
4. Submit the form.
5. Confirm that the final page shows:
   - `client_id`
   - `client_secret` only if it was just created
6. Run the token curl.
7. Copy the `access_token`.
8. Run the `GET /api/v1/me` curl.
9. Validate that the JSON belongs to the authenticated user.
10. Run the diagnostics endpoint if there is any doubt about propagated identity.

## 5. Commands with Clear Placeholders

```bash
export HOST="https://<HOST>"
export SCHEMA_MAPPING="<SCHEMA_MAPPING>"
export CLIENT_ID="<CLIENT_ID>"
export CLIENT_SECRET="<CLIENT_SECRET>"
```

```bash
curl -X POST "$HOST/ords/$SCHEMA_MAPPING/oauth/token" \
  -u "$CLIENT_ID:$CLIENT_SECRET" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials"
```

```bash
curl -X GET "$HOST/ords/$SCHEMA_MAPPING/api/v1/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Accept: application/json"
```

## 6. Real Validation Example

The flow was validated successfully with the generated ORDS credentials in the target environment.

Observed `/api/v1/me` response:

```json
{
  "app_user_id": 1,
  "email": "denioflavio@gmail.com",
  "full_name": "Dênio Flávio Garcia",
  "phone_number": "555444666664",
  "ords_client_id": "MER5D5tlWsNBFPdslRrLRw..",
  "ords_client_name": "APPUSR_1_313133363939383836323535353936393037303431",
  "created_at": "2026-04-19T15:53:27"
}
```
