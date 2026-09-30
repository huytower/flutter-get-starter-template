# Project

#### Build||Release

##### IOS - Build testflight

<br />
a. In `appConfigBase.dart`, increase internal version before build

     Ex.
     int versionIOS = 115;
     int versionAndroid = 115;

<br />
b. Run `flutter build ios`

```
Building ${prj_name} for device (ios-release)...
Automatically signing iOS for device deployment using specified development team in Xcode project: 2G394G9EZU
Running pod install...                                           1,479ms
Running Xcode build...                                                  
 └─Compiling, linking and signing...                         4.9s
Xcode build done.                                           64.2s
Built /Users/macmini/Desktop/${prj_name}/build/ios/iphoneos/Runner.app.
```

<br />
c. Open Xcode tool, 

     - in `Runner -> Tab General` : Increase version name & version code 
     - choose `Product -> Archive -> Distribute` App new version

<br />
d. Click `Next` -> `Upload`
<br />
e. Visit `App Store Connect -> Testflight`, to see new version

##### Android

<br />
a. Bump the version in `pubspec.yaml` (`version: 1.0.0+<code>`). This is the single source of truth:
   `android/app/build.gradle.kts` parses it, so every build path (Flutter CLI, Android Studio, fastlane)
   produces the same `versionCode`/`versionName`. `flutter.versionCode` in `android/local.properties` is
   only rewritten by the CLI and must never be edited by hand.
<br />
b. Check the release keystore matches the upload key registered in Play Console
   (Setup -> App signing -> Upload key certificate), otherwise the upload is rejected:
   `keytool -list -v -keystore android/app/release.jks -alias release`
<br />
c. Build the bundle: `flutter build appbundle --release --flavor prod` (or `--flavor uat`)
   → `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
<br />
d. Verify the produced version before uploading:
   `Select-String build/app/intermediates/manifest_merge_blame_file/prodRelease/processProdReleaseMainManifest/manifest-merger-blame-prod-release-report.txt -Pattern "versionCode|versionName"`
   Play rejects an upload whose `versionCode` is not strictly greater than every code ever uploaded for the
   app, with `Version code X has already been used`, even if the previous release was never published.
<br />
e. Open `Google Play Console`, create a release, and upload `app-prod-release.aab`

#### Docs. || Refs.

<br />
1. Reference

[Project Base document]()

<br />
2. Account :

   ```
   ```