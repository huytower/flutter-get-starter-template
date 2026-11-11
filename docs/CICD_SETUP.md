# CI/CD Setup Guide (Pro Version)

This guide explains how to set up the automated CI/CD pipeline for this modular Flutter project using **Melos 8.10.0**, **Fastlane**, and **GitHub Actions**.

## Overview

The CI/CD pipeline automatically:

- **Validates**: Runs Linting (`melos run analyze`) and Unit Tests (`melos run test`) across all workspace packages using **Melos 8.10.0**.
- **Android**:
  - Builds Release AAB and uploads directly to **Google Play Console (Alpha / Closed Testing track)** via Fastlane `upload_to_play_store`.
  - Automatically auto-increments build numbers (`25 + github.run_number`).
- **iOS**:
  - Fetches the latest build number from TestFlight via `latest_testflight_build_number` and auto-increments dynamically (`latest + 1`).
  - Auto-imports the `.p12` Distribution Certificate and downloads the App Store Provisioning Profile.
  - Builds Release IPA (Gym) with **manual** signing using the freshly downloaded App Store profile (`signingStyle: "manual"`, `teamID: "46KM345YTJ"`) and uploads directly to **TestFlight** (Pilot).

## Prerequisites

1. **GitHub Repository** with Actions enabled.
2. **Firebase Project** (Auth, Firestore, Crashlytics; its service account is also used for the Google Play upload).
3. **Google Play Console Account** with Service Account access for Alpha track distribution.
4. **Apple Developer Program Membership** with App Store Connect API Key and Distribution Certificate (`.p12`).
5. **Melos 8.10.0** installed locally (`dart pub global activate melos ^8.10.0`).
6. **Submodules**: This project uses submodules (e.g., `shared/cc_core_sdk`). Ensure they are initialized (`git submodule update --init --recursive`).

---

## Required GitHub Secrets

Configure these secrets in `Settings > Secrets and variables > Actions`:

### 1. Android Signing & Firebase / Google Play

| Secret Name                    | Description                                   | How to Get / Format                                    |
|:-------------------------------|:----------------------------------------------|:-------------------------------------------------------|
| `KEYSTORE_BASE64`              | Base64-encoded `.jks` file                    | `[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.jks")) \| Set-Clipboard` |
| `KEYSTORE_PASSWORD`            | Password for the keystore                     | Choose a strong, unique password (never commit it)     |
| `KEY_PASSWORD`                 | Password for the key                          | Choose a strong, unique password (never commit it)    |
| `KEY_ALIAS`                    | Alias of the key in keystore                  | e.g., `release`                                        |
| `FIREBASE_SERVICE_CREDENTIALS` | Full Service Account JSON string for GCP      | Firebase Console > Service Accounts > Generate Key     |
| `FIREBASE_PROJECT_ID`          | Project ID (e.g., `sosachxin`)                | Firebase Console > Project Settings                   |
| `GOOGLE_API_KEY_ANDROID`       | Google API Key for Android services           | Google Cloud Console / Firebase                       |
| `GOOGLE_API_KEY_IOS`           | Google API Key for iOS services               | Google Cloud Console / Firebase                       |

> [!NOTE]
> `FIREBASE_SERVICE_CREDENTIALS` is also used by Fastlane `upload_to_play_store` to upload AABs to Google Play Console (Alpha track). Ensure the Service Account email is invited to Google Play Console under **Users and permissions** with **Release to testing tracks** permissions.

### 2. iOS & TestFlight (App Store Connect & Signing Certificate)

| Secret Name                     | Description                                    | How to Get / Format                                    |
|:--------------------------------|:-----------------------------------------------|:-------------------------------------------------------|
| `APP_STORE_CONNECT_KEY_ID`      | 10-char Key ID                                 | App Store Connect > Users > Keys                       |
| `APP_STORE_CONNECT_ISSUER_ID`   | Issuer ID UUID                                 | App Store Connect > Users > Keys                       |
| `APP_STORE_CONNECT_KEY_CONTENT` | Raw or Base64 encoded `.p8` key                | Original `.p8` key content                             |
| `APPLE_CERTIFICATE_BASE64`      | Base64-encoded `.p12` Distribution Certificate | Export `.p12` from Mac Keychain > Convert to Base64    |
| `APPLE_CERTIFICATE_PASSWORD`    | Password for the `.p12` certificate            | Password set during `.p12` export from Mac Keychain   |

---

## Setup Steps

### 1. Workspace Management (Melos)

This project is a monorepo managed with **Melos 8.10.0**. Workspace scripts are defined in the root `pubspec.yaml` under `melos.scripts`.
Locally, run:

```bash
flutter pub get
melos bootstrap
```

### 2. Android Keystore & Credentials

Generate or convert your release keystore to Base64 for GitHub Secrets:

```powershell
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/release.jks")) | Set-Clipboard
```

Paste the clipboard output into the `KEYSTORE_BASE64` secret.

### 3. iOS Certificates & Provisioning

