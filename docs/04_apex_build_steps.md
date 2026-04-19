# APEX Build Steps

This file is the manual build path.

If you are importing [apex/f100/install.sql](../apex/f100/install.sql), most of this is already represented in the exported application. In that case, focus on:

- installing Supporting Objects
- confirming the parsing schema is `APP_DEMO`
- creating the Google Web Credential
- reviewing the authentication scheme values

## 1. Create the Application

1. Sign in to the APEX workspace.
2. Create a new application named `Google ORDS Self-Service Demo`.
3. Keep the application minimal.
4. Create these pages:
   - Page 1: `Home`
   - Page 10: `Complete your profile`
   - Page 20: `Credentials generated`
5. Keep Home as a routing page. In the exported app, page 1 branches before header and is normally not shown to the user.

## 1a. Import Alternative

If you do not want to rebuild the app manually:

1. Import [apex/f100/install.sql](../apex/f100/install.sql)
2. Install the application's Supporting Objects
3. Open the imported app
4. Review the authentication scheme and Web Credential setup

Practical note:

- the Supporting Objects bundle installs the database objects the app expects
- this is the cleanest installation path for blog readers and lab users

## 2. Required Shared Components

### Authentication Scheme

Create or replace the application's `Authentication Scheme` with `Social Sign-In`.

Selection:

- Type: `Social Sign-In`
- Provider: `Google`, if it is available natively in your APEX version
- If a native Google provider is not available, use `OpenID Connect`

Recommended logout-related settings for this case:

- `Logout URL`:
  - leave empty
- `Authentication URI Parameters`:
  - optionally set `prompt=select_account`

Reason:

- the app's Navigation Bar logout entry uses `&LOGOUT_URL.`
- if `Logout URL` is filled with an external address, logout will redirect there
- for this demo, the cleanest behavior is to terminate the APEX session and stay within the application flow

### Application Items

Create these `Application Items`:

- `G_GOOGLE_SUB`
- `G_SOCIAL_EMAIL`
- `G_SOCIAL_FULL_NAME`
- `G_APP_USER_ID`
- `G_ORDS_CLIENT_NAME`
- `G_ORDS_CLIENT_ID`
- `G_ORDS_CLIENT_SECRET`
- `G_CREDS_CREATED_NOW`

These items keep the flow simple and avoid repeated lookups.

### Parsing Schema Check

Before creating the APEX processes, confirm the application's parsing schema.

In the environment used for this demo:

- object owner schema: `APP_DEMO`
- recommended APEX parsing schema: `APP_DEMO`

For this case, keep the application parsing schema aligned with `APP_DEMO`. That removes the need for schema prefixes and cross-schema grants.

## 2a. Supporting Objects

When you import the ready application, use Supporting Objects instead of running the SQL manually.

Included install scripts:

- `01 Tables`
- `02 Packages`
- `03 ORDS REST`
- `04 APEX Helper Package`

They correspond to:

- `sql/01_tables.sql`
- `sql/02_packages.sql`
- `sql/03_ords_rest.sql`
- `sql/04_apex_helpers.sql`

## 3. Configure the Post-Login Flow

Configure the authentication scheme so that APEX maps the social claims directly into application items, then use `APP_APEX_AUTH.POST_LOGIN` to resolve the existing user before page 1 branches.

In the authentication scheme:

- `Username`:
  - `#name#`
- `Additional User Attributes`:
  - `sub,email,name`
- `Map Additional User Attributes To`:
  - `G_GOOGLE_SUB,G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME`
- `Post-Authentication Procedure Name`:
  - `APP_APEX_AUTH.POST_LOGIN`
- `Authentication URI Parameters`:
  - `prompt=select_account`

Practical note:

- `#name#` is only the APEX session username display.
- `G_GOOGLE_SUB` remains the stable identity key used by the application and by `APP_APEX_AUTH.POST_LOGIN`.

### Post-Authentication Procedure

Run `sql/04_apex_helpers.sql` and keep this procedure in the authentication scheme:

```text
APP_APEX_AUTH.POST_LOGIN
```

Practical note:

- This is the flow used by the exported app.
- The helper procedure reads `G_GOOGLE_SUB` from session state and sets `G_APP_USER_ID` when the user already exists.
- That keeps page 1 clean and lets it act only as a router.
- If you imported the app and installed Supporting Objects, this package is already installed.

## 4. Main Branch After Login

Create page 1 as a routing page with branches only:

Logic:

- If `G_APP_USER_ID` is null, go to page 10
- If `G_APP_USER_ID` is not null, go to page 20

PL/SQL expression for the branch to page 10:

```plsql
:G_APP_USER_ID is null
```

PL/SQL expression for the branch to page 20:

```plsql
:G_APP_USER_ID is not null
```

## 5. Page 10: Complete your profile

This is the profile completion page.

### Page Items

- `P10_FULL_NAME` - Text Field
- `P10_BIRTH_DATE` - Date Picker
- `P10_PHONE_NUMBER` - Text Field
- `P10_EMAIL` - Display Only
- `P10_GOOGLE_SUB` - Hidden

### Defaults

- `P10_FULL_NAME` default = `&G_SOCIAL_FULL_NAME.`
- `P10_EMAIL` default = `&G_SOCIAL_EMAIL.`
- `P10_GOOGLE_SUB` default = `&G_GOOGLE_SUB.`

### Validations

You can keep validations in APEX and in the package.

Minimum validations:

- `P10_FULL_NAME` required
- `P10_BIRTH_DATE` required
- `P10_PHONE_NUMBER` required

