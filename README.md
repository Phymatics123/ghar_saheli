# Ghar Saheli — Stages 0–5

Household ledger for Pakistani homes. Fully offline. No accounts, no cloud,
no AI, no third-party services. Distributed as a direct APK.

Stage 0 is the layer nothing is visible in: the database, the double-entry
ledger, the event log and the money type. Stage 1 is the interface on top of
it — Urdu first, icon led, two taps to record a purchase.

Stage 2 adds the reasons to open it daily: a warning when the money will run
out before the month does, monthly bills that ask to be confirmed rather than
retyped, and the amounts you last paid offered as chips above the keypad.

Stage 3 adds the parts no generic budgeting app has: a staff register with
peshgi that settles itself, a slab-tariff bill estimator, and salary receipts
that share straight into WhatsApp.

Stage 4 adds privacy and encrypted backups — and, because backups are event
logs, a way for two phones in one household to end up with the same ledger.

Stage 5 is delivery: release signing, an in-app updater, and the install
guidance a sideloaded app needs. **See [RELEASE.md](RELEASE.md)** for the
one-time setup and the steps to ship a build.

## Updating without a store

Three things make an app that installs its own APKs safe enough to hold
someone's finances:

1. **HTTPS only**, enforced when the manifest is parsed. Over plain HTTP an
   attacker on the same WiFi could swap the APK *and* the checksum meant to
   vouch for it, since both travel together.
2. **A SHA-256 checksum, verified before install.** Computed as the bytes
   arrive rather than by re-reading the file afterwards. The common failure is
   a dropped connection on mobile data, not an attack, and this catches it.
3. **Android's own signature check.** An APK signed with a different key
   cannot replace an installed app, whatever this code does. That is the
   backstop, and it is the strongest guarantee in the chain — which is also why
   losing the keystore is unrecoverable.

The native side is about sixty lines of Kotlin in `MainActivity.kt` rather than
a plugin. An unmaintained package on the path that installs APKs is a poor
trade, and it keeps the dependency count — and the APK — smaller.

Nothing installs silently. The app downloads and verifies; Android shows its
own installer and its own warnings, and the user decides. The app warns them
that warning is coming, because a user who expects it continues and a user who
is surprised by it abandons the install.

## Backups are the event log, not the database

Every table in this app is a projection of the event log, so the log is what
gets exported. It is smaller, it survives schema changes, and — because
applying an event is idempotent by id — it can be *merged* rather than only
restored.

That last property is family sync. Export on one phone, send the file over
WhatsApp, restore on another: their entries fold into yours, anything both
already had is skipped, and no server, account or hosting is involved. Import
the same file twice and nothing happens the second time.

It is manual, and that is the honest limit. Nothing syncs until someone sends a
file. Automatic sync needs something in the middle both phones can reach, which
is a different decision from "no cloud" and has not been made.

The file is AES-256-GCM with a PBKDF2-stretched passphrase (100,000 rounds).
GCM authenticates as well as encrypts, so a truncated download or a tampered
file fails loudly instead of restoring corrupted entries into a ledger. The
consequence worth stating plainly: **a lost password means a lost backup.**
There is no account to recover through and nothing is stored anywhere else.

## What the privacy features actually protect

The research behind this app found two things that shape this: women described
borrowing from relatives as humiliating, and phones in these households are
often shared rather than owned. So the threat is someone standing next to you,
not a forensic analyst.

- **Hide amounts** replaces every figure with fixed-width dots — fixed width so
  the length of the dots does not leak the size of the number. It is one tap
  from the home screen, because its entire use is the moment someone walks over.
- **The curtain** covers the app whenever it leaves the foreground, so the
  Android recents screenshot shows a logo rather than a balance.
- **Re-locking** asks for the PIN again after 30 seconds away. Before this,
  unlocking lasted until the app was killed — handing over an already-open
  phone defeated the lock entirely.

All three sit in `MaterialApp.builder`, wrapping the navigator. As a route they
would only have covered the home screen, leaving Settings, Staff, Backup and
the keypad exposed.

## Why there is no voice input

It was in the original Stage 4 sketch and is deliberately not built.

