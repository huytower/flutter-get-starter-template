# Upgrade Flutter projects

Docs. detail that MUST consider to upgrade these sections, for all sides :

```
    - flutter
    - android
    - iOs
```

## Flutter side

<br />
**MUST do these steps** since `their build|run system` is `linking very tight`

<br />
1. Update `all latest library & sdk` version, included :

```
    - flutter sdk
    - 3rd-party lib
```

Run command line :

- `brew upgrade` : update related 3rd sdk

- `flutter upgrade` : to upgrade to latest version

**Refs.**
<br />

- [Release notes](https://docs.flutter.dev/development/tools/sdk/release-notes)
  <br />
- [pub.dev](https://pub.dev/)
  <br />
- [fvm 3rd lib for config different flutter sdk versions](https://pub.dev/packages/fvm)

<br />
2. **RECOMMEND** `minimum support dart sdk` is :

```
    environment:
        sdk: '>=3.9.0'
        flutter: ">=3.35.0"
```

**Refs.**
<br />

- [Release notes](https://dart.dev/get-dart/archive)

## Android side

<br />
**MUST do these steps** since `their build|run system` is `linking very tight`

<br />
1. Upgrade `Developer tools`

**Refs.**
<br />

- [Release notes](https://androidstudio.googleblog.com/)

<br />
2. Upgrade `openjdk` version (NOT RECOMMEND using `jdk` version)
<br />
Notice that `openjdk` supports for `M1` chip very well.

**Refs.**
<br />

- [Release notes](https://openjdk.org/projects/jdk-updates/)
  <br />
- [How to install openjdk via brew command line](https://formulae.brew.sh/formula/openjdk)

<br />
3. Upgrade `gradle` version (`building system`)

<br />
- Delete old `gradle` version

<br />
- Use `stable gradle` version,
<br />
define in file path : `/${prj_name}/android/gradle/wrapper/gradle-wrapper.properties`

```
    ex.
    distributionUrl=https\://services.gradle.org/distributions/gradle-7.5.1-all.zip
```

**Refs.**
<br />

- [Release notes](https://gradle.org/releases/)

<br />
- Use `corresponding build gradle` version,
<br />
define in file path : `/${prj_name}/android/app/build.gradle`

```
    ex.
    classpath 'com.android.tools.build:gradle:8.10.1'
```

**Refs.**
<br />

- [Release notes](https://developer.android.com/studio/releases/gradle-plugin)

<br />
4. Upgrade `stable kotlin` version 

```
    ex.
    ext.kotlin_version = '2.1.0'
```

**Refs.**
<br />

- [Release notes](https://kotlinlang.org/docs/releases.html)

<br />
5. Upgrade `android sdk` version,
<br />
in the file path : `/${prj_name}/android/app/build.gradle`

Use **RECOMMEND** `sdk` version

```
minSdkVersion 19    - Android 4.4
```

Update `latest sdk` version if existed

```
targetSdkVersion 37
compileSdkVersion 37
```

![](/doc/os_usage/user_usage_android.jpg)

**Refs.**
<br />

- [Android Distribution](https://apilevels.com/)

## iOs side

<br />
**MUST do these steps** since `their build|run system` is `linking very tight`

<br />
1. Upgrade `Developer tools`

**Refs.**
<br />

- [Release notes](https://developer.apple.com/documentation/xcode-release-notes)

<br />
2. Upgrade `cocoapods` `building system`

**Refs.**
<br />

- [Release notes](https://github.com/CocoaPods/CocoaPods/releases)

<br />
3. Upgrade `Podfile` os
<br />
in the file path : `/${prj_name}/ios/Podfile`

<br />
**RECOMMEND** `minimum support ios` version is :

```
    ex.
    platform :ios, '12.0'
```

![](/doc/os_usage/user_usage_ios.png)

**Refs.**
<br />

- [iOs Distribution](https://developer.apple.com/support/app-store/)

<br />
4. Define|Request `Info.plist` `permission reason` exactly

![](/doc/submit_app_store/define_permisison_reason.png)