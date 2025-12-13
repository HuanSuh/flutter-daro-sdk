pluginManagement {
    val flutterSdkPath = run {
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
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("so.daro.a") version "1.0.12" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter 엔진 저장소
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        // DARO SDK Maven 저장소 (Non-Reward 앱용)
        maven { url = uri("https://artifact.bytedance.com/repository/pangle") }
        maven { url = uri("https://verve.jfrog.io/artifactory/verve-gradle-release") }
        maven { url = uri("https://cboost.jfrog.io/artifactory/chartboost-ads/") }
        maven { url = uri("https://repo.premiumads.net/artifactory/mobile-ads-sdk/") }
        maven { url = uri("https://repo.pubmatic.com/artifactory/public-repos") }
        maven { url = uri("https://s3.amazonaws.com/smaato-sdk-releases/") }
        maven { url = uri("https://android-sdk.is.com/") }
        maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
    }
}

include(":app")
