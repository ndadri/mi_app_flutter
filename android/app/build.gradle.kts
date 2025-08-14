plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") // Habilitado para Firebase y Google Sign-In
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.petmatch"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "26.3.11579264" // Usando NDK instalado y verificado como funcional

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Configuración de lint mejorada
    lint {
        disable.add("GradleCompatible")
        disable.add("ObsoleteLintCustomCheck")
        checkReleaseBuilds = false
    }

    defaultConfig {
        // Application ID actualizado para coincidir con Firebase
        applicationId = "com.petmatch"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // Requerido por Firebase Auth 24.0.1
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Suprimir advertencias de Java obsoleto
    tasks.withType<JavaCompile> {
        options.compilerArgs.addAll(listOf("-Xlint:-options"))
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    
    // Firebase products (cuando uses BoM, no especifiques versiones)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    
    // Google Play Services para Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
