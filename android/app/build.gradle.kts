import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val localProperties = Properties()

// 加载打包key
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    localProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.example.flutter_riverpod_template"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
      compilerOptions {
        jvmTarget = JvmTarget.JVM_17
      }
    }
    packaging {
        dex {
            useLegacyPackaging = true
        }
        jniLibs {
            useLegacyPackaging = true
        }
    }
    packaging {
        resources {
            excludes += "lib/**/libc++_shared.so"
        }
    }
    // externalNativeBuild {
    //     cmake {
    //         path = rootProject.file("whisper_ggml/android/src/whisper/CMakeLists.txt")
    //         version = "3.22.1"
    //     }
    // }
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_riverpod_template"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        ndk {
            abiFilters += listOf("armeabi-v7a","arm64-v8a", "x86_64")
        }
    }
    signingConfigs {
        create("release") {
            keyAlias = localProperties["keyAlias"] as String
            keyPassword = localProperties["keyPassword"] as String
            storeFile = localProperties["storeFile"]?.let { file(it as String) }
            storePassword = localProperties["storePassword"] as String
            // isMinifyEnabled = true
            // isShrinkResources = false
            // enableProguard = true
        }
    }
    buildTypes {
       debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // isMinifyEnabled = true
            // isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}