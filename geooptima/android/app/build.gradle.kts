plugins {
    id("com.android.application")
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.geooptima"
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
        applicationId = "com.example.geooptima"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    sourceSets {
        getByName("main") {
            jniLibs.srcDir("libs")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

repositories {
    flatDir {
        dirs("libs") 
    }
}

dependencies {
    implementation(files("libs/OlaMapSdk-1.6.0.aar"))
    implementation(files("libs/Places-sdk-2.3.9.jar"))
    implementation ("androidx.core:core:1.12.0")
    implementation ("androidx.fragment:fragment:1.6.2")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation ("org.maplibre.gl:android-sdk:10.0.2")
    implementation ("org.maplibre.gl:android-plugin-annotation-v9:1.0.0")
    implementation ("org.maplibre.gl:android-plugin-markerview-v9:1.0.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
}
 

flutter {
    source = "../.."
}
