-- Run this entire file once in your external Supabase project's SQL editor.
-- It enables the "Time by Area" dashboard card and makes the leaderboard rank by accuracy.

-- =====================================================================
-- 1. Study time tracking (Time by Area on the dashboard)
-- =====================================================================
create table if not exists public.study_time (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  area text not null,
  day date not null default (now() at time zone 'utc')::date,
  seconds integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, area, day)
);

grant select, insert, update on public.study_time to authenticated;
grant all on public.study_time to service_role;

alter table public.study_time enable row level security;

drop policy if exists "Users manage their own study time" on public.study_time;
create policy "Users manage their own study time"
  on public.study_time for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop trigger if exists study_time_updated_at on public.study_time;
create trigger study_time_updated_at before update on public.study_time
  for each row execute function public.set_updated_at();

-- Adds seconds to today's row for the signed-in user.
create or replace function public.add_study_time(_area text, _seconds integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or _seconds is null or _seconds <= 0 then
    return;
  end if;
  -- Guard against a single absurd write (max ~4h per call).
  if _seconds > 14400 then
    _seconds := 14400;
  end if;

  insert into public.study_time (user_id, area, day, seconds)
  values (auth.uid(), _area, (now() at time zone 'utc')::date, _seconds)
  on conflict (user_id, area, day)
  do update set seconds = public.study_time.seconds + excluded.seconds,
                updated_at = now();
end;
$$;

revoke all on function public.add_study_time(text, integer) from public;
grant execute on function public.add_study_time(text, integer) to authenticated;

-- =====================================================================
-- 2. Leaderboard ranks by accuracy first, then correct count as tiebreak
-- =====================================================================
create or replace function public.leaderboard()
returns table (
  user_id uuid,
  name text,
  correct integer,
  attempted integer,
  accuracy numeric,
  rank integer
)
language sql
stable
security definer
set search_path = public
as $$
  with agg as (
    select
      t.user_id,
      count(*) filter (where t.status = 'correct')::int as correct,
      count(*) filter (where t.status in ('correct','incorrect'))::int as attempted
    from public.tracker_progress t
    -- Only count progress for questions that still exist in the bank,
    -- so rows left behind by deleted questions never inflate the totals.
    join public.practice_questions q on q.id::text = t.question_id::text
    group by t.user_id
  ),
  scored as (
    select
      a.*,
      case when a.attempted > 0 then round((a.correct::numeric / a.attempted) * 100, 0) else 0 end as accuracy
    from agg a
    where a.attempted > 0
  )
  select
    s.user_id,
    coalesce(nullif(p.full_name, ''), split_part(coalesce(p.email, ''), '@', 1), 'Student') as name,
    s.correct,
    s.attempted,
    s.accuracy,
    rank() over (order by s.accuracy desc, s.correct desc, s.attempted asc)::int as rank
  from scored s
  left join public.profiles p on p.id = s.user_id
  order by rank
$$;

revoke all on function public.leaderboard() from public;
grant execute on function public.leaderboard() to authenticated;
