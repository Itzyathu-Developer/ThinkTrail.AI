alter table public.profiles
  drop constraint profiles_xp_earned_today_check;

alter table public.profiles
  add constraint profiles_xp_earned_today_check check (xp_earned_today >= 0);

create or replace function public.record_study_activity(p_xp integer default 0)
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

  if p_xp is null or p_xp < 0 or p_xp > 25 then
    raise exception 'XP awards must be between 0 and 25.' using errcode = '22023';
  end if;

  insert into public.profiles (id)
  values (student_id)
  on conflict (id) do nothing;

  awarded_xp := p_xp;

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
    'activity_date', updated_profile.last_active_on
  );
end;
$$;