Android's `SpeechRecognizer` sends audio to Google's servers on most devices.
The settings screen of this app tells the user, in Urdu, that everything stays
on their phone and nothing is ever sent anywhere. Shipping voice input would
make that sentence false — and it is the sentence the whole design rests on.

It is also third-party ML, which the project's zero-AI constraint rules out.
Genuinely on-device recognition, opt-in and clearly labelled, could be revisited
as its own decision.

## Peshgi, and why double-entry was worth it

The advance a maid or driver takes mid-month is the single most argued-about
number in a Pakistani household, because the whole arrangement is verbal —
handed over, remembered by both sides, disputed on payday.

Double-entry settles it with no special-case code at all. An advance debits the
person's advance account (an asset — the household is owed work) and credits
cash. Nothing is an expense yet. When salary is paid, one three-line entry posts
the full salary as expense, credits the advance account by whatever this month
can cover, and only the remainder leaves the cash box. Anything beyond the
month's pay simply stays on the books and carries forward.

Nobody has to remember to subtract anything. That is the entire reason Stage 0
insisted every entry balance to zero.

Two rules the calculation follows deliberately:

- **Unmarked days are paid.** An empty register is the household failing to fill
  it in, not evidence anyone stayed home. Defaulting the other way would dock a
  worker's pay for someone else's forgetfulness.
- **Nothing is applied silently.** The working is shown before anything is
  recorded, and it is on the receipt too. A wrong deduction from a domestic
  worker's wage is not an error this app should be able to make on its own.

## Bill estimates are estimates

The slab tables in `domain/tariffs.dart` were taken from published 2026 figures
and **will go stale** — NEPRA revises them without warning. The screen says so,
and every total is labelled an estimate.

FCA, quarterly adjustment, GST and meter rent are entered by the user rather
than guessed, because they are printed on last month's bill and cannot be
derived. Folding them into a blended per-unit rate is exactly how estimates end
up wrong by thousands.

The tests cover the *band arithmetic*, which stays true whatever the rates
become: each band is charged separately, and 150 units is not 150 × the top
rate.

## Receipts are Roman Urdu

A PDF has to carry its own font, and Urdu script needs an embedded Nastaliq face
plus right-to-left shaping — about a megabyte for a document most people glance
at once. Roman Urdu reads naturally to the same audience and is what a
handwritten khata receipt usually looks like anyway.

Sharing goes through Android's own share sheet. The app never asks for
contacts, never talks to WhatsApp, and does not know where the file ends up.
Note that WhatsApp drops the accompanying message and keeps only the
attachment, so everything that matters is printed on the page.

## Why there are no push notifications

Reminders surface as cards at the top of the home screen, not as OS
notifications, and that is a decision rather than an omission.

Scheduled alarms are killed aggressively by the battery managers shipped on
exactly the budget phones this app targets — Vivo's Funtouch, MIUI, ColorOS.
A notification is therefore a promise the OS may quietly break, and a rent
reminder that silently never fires is worse than no reminder at all. A card on
a screen the user already opens cannot be dropped by anyone.

It also keeps three permissions, a native dependency, a manifest full of alarm
and boot receivers, and roughly a megabyte of download.
If OS notifications are added later, they belong *on top of* this due-detection
logic as a best-effort nudge, never as the only path.

## The language rule

Roman Urdu is the default and leads every picker — it is what most people in
Pakistan already read and type on a phone, so it asks nothing of a new user.
Urdu script is one tap away. English is an option, not the baseline. This is not a localisation afterthought: for the household this is
built for, English on a money screen is friction rather than clarity, so the
app is designed in Urdu and translated outward.

Strings live in `lib/src/ui/strings.dart`, all three languages side by side, so
wording can be tuned with real users without hunting through files. Amounts stay
in Latin digits in every language — that is how every utility bill, bank slip
and price tag in Pakistan writes money.

**Font.** Flutter ships no Urdu glyphs and falls back to the device font, which
on most Android builds is Naskh rather than the Nastaliq an Urdu reader expects.
It is legible everywhere and costs nothing, which is why it is the default. To
upgrade, drop `NotoNastaliqUrdu-Regular.ttf` into `assets/fonts/`, declare it in
`pubspec.yaml`, and set `AppTheme.urduFontFamily`. It looks considerably better
and costs roughly a megabyte on an 18 MB download — a call worth
making with real users in front of it.

