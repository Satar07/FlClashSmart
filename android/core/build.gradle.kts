import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
}

android {
    namespace = "com.flsmart.clash.core"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndkVersion.get()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }

    externalNativeBuild {
        cmake {
            path("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation(libs.annotation.jvm)
}

val copyNativeLibs by tasks.register<Copy>("copyNativeLibs") {
    doFirst {
        delete("src/main/jniLibs")
    }
    from("../../libclash/android")
    into("src/main/jniLibs")

    doLast {
        val includesDir = file("src/main/jniLibs/includes")
        val targetDir = file("src/main/cpp/includes")
        if (includesDir.exists()) {
            copy {
                from(includesDir)
                into(targetDir)
            }
            delete(includesDir)
        }
    }
}

afterEvaluate {
    tasks.named("preBuild") {
        dependsOn(copyNativeLibs)
    }
}
