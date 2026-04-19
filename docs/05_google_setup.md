# Google Cloud Setup

This document covers the Google Cloud side of the configuration, from creating a new project to generating the OAuth client used by Oracle APEX Social Sign-In.

## Official References

- Google Auth Platform: https://console.cloud.google.com/auth
- Configure OAuth consent, branding, audience, and scopes:
  https://developers.google.com/workspace/guides/configure-oauth-consent
- Manage OAuth app branding:
  https://support.google.com/cloud/answer/10311615
- Manage OAuth clients:
  https://support.google.com/cloud/answer/15549257
- Google OpenID Connect overview:
  https://developers.google.com/identity/openid-connect/openid-connect
- Oracle APEX Social Sign-In:
  https://docs.oracle.com/en/database/oracle/application-express/21.2/htmdb/social-sign-in.html

## Goal

At the end of this setup, you should have:

- a Google Cloud project
- OAuth consent configuration
- an OAuth client of type `Web application`
- authorized redirect URIs matching the exact callback URL shown by APEX
- the `Client ID` and `Client Secret` ready to store in APEX

If you are importing the ready application export, you still need to do this Google setup. Supporting Objects install the database side of the case, not the Google OAuth client.

## 1. Create a New Google Cloud Project

Menu path:

- Google Cloud Console
- top project selector
- `New Project`

Direct entry point:

- https://console.cloud.google.com/projectcreate

Suggested values:

- Project name:
  - `apex-google-ords-demo`
- Organization:
  - use your default organization if applicable
- Location:
  - leave the default if you do not need a specific folder structure

After creating the project:

1. Wait until the new project is selected in the top bar.
2. Confirm that all later steps are being done inside this project.

## 2. Open Google Auth Platform

Menu path:

- `Navigation menu`
- `Google Auth Platform`

Direct entry point:

- https://console.cloud.google.com/auth

If the project is brand new, Google may show a `Get started` flow for the Auth Platform.

## 3. Configure App Branding

Menu path:

- `Google Auth Platform`
- `Branding`

Direct help reference:

- https://support.google.com/cloud/answer/10311615

If prompted, click `Get started`.

Fill at least:

- `App name`
- `User support email`
- `Developer contact information`

For a demo, keep the branding minimal and clear.

Suggested example:

- App name:
  - `Google ORDS Self-Service Demo`

Important note:

- Google states that branding details shown on the consent screen are controlled from this section.
- App name and logo display can require verification depending on how the app is used later.

## 4. Configure Audience

Menu path:

- `Google Auth Platform`
- `Audience`

For a simple demo, use the most permissive path that still fits testing:

- User type:
  - `External`

Then keep the app in a test-ready mode if Google presents the equivalent testing workflow for your project.

Add the accounts that will actually test the login.

Typical action:

- `Add users`
- enter the Google account emails that will sign in to the APEX app

Practical recommendation:

- for a lab or blog case, do not jump to production or verification too early
- keep the app limited to test users first

## 5. Configure Data Access / Scopes

Menu path:

- `Google Auth Platform`
- `Data Access`

Official reference:

- https://developers.google.com/workspace/guides/configure-oauth-consent

Use only the scopes required for this case:

- `openid`
- `email`
- `profile`

Why these scopes:

- `openid` is required for OpenID Connect
- `profile` is used for claims such as `name` and `sub`-related profile context
- `email` is used to return the email claim

Google OpenID Connect reference:

- https://developers.google.com/identity/openid-connect/openid-connect

Expected identity data for this case:

- `sub`
- `email`
- `name`

## 6. Create the OAuth Client

Menu path:

- `Google Auth Platform`
- `Clients`
- `Create client`

Alternative path:

- `APIs & Services`
- `Credentials`
- `Create Credentials`
- `OAuth client ID`

Use these values:

- Application type:
  - `Web application`
- Name:
  - `apex-social-signin-demo`

## 7. Configure Authorized Redirect URIs

This is the most important part.

You must copy the callback URL exactly from APEX and register it exactly in Google Cloud.

Do not guess the path.

Common APEX callback formats:

```text
https://<host>/ords/apex_authentication.callback
```

or

```text
https://<host>/ords/apex_authentication.callback2
```

How to get the correct value:

1. In APEX, open the Social Sign-In authentication scheme.
2. Locate the `Callback URL` shown by APEX.
3. Copy that value exactly.
4. In Google Cloud, add it under `Authorized redirect URIs`.

Examples:

```text
https://your-adb-host/ords/apex_authentication.callback
```

```text
https://your-adb-host/ords/apex_authentication.callback2
```

Google redirect URI rules reference:

- https://support.google.com/cloud/answer/15549257

Key rules from Google:

- redirect URIs should use `https`
- raw IP addresses are not valid, except localhost cases
- the URI must match exactly

## 8. Authorized JavaScript Origins

For the APEX Social Sign-In case, this is usually not the main issue, but you can populate it if desired.

Use the base host only:

```text
https://<host>
```

Do not include the callback path here.

## 9. Copy the Generated Credentials

After creating the client, copy:

- `Client ID`
- `Client Secret`

These values will be stored in APEX as a `Web Credential` or equivalent credential store entry.

## 10. Suggested End-to-End Sequence

Use this order to avoid rework:

1. Create the Google Cloud project
2. Configure `Branding`
3. Configure `Audience`
4. Configure `Data Access` with:
   - `openid`
   - `email`
   - `profile`
5. Open APEX and inspect the Social Sign-In scheme
6. Copy the exact APEX callback URL
7. Create the Google OAuth client as `Web application`
8. Paste the callback URL into `Authorized redirect URIs`
9. Copy `Client ID` and `Client Secret`
10. Store them in APEX

## 11. Common Errors and How to Avoid Them

### `redirect_uri_mismatch`

Cause:

- the URI configured in Google does not exactly match the callback URI used by APEX

How to avoid it:

1. copy the callback from APEX
2. paste it into Google unchanged
3. confirm protocol, host, path, and slashes

Official reference:

- https://support.google.com/cloud/answer/15549257

### Missing identity attributes

Cause:

- missing scopes
- or incomplete APEX mapping

How to avoid it:

- use `openid email profile`
- map `sub,email,name` in APEX

### Wrong project selected

Cause:

- credentials were created in one project, but branding or audience was configured in another

How to avoid it:

- always confirm the project selector in the top bar before editing settings

### Test user cannot sign in

Cause:

- the app is not broadly available yet and the account was not added to the allowed testing audience

How to avoid it:

- add the actual test accounts in the audience / test user area

## 12. Final Checklist

Before leaving Google Cloud, confirm:

- project created and selected
- branding configured
- audience configured
- required test users added
- scopes configured:
  - `openid`
  - `email`
  - `profile`
- OAuth client created as `Web application`
- APEX callback URL added exactly
- `Client ID` copied
- `Client Secret` copied