## What is here

```
lib/
  main.dart                       boots the engine, then the app
  src/
    engine.dart                   assembles database + clock + repository
    dev_home.dart                 engine check, reachable from settings
    security/
      pin_service.dart            PBKDF2-hashed screen lock
    ui/
      app.dart                    root widget, RTL, onboarding/lock gate
      app_scope.dart              engine + settings down the tree
      strings.dart                Urdu / Roman Urdu / English
      theme.dart                  colours, type, category palette
      category_icons.dart         iconKey -> icon
      widgets/                    money text, keypad, viewport-filling scroll
      screens/                    home, add entry, PIN, onboarding, settings
    core/
      money.dart                  integer paisa, South Asian digit grouping
      hlc.dart                    hybrid logical clock
      ulid.dart                   time-sortable ids
    data/
      tables.dart                 schema
      database.dart               drift database, migration, indexes
      connection.dart             opens SQLite on a background isolate
    domain/
      account_type.dart           asset / liability / income / expense / equity
      chart_of_accounts.dart      seeded Pakistani household categories
      ledger_event.dart           the event envelope
      models.dart                 drafts, read models, validation errors
      ledger_repository.dart      the only thing that writes
test/
  engine_test.dart                pure-logic tests, no device needed
```

## Four decisions everything else rests on

**Money is an integer, never a double.** Amounts are whole paisa. Binary
floating point cannot represent `0.1` exactly, and a household ledger that is
off by a hundredth of a rupee is one the user stops believing. Decimals appear
only in `Money.format()`, at the moment of display.

**Every entry is double-entry and must balance.** Two lines minimum, summing to
zero. This is not bookkeeping ceremony — it is what makes a peshgi work without
special-case code. Give Nasreen Rs 5,000 advance, pay her Rs 12,000 salary
later, and the advance nets itself off automatically because the accounts do
the arithmetic. `DraftEntry.validate()` refuses anything that does not balance.

**Nothing is ever deleted.** Entries are voided, not removed; accounts are
archived, not dropped. History that can disappear is history two phones can
silently disagree about after a sync — and a household arguing about a salary
needs the original record intact.

**Every write is an event first.** `LedgerRepository.applyEvent` is the single
chokepoint: it appends to the log and updates the tables in one transaction,
and it is idempotent by event id. When Stage 4 adds family sync, a remote event
takes that same path. There is no second write path that can drift out of step.
`ingestRemoteEvents` and `exportEvents` are already there, unused.

The HLC exists for the same reason. Cheap phones have clocks that get set by
hand and jump when network time arrives; ordering events by `DateTime.now()`
would eventually place a later edit before an earlier one. Retrofitting causal
ordering onto a ledger already written with naive timestamps means rewriting
history, so it is here from the start even though nothing syncs yet.

## Setup

Dependencies and code generation are run by hand:

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The second command writes `lib/src/data/database.g.dart`. Until it runs, the
analyser reports `AccountRow` and friends as undefined — that is expected, not
a mistake. Re-run it after any change to `tables.dart`.

```
flutter test                       # pure logic, ~1 second, no phone
flutter run -d <device>            # engine self-check on a real phone
```

The dev screen has a **Run self-check** button that verifies the invariants on
the device: unbalanced entries are refused, digits group as `1,23,45,678`,
typed input survives commas and Urdu digits, categories are seeded, and voiding
leaves balances untouched.

## Notes for later stages

- Web and desktop targets are not set up. drift on web needs a WASM SQLite
  worker, which is real extra work for a target this app does not ship to.
  Android is the platform; test on the phone.
- Seeded account ids derive from their slug (`sys.expense.groceries`), so two
  phones in one household independently create the *same* id for Groceries and
  merge cleanly instead of producing duplicate categories.
- `sqlite3_flutter_libs` bundles a modern SQLite rather than trusting the one
  in old Android builds. It costs roughly 1.7 MB, and is the only dependency
  in the APK large enough to be worth naming — see RELEASE.md on size.