### Button

- Button `Generate Credentials`

### Submit Process

Type:

- `Invoke API`
- Source Type:
  - `PL/SQL Package`
- Package:
  - `APP_USER_API`
- Procedure:
  - `COMPLETE_REGISTRATION`

Bind the parameters like this:

```plsql
p_google_sub           -> P10_GOOGLE_SUB
p_email                -> P10_EMAIL
p_full_name            -> P10_FULL_NAME
p_birth_date           -> P10_BIRTH_DATE
p_phone_number         -> P10_PHONE_NUMBER
p_out_app_user_id      -> G_APP_USER_ID
p_out_client_name      -> G_ORDS_CLIENT_NAME
p_out_client_id        -> G_ORDS_CLIENT_ID
p_out_client_secret    -> G_ORDS_CLIENT_SECRET
p_out_created_now_flag -> G_CREDS_CREATED_NOW
```

Items to return:

- `G_APP_USER_ID`
- `G_ORDS_CLIENT_NAME`
- `G_ORDS_CLIENT_ID`
- `G_ORDS_CLIENT_SECRET`
- `G_CREDS_CREATED_NOW`

### Branch After Submit

Redirect to page 20.

## 6. Page 20: Credentials generated

This page shows the profile result and the credentials when they have just been created.

### Page Items

- `P20_FULL_NAME` - Display Only
- `P20_EMAIL` - Display Only
- `P20_PHONE_NUMBER` - Display Only
- `P20_CLIENT_NAME` - Display Only
- `P20_CLIENT_ID` - Display Only
- `P20_CLIENT_SECRET` - Display Only or Textarea Display Only
- `P20_MESSAGE` - Display Only

### Before Header Process

Type:

- `Execute Code`

Code:

```plsql
declare
    l_client_name varchar2(255 char);
    l_client_id   varchar2(255 char);
begin
    select full_name, email, phone_number
      into :P20_FULL_NAME, :P20_EMAIL, :P20_PHONE_NUMBER
      from app_users
     where id = :G_APP_USER_ID;

    app_user_api.get_credentials_for_display(
        p_app_user_id     => :G_APP_USER_ID,
        p_out_client_name => l_client_name,
        p_out_client_id   => l_client_id
    );

    :P20_CLIENT_NAME := l_client_name;
    :P20_CLIENT_ID   := l_client_id;

    if :G_CREDS_CREATED_NOW = 'Y' then
        :P20_CLIENT_SECRET := :G_ORDS_CLIENT_SECRET;
        :P20_MESSAGE := 'Credentials were created now. Copy this secret now because it will not be displayed again.';
    else
        :P20_CLIENT_SECRET := null;
        :P20_MESSAGE := 'An active OAuth client already exists. This demo reuses the existing client and does not regenerate the secret.';
    end if;
end;
```

### Important Settings

- Mark `P20_CLIENT_SECRET` as read only.
- Do not persist `client_secret` in a custom table.
- If the user reloads the page later, the secret may no longer be available in session state. That is expected.

## 7. Page 1: Routing Page

In the exported app, page 1 does not need a user-facing region.

Keep it simple:

- no page process is required on page 1
- no display content is required
- keep the two `Before Header` branches only

Reason:

- `APP_APEX_AUTH.POST_LOGIN` already resolves `G_APP_USER_ID`
- page 1 only decides whether the user goes to page 10 or page 20

## 8. First Access vs Returning Access

Choice adopted in this case:

- First access:
  - `app_users.google_sub` does not exist
  - go to page 10
  - complete the profile
  - generate the OAuth client
- Returning access:
  - `app_users.google_sub` already exists
  - go to page 20
  - if an active client already exists, only show `client_id` and explain that secret rotation is outside the demo scope

## 9. How to Read and Use Google Identity Data

The simplest strategy is to use these claims:

- `sub`
- `email`
- `name`

Practical recommendation:

1. Perform the first login.
2. Inspect which claims APEX actually exposes.
3. Adjust the `Load Social Identity` process if the claim names vary.

This case uses:

- `google_sub` as the stable key
- `email` as informational support data
- `full_name` as an editable pre-filled value

## 10. Additional Shared Components

### Navigation Menu

In the current exported app, keep only:

- `Home`

Reason:

- page 10 and page 20 are flow pages
- users reach them through routing and branches, not through the menu

### Authorization

No additional authorization schemes are required for the demo.

### Session State Protection

Keep the APEX default.

## 11. APEX Build Checklist

1. Create the app and pages
2. Create the `Application Items`
3. Create the Google authentication scheme
4. Configure the callback URI in Google Cloud
5. Set or confirm the application parsing schema as `APP_DEMO`
6. Configure attribute mapping for `sub,email,name`
7. Set `APP_APEX_AUTH.POST_LOGIN` in the authentication scheme
8. Create the page 1 branches to page 10 or 20
9. Create the page 10 invoke process calling `APP_USER_API.COMPLETE_REGISTRATION`
10. Create the page 20 process to display credentials
11. Test the full flow

## 12. Important Note About Claims in APEX

The exact way claims are exposed can vary slightly depending on the APEX version and provider configuration.

Recommended implementation for this case:

- let the authentication scheme map `sub`, `email`, and `name` into application items
- then read those application items in page or application processes

Recommended validation:

- perform a login test
- temporarily display the mapped application items
- adjust the authentication scheme mapping if needed

If your environment uses `callback2`, the design stays the same. Just make sure the URI registered in Google Cloud exactly matches the value shown by APEX.
