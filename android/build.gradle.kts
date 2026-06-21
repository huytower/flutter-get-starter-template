allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(rootProject.projectDir.resolve("../build"))

subprojects {
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.get().asFile.resolve(project.name))
}

subprojects {
    if (project.name != "app") {
        afterEvaluate {
            if (project.hasProperty("android")) {
                project.evaluationDependsOn(":app")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins {
    // ...

    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.4" apply false
    id("com.google.firebase.crashlytics") version "3.0.3" apply false
    id("com.google.firebase.firebase-perf") version "1.4.2" apply false
}
