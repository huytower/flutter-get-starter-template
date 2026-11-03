# CI/CD Setup Guide (Pro Version)

This guide explains how to set up the automated CI/CD pipeline for this modular Flutter project using **Melos 8.10.0**, **Fastlane**, and **GitHub Actions**.

## Overview

The CI/CD pipeline automatically:

- **Validates**: Runs Linting (`melos run analyze`) and Unit Tests (`melos run test`) across all 12 modules using **Melos 8.10.0**.
- **Android**:
  - Builds Release APK and distributes to **Firebase App Distribution** (for internal testers/QA).
  - Builds Release AAB and uploads directly to **Google Play Console (Alpha / Closed Testing track)** via Fastlane `upload_to_play_store`.
  - Automatically auto-increments build numbers (`25 + github.run_number`).
- **iOS**:
  - Fetches the latest build number from TestFlight via `latest_testflight_build_number` and auto-increments dynamically (`latest + 1`).
  - Auto-imports the `.p12` Distribution Certificate and downloads the App Store Provisioning Profile.
  - Builds Release IPA (Gym) with automatic signing (`signingStyle: "automatic"`, `teamID: "46KM345YTJ"`) and uploads directly to **TestFlight** (Pilot).

## Prerequisites

1. **GitHub Repository** with Actions enabled.
2. **Firebase Project** for Android testing and Firebase App Distribution.
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
| `KEYSTORE_PASSWORD`            | Password for the keystore                     | e.g., `!Cc121212`                                      |
| `KEY_PASSWORD`                 | Password for the key                          | e.g., `!Cc121212`                                      |
| `KEY_ALIAS`                    | Alias of the key in keystore                  | e.g., `release`                                        |
| `FIREBASE_APP_ID`              | Android App ID from Firebase                  | Firebase Console > Project Settings                   |
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

### Jobs & Auto-versioning:

1. **Quality Check**: Runs `melos run analyze` and `melos run test`. Must pass clean before deployments start.
2. **Android Distribute**:
   - Auto-calculates build number: `25 + github.run_number`.
   - Builds Release APK and uploads to **Firebase App Distribution**.
   - Builds Release AAB and uploads directly to **Google Play Console (Alpha track)** via `upload_to_play_store`.
3. **iOS Distribute**:
   - Queries App Store Connect for the latest TestFlight build number and auto-increments (`latest + 1`).
   - Imports `.p12` certificate into a temporary Keychain (`build.keychain`).
   - Downloads App Store Provisioning Profile (`get_provisioning_profile`).
   - Archives and exports IPA (Gym) with `signingStyle: "automatic"` and `teamID: "46KM345YTJ"`.
   - Uploads IPA directly to **TestFlight** (Pilot).

---

## Troubleshooting

### Android Build & Memory

- **Java Heap Space Error**: `org.gradle.jvmargs=-Xmx4096m` and `kotlin.daemon.jvmargs=-Xmx2048m` are configured in `android/gradle.properties`. In CI, `GRADLE_OPTS` is passed automatically.
- **`25.0.2` Local JDK Error**: If local Android Studio shows `java.lang.IllegalArgumentException: 25.0.2`, set **Gradle JDK** in Android Studio Settings to **JDK 21** (`corretto-21`), or set system `JAVA_HOME=C:\Users\Admin\.jdks\corretto-21.0.12.1` (without trailing `\bin`).

### iOS TestFlight & Signing

- **Duplicate Build Version Error**: Solved automatically by `latest_testflight_build_number` in `Fastfile` which auto-increments the build version past any previously uploaded version on TestFlight.
- **Export Compliance**: `<key>ITSAppUsesNonExemptEncryption</key><false/>` is set in `ios/Runner/Info.plist` to automatically bypass export compliance prompts on App Store Connect.

### Local Command Testing

```bash
# Android - Firebase App Distribution
cd android && bundle exec fastlane distribute_firebase flavor:prod

# Android - Google Play Console Alpha Track
cd android && bundle exec fastlane build_release flavor:prod

# iOS - TestFlight
cd ios && bundle exec fastlane beta flavor:prod
```
