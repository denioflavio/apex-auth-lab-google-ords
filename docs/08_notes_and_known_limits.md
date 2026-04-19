# Known Limits and Simplifications

## What Was Simplified

- The case uses only two business tables and one lightweight log table.
- The application user can have at most one active OAuth client.
- There is no manual approval workflow.
- There is no in-app secret rotation.
- There is no additional service layer between APEX, the database, and ORDS.
- The API surface is limited to `GET /api/v1/me`.
- The ready APEX export relies on Supporting Objects to install the required database artifacts in one pass.

## What to Harden in Production

- Review the log retention policy for `app_api_event_log`.
- Implement client secret rotation and revocation.
- Add a stronger audit trail for provisioning and usage.
- Add rate limiting and monitoring at the ORDS or gateway layer.
- Review expiration, revocation, and naming policies for OAuth clients.
- Validate and normalize phone numbers according to the real business rules.
- Handle user deactivation and revoke the linked client accordingly.
- Restrict and review the privileges granted to the application schema.

## Security Considerations

- `client_secret` should only be displayed at creation time.
- Do not persist `client_secret` in a custom table without a strong reason.
- The user should be instructed to store the secret securely.
- The diagnostics endpoint should be treated as an implementation aid.
- In production, consider removing or restricting `runtime-diagnostics`.
- Social login uses `google_sub` as the stable identity key; email must not be the only key.
- The schema needs permission to create OAuth clients, and that must be controlled carefully.

## Runtime Assumptions in the Endpoint

The least deterministic part of this case is how ORDS propagates the authenticated OAuth client identity into the handler runtime.

The implementation is intentionally defensive:

1. It first checks `SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')`
2. Then it checks `:current_user`
3. Then it checks `:remote_user`
4. Then it checks `REMOTE_IDENT`
5. Every candidate value is compared against `USER_ORDS_CLIENTS.CLIENT_ID` and `USER_ORDS_CLIENTS.NAME`

In addition:

- the package writes runtime logs into `app_api_event_log`
- the `/api/v1/runtime-diagnostics` endpoint helps validate the actual runtime behavior

## How to Validate the Assumption in Your Environment

1. Create an OAuth client through the APEX flow.
2. Generate a `client_credentials` token.
3. Call `/api/v1/runtime-diagnostics`.
4. Inspect which values are populated in:
   - `client_identifier`
   - `current_user`
   - `remote_user`
   - `remote_ident`
5. Review the `app_api_event_log` table.

If your environment propagates identity differently, adjust only `app_user_api.resolve_client_id_from_runtime`.

## Confirmed Runtime Behavior in This Environment

In the validated target environment, the diagnostics endpoint returned the OAuth `client_id` consistently in:

- `current_user`
- `remote_ident`
- `client_identifier`

This means the current implementation is already aligned with the observed ORDS runtime behavior for the demo.

## Natural Next Evolutions

- Controlled secret rotation
- Client revocation and reissue
- Minimal administration page
- Multiple clients per user for different purposes
- Additional scopes and privileges by product or plan
- Additional profile endpoints or real service endpoints

## Real Value This Case Can Enable Later

- self-service partner onboarding
- credential issuance for B2B integrations
- secure programmatic access to client APIs
- hybrid human-to-machine journeys:
  - a person signs in through Google in APEX
  - completes the profile
  - receives credentials for system-to-system integration

## Central Demo Decision

The selected approach is:

- reuse the existing active OAuth client
- avoid duplicate clients
- do not offer regenerate in the first version

This keeps the flow simple, safe for a demo, and easy to explain later.
