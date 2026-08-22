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

Both point at `example.invalid` on purpose, so a forgotten placeholder fails
loudly instead of quietly never finding an update.

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

The target is under 8 MB. If it is over, the levers in rough order of payoff:
drop `--split-per-abi` output to one ABI, remove an unused dependency, and
check that `isMinifyEnabled` is still on in `android/app/build.gradle.kts`.

### 4. Get the checksum

```
(Get-FileHash .\build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256).Hash.ToLower()
```

### 5. Publish

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
