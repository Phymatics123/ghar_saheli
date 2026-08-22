# Releasing Ghar Saheli

Everything here is done by hand, once. After that, shipping an update is three
commands and uploading two files.

---

## One-time setup

### 1. Create the signing key

Android identifies an app by its signature. **If this keystore is lost, no
future build can ever update an already-installed copy** — to every phone that
has the app, a differently-signed APK is a different app entirely. There is no
recovery, no reset, and no support line. Back it up somewhere you will still
have in five years.

From `android/app/`:

```
keytool -genkey -v -keystore ghar-saheli.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ghar-saheli
```

It asks for a password and some name/organisation fields. The fields are
cosmetic; the passwords are not.

### 2. Point Gradle at it

Copy `android/key.properties.example` to `android/key.properties` and fill in
the passwords and alias you just chose.

Both `key.properties` and `*.jks` are already gitignored. Keep it that way.

If `key.properties` is missing, release builds fall back to debug signing so
`flutter run --release` still works — but a debug-signed APK **cannot** be
distributed or updated over.

### 3. Set the two URLs

In `lib/src/services/update_service.dart`:

- `kUpdateManifestUrl` — where `latest.json` will live
- `kAppDownloadPageUrl` — the page new users are sent to

These are already set to the GitHub Releases repository
(`github.com/Phymatics123/ghar_saheli`), pinned to a single release tagged
**v1.0.0**.

**That tag is permanent, on purpose, and is not "the first version."** These
two URLs are compiled into every install and can never be changed after the
app has shipped — an already-installed copy has no way to be told a URL
changed. GitHub lets a release's attached files be replaced without touching
its tag, so `v1.0.0` is the fixed address `latest.json` and the current APK
always live at, however many real versions have shipped since. **Every**
release — v1.0.1, v2.0.0, whatever — uploads its `latest.json` and APK to
this same `v1.0.0` release, overwriting what was there. The version number
that actually matters to users lives in `pubspec.yaml` and inside
`latest.json`, not in the release tag.

Hosting can be anything that serves static files over HTTPS — GitHub Releases,
Firebase Hosting, a folder on a web server. There is no backend.

**The APK must be served over HTTPS.** The app refuses plain HTTP, because over
HTTP someone on the same WiFi could swap the APK *and* the checksum that is
meant to vouch for it.

---

## Shipping a build

### 1. Bump the version

In `pubspec.yaml`:

```yaml
version: 1.0.1+2
```

The part before `+` is the version name people see. The number after `+` is the
version code, and **it must increase every single release** — it is the only
thing the updater compares, and Android refuses to install a build whose code
is not higher than the installed one.

### 2. Build

```
flutter build apk --release
```

The APK lands in `build/app/outputs/flutter-apk/app-release.apk`.

For a smaller download, split by processor type:

```
flutter build apk --release --split-per-abi
```

Note on which one to ship: `flutter devices` reported the test phone as
`android-arm`, meaning 32-bit. An `arm64-v8a`-only APK would not install on it,
or on similar budget devices. `armeabi-v7a` runs on both 32- and 64-bit phones,
so a single `armeabi-v7a` build is the safest thing to distribute, at some cost
in performance on 64-bit hardware.

### 3. Check the size

```
ls -lh build/app/outputs/flutter-apk/
```

Expect roughly **18 MB** for the `armeabi-v7a` build. An earlier draft of this
file claimed a target under 8 MB; that was never achievable and has been
corrected.

Practically the whole APK is native code, and almost none of it is ours:

| | |
|---|---|
| `libflutter.so` | 8.1 MB — the Flutter engine. Fixed cost, identical in a hello-world app. |
| `libapp.so` | 7.6 MB — all our Dart, plus every package compiled in. |
| `libsqlite3.so` | 1.7 MB — the bundled modern SQLite. |
| everything else | under 1 MB — assets, Kotlin, resources, manifest. |

Native libraries are stored *uncompressed* in a modern APK, so these add up
almost exactly to the file size. The floor for any Flutter app on this ABI is
therefore ~10 MB before a line of app code exists, which is what made the old
target impossible.

If it ever needs to come down, the honest levers in order of payoff: drop the
`pdf` dependency (the largest single contributor to `libapp.so`, at the cost of
salary receipts), drop `sqlite3_flutter_libs` and trust the OS SQLite (saves
1.7 MB, at the cost of old-Android reliability), and confirm `isMinifyEnabled`
is still on in `android/app/build.gradle.kts`. None of these are worth doing
on current numbers — 18 MB is unremarkable next to WhatsApp's ~70 MB, and
users download it once.

### 4. Get the checksum

```
(Get-FileHash .\build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256).Hash.ToLower()
```

### 5. Publish

Every release, first and every one after it, is uploaded to the **same**
GitHub Release — the one tagged `v1.0.0` — because `kUpdateManifestUrl` is
compiled into already-installed copies and can never point anywhere else. Open
that release on GitHub and edit it (not "create new release"); a same-named
uploaded file replaces the old one.

Upload the APK, then upload a `latest.json` built from
`release/latest.json.example` with the new version code, name, URL, checksum
and size filled in.

Order matters: **upload the APK first.** If the manifest goes up first, every
phone that checks in the meantime tries to download a file that is not there
yet.

---

## Testing the updater

This is the one feature that cannot be tested from the IDE, and it has an
ordering dependency worth knowing before you start.

An OTA update replaces an installed app, and Android only permits that when
both are signed with the same key. The build currently on the test phone is
debug-signed, so:

1. Create the keystore (above).
2. Build a release APK at version code 1 and install it by hand
   (`flutter install --release`, or copy the APK across and tap it).
3. Bump to version code 2, build, upload it and a matching `latest.json`.
4. On the phone: Settings → ایپ اپ ڈیٹ → check.

Expect to be asked for the install permission the first time, and expect
Android to show its own warning about installing outside the Play Store. Both
are normal and the app explains them beforehand.

### If the release build crashes but debug works

The first suspect is R8, which strips unused code in release builds only. It
is a one-line test — set `isMinifyEnabled = false` in
`android/app/build.gradle.kts`, rebuild, and if the crash goes away the fix is
a keep rule in `android/app/proguard-rules.pro`, not disabling minification
permanently.

---

## Publishing an update, once set up

1. Bump `version:` in `pubspec.yaml`
2. `flutter build apk --release`
3. Upload the APK
4. Upload `latest.json` with the new version code, URL and checksum

Phones pick it up the next time someone opens the update screen.
