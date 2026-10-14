alter table users add column totp_secret text, add column totp_enabled boolean not null default false;

create table doctor_blocks (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references users(id) on delete cascade,
  starts_at timestamptz not null, ends_at timestamptz not null, reason text,
  created_at timestamptz not null default now()
);
create table appointment_messages (
  id bigserial primary key,
  appointment_id uuid not null references appointments(id) on delete cascade,
  sender_id uuid not null references users(id),
  content text not null, created_at timestamptz not null default now()
);
create table reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references users(id) on delete cascade,
  reason text not null,
  status text not null default 'open' check (status in ('open','resolved')),
  admin_note text, created_at timestamptz not null default now()
);
