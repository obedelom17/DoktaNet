
create table chat_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  title text, created_at timestamptz not null default now()
);
create table chat_messages (
  id bigserial primary key,
  conversation_id uuid not null references chat_conversations(id) on delete cascade,
  role text not null check (role in ('user','assistant')),
  content text not null, created_at timestamptz not null default now()
);
create table reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  medication text not null, times text[] not null, end_date date not null,
  created_at timestamptz not null default now()
);
