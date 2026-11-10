-- Room Work v4 schema. Run in Supabase SQL Editor.
-- Public anonymous read/write is intentional for this no-login shared site.
create table if not exists public.room_work_cells (
  work_date date not null,
  task_name text not null,
  person_name text not null,
  cell_value text not null default '',
  updated_at timestamptz not null default now(),
  primary key (work_date, task_name, person_name)
);
create table if not exists public.room_work_dates (
  work_date date primary key,
  confirmed boolean not null default true
);
alter table public.room_work_cells enable row level security;
alter table public.room_work_dates enable row level security;
drop policy if exists "Public read cells" on public.room_work_cells;
create policy "Public read cells" on public.room_work_cells for select to anon using (true);
drop policy if exists "Public insert cells" on public.room_work_cells;
create policy "Public insert cells" on public.room_work_cells for insert to anon with check (true);
drop policy if exists "Public update cells" on public.room_work_cells;
create policy "Public update cells" on public.room_work_cells for update to anon using (true) with check (true);
drop policy if exists "Public read dates" on public.room_work_dates;
create policy "Public read dates" on public.room_work_dates for select to anon using (true);
drop policy if exists "Public insert dates" on public.room_work_dates;
create policy "Public insert dates" on public.room_work_dates for insert to anon with check (true);
drop policy if exists "Public update dates" on public.room_work_dates;
create policy "Public update dates" on public.room_work_dates for update to anon using (true) with check (true);
do $$ begin alter publication supabase_realtime add table public.room_work_cells; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.room_work_dates; exception when duplicate_object then null; end $$;


-- V8 editable spreadsheet labels. This stores task and person headings centrally.
create table if not exists public.room_work_layout (
  id smallint primary key check (id = 1),
  people jsonb not null,
  tasks jsonb not null,
  task_header text not null default 'WORK / TASK',
  updated_at timestamptz not null default now()
);
alter table public.room_work_layout enable row level security;
drop policy if exists "Public read layout" on public.room_work_layout;
create policy "Public read layout" on public.room_work_layout for select to anon using (true);
drop policy if exists "Public insert layout" on public.room_work_layout;
create policy "Public insert layout" on public.room_work_layout for insert to anon with check (true);
drop policy if exists "Public update layout" on public.room_work_layout;
create policy "Public update layout" on public.room_work_layout for update to anon using (true) with check (true);
grant select, insert, update on public.room_work_layout to anon;
alter table public.room_work_layout add column if not exists task_header text not null default 'WORK / TASK';
insert into public.room_work_layout (id, people, tasks, task_header)
values (
  1,
  '["DHRSHYA","SANDRA","SHAKINA","VIJAYSHREE"]'::jsonb,
  '["FLOOR & TOP","MOP","MAT WASHING","WASTE","CAN WATER & WASH","KITCHEN VESSEL KEEPING","BATHROOM","TOMATO & ONION MARKET"]'::jsonb,
  'WORK / TASK'
)
on conflict (id) do nothing;
do $$ begin alter publication supabase_realtime add table public.room_work_layout; exception when duplicate_object then null; end $$;
