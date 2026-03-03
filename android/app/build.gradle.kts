plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.snackly.app"
    compileSdk = 36  // Android 16 - required by plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Java 17 (LTS) - Currently building with Java 17
        // To use Java 21: Install JDK 21, update gradle.properties, then change VERSION_17 to VERSION_21 below
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Snackly - Smart Vending Machine App
        applicationId = "com.snackly.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Android 5.0+ (Lollipop) for maximum device compatibility
        targetSdk = 35  // Android 15 - Play Store recommended
        versionCode = 1  // Updated from flutter.versionCode
        versionName = "1.0.0"  // Updated from flutter.versionName
        
        // Enable multidex for large method count
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable minification to avoid TensorFlow Lite R8 issues
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
