# Google Cloud Setup

## 1. Create or Select the Project

1. Open Google Cloud Console.
2. Create a new project or select an existing one.
3. Use a simple name, for example `apex-ords-google-demo`.

## 2. Configure the OAuth Consent Screen

1. Go to `APIs & Services` > `OAuth consent screen`.
2. Choose the user type.

For a demo and testing flow, the simplest choice is usually:

- `External`

3. Fill in the minimum required fields:
   - App name
   - User support email
   - Developer contact information
4. Save.

## 3. Keep the App in Testing Mode

For a technical case and demo:

- keep it in `Testing`

This typically requires adding test users.

## 4. Add Test Users

1. In the same consent screen area, open `Test users`.
2. Add the Google account that will test the login.

If you skip this while the app is in `Testing`, login may fail.

## 5. Create the OAuth Client ID

1. Go to `APIs & Services` > `Credentials`.
2. Click `Create Credentials`.
3. Choose `OAuth client ID`.
4. Application type:
   - `Web application`
5. Use a clear name:
   - `apex-google-signin-demo`

## 6. Configure Redirect URIs

Register exactly the callback URL shown by APEX in the authentication scheme.

Common patterns are:

```text
https://<host>/ords/apex_authentication.callback
```

ou

```text
https://<host>/ords/apex_authentication.callback2
```

In some environments with a different context path, the URL can include additional prefixes. The practical rule is:

- do not guess
- copy the exact `Callback URL` displayed by APEX

If you use APEX on Autonomous Database, typical examples look like this:

```text
https://<adb-endpoint>/ords/apex_authentication.callback
```

ou

```text
https://<adb-endpoint>/ords/apex_authentication.callback2
```

## 7. Authorized JavaScript Origins

In most APEX Social Sign-In flows this is not the critical setting. If you want to populate it anyway:

```text
https://<host>
```

Use only the base host of the published APEX/ORDS environment.

## 8. Values You Need to Copy into APEX

After creating the Google OAuth client, copy:

- `Client ID`
- `Client Secret`

You will use those values in the APEX `Web Credential` or credential store.

## 9. Recommended Minimum Scopes

For this case, keep the scopes minimal:

- `openid`
- `email`
- `profile`

These scopes are enough to get:

- `sub`
- `email`
- `name`

## 10. Campos esperados no retorno

Para o case funcionar do jeito proposto, precisamos conseguir mapear:

- `sub`
- `email`
- `name`

The key claim is `sub`.

## 11. Common Errors

### `redirect_uri_mismatch`

Most common cause:

- the URI registered in Google is not exactly the same one used by APEX

How to avoid it:

1. Copy the `Callback URL` directly from APEX
2. Paste it into Google without changing anything
3. Verify protocol, host, path, and slashes

### Incomplete consent screen

Symptoms:

- error when starting the login
- screen blocking access

How to avoid it:

- fill in the minimum consent screen fields
- add test users if the app is in `Testing`

### Unauthorized user in testing mode

Symptom:

- the Google account cannot authenticate

How to avoid it:

- include the account in `Test users`

### Incorrect host

Symptom:

- callback returns to a different host or fails

How to avoid it:

- use the exact host of the published APEX/ORDS environment

### Insufficient scope

Symptom:

- missing claims

How to avoid it:

- use `openid email profile`

## 12. Quick Checklist

1. Project created
2. Consent screen configured
3. App kept in `Testing`
4. Test user added
5. OAuth Client ID created as `Web application`
6. Redirect URI exactly matches the APEX callback
7. `Client ID` and `Client Secret` copied
