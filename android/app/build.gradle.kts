plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // NOTE: You can keep this, but consider removing underscores for long-term safety:
    // e.g., "com.grabdone.interviewapp"
    namespace = "com.grabdone.interviewapp"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // IMPORTANT: Make applicationId unique and ideally match namespace (no underscores is safest).
        // If you want to align now, set both to: "com.grabdone.interviewapp"
        applicationId = "com.grabdone.interviewapp" 
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ↓↓↓ NEW: real release signing using key.properties
    signingConfigs {
        create("release") {
            // Only run if key.properties exists (lets debug builds still work without secrets)
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use the real release signing (was "debug" before)
            signingConfig = signingConfigs.getByName("release")

            // Enable code & resource shrinking for smaller/optimized builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            // unchanged; debug stays debug-signed
        }
    }
}


flutter {
    source = "../.."
}
