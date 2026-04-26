# Multi-Login Configuration: Custom, Google, and Facebook

This guide documents the final Application 100 authentication model.

The application supports:

- Custom Login with local username/password
- Google Social Sign-In
- Facebook Social Sign-In
- duplicate-account prevention across login methods using normalized email
- direct navigation to Page 20 for returning users
- first-login profile completion on Page 10 for social users

## 1. Database Objects

If you import Application 100 and install its Supporting Objects, this script is installed by the application export. For manual installs, run:

```bash
./run_sqlcl.sh multi-login
```

The script [sql/08_multi_login_evolution.sql](../sql/08_multi_login_evolution.sql):

- adds provider-aware columns to `APP_USERS`
- creates uniqueness rules for provider identity, custom usernames, and email
- creates package `APP_MULTI_AUTH`
- supports `GOOGLE`, `FACEBOOK`, and `CUSTOM`
- blocks new registrations when the email already exists through another login method

Important package entry points:

| Use | PL/SQL |
| --- | --- |
| Custom authentication function | `APP_MULTI_AUTH.AUTHENTICATE_CUSTOM` |
| Custom post-authentication procedure | `APP_MULTI_AUTH.POST_LOGIN_CUSTOM` |
| Google post-authentication procedure | `APP_MULTI_AUTH.POST_LOGIN_GOOGLE` |
| Facebook post-authentication procedure | `APP_MULTI_AUTH.POST_LOGIN_FACEBOOK` |
| Social profile completion | `APP_MULTI_AUTH.COMPLETE_SOCIAL_REGISTRATION` |
| Custom account creation | `APP_MULTI_AUTH.CREATE_CUSTOM_USER` |

`APP_MULTI_AUTH` must exist in the same parsing schema used by the APEX application.

## 2. Application Items

Create or confirm these application items:

| Item | Purpose |
| --- | --- |
| `G_APP_USER_ID` | Current application user id |
| `G_AUTH_PROVIDER` | Current login provider |
| `G_EXTERNAL_SUBJECT` | Stable provider user id |
| `G_GOOGLE_SUB` | Google subject mapped by Social Sign-In |
| `G_SOCIAL_EMAIL` | Email returned by the social provider |
| `G_SOCIAL_FULL_NAME` | Display name returned by the social provider |
| `G_AUTH_NOTICE_CODE` | Router notice code |
| `G_AUTH_NOTICE_EMAIL` | Email involved in an auth notice |
| `G_AUTH_NOTICE_EXISTING_PROVIDER` | Existing provider for duplicate email |
| `G_AUTH_NOTICE_ATTEMPT_PROVIDER` | Provider attempted by the user |
| `G_AUTH_NOTICE_MESSAGE` | User-facing auth notice message |

Keep the existing ORDS credential page items used by Page 20.

## 3. Authentication Schemes

### 3.1 Custom Login

Create or confirm the current authentication scheme:

- Name: `Custom Login`
- Scheme Type: `Custom`
- Authentication Function Name:

```text
APP_MULTI_AUTH.AUTHENTICATE_CUSTOM
```

- Post-Authentication Procedure Name:

```text
APP_MULTI_AUTH.POST_LOGIN_CUSTOM
```

- Invalid Session Procedure / Login Page: Page `9999`

Set `Custom Login` as the current authentication scheme.

### 3.2 Google Login

Create or confirm:

- Name: `GOOGLE_LOGIN`
- Scheme Type: `Social Sign-In`
- Provider: `Google`
- Web Credential: your Google OAuth credential
- Scope:

```text
openid email profile
```

- Username:

```text
#name#
```

- Additional User Attributes:

```text
sub,email,name
```

- Map Additional User Attributes To:

```text
G_GOOGLE_SUB,G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME
```

- Post-Authentication Procedure Name:

```text
APP_MULTI_AUTH.POST_LOGIN_GOOGLE
```

- Switch in Session: enabled

### 3.3 Facebook Login

Create or confirm:

- Name: `FACEBOOK_LOGIN`
- Scheme Type: `Social Sign-In`
- Provider: `Facebook`
- Web Credential: `FACEBOOK_OAUTH_CREDENTIAL`
- Scope:

```text
public_profile
```

- Username:

```text
id
```

