create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('worker','business')),
  full_name text not null,
  phone text,
  area text,
  skills text,
  company_name text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  category text not null,
  work_type text not null,
  area text not null,
  pay text,
  description text not null,
  contact_phone text,
  status text not null default 'open' check (status in ('open','closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs(id) on delete cascade,
  worker_id uuid not null references public.profiles(id) on delete cascade,
  message text,
  status text not null default 'new' check (status in ('new','reviewing','accepted','rejected')),
  created_at timestamptz not null default now(),
  unique(job_id, worker_id)
);

alter table public.profiles enable row level security;
alter table public.jobs enable row level security;
alter table public.applications enable row level security;

revoke all on public.profiles, public.jobs, public.applications from anon;
grant select on public.profiles, public.jobs to anon;
grant select, insert, update on public.profiles, public.jobs, public.applications to authenticated;

drop policy if exists "public can view open jobs" on public.jobs;
create policy "public can view open jobs" on public.jobs for select to anon, authenticated using (status='open');

drop policy if exists "users view own profile" on public.profiles;
create policy "users view own profile" on public.profiles for select to authenticated using ((select auth.uid())=id);

drop policy if exists "users create own profile" on public.profiles;
create policy "users create own profile" on public.profiles for insert to authenticated with check ((select auth.uid())=id);

drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile" on public.profiles for update to authenticated using ((select auth.uid())=id) with check ((select auth.uid())=id);

drop policy if exists "business can create jobs" on public.jobs;
create policy "business can create jobs" on public.jobs for insert to authenticated
with check ((select auth.uid())=business_id and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='business'));

drop policy if exists "business can update own jobs" on public.jobs;
create policy "business can update own jobs" on public.jobs for update to authenticated
using ((select auth.uid())=business_id) with check ((select auth.uid())=business_id);

drop policy if exists "worker creates own applications" on public.applications;
create policy "worker creates own applications" on public.applications for insert to authenticated
with check ((select auth.uid())=worker_id and exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role='worker'));

drop policy if exists "worker sees own applications" on public.applications;
create policy "worker sees own applications" on public.applications for select to authenticated
using ((select auth.uid())=worker_id or exists(select 1 from public.jobs j where j.id=job_id and j.business_id=(select auth.uid())));

drop policy if exists "business updates applications" on public.applications;
create policy "business updates applications" on public.applications for update to authenticated
using (exists(select 1 from public.jobs j where j.id=job_id and j.business_id=(select auth.uid())))
with check (exists(select 1 from public.jobs j where j.id=job_id and j.business_id=(select auth.uid())));
