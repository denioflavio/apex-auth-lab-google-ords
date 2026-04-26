# Facebook Login Setup for APEX

This guide creates the Meta/Facebook app credentials used by the APEX `Facebook Social Sign-In` authentication scheme.

## Official References

- Meta for Developers:
  https://developers.facebook.com/
- Facebook Login:
  https://developers.facebook.com/docs/facebook-login/
- Facebook Login for the Web:
  https://developers.facebook.com/docs/facebook-login/web/
- Facebook permissions:
  https://developers.facebook.com/docs/permissions/
- Oracle APEX Social Sign-In:
  https://docs.oracle.com/en/database/oracle/apex/23.2/htmdb/social-sign-in.html

## Goal

At the end, you should have:

- a Meta developer app
- Facebook Login enabled
- a valid OAuth redirect URI copied from APEX
- App ID
- App Secret
- an APEX Web Credential named `FACEBOOK_OAUTH_CREDENTIAL`

## 1. Get the APEX Callback URL First

In APEX:

1. Open the application.
2. Go to `Shared Components > Authentication Schemes`.
3. Create or open `Facebook Social Sign-In`.
4. Copy the callback URL shown by APEX.

Common formats:

```text
https://<host>/ords/apex_authentication.callback
```

```text
https://<host>/ords/apex_authentication.callback2
```

Copy the exact URL. Do not guess it.

## 2. Create the Meta App

1. Open https://developers.facebook.com/
2. Sign in with the Meta account that will own the app.
3. Open `My Apps`.
4. Choose `Create App`.
5. Select the app type/use case that supports Facebook Login for consumer authentication.
6. Fill in:
   - App name
   - Contact email
   - Business portfolio, if your organization requires one
7. Create the app.

The Meta console changes layout over time. If the UI asks for a use case, choose the authentication/account creation use case that includes Facebook Login.

## 3. Add Facebook Login

Inside the app:

1. Open the app dashboard.
2. Add or customize the `Facebook Login` product/use case.
3. Select `Web` as the platform when prompted.
4. Enter your site URL:

```text
https://<your-apex-host>
```

Do not include the APEX callback path in the site URL.

## 4. Configure OAuth Redirect URI

Open the Facebook Login settings.

Depending on the current Meta UI, this may be under:

- `Use cases > Authentication and account creation > Customize > Settings`
- or `Facebook Login > Settings`
- or `Products > Facebook Login > Settings`

Enable these settings if shown:

- Client OAuth Login: `Yes`
- Web OAuth Login: `Yes`

Paste the APEX callback URL into:

```text
Valid OAuth Redirect URIs
```

Save changes.

Important:

- use HTTPS for real environments
- protocol, host, path, and trailing slash must match exactly
- copy the URL from APEX instead of typing it manually

## 5. Request / Confirm Permissions

For the exported Application 100 scheme, use:

```text
public_profile
```

`public_profile` supplies basic profile fields. If your Meta app is approved to expose email, add `email` to the scope so APEX can map the user's email into `G_SOCIAL_EMAIL`.

This project uses normalized email to prevent duplicate accounts across login methods. If Facebook does not return an email for the user, do not complete the registration silently. Ask the user for an email on Page 10 and verify it before creating the application user.

In development mode, only app roles/test users can usually sign in. For broader use, review Meta's app mode, access level, and permission review requirements in the developer console.

## 6. Copy App ID and App Secret

In the Meta app:

1. Open app settings.
2. Copy:
   - App ID
   - App Secret

Keep the App Secret private.

## 7. Create the APEX Web Credential

In APEX:

1. Go to `Shared Components > Web Credentials`.
2. Create a credential named:

```text
FACEBOOK_OAUTH_CREDENTIAL
```

3. Enter:
   - Client ID: Meta App ID
   - Client Secret: Meta App Secret
4. Save.

## 8. Configure the APEX Authentication Scheme

Use the values from `docs/09_multi_login_evolution.md`.

Recommended scheme settings:

- Name: `FACEBOOK_LOGIN`
- Provider: `Facebook`
- Web Credential: `FACEBOOK_OAUTH_CREDENTIAL`
- Scope:

```text
public_profile
```

- Additional User Attributes:

```text
email,name
```

- Map Additional User Attributes To:

```text
G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME
```

- Username:

```text
id
```

- Post-Authentication Procedure Name:

```text
APP_MULTI_AUTH.POST_LOGIN_FACEBOOK
```

Do not use `#name#` as the Facebook username and do not include `id` again in `Additional User Attributes`. Otherwise APEX may request invalid duplicated Facebook fields such as:

```text
id,email,name,#name#
```

## 9. Test

1. Run the APEX app.
2. Click `Continue with Facebook`.
3. Authenticate with a Facebook test user.
4. Confirm the first login goes to Page 10.
5. Complete the profile.
6. Confirm Page 20 shows the generated ORDS OAuth client.
7. Log out and sign in again.
8. Confirm the returning user goes directly to Page 20.

## 10. Common Errors

### Redirect URI blocked

Cause:

- the APEX callback URL was not added to `Valid OAuth Redirect URIs`
- or the registered URL differs from the actual URL

Fix:

- copy the callback from APEX again
- paste it into the Facebook Login OAuth settings
- save the app settings

### Email is missing

Cause:

- `email` scope was not requested
- or the Facebook account does not expose an email to the app

Fix:

- confirm scope includes `email`
- require and verify an email before completing Page 10
- without a verified email, the app cannot reliably detect that the same person already registered through Google or Custom Login

### Test user cannot log in

Cause:

- the app is still in development mode and the user is not assigned as a tester/developer/admin

Fix:

- add the account under app roles/test users
- or complete the requirements to move the app to live mode
