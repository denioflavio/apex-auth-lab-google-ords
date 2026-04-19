prompt =========================================================
prompt 02_packages.sql
prompt PL/SQL packages for the demo case
prompt =========================================================

set define off

-------------------------------------------------------------------------------
-- APEX session context helpers
-------------------------------------------------------------------------------
create or replace package app_security_ctx as
    function app_user_id return number;
    function google_sub return varchar2;
    function email return varchar2;
    function full_name return varchar2;
end app_security_ctx;
/

create or replace package body app_security_ctx as
    function get_app_item (
        p_item_name in varchar2
    ) return varchar2
    is
        l_value varchar2(4000 char);
    begin
        begin
            l_value := apex_util.get_session_state(p_item_name);
        exception
            when others then
                l_value := null;
        end;

        return l_value;
    end get_app_item;

    function app_user_id return number is
    begin
        return to_number(get_app_item('G_APP_USER_ID'));
    exception
        when value_error then
            return null;
    end app_user_id;

    function google_sub return varchar2 is
    begin
        return get_app_item('G_GOOGLE_SUB');
    end google_sub;

    function email return varchar2 is
    begin
        return get_app_item('G_SOCIAL_EMAIL');
    end email;

    function full_name return varchar2 is
    begin
        return get_app_item('G_SOCIAL_FULL_NAME');
    end full_name;
end app_security_ctx;
/

show errors

-------------------------------------------------------------------------------
-- Main API package for the demo case
-------------------------------------------------------------------------------
create or replace package app_user_api as
    subtype t_varchar2 is varchar2(32767 char);

    type t_identity_rec is record (
        google_sub      app_users.google_sub%type,
        email           app_users.email%type,
        full_name       app_users.full_name%type
    );

    type t_credentials_rec is record (
        app_user_id        app_users.id%type,
        email              app_users.email%type,
        full_name          app_users.full_name%type,
        phone_number       app_users.phone_number%type,
        ords_client_name   app_user_oauth_clients.ords_client_name%type,
        ords_client_id     app_user_oauth_clients.ords_client_id%type,
        ords_client_secret varchar2(4000 char),
        created_now_flag   varchar2(1 char)
    );

    type t_me_rec is record (
        app_user_id        app_users.id%type,
        email              app_users.email%type,
        full_name          app_users.full_name%type,
        phone_number       app_users.phone_number%type,
        ords_client_id     app_user_oauth_clients.ords_client_id%type,
        ords_client_name   app_user_oauth_clients.ords_client_name%type,
        created_at         app_user_oauth_clients.created_at%type
    );

    function normalize_phone (
        p_phone_number in varchar2
    ) return varchar2;

    procedure validate_profile (
        p_full_name     in varchar2,
        p_birth_date    in date,
        p_phone_number  in varchar2
    );

    function find_user_by_google_sub (
        p_google_sub in varchar2
    ) return app_users%rowtype;

    function upsert_social_user (
        p_google_sub in varchar2,
        p_email      in varchar2,
        p_full_name  in varchar2
    ) return number;

    function has_active_client (
        p_app_user_id in number
    ) return varchar2;

    procedure complete_registration (
        p_google_sub            in varchar2,
        p_email                 in varchar2,
        p_full_name             in varchar2,
        p_birth_date            in date,
        p_phone_number          in varchar2,
        p_out_app_user_id       out nocopy number,
        p_out_client_name       out nocopy varchar2,
        p_out_client_id         out nocopy varchar2,
        p_out_client_secret     out nocopy varchar2,
        p_out_created_now_flag  out nocopy varchar2
    );

    procedure get_credentials_for_display (
        p_app_user_id           in number,
        p_out_client_name       out nocopy varchar2,
        p_out_client_id         out nocopy varchar2
    );

    procedure write_runtime_log (
        p_event_type          in varchar2,
        p_ords_client_id      in varchar2,
        p_ords_client_name    in varchar2,
        p_current_user_value  in varchar2,
        p_remote_user_value   in varchar2,
        p_remote_ident_value  in varchar2,
        p_client_identifier   in varchar2,
        p_notes               in varchar2 default null
    );

    function resolve_client_id_from_runtime (
        p_current_user_value  in varchar2,
        p_remote_user_value   in varchar2,
        p_remote_ident_value  in varchar2
    ) return varchar2;

    function get_me_by_runtime (
        p_current_user_value  in varchar2,
        p_remote_user_value   in varchar2,
        p_remote_ident_value  in varchar2
    ) return t_me_rec;
