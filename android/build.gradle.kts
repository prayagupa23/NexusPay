// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    val kotlinVersion = "1.9.22"
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath(kotlin("gradle-plugin", version = kotlinVersion))
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: File = rootProject.layout.buildDirectory.dir("../../build").get().asFile
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.resolve(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    
    project.plugins.withType<com.android.build.gradle.BasePlugin> {
        project.extensions.getByType<com.android.build.gradle.BaseExtension>().compileSdkVersion(34)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
    delete(files("${'$'}{rootProject.projectDir}/.gradle"))
}
