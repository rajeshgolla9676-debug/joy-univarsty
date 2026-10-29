-- Supabase PostgreSQL schema. Run in the SQL Editor before using the portal.
create table if not exists public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 student_id text not null unique check(length(trim(student_id)) between 1 and 40),
 full_name text not null check(length(trim(full_name)) between 1 and 100),
 department text not null default 'Other', course text not null, academic_year text not null,
 phone text, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create unique index if not exists profiles_student_id_lower_idx on public.profiles(lower(student_id));
create index if not exists profiles_name_lower_idx on public.profiles(lower(full_name));
create index if not exists profiles_department_idx on public.profiles(department);
create table if not exists public.user_roles(
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'student' check(role in ('student','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.admin_audit_logs(
 id bigint generated always as identity primary key,
 actor_user_id uuid references auth.users(id) on delete set null,
 action text not null,target_user_id uuid references auth.users(id) on delete set null,
 metadata jsonb not null default '{}'::jsonb,created_at timestamptz not null default now()
);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path='' as $$
declare m jsonb:=coalesce(new.raw_user_meta_data,'{}'::jsonb); sid text:=nullif(trim(m->>'student_id'),'');
begin
 if sid is null then sid:='STU-'||upper(substr(replace(new.id::text,'-',''),1,12)); end if;
 insert into public.profiles(id,student_id,full_name,department,course,academic_year,phone)
 values(new.id,sid,coalesce(nullif(trim(m->>'full_name'),''),'Student'),coalesce(nullif(trim(m->>'department'),''),'Other'),coalesce(nullif(trim(m->>'course'),''),'Not specified'),coalesce(nullif(trim(m->>'academic_year'),''),'Other'),nullif(trim(m->>'phone'),''));
 insert into public.user_roles(user_id,role) values(new.id,'student');
 return new;
end; $$;
drop trigger if exists on_auth_user_created_student_portal on auth.users;
create trigger on_auth_user_created_student_portal after insert on auth.users for each row execute function public.handle_new_user();
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.user_roles where user_id=(select auth.uid()) and role='admin');
$$;
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.admin_audit_logs enable row level security;
drop policy if exists profiles_select_own_or_admin on public.profiles;
create policy profiles_select_own_or_admin on public.profiles for select to authenticated using(id=(select auth.uid()) or (select public.is_admin()));
drop policy if exists profiles_update_own_or_admin on public.profiles;
create policy profiles_update_own_or_admin on public.profiles for update to authenticated using(id=(select auth.uid()) or (select public.is_admin())) with check(id=(select auth.uid()) or (select public.is_admin()));
drop policy if exists roles_select_own_or_admin on public.user_roles;
create policy roles_select_own_or_admin on public.user_roles for select to authenticated using(user_id=(select auth.uid()) or (select public.is_admin()));
drop policy if exists audit_admin_select on public.admin_audit_logs;
create policy audit_admin_select on public.admin_audit_logs for select to authenticated using((select public.is_admin()));
grant usage on schema public to anon,authenticated;
grant select,update on public.profiles to authenticated;
grant select on public.user_roles,public.admin_audit_logs to authenticated;
grant execute on function public.is_admin() to authenticated;
-- After the intended admin account has signed up, run this trusted SQL with that account's UUID:
-- insert into public.user_roles(user_id,role) values('AUTH_USER_UUID_HERE','admin')
-- on conflict(user_id) do update set role=excluded.role;
-- Signup always creates the student role; client-supplied role values are ignored.
