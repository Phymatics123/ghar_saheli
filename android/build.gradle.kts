allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

/**
 * Forces every Android plugin module to compile against the same SDK as the
 * app.
 *
 * Plugins each declare their own `compileSdk`, and `file_picker` pins itself
 * to 34 while a package it depends on now demands 36 or higher. That
 * contradiction lives inside the plugin's own build file, which sits in the
 * pub cache and is overwritten on every fetch — so it cannot be fixed there.
 * Overriding from here is the only edit that survives.
 *
 * Raising `compileSdk` only widens the set of APIs a module may reference. It
 * does not change runtime behaviour, which follows `targetSdk`, nor which
 * phones can install the app, which follows `minSdk`.
 *
 * Set through Gradle's dynamic builder rather than by importing
 * `com.android.build.gradle.BaseExtension`, since the Android plugin is
 * declared `apply false` at the root and its types are not on this script's
 * compile classpath.
 *
 * This block must stay **above** the `evaluationDependsOn` block below. That
 * one forces `:app` to evaluate as the loop runs, and `afterEvaluate` cannot
 * be registered on a project that has already been evaluated.
 */
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.withGroovyBuilder {
            "compileSdkVersion"(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
