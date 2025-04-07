plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Add this block before the android { ... } block
val keystorePropertiesFile = rootProject.file("/Users/paruljuniwal/kuzushi_labs/metesh/iti/seeker_flutter/android/key.properties") // Path relative to android/app/build.gradle.kts
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    try {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    } catch (e: Exception) {
        println("Warning: Failed to load key.properties: ${e.message}")
        // Handle error appropriately, e.g., throw exception if signing is mandatory
    }
} else {
    println("Warning: key.properties file not found.")
    // Handle missing file case if necessary
}

android {
    namespace = "com.kuzushiprotean.seeker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kuzushiprotean.seeker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23  // Updated from flutter.minSdkVersion to support Firebase Auth
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
// 1. Define Signing Configs (NO fallback logic assigning signingConfig here)
    signingConfigs {
        create("release") {
            if (keystoreProperties.getProperty("storeFile") != null && keystorePropertiesFile.exists()) {
                // Define the properties for the 'release' config
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
            // DO NOT add 'else { signingConfig = ... }' here
        }
        // debug is usually predefined
    }

    // 2. Configure Build Types (Assign signingConfig with fallback logic HERE)
    buildTypes {
        getByName("release") {
            // Recommended settings
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // --- Correct place to assign signingConfig with fallback ---
            if (keystoreProperties.getProperty("storeFile") != null && keystorePropertiesFile.exists()) {
                 // If key properties exist, use the 'release' signing config we defined above
                 signingConfig = signingConfigs.getByName("release")
                 println("Info: Using release signing configuration.")
            } else {
                 // If key properties don't exist, fall back to using the 'debug' signing config
                 println("Warning: Release signing config not found in key.properties. Falling back to debug signing for release build type.")
                 signingConfig = signingConfigs.getByName("debug")
            }
            // --- End assignment ---
        }
        // Configure debug type if needed
        // getByName("debug") { ... }
    }
}

flutter {
    source = "../.."
}
