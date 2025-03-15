plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Moved here
}

android {
    namespace = "com.example.aether"
    compileSdk = 34  // ✅ Explicitly set compileSdkVersion
    ndkVersion = "27.0.12077973"  // ✅ Fix NDK version mismatch

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.aether"
        minSdkVersion(23)  // ✅ Ensure this is 23
        targetSdkVersion(34)  // ✅ Explicitly set target SDK
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