- Additional User Attributes:

```text
email,name
```

- Map Additional User Attributes To:

```text
G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME
```

- Post-Authentication Procedure Name:

```text
APP_MULTI_AUTH.POST_LOGIN_FACEBOOK
```

- Switch in Session: enabled

Do not include `id` again in `Additional User Attributes`, and do not use `#name#` as the Facebook username.

If your Meta app is approved to expose email, you may include `email` in the scope. Keep Page 10 able to collect an email because Facebook may not return one for every account.

## 4. Page 9999: Login

Page 9999 is the APEX login page.

Create or confirm these items:

| Item | Type |
| --- | --- |
| `P9999_USERNAME` | Text Field |
| `P9999_PASSWORD` | Password |
| `P9999_REMEMBER` | Checkbox |

Create or confirm these buttons:

| Button | Action |
| --- | --- |
| `LOGIN` | Submit Page |
| `LOGIN_GOOGLE` | Redirect to Page 100 with request `APEX_AUTHENTICATION=GOOGLE_LOGIN` |
| `LOGIN_FACEBOOK` | Redirect to Page 100 with request `APEX_AUTHENTICATION=FACEBOOK_LOGIN` |
| `SIGN_UP` | Redirect to Page 11 |

The custom login process must run when `LOGIN` is pressed:

```sql
declare
    l_authenticated boolean;
begin
    l_authenticated := app_multi_auth.authenticate_custom(
        p_username => :P9999_USERNAME,
        p_password => :P9999_PASSWORD
    );

    if not l_authenticated then
        apex_error.add_error(
            p_message          => 'Invalid username or password.',
            p_display_location => apex_error.c_inline_in_notification
        );
        return;
    end if;

    apex_authentication.login(
        p_username           => :P9999_USERNAME,
        p_password           => :P9999_PASSWORD,
        p_uppercase_username => false
    );

    apex_util.redirect_url(p_url => apex_page.get_url(p_page => 20));
    apex_application.stop_apex_engine;
end;
```

Recommended process sequence:

| Sequence | Process |
| --- | --- |
| 10 | Set Username Cookie |
| 20 | Custom login process |
| 30 | Clear Page(s) Cache |

## 5. Page 100: Auth Router

Page 100 is protected and is used as the target for social login buttons.

Create branches in this order:

| Sequence | Condition | Target |
| --- | --- | --- |
| 10 | `G_AUTH_NOTICE_CODE = DUPLICATE_PROVIDER` | Page 40 |
| 20 | `G_APP_USER_ID is not null` | Page 20 |
| 30 | `G_APP_USER_ID is null` | Page 10 |

This keeps returning users on the shortest path to Page 20 and sends first-time social users to Page 10.

## 6. Page 10: Social Profile Completion

Page 10 collects required profile data for first-time Google and Facebook users.

Recommended items:

| Item | Source |
| --- | --- |
| `P10_AUTH_PROVIDER` | `&G_AUTH_PROVIDER.` |
| `P10_EXTERNAL_SUBJECT` | `&G_EXTERNAL_SUBJECT.` |
| `P10_GOOGLE_SUB` | `&G_GOOGLE_SUB.` |
| `P10_EMAIL` | `&G_SOCIAL_EMAIL.` |
| `P10_FULL_NAME` | `&G_SOCIAL_FULL_NAME.` |
| `P10_BIRTH_DATE` | user input |
| `P10_PHONE_NUMBER` | user input |

The submit process calls `APP_MULTI_AUTH.COMPLETE_SOCIAL_REGISTRATION`, stores generated ORDS credentials in Page 20 items, and redirects to Page 20.

When `P10_EXTERNAL_SUBJECT` is empty for Google, use `P10_GOOGLE_SUB` as the subject.

## 7. Page 11: Custom Account Creation

Page 11 is public and creates local users.

Recommended items:

| Item | Type |
| --- | --- |
| `P11_EMAIL` | Text Field |
| `P11_FULL_NAME` | Text Field |
| `P11_BIRTH_DATE` | Date Picker |
| `P11_PHONE_NUMBER` | Text Field |
| `P11_PASSWORD` | Password |
| `P11_CONFIRM_PASSWORD` | Password |

The create account process:

