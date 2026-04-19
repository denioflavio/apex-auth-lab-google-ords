# Google Configuration in APEX

This file covers only the APEX-side configuration. The Google Cloud project setup is documented in `docs/05_google_setup.md`.

If you import [apex/f100/install.sql](../apex/f100/install.sql), the authentication scheme is already there. In that scenario, this file is mostly a verification checklist.

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

or

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
4. Set `Post-Authentication Procedure Name` to:
   - `APP_APEX_AUTH.POST_LOGIN`
5. Let page 1 branch based on `G_APP_USER_ID`.

## 5a. Logout Configuration

For this project, keep logout behavior simple.

Recommended configuration in the authentication scheme:

- `Logout URL`:
  - leave it empty

Why:

- the Navigation Bar logout entry uses `&LOGOUT_URL.`
- if you hardcode an external URL there, APEX will redirect the user to that URL after logout
- for Google Social Sign-In, a full identity-provider logout is usually not the practical goal in this demo
- the main objective is to end the APEX session cleanly

Important practical note:

- signing out of APEX does not necessarily sign the user out of the Google browser session
- this is expected behavior for this kind of demo
- if the user starts login again, Google may automatically recognize the existing Google session

If you want a more explicit new-login experience after logout, set this in:

- `Authentication URI Parameters`:
  - `prompt=select_account`

That does not change logout behavior itself, but it helps during the next login by forcing account selection.

## 6. How to Read the Identity Attributes

Recommended setup:

- `Username`:
  - `#name#`
- `Additional User Attributes`:
  - `sub,email,name`
- `Map Additional User Attributes To`:
  - `G_GOOGLE_SUB,G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME`

Practical note:

- `#name#` is only the APEX session username display used by the current exported app
- the application identity still relies on `G_GOOGLE_SUB`
- `APP_APEX_AUTH.POST_LOGIN` reads `G_GOOGLE_SUB` and sets `G_APP_USER_ID`

Then the page or application process can simply read the mapped application items:

```plsql
begin
    if :G_GOOGLE_SUB is null then
        raise_application_error(-20050, 'G_GOOGLE_SUB is null. Check the authentication scheme mapping.');
    end if;
end;
```

This approach is simpler and more reliable than calling a version-specific API to fetch claims programmatically.

Run `sql/04_apex_helpers.sql` before rebuilding the app manually.

If you imported the ready app and installed Supporting Objects, this helper package is already included.

Recommended parsing schema for this project:

- `APP_DEMO`

## 7. Recommended Post-Login Flow

1. Google login completes successfully.
2. The authentication scheme maps `G_GOOGLE_SUB`, `G_SOCIAL_EMAIL`, and `G_SOCIAL_FULL_NAME`.
3. `APP_APEX_AUTH.POST_LOGIN` looks up `app_users` by `google_sub` and sets `G_APP_USER_ID`.
4. Page 1 branches.
5. If no row is found:
   - redirect to `Complete your profile`
6. If a row exists:
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

### Missing scopes or missing mapped attributes

Symptom:

- `G_GOOGLE_SUB`, `G_SOCIAL_EMAIL`, or `G_SOCIAL_FULL_NAME` is null

Cause:

- either the scope is smaller than `openid email profile`
- or the authentication scheme mapping is incomplete

### Incorrect credential

Symptom:

- code-to-token exchange fails

Cause:

- wrong `Client ID` or `Client Secret` in the web credential

### Logout redirects to the wrong place

Symptom:

- clicking `Sign Out` redirects to an unexpected external page

Cause:

- `Logout URL` in the authentication scheme is set to an external URL

How to avoid it:

- leave `Logout URL` empty for this demo

## 10. Practical Choice for This Case

The simplest path for this demo is:

1. Use `Social Sign-In` with the native Google provider, if available
2. Use a `Web Credential` to store the `client_id` and `client_secret`
3. Use `openid email profile`
4. Read the mapped application items instead of calling `apex_authentication.get_attribute`

If your APEX version does not provide a native Google provider, manual OIDC with the endpoints above preserves the same case design.
