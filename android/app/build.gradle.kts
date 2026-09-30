import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("com.google.firebase.firebase-perf")
}

// Version SSOT: pubspec.yaml (`version: 1.0.0+2`).
//
// `flutter.versionCode` in android/local.properties is only rewritten by the
// Flutter CLI, so it goes stale when the bundle is built from Android Studio
// and would silently ship an already-used versionCode to Play. Reading the
// manifest here keeps every entry point (CLI, Android Studio, fastlane) on the
// same version. For AAB the artifact also uses an override of
// `abiCode * 1000 + versionCode`, so only the plain versionCode reaches Play.
fun readPubspecVersion(): Pair<String, String> {
    val manifest = rootProject.file("../pubspec.yaml")
    check(manifest.exists()) { "Cannot read app version, missing manifest: $manifest" }
    val raw = manifest.readLines()
        .firstOrNull { it.trimStart().startsWith("version:") }
        ?.substringAfter("version:")
        ?.trim()
    val parts = raw.orEmpty().split("+").map { it.trim() }
    check(parts.size == 2) {
        "pubspec.yaml `version:` must be <name>+<code> (e.g. 1.0.0+2), found: $raw"
    }
    return parts[0] to parts[1]
}

val (pubspecVersionName, pubspecVersionCode) = readPubspecVersion()

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "vn.sosachxin.finance"
    compileSdk = 37
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        // Required by flutter_local_notifications 10+ (scheduled/local
        // reminders) even on our minSdk 28 — the plugin's own Android code
        // needs the desugared JDK libs to compile. See coreLibraryDesugaring
        // dependency below; doesn't affect release build correctness, only
        // adds the desugared library at compile time.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    sourceSets {
        getByName("main").java.srcDirs("core/main/common")
    }

    defaultConfig {
        applicationId = "vn.sosachxin.finance"
        minSdk = 28
        targetSdk = 37
        versionCode = pubspecVersionCode.toInt()
        versionName = pubspecVersionName
        // Enabling multidex support.
        multiDexEnabled = true
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Use release signing config if available, otherwise debug
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("uat") {
            dimension = "environment"
            applicationIdSuffix = ".uat"
            versionNameSuffix = "-uat"
        }
        create("prod") {
            dimension = "environment"
        }
    }

    lint {
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.constraintlayout:constraintlayout:2.2.1")
    implementation("com.airbnb.android:lottie:6.7.1")
    implementation(platform("com.google.firebase:firebase-bom:34.17.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")
    implementation("com.google.firebase:firebase-appcheck-playintegrity")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}