```sql
begin
    if :P11_PASSWORD != :P11_CONFIRM_PASSWORD then
        raise_application_error(-20001, 'Password confirmation does not match.');
    end if;

    app_multi_auth.create_custom_user(
        p_email                => :P11_EMAIL,
        p_full_name            => :P11_FULL_NAME,
        p_birth_date           => :P11_BIRTH_DATE,
        p_phone_number         => :P11_PHONE_NUMBER,
        p_password             => :P11_PASSWORD,
        p_out_app_user_id      => :P20_APP_USER_ID,
        p_out_client_name      => :P20_CLIENT_NAME,
        p_out_client_id        => :P20_CLIENT_ID,
        p_out_client_secret    => :P20_CLIENT_SECRET,
        p_out_created_now_flag => :P20_CREATED_NOW_FLAG
    );

    apex_authentication.login(
        p_username           => lower(trim(:P11_EMAIL)),
        p_password           => :P11_PASSWORD,
        p_uppercase_username => false
    );

    apex_util.redirect_url(p_url => apex_page.get_url(p_page => 20));
    apex_application.stop_apex_engine;
end;
```

Password policy enforced by the package:

- at least 12 characters
- at least one uppercase letter
- at least one lowercase letter
- at least one number

## 8. Page 20: Credentials Generated

Page 20 displays the ORDS credentials generated for the authenticated application user.

Use this process to ensure returning users always see their active client:

```sql
declare
    l_client_name         app_user_oauth_clients.ords_client_name%type;
    l_client_id           app_user_oauth_clients.ords_client_id%type;
    l_app_user_id         app_users.id%type;
    l_created_now_flag    varchar2(1 char) := 'N';
begin
    l_app_user_id := to_number(:G_APP_USER_ID);

    select c.ords_client_name,
           c.ords_client_id
      into l_client_name,
           l_client_id
      from app_user_oauth_clients c
     where c.app_user_id = l_app_user_id
       and c.active_flag = 'Y'
       and rownum = 1;

    :P20_APP_USER_ID := l_app_user_id;
    :P20_CLIENT_NAME := l_client_name;
    :P20_CLIENT_ID := l_client_id;
    :P20_CLIENT_SECRET := null;
    :P20_CREATED_NOW_FLAG := l_created_now_flag;
exception
    when no_data_found then
        :P20_APP_USER_ID := l_app_user_id;
        :P20_CLIENT_NAME := null;
        :P20_CLIENT_ID := null;
        :P20_CLIENT_SECRET := null;
        :P20_CREATED_NOW_FLAG := 'N';
end;
```

Page items:

| Item | Purpose |
| --- | --- |
| `P20_APP_USER_ID` | Application user id |
| `P20_CLIENT_NAME` | ORDS client name |
| `P20_CLIENT_ID` | ORDS client id |
| `P20_CLIENT_SECRET` | ORDS client secret, shown only when newly generated |
| `P20_CREATED_NOW_FLAG` | `Y` when credentials were generated in the current flow |

## 9. Page 40: Duplicate Login Method Notice

Page 40 explains that the email already exists through another login method.

Recommended display-only items:

| Item | Source |
| --- | --- |
| `P40_MESSAGE` | `&G_AUTH_NOTICE_MESSAGE.` |
| `P40_EMAIL` | `&G_AUTH_NOTICE_EMAIL.` |
| `P40_EXISTING_PROVIDER` | `&G_AUTH_NOTICE_EXISTING_PROVIDER.` |
| `P40_ATTEMPT_PROVIDER` | `&G_AUTH_NOTICE_ATTEMPT_PROVIDER.` |

Add buttons for the active login methods:

- Custom Login
- Google
- Facebook

## 10. Final Test Matrix

Validate these flows before publishing:

- new Custom user reaches Page 20
- returning Custom user reaches Page 20
- invalid Custom credentials show an inline error on Page 9999
- new Google user reaches Page 10, completes profile, reaches Page 20
- returning Google user reaches Page 20 directly
- new Facebook user reaches Page 10, completes profile, reaches Page 20
- returning Facebook user reaches Page 20 directly
- Facebook attempt using an email already registered with Google is blocked on Page 40
- Google attempt using an email already registered with Custom Login is blocked on Page 40