1. Go to [App Store Connect > Users and Access > Integrations](https://appstoreconnect.apple.com/access/api).
2. Generate an **App Store Connect API Key** (Admin or App Manager access) and paste its content into `APP_STORE_CONNECT_KEY_CONTENT`.
3. Open **Keychain Access** on Mac > Certificates > Export `Apple Distribution: Huy Tran Duc` as `dist_cert.p12`.
4. Convert `dist_cert.p12` to Base64:
   ```bash
   # macOS Terminal
   base64 -i dist_cert.p12 | pbcopy
   ```
   Or in PowerShell on Windows:
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("dist_cert.p12")) | Set-Clipboard
   ```
5. Paste the result into `APPLE_CERTIFICATE_BASE64` and set `APPLE_CERTIFICATE_PASSWORD`.

---

## Workflow Structure & Automation

The pipeline is defined in `.github/workflows/firebase-app-distribution.yml`.

### Triggers and safety

- Runs on push / pull request to `qltc`, or manually (`workflow_dispatch`). Changes that only touch `*.md` or
  `docs/**` are ignored.
- **A push to `qltc` is a release**: both distribute jobs run automatically after the quality gate. The distribute
  jobs use `environment: production`; in GitHub go to **Settings > Environments > production** and add *Required
  reviewers* so every release needs a manual approval.
- `concurrency` allows one pipeline per ref (PR runs are cancelled by newer pushes, release runs queue). Jobs have
  timeouts and the token is `contents: read`.
- The workflow runs `melos run gen` once and sets `SKIP_GEN=true`, so the Fastlane lanes do not repeat it. Running a
  lane locally (without `SKIP_GEN`) still generates code first.

### Jobs & Auto-versioning:

1. **Quality Check**: Runs `melos run analyze` and `melos run test`. Must pass clean before deployments start.
2. **Android Distribute** (fails if `FIREBASE_SERVICE_CREDENTIALS` is missing; it no longer skips the Play upload silently):
   - Auto-calculates build number: `25 + github.run_number`.
   - Builds Release AAB and uploads directly to **Google Play Console (Alpha track)** via `upload_to_play_store`.
3. **iOS Distribute**:
   - Queries App Store Connect for the latest TestFlight build number and auto-increments (`latest + 1`). If the query fails the lane stops immediately instead of guessing a number.
   - Imports `.p12` certificate into a temporary Keychain (`build.keychain`).
   - Downloads the App Store Provisioning Profile (`get_provisioning_profile`). Do **not** pass `cert_id` with the local keychain SHA-1: that parameter is the App Store Connect certificate ID, and a SHA-1 matches nothing ("No certificates for filter").
   - Archives and exports IPA (Gym) with `signingStyle: "manual"` and `teamID: "46KM345YTJ"`.
   - Uploads IPA directly to **TestFlight** (Pilot).

---

> **Firebase App Distribution was removed.** Android builds are delivered only through Google Play (alpha / closed
> testing). The `FIREBASE_APP_ID` secret is no longer used and can be deleted. Testers who are not on the Play
> testing list no longer receive builds.

## Troubleshooting

### Android Build & Memory

- **Java Heap Space Error**: `org.gradle.jvmargs=-Xmx4096m` and `kotlin.daemon.jvmargs=-Xmx2048m` are configured in `android/gradle.properties`. In CI, `GRADLE_OPTS` is passed automatically.
- **`25.0.2` Local JDK Error**: `android/gradle/gradle-daemon-jvm.properties` pins the Gradle daemon to Java 21, so Android Studio should use the JDK 21 toolchain automatically. If Android Studio still reports `java.lang.IllegalArgumentException: 25.0.2`, set **Gradle JDK** to **JDK 21** (`corretto-21`) and restart the Gradle daemon.

### iOS TestFlight & Signing

- **Single build**: the lane runs `flutter build ios --config-only` (no compile) and lets `gym` do the only real
  build. If an archive ever fails with missing Flutter settings, check that `ios/Flutter/Generated.xcconfig` was
  written by that step.

- **"Could not find a matching code signing identity for type 'AppStore'"** / **"No certificates for filter"**: caused by
  passing a local SHA-1 as `cert_id`. The Fastfile now lets `sigh` match profiles against the certificate imported
  into `build.keychain`. If it still fails, the `.p12` certificate is probably not registered (or was revoked) in the
  Apple Developer team — export a fresh Apple Distribution certificate and update `APPLE_CERTIFICATE_BASE64`.
- **Build/upload succeeds but a capability (e.g. Sign in with Apple) does not work in the release build**: the
  provisioning profile was generated before the capability was enabled on the App ID. A GitHub runner is a fresh
  VM (and the lane wipes `~/Library/MobileDevice/Provisioning Profiles`), so the stale copy lives on Apple's side,
  not in a CI cache. The `beta` lane now guards against it:
  1. After `get_provisioning_profile` it compares every key in `ios/Runner/RunnerRelease.entitlements` with the
     profile's `Entitlements`. If any is missing it regenerates the profile (`force: true`) from the App ID's
     current capabilities, and fails with a clear message if the App ID still does not grant it.
  2. After `gym` it reads the signed IPA (`codesign -d --entitlements`) and aborts **before** the TestFlight upload
     if a required entitlement is absent.
  If both checks pass but the feature still fails at runtime, the cause is not signing: check the iOS API key in
  `GOOGLE_API_KEY_IOS` (must be the key from the real `GoogleService-Info.plist`, with Identity Toolkit allowed for
  the bundle id) and the `[AppleSignInTrace]` logs.
- Use a strong `APPLE_CERTIFICATE_PASSWORD`; do not reuse the bundle id or other guessable text.

- **Duplicate Build Version Error**: Solved automatically by `latest_testflight_build_number` in `Fastfile` which auto-increments the build version past any previously uploaded version on TestFlight.
- **Export Compliance**: `<key>ITSAppUsesNonExemptEncryption</key><false/>` is set in `ios/Runner/Info.plist` to automatically bypass export compliance prompts on App Store Connect.

### Local Command Testing

```bash
# Android - Google Play Console Alpha Track
cd android && bundle exec fastlane build_release flavor:prod

# iOS - TestFlight
cd ios && bundle exec fastlane beta flavor:prod
```
