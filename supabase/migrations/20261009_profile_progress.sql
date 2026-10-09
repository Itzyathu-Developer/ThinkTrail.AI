create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default 'Student',
  email text,
  xp integer not null default 120 check (xp >= 0),
  streak integer not null default 0 check (streak >= 0),
  last_active_on date,
  xp_earned_on date,
  xp_earned_today integer not null default 0 check (xp_earned_today >= 0 and xp_earned_today <= 100),
  bio text not null default '',
  focus_areas text[] not null default array['Math', 'Science']::text[],
  study_materials text not null default '',
  reward_goal text not null default 'Unlock a mastery badge',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Students can read their own profile"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Students can update their own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (name, email, bio, focus_areas, study_materials, reward_goal, updated_at)
  on public.profiles to authenticated;

create function public.create_student_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, name)
  values (
    new.id,
    new.email,
    coalesce(
      nullif(btrim(new.raw_user_meta_data ->> 'name'), ''),
      nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
      'Student'
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created_profile
  after insert on auth.users
  for each row execute function public.create_student_profile();

insert into public.profiles (id, email, name)
select
  users.id,
  users.email,
  coalesce(
    nullif(btrim(users.raw_user_meta_data ->> 'name'), ''),
    nullif(split_part(coalesce(users.email, ''), '@', 1), ''),
    'Student'
  )
from auth.users as users
on conflict (id) do nothing;

create function public.record_study_activity(p_xp integer default 0)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  student_id uuid := auth.uid();
  activity_day date := (now() at time zone 'utc')::date;
  awarded_xp integer;
  updated_profile public.profiles%rowtype;
begin
  if student_id is null then
    raise exception 'Sign in is required to record study progress.' using errcode = '28000';
  end if;

  if p_xp < 0 or p_xp > 25 then
    raise exception 'XP awards must be between 0 and 25.' using errcode = '22023';
  end if;

  insert into public.profiles (id)
  values (student_id)
  on conflict (id) do nothing;

  select least(
    p_xp,
    greatest(0, 100 - case
      when profile.xp_earned_on = activity_day then profile.xp_earned_today
      else 0
    end)
  )
  into awarded_xp
  from public.profiles as profile
  where profile.id = student_id
  for update;

  update public.profiles as profile
  set
    xp = profile.xp + awarded_xp,
    xp_earned_today = case
      when profile.xp_earned_on = activity_day then profile.xp_earned_today + awarded_xp
      else awarded_xp
    end,
    xp_earned_on = activity_day,
    streak = case
      when profile.last_active_on = activity_day then profile.streak
      when profile.last_active_on = activity_day - 1 then profile.streak + 1
      else 1
    end,
    last_active_on = activity_day,
    updated_at = now()
  where profile.id = student_id
  returning * into updated_profile;

  return jsonb_build_object(
    'xp', updated_profile.xp,
    'streak', updated_profile.streak,
    'awarded_xp', awarded_xp,
    'xp_earned_today', updated_profile.xp_earned_today,
    'daily_xp_limit', 100,
    'activity_date', updated_profile.last_active_on
  );
end;
$$;

revoke all on function public.record_study_activity(integer) from public, anon;
grant execute on function public.record_study_activity(integer) to authenticated;
