# APEX Build Steps

## 1. Create the Application

1. Sign in to the APEX workspace.
2. Create a new application named `Google ORDS Self-Service Demo`.
3. Keep the application minimal.
4. Create these pages:
   - Page 1: `Home`
   - Page 10: `Complete your profile`
   - Page 20: `Credentials generated`
5. Keep Home minimal, only to confirm login and provide simple navigation.

## 2. Required Shared Components

### Authentication Scheme

Create or replace the application's `Authentication Scheme` with `Social Sign-In`.

Selection:

- Type: `Social Sign-In`
- Provider: `Google`, if it is available natively in your APEX version
- If a native Google provider is not available, use `OpenID Connect`

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

## 3. Configure the Post-Login Flow

Configure the authentication scheme so that APEX maps the social claims directly into application items, then use a lightweight process on the landing page to route the user.

In the authentication scheme:

- `Username`:
  - `#sub#`
- `Additional User Attributes`:
  - `sub,email,name`
- `Map Additional User Attributes To`:
  - `G_GOOGLE_SUB,G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME`

### Recommended Process: `Load Social Identity`

Type:

- `Execute Code`

Suggested PL/SQL:

```plsql
declare
    l_sub        varchar2(255 char);
    l_app_user_id number;
begin
    l_sub := :G_GOOGLE_SUB;

    if l_sub is null then
        raise_application_error(-20050, 'G_GOOGLE_SUB is null. Check the Social Sign-In attribute mapping.');
    end if;

    begin
        select id
          into l_app_user_id
          from app_users
         where google_sub = l_sub;

        :G_APP_USER_ID := l_app_user_id;
    exception
        when no_data_found then
            :G_APP_USER_ID := null;
    end;
end;
```

Practical note:

- This approach avoids version-specific APIs such as `apex_authentication.get_attribute`.
- It also avoids `%ROWTYPE` in the page process, which can fail if the page parsing context cannot resolve the table name.
- Before refining the flow, perform a login test and confirm that the mapped items receive values.

## 4. Main Branch After Login

Create a branch on Home, or on a dedicated landing page used only for routing:

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

- `Execute Code`

Code:

```plsql
begin
    app_user_api.complete_registration(
        p_google_sub            => :G_GOOGLE_SUB,
        p_email                 => :G_SOCIAL_EMAIL,
        p_full_name             => :P10_FULL_NAME,
        p_birth_date            => :P10_BIRTH_DATE,
        p_phone_number          => :P10_PHONE_NUMBER,
        p_out_app_user_id       => :G_APP_USER_ID,
        p_out_client_name       => :G_ORDS_CLIENT_NAME,
        p_out_client_id         => :G_ORDS_CLIENT_ID,
        p_out_client_secret     => :G_ORDS_CLIENT_SECRET,
        p_out_created_now_flag  => :G_CREDS_CREATED_NOW
    );
end;
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

## 7. Page 1: Minimal Home

It can contain only:

- Text showing:
  - authenticated user
  - email
  - link to page 20
  - short `curl` testing hint

Optionally, Home can be only a routing page and does not need to be visible to the user.

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

You can keep only:

- `Home`
- `Complete your profile`
- `Credentials generated`

### Authorization

No additional authorization schemes are required for the demo.

### Session State Protection

Keep the APEX default.

## 11. APEX Build Checklist

1. Create the app and pages
2. Create the `Application Items`
3. Create the Google authentication scheme
4. Configure the callback URI in Google Cloud
5. Create the social identity loading process
6. Create the branch to page 10 or 20
7. Create the page 10 process calling `app_user_api.complete_registration`
8. Create the page 20 process to display credentials
9. Test the full flow

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
