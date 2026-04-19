# Google Configuration in APEX

This file covers only the APEX-side configuration. The Google Cloud project setup is documented in `docs/05_google_setup.md`.

## 1. Create the Web Credential

In APEX:

1. Go to `Workspace Utilities` or `Shared Components`, depending on the version.
2. Open `Web Credentials`.
3. Create a credential, for example:
   - `GOOGLE_OAUTH_CRED`
4. Enter:
   - `Client ID`
   - `Client Secret`
5. Save.

If your APEX version uses slightly different credential store terminology, the idea is the same: store the Google `client_id` and `client_secret` securely for the authentication scheme.

## 2. Create the Authentication Scheme

In the application:

1. Go to `Shared Components` > `Authentication Schemes`.
2. Create a new scheme.
3. Type:
   - `Social Sign-In`
4. Provider:
   - `Google`, if available natively
5. Otherwise use:
   - `OpenID Connect`

## 3. Main Provider Settings

### Preferred Path: Native Google Provider

Populate:

- Client Credential / Web Credential: `GOOGLE_OAUTH_CRED`
- Scope:
  - `openid email profile`

Check the `Callback URL` displayed by APEX and copy it exactly into Google Cloud.

### Alternative Path: OpenID Connect

If you need to configure OIDC manually, use Google's standard endpoints:

- Authorization Endpoint:

```text
https://accounts.google.com/o/oauth2/v2/auth
```

- Token Endpoint:

```text
https://oauth2.googleapis.com/token
```

- User Info Endpoint:

```text
https://openidconnect.googleapis.com/v1/userinfo
```

- Scope:

```text
openid email profile
```

## 4. Callback URL

The correct value is the one displayed by APEX inside the authentication scheme.

Common formats are:

```text
https://<host>/ords/apex_authentication.callback
```

ou

```text
https://<host>/ords/apex_authentication.callback2
```

Rule used in this case:

- copy exactly the URL shown by APEX
- register the exact same URL in Google Cloud

## 5. Post-Authentication

After saving the authentication scheme:

1. Set this scheme as `Current`.
2. Make sure the landing page executes the social identity loading process.
3. Populate these `Application Items` after login:
   - `G_GOOGLE_SUB`
   - `G_SOCIAL_EMAIL`
   - `G_SOCIAL_FULL_NAME`

## 6. How to Read the Identity Attributes

The case assumes these standard claims:

- `sub`
- `email`
- `name`

Exemplo de processo:

```plsql
begin
    :G_GOOGLE_SUB       := apex_authentication.get_attribute('sub');
    :G_SOCIAL_EMAIL     := apex_authentication.get_attribute('email');
    :G_SOCIAL_FULL_NAME := apex_authentication.get_attribute('name');
end;
```

If your APEX version exposes authenticated user attributes differently, adjust this process after validating the real runtime behavior.

## 7. Recommended Post-Login Flow

1. Google login completes successfully.
2. The process reads `sub`, `email`, and `name`.
3. The application looks up `app_users` by `google_sub`.
4. If no row is found:
   - redirect to `Complete your profile`
5. If a row exists:
   - redirect to `Credentials generated`

## 8. Quick Login Test

1. Run the application.
2. Start the social login.
3. Authenticate with a Google test user.
4. Confirm that the session opens without error.
5. Confirm that the application items are populated.

A simple early validation approach is to temporarily show these values on Home:

- `&G_GOOGLE_SUB.`
- `&G_SOCIAL_EMAIL.`
- `&G_SOCIAL_FULL_NAME.`

After validation, remove that exposure from the UI.

## 9. Common APEX-Side Errors

### Incorrect callback

Symptom:

- login redirects to an error page

Cause:

- the URI differs from the one registered in Google

### Missing scopes

Symptom:

- `email` or `name` is missing

Cause:

- the scope is smaller than `openid email profile`

### Incorrect credential

Symptom:

- code-to-token exchange fails

Cause:

- wrong `Client ID` or `Client Secret` in the web credential

## 10. Practical Choice for This Case

The simplest path for this demo is:

1. Use `Social Sign-In` with the native Google provider, if available
2. Use a `Web Credential` to store the `client_id` and `client_secret`
3. Use `openid email profile`
4. Read `sub`, `email`, and `name`

If your APEX version does not provide a native Google provider, manual OIDC with the endpoints above preserves the same case design.
