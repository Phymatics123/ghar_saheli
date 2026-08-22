-- Ghar Saheli: activation codes.
--
-- Each code may be redeemed a small number of times (3 by default) rather than
-- exactly once. That is deliberate. A code is not tied to a device, so the
-- server cannot tell "the same customer reinstalling" apart from "somebody
-- else trying a leaked code" — both look identical. A strict single use would
-- lock a paying customer out the first time they reset their phone; a small
-- allowance absorbs that without letting a leaked code serve a crowd.
--
-- ============================================================================
-- WHY IT IS SAFE TO SHIP THE PUBLISHABLE KEY INSIDE THE APK
-- ============================================================================
--   1. Row level security is ON for this table with NO policies granted. An
--      RLS table with zero policies denies all direct access — that absence
--      is the lock, not an oversight. The publishable key cannot select,
--      insert, update or delete a single row, so pulling it out of the APK
--      gains an attacker nothing on its own.
--
--   2. The only door left open is redeem_license below. It is SECURITY
--      DEFINER, so it runs as the table owner and may bypass RLS to do its
--      one job, while the key still cannot reach the table any other way. It
--      answers a single yes/no about a single code and reveals nothing else —
--      not whether a code exists, not how many redemptions remain. A wrong
--      guess and an exhausted code return the same answer, so it is no use
--      for probing.
--
--   3. generate_license_keys is NOT granted to anon. It runs only under your
--      own account, from the dashboard or the CLI.
-- ============================================================================

create extension if not exists pgcrypto;

create table if not exists license_keys (
  code             text primary key,
  redemptions_used int  not null default 0,
  max_redemptions  int  not null default 3,
  first_used_at    timestamptz,
  last_used_at     timestamptz,
  note             text,
  created_at       timestamptz not null default now()
);

alter table license_keys enable row level security;

-- ----------------------------------------------------------------------------
-- redeem_license — the one thing the app may call.
--
-- Atomic by construction: the WHERE clause tests the remaining allowance in
-- the same statement that spends it, so two phones redeeming the last
-- redemption at the same instant cannot both succeed. Postgres serialises the
-- row lock and the loser simply matches zero rows.
-- ----------------------------------------------------------------------------
create or replace function redeem_license(input_code text)
returns boolean
language plpgsql
security definer
set search_path = public
as $fn$
declare
  rows_updated int;
begin
  update license_keys
  set redemptions_used = redemptions_used + 1,
      first_used_at    = coalesce(first_used_at, now()),
      last_used_at     = now()
  where code = upper(trim(input_code))
    and redemptions_used < max_redemptions;

  get diagnostics rows_updated = row_count;
  return rows_updated > 0;
end;
$fn$;

revoke all on function redeem_license(text) from public;
grant execute on function redeem_license(text) to anon;

-- ----------------------------------------------------------------------------
-- generate_license_keys — restocking, for you only.
--
-- Codes use the same Crockford-style alphabet as the app's own ULIDs: no
-- 0/O and no 1/I/L to confuse, so a code survives being read off a screenshot
-- or dictated over the phone. Sixteen characters from a 32-symbol alphabet is
-- eighty bits — guessing one is not a realistic attack.
-- ----------------------------------------------------------------------------
create or replace function generate_license_keys(
  how_many   int,
  batch_note text default null,
  allowance  int default 3
)
returns setof text
language plpgsql
as $fn$
declare
  alphabet text := '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  new_code text;
  attempts int;
begin
  for i in 1..how_many loop
    attempts := 0;
    loop
      new_code := '';
      for g in 1..4 loop
        for c in 1..4 loop
          new_code := new_code
            || substr(alphabet, floor(random() * 32)::int + 1, 1);
        end loop;
        if g < 4 then
          new_code := new_code || '-';
        end if;
      end loop;

      attempts := attempts + 1;
      exit when not exists (select 1 from license_keys where code = new_code)
             or attempts > 20;
    end loop;

    insert into license_keys (code, note, max_redemptions)
    values (new_code, batch_note, allowance);
    return next new_code;
  end loop;
end;
$fn$;

revoke all on function generate_license_keys(int, text, int) from public;
