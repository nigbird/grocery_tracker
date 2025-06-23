plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter plugin **must** come after Android & Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")

    // Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.grocery_tracker"

    // Versions handed over by the Flutter Gradle plugin
    compileSdk  = flutter.compileSdkVersion
    ndkVersion  = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        // Unique application ID (package name)
        applicationId = "com.example.grocery_tracker"

        // Values provided by Flutter’s tooling
        minSdk       = flutter.minSdkVersion
        targetSdk    = flutter.targetSdkVersion
        versionCode  = flutter.versionCode
        versionName  = flutter.versionName
    }

    buildTypes {
        release {
            // Sign with debug keys for now so `flutter run --release` works
            signingConfig = signingConfigs.getByName("debug")
            // Enables shrinking/obfuscation only when you‘re ready
            // minifyEnabled true
            // proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
            //               'proguard-rules.pro'
        }
    }
}

flutter {
    // Points the Android module back to the Flutter project
    source = "../.."
}

/*
 * ----------------------------------------------------------------------
 *  Dependencies
 *  ---------------------------------------------------------------------
 *  - The Firebase BoM lets you pin all Firebase libraries to the same
 *    version, so individual FlutterFire plugins can safely resolve them.
 *  - You don’t have to list each Firebase native library manually; the
 *    “BoM + FlutterFire plugin” combo is the recommended setup.
 */
dependencies {
    implementation platform("com.google.firebase:firebase-bom:32.7.0")
    // If you later need a native-only Firebase library, list it *after*
    // the BoM, e.g.:
    // implementation("com.google.firebase:firebase-analytics")
}
