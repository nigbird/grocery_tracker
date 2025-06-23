// Top-level build.gradle.kts

plugins {
    // Google Services Gradle plugin required for Firebase
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: customize shared build directory (Flutter supports this)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Point each subproject to its own folder in the shared build dir
    val subprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(subprojectBuildDir)

    // Make sure the app module is evaluated early
    evaluationDependsOn(":app")
}

// Clean task for `./gradlew clean`
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
