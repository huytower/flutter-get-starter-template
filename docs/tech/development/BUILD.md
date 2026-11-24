# Build and release

The normal release path is CI: a push to `qltc` builds and uploads both apps (Android to Google Play alpha, iOS to
TestFlight). See `docs/CICD_SETUP.md`. This page covers versioning and building by hand when CI is not an option.

Only the `prod` flavor exists. Every build needs `env/prod.json` (copy of `env/prod.example.json`, see
`CONFIG_ENV.md`) and the Firebase config files (`melos run setup:firebase`).

## Versioning

`pubspec.yaml` (`version: <name>+<code>`, e.g. `1.0.0+25`) is the source of truth for the version **name** on
both platforms and for the build **number** of local builds.

| Build path | Build number used |
|---|---|
| Local, Android (CLI, Android Studio) | the `+<code>` in `pubspec.yaml`. `android/app/build.gradle.kts` reads it, so every entry point agrees. Never edit `flutter.versionCode` in `android/local.properties` by hand |
| CI or Fastlane, Android | `25 + BUILD_NUMBER` (CI passes `github.run_number`), at least 26. The `BUILD_NUMBER` environment variable wins over `pubspec.yaml` |
| CI or Fastlane, iOS | latest TestFlight build number + 1 (falls back to `BUILD_NUMBER` only when TestFlight has none) |

Google Play rejects a `versionCode` that is not higher than every code uploaded before
(`Version code X has already been used`), even if that release was never published.

## Android, by hand

1. Bump `version:` in `pubspec.yaml`.
2. Check that the release keystore matches the upload key in Play Console (Setup -> App signing -> Upload key
   certificate), otherwise the upload is rejected:
   `keytool -list -v -keystore android/app/release.jks -alias release`
3. Build the bundle:
   `flutter build appbundle --release --flavor prod --dart-define-from-file=env/prod.json`
   -> `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
4. Check the version before uploading:
   `Select-String build/app/intermediates/manifest_merge_blame_file/prodRelease/processProdReleaseMainManifest/manifest-merger-blame-prod-release-report.txt -Pattern "versionCode|versionName"`
5. In Google Play Console, create a release and upload `app-prod-release.aab`.

Or run the same lane CI uses (builds and uploads to the alpha track):
`cd android && bundle exec fastlane build_release flavor:prod`

## iOS, by hand (macOS)

Run the lane CI uses. It picks the build number from TestFlight, signs with the App Store profile and uploads to
TestFlight; it needs the App Store Connect API key and certificate described in `docs/CICD_SETUP.md`:

`cd ios && bundle exec fastlane beta flavor:prod`

Without Fastlane: bump `version:` in `pubspec.yaml`, run
`flutter build ipa --release --flavor prod --dart-define-from-file=env/prod.json --build-number=<next TestFlight number>`,
then upload the IPA with Xcode Organizer or Transporter and check it in App Store Connect -> TestFlight.
