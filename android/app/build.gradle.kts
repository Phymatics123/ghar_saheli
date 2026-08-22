import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials, kept out of the repository.
//
// `key.properties` sits next to this file's parent (android/) and is listed in
// .gitignore. If it is missing — a fresh clone, or a machine that only ever
// builds debug — the release build falls back to debug signing rather than
// failing, so `flutter run --release` still works for testing.
//
// Losing the keystore this points at means no future build can ever update an
// already-installed app. Android identifies an app by its signature, so a
// replacement key is a different app to every phone that already has this one.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.gharsaheli.ghar_saheli"
    // Pinned rather than following `flutter.compileSdkVersion`, which resolves
    // to 34 here. `file_picker` pulls in `flutter_plugin_android_lifecycle`,
    // which now requires its dependents to compile against 36 or the build
    // fails outright.
    //
    // compileSdk only says which APIs the code may reference. Runtime
    // behaviour is governed by targetSdk, and which phones can install the app
    // by minSdk — both left as Flutter sets them, so raising this changes
    // nothing for the user.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.gharsaheli.ghar_saheli"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Strips unused Dart-facing Java/Kotlin and shrinks resources.
            // Worth real megabytes against the size budget, and the Flutter
            // engine ships its own keep rules so nothing needed is removed.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
