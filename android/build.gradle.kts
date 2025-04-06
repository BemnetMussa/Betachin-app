buildscript {
    repositories {
        google() // Line 3: This causes the error
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}