pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    // Pinned explicitly (instead of the Flutter Gradle Plugin's built-in
    // Kotlin) because current plugin versions — e.g. image_picker_android
    // 0.8.13+17 — use the Kotlin 2.x `compilerOptions` DSL and fail with
    // older built-in Kotlin:
    //   'void KotlinAndroidProjectExtension.compilerOptions(Function1)'
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
