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
subprojects {
    project.evaluationDependsOn(":app")
}

// home_widget 0.8.1 asks for dynamic versions ("1.+", "2.+"). Newer releases
// of these libraries break the Android build: glance 1.3 alphas need
// compileSdk 37 and Android Gradle plugin 9.1, and work 2.12 cannot be inlined
// into home_widget's JVM 1.8 code. Pin the last versions that build until
// home_widget or the Android toolchain is upgraded.
subprojects {
    configurations.configureEach {
        resolutionStrategy.force(
            "androidx.glance:glance-appwidget:1.2.0",
            "androidx.work:work-runtime:2.11.1",
            "androidx.work:work-runtime-ktx:2.11.1",
        )
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
