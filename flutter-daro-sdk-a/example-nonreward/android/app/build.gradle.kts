import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("so.daro.a")
}

val dartDefineVariables: Map<String, String> = if (project.hasProperty("dart-defines")) {
    (project.property("dart-defines") as String)
        .split(",")
        .associate { entry ->
            // decode Base64 and split into key/value
            val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
            val (key, value) = decoded.split("=", limit = 2)
            key to value
        }
} else {
    emptyMap()
}

android {
    namespace = "com.example.daro_core_a"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.daro_core_a"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        extra["daroAppKey"] = dartDefineVariables["DARO_APP_KEY_ANDROID"]
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // ProGuard rules 적용을 위한 consumerProguardFiles 추가
            // consumerProguardFiles("proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
