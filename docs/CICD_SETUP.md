# CI/CD Setup Guide (Pro Version)

This guide explains how to set up the automated CI/CD pipeline for this modular Flutter project using **Melos**, *
*Fastlane**, and **GitHub Actions**.

## Overview

The CI/CD pipeline automatically:

- **Validates**: Runs Linting and Tests across all modules using **Melos**.
- **Android**: Builds AAB and distributes to **Firebase App Distribution**.
- **iOS**: Builds IPA (Gym) and distributes to **TestFlight** (Pilot) using App Store Connect API Keys.

## Prerequisites

1. **GitHub Repository** with Actions enabled.
2. **Firebase Project** for Android testing.
3. **Apple Developer Program** membership for TestFlight.
4. **Melos** installed locally for management (`dart pub global activate melos`).
5. **Submodules**: This project uses submodules (e.g., `cc_core_sdk`). Ensure they are initialized locally (
   `git submodule update --init --recursive`).
``````
---

## Required GitHub Secrets

Configure these secrets in `Settings > Secrets and variables > Actions`:

### 1. Android Signing & Firebase

| Secret Name                    | Description                                   |
|:-------------------------------|:----------------------------------------------|
| `KEYSTORE_BASE64`              | Base64-encoded `.jks` file                    |
| `KEYSTORE_PASSWORD`            | Password for the keystore                     |
| `KEY_PASSWORD`                 | Password for the key                          |
| `KEY_ALIAS`                    | Alias of the key in keystore                  |
| `FIREBASE_APP_ID`              | Android App ID from Firebase                  |
| `FIREBASE_SERVICE_CREDENTIALS` | Full Service Account JSON string for Firebase |
| `FIREBASE_PROJECT_ID`          | Project ID (e.g., `mobile-flutter-template`)  |
| `GOOGLE_API_KEY_ANDROID`       | Google API Key for Android services           |
| `GOOGLE_API_KEY_IOS`           | Google API Key for iOS services               |

### 2. iOS & TestFlight (App Store Connect API)

| Secret Name                     | Description              | How to Get                       |
|:--------------------------------|:-------------------------|:---------------------------------|
| `APP_STORE_CONNECT_KEY_ID`      | 10-char Key ID           | App Store Connect > Users > Keys |
| `APP_STORE_CONNECT_ISSUER_ID`   | Issuer ID UUID           | App Store Connect > Users > Keys |
| `APP_STORE_CONNECT_KEY_CONTENT` | Base64 encoded `.p8` key | `base64 AuthKey_XXX.p8`          |

---

## Setup Steps

### 1. Workspace Management (Melos)

This project is modular and uses **Flutter Workspaces**. Melos scripts are defined in `pubspec.yaml`.
Locally, always run:

```bash
melos bootstrap
```

This links all packages (`cc_sdk`, `message`, `data`, etc.) and runs `pub get` everywhere.

### 2. Android Keystore

Generate a keystore and encode it for GitHub:

```powershell
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("your-keystore.jks")) | Set-Clipboard
```

Paste this into the `KEYSTORE_BASE64` secret.

### 3. iOS Fastlane Setup

1. Go to [App Store Connect > Users and Access > Integrations](https://appstoreconnect.apple.com/access/api).
2. Generate an **App Store Connect API Key** (Admin or App Manager access).
3. Download the `.p8` file, encode it to base64, and add to GitHub Secrets.
4. Update `ios/fastlane/Appfile` with your `team_id` and `itc_team_id`.

---

## Environment & Secret Injection

To prevent sensitive keys from leaking in public repositories, this project uses an automated injection system.

### How it works:

1. **Templates**: Native config files (`google-services.json`, `GoogleService-Info.plist`) are stored as `.template`
   files with placeholders like `{{GOOGLE_API_KEY_ANDROID}}`.
2. **Environment Files**: `.env` files in `env/` use placeholders like `YOUR_ANDROID_KEY_HERE`.
3. **CI Injection**: The GitHub Action (`flutter-setup`) automatically:
    - Creates missing `.env` and native files from their templates.
    - Uses `perl` to swap placeholders with real values from **GitHub Secrets**.
4. **Local Development**: Run `melos run setup:firebase` to generate local config files from templates. You can then
   manually fill in your local `.env` files (which are ignored by Git).

---

## Workflow Structure

The pipeline is defined in `.github/workflows/firebase-app-distribution.yml` and uses a composite action for speed.

### Jobs:

1. **Quality Check**: Runs `melos run analyze` and `melos run test`. **Must pass** for any build to start.
2. **Android Distribute**: Triggered on push to `main` or manual dispatch. Uses Fastlane `distribute_firebase`.
3. **iOS Distribute**: Triggered on push to `main` or manual dispatch. Uses Fastlane `beta` (Gym + Pilot).
4. **PR Smoke Test**: Runs on Pull Requests to ensure the app compiles (`uat` flavor).

### Manual Deployment

1. Go to **Actions** tab.
2. Select **CI/CD Pipeline**.
3. Click **Run workflow**, choose your branch and **Flavor** (uat, prod).

---

## Troubleshooting

### Submodule Issues

- **Pulling Latest SDK**: To get the latest changes from the remote SDK repository and merge them into your local submodule:
  ```bash
  git submodule update --remote --merge
  ```
- **Missing/Deleted Files**: If files inside `shared/cc_core_sdk` appear as "deleted" or are missing after a pull, run:
  ```bash
  git submodule update --init --recursive --force
  ```
- **"Embedded Repository" Warning**: If `git status` shows individual files inside a submodule, the boundary is broken. Fix it with:
  ```bash
  git rm -r --cached shared/cc_core_sdk
  git add shared/cc_core_sdk
  ```
- **Out of Sync CI**: If the CI fails with "not our ref", ensure all local commits in `cc_core_sdk` have been pushed to its remote BEFORE pushing the main project.

### Melos Issues

- If scripts aren't found, check the `melos:` section in the root `pubspec.yaml`.
- To run code gen everywhere: `melos run gen`.

### Fastlane Errors

- **Android**: Ensure `FIREBASE_SERVICE_CREDENTIALS` is the full JSON string. The CI converts this to a file
  automatically.
- **iOS**: If upload fails, check if the `APP_STORE_CONNECT_KEY_CONTENT` base64 string includes the "BEGIN/END"
  headers (it should).

### Local Testing

You can run the exact same logic as the CI locally:

```bash
# Android
cd android && bundle exec fastlane distribute_firebase flavor:uat

# iOS
cd ios && bundle exec fastlane beta flavor:uat
```

---

## Maintenance

- **Flutter Version**: Update `FLUTTER_VERSION` in the `.yml` file.
- **Tools**: The setup logic is shared in `.github/actions/flutter-setup/action.yml`.
- **Linting**: Static analysis rules are managed in the root `analysis_options.yaml`. Generated files are excluded by
  default to avoid CI noise.
