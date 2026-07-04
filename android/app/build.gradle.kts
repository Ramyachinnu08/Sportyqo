import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    // Explicit Kotlin (see android/settings.gradle.kts for why the version
    // is pinned there). The Flutter Gradle Plugin must be applied last.
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sportyqo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.sportyqo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Current plugin versions (image_picker_android 0.8.13+) require
        // at least API 24; keep whichever is higher.
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        // Keep Kotlin's JVM target in lockstep with compileOptions above,
        // otherwise KGP 2.x fails the build on a JVM-target mismatch.
        jvmTarget = JvmTarget.fromTarget(JavaVersion.VERSION_17.toString())
    }
}

flutter {
    source = "../.."
}