end app_user_api;
/

create or replace package body app_user_api as
    g_ords_role_name constant varchar2(128 char) := 'app_me_role';
    g_ords_priv_name constant varchar2(128 char) := 'app.me.privilege';

    function normalize_phone (
        p_phone_number in varchar2
    ) return varchar2
    is
    begin
        return regexp_replace(trim(p_phone_number), '[^0-9+]', '');
    end normalize_phone;

    procedure validate_profile (
        p_full_name     in varchar2,
        p_birth_date    in date,
        p_phone_number  in varchar2
    )
    is
    begin
        if p_full_name is null or length(trim(p_full_name)) < 3 then
            raise_application_error(-20001, 'Enter a valid full name.');
        end if;

        if p_birth_date is null then
            raise_application_error(-20002, 'Enter a birth date.');
        end if;

        if p_birth_date > trunc(sysdate) then
            raise_application_error(-20003, 'Birth date cannot be in the future.');
        end if;

        if add_months(trunc(sysdate), -12 * 120) > p_birth_date then
            raise_application_error(-20004, 'Birth date is outside the expected range for this demo.');
        end if;

        if p_phone_number is null or length(normalize_phone(p_phone_number)) < 8 then
            raise_application_error(-20005, 'Enter a valid phone number.');
        end if;
    end validate_profile;

    function find_user_by_google_sub (
        p_google_sub in varchar2
    ) return app_users%rowtype
    is
        l_user app_users%rowtype;
    begin
        select *
          into l_user
          from app_users
         where google_sub = p_google_sub;

        return l_user;
    exception
        when no_data_found then
            return l_user;
    end find_user_by_google_sub;

    function upsert_social_user (
        p_google_sub in varchar2,
        p_email      in varchar2,
        p_full_name  in varchar2
    ) return number
    is
        l_app_user_id app_users.id%type;
    begin
        if p_google_sub is null then
            raise_application_error(-20010, 'google_sub was not returned by the social authentication flow.');
        end if;

        merge into app_users dst
        using (
            select p_google_sub as google_sub,
                   p_email      as email,
                   nvl(trim(p_full_name), 'Google User') as full_name
              from dual
        ) src
           on (dst.google_sub = src.google_sub)
        when matched then update
             set dst.email = coalesce(src.email, dst.email),
                 dst.full_name = case
                                     when dst.full_name is null or dst.full_name = 'Google User'
                                     then src.full_name
                                     else dst.full_name
                                 end
        when not matched then insert (
             google_sub, email, full_name, status
        ) values (
             src.google_sub, src.email, src.full_name, 'ACTIVE'
        );

        select id
          into l_app_user_id
          from app_users
         where google_sub = p_google_sub;

        return l_app_user_id;
    end upsert_social_user;

    function has_active_client (
        p_app_user_id in number
    ) return varchar2
    is
        l_dummy varchar2(1 char);
    begin
        select 'Y'
          into l_dummy
          from app_user_oauth_clients
         where app_user_id = p_app_user_id
           and active_flag = 'Y';

        return 'Y';
    exception
        when no_data_found then
            return 'N';
    end has_active_client;

    procedure ensure_ords_role is
    begin
        begin
            ords.create_role(p_role_name => g_ords_role_name);
        exception
            when others then
                if sqlcode not in (-20001, -955) then
                    raise;
                end if;
        end;
    end ensure_ords_role;

    procedure provision_ords_client (
        p_app_user_id           in number,
        p_google_sub            in varchar2,
        p_email                 in varchar2,
        p_out_client_name       out nocopy varchar2,
        p_out_client_id         out nocopy varchar2,
        p_out_client_secret     out nocopy varchar2,
        p_out_created_now_flag  out nocopy varchar2
    )
    is
        l_client_name    varchar2(255 char);
        l_existing_id    app_user_oauth_clients.ords_client_id%type;
        l_existing_name  app_user_oauth_clients.ords_client_name%type;
    begin
        begin
            select ords_client_id, ords_client_name
              into l_existing_id, l_existing_name
              from app_user_oauth_clients
             where app_user_id = p_app_user_id
               and active_flag = 'Y';

            p_out_client_name      := l_existing_name;
            p_out_client_id        := l_existing_id;
            p_out_client_secret    := null;
            p_out_created_now_flag := 'N';
            return;
        exception
            when no_data_found then
                null;
        end;

        l_client_name := substr(
            'APPUSR_' || p_app_user_id || '_' || replace(lower(rawtohex(utl_raw.cast_to_raw(p_google_sub))), ' ', ''),
            1,
            120
        );

        ensure_ords_role;

        oauth.create_client(
            p_name            => l_client_name,
            p_grant_type      => 'client_credentials',
            p_owner           => user,
            p_description     => 'OAuth client created by the APEX self-service flow for app_user_id=' || p_app_user_id,
            p_support_email   => nvl(p_email, 'noreply@example.com'),
            p_privilege_names => g_ords_priv_name
        );

        oauth.grant_client_role(
            p_client_name => l_client_name,
            p_role_name   => g_ords_role_name
        );

        select client_id, client_secret
          into p_out_client_id, p_out_client_secret
          from user_ords_clients
         where name = l_client_name;

        insert into app_user_oauth_clients (
            app_user_id,
            ords_client_name,
            ords_client_id,
            active_flag
        ) values (
            p_app_user_id,
            l_client_name,
            p_out_client_id,
            'Y'
        );

        p_out_client_name      := l_client_name;
        p_out_created_now_flag := 'Y';
    exception
        when dup_val_on_index then
            raise_application_error(-20020, 'An active OAuth client already exists for this user.');
    end provision_ords_client;

    procedure complete_registration (
        p_google_sub            in varchar2,
        p_email                 in varchar2,
        p_full_name             in varchar2,
        p_birth_date            in date,
        p_phone_number          in varchar2,
        p_out_app_user_id       out nocopy number,
        p_out_client_name       out nocopy varchar2,
        p_out_client_id         out nocopy varchar2,
        p_out_client_secret     out nocopy varchar2,
        p_out_created_now_flag  out nocopy varchar2
    )
    is
        l_phone_number app_users.phone_number%type;
    begin
        validate_profile(
            p_full_name    => p_full_name,
            p_birth_date   => p_birth_date,
            p_phone_number => p_phone_number
        );

        p_out_app_user_id := upsert_social_user(
            p_google_sub => p_google_sub,
            p_email      => p_email,
            p_full_name  => p_full_name
        );

        l_phone_number := normalize_phone(p_phone_number);

        update app_users
           set full_name    = trim(p_full_name),
               birth_date   = p_birth_date,
               phone_number = l_phone_number,
               email        = coalesce(p_email, email),
               status       = 'ACTIVE'
         where id = p_out_app_user_id;

        provision_ords_client(
            p_app_user_id           => p_out_app_user_id,
            p_google_sub            => p_google_sub,
            p_email                 => p_email,
            p_out_client_name       => p_out_client_name,
            p_out_client_id         => p_out_client_id,
            p_out_client_secret     => p_out_client_secret,
            p_out_created_now_flag  => p_out_created_now_flag
        );
    end complete_registration;

    procedure get_credentials_for_display (
        p_app_user_id           in number,
        p_out_client_name       out nocopy varchar2,
        p_out_client_id         out nocopy varchar2
    )
    is
    begin
        begin
            select ords_client_name, ords_client_id
              into p_out_client_name, p_out_client_id
              from app_user_oauth_clients
             where app_user_id = p_app_user_id
               and active_flag = 'Y';
        exception
            when no_data_found then
                p_out_client_name := null;
                p_out_client_id   := null;
        end;
    end get_credentials_for_display;

    procedure write_runtime_log (
        p_event_type          in varchar2,
        p_ords_client_id      in varchar2,
        p_ords_client_name    in varchar2,
        p_current_user_value  in varchar2,
        p_remote_user_value   in varchar2,
        p_remote_ident_value  in varchar2,
        p_client_identifier   in varchar2,
        p_notes               in varchar2 default null
    )
    is
        pragma autonomous_transaction;
    begin
        insert into app_api_event_log (
            event_type,
            ords_client_id,
            ords_client_name,
            current_user_value,
            remote_user_value,
            remote_ident_value,
            client_identifier,
            notes
        ) values (
            p_event_type,
            p_ords_client_id,
            p_ords_client_name,
            p_current_user_value,
            p_remote_user_value,
            p_remote_ident_value,
            p_client_identifier,
            p_notes
        );

        commit;
    exception
        when others then
            rollback;
    end write_runtime_log;

    function resolve_client_id_from_runtime (
        p_current_user_value  in varchar2,
        p_remote_user_value   in varchar2,
        p_remote_ident_value  in varchar2
    ) return varchar2
    is
        l_client_identifier varchar2(255 char);
        l_client_id         varchar2(255 char);
    begin
        l_client_identifier := sys_context('userenv', 'client_identifier');

        if l_client_identifier is not null then
            begin
                select c.client_id
                  into l_client_id
                  from user_ords_clients c
                 where c.client_id = l_client_identifier;
                return l_client_id;
            exception
                when no_data_found then
                    null;
            end;

            begin
                select c.client_id
                  into l_client_id
                  from user_ords_clients c
                 where c.name = l_client_identifier;
                return l_client_id;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        if p_current_user_value is not null then
            begin
                select c.client_id
                  into l_client_id
                  from user_ords_clients c
                 where c.client_id = p_current_user_value
                    or c.name = p_current_user_value;
                return l_client_id;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        if p_remote_user_value is not null then
            begin
                select c.client_id
                  into l_client_id
                  from user_ords_clients c
                 where c.client_id = p_remote_user_value
                    or c.name = p_remote_user_value;
                return l_client_id;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        if p_remote_ident_value is not null then
            begin
                select c.client_id
                  into l_client_id
                  from user_ords_clients c
                 where c.client_id = p_remote_ident_value
                    or c.name = p_remote_ident_value;
                return l_client_id;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        return null;
    end resolve_client_id_from_runtime;

    function get_me_by_runtime (
        p_current_user_value  in varchar2,
        p_remote_user_value   in varchar2,
        p_remote_ident_value  in varchar2
    ) return t_me_rec
    is
        l_me                t_me_rec;
        l_client_id         varchar2(255 char);
        l_client_name       varchar2(255 char);
        l_client_identifier varchar2(255 char);
    begin
        l_client_identifier := sys_context('userenv', 'client_identifier');
        l_client_id := resolve_client_id_from_runtime(
            p_current_user_value => p_current_user_value,
            p_remote_user_value  => p_remote_user_value,
            p_remote_ident_value => p_remote_ident_value
        );

        if l_client_id is null then
            write_runtime_log(
                p_event_type         => 'ME_LOOKUP_FAILED',
                p_ords_client_id     => null,
                p_ords_client_name   => null,
                p_current_user_value => p_current_user_value,
                p_remote_user_value  => p_remote_user_value,
                p_remote_ident_value => p_remote_ident_value,
                p_client_identifier  => l_client_identifier,
                p_notes              => 'Unable to resolve client_id from the ORDS runtime context.'
            );

            raise_application_error(-20030, 'Unable to identify the authenticated OAuth client.');
        end if;

        select u.id,
               u.email,
               u.full_name,
               u.phone_number,
               c.ords_client_id,
               c.ords_client_name,
               c.created_at
          into l_me.app_user_id,
               l_me.email,
               l_me.full_name,
               l_me.phone_number,
               l_me.ords_client_id,
               l_me.ords_client_name,
               l_me.created_at
          from app_users u
          join app_user_oauth_clients c
            on c.app_user_id = u.id
         where c.ords_client_id = l_client_id
           and c.active_flag = 'Y';

        begin
            select name
              into l_client_name
              from user_ords_clients
             where client_id = l_client_id;
        exception
            when no_data_found then
                l_client_name := l_me.ords_client_name;
        end;

        write_runtime_log(
            p_event_type         => 'ME_LOOKUP_OK',
            p_ords_client_id     => l_client_id,
            p_ords_client_name   => l_client_name,
            p_current_user_value => p_current_user_value,
            p_remote_user_value  => p_remote_user_value,
            p_remote_ident_value => p_remote_ident_value,
            p_client_identifier  => l_client_identifier,
            p_notes              => 'Lookup completed successfully.'
        );

        return l_me;
    end get_me_by_runtime;
end app_user_api;
/

show errors
