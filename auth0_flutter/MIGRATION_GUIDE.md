# Migration Guide

## Upgrading to Java 17 (Android)

The Android SDK now requires **Java 17** to build. This change is driven by the update to the Android Gradle Plugin (AGP) version 8.4.0, which mandates JDK 17.

### Why is this happening?
Newer versions of the Android build tools require a more recent Java version to support modern Android development features and performance improvements.

### How to migrate

#### 1. Install Java 17
Ensure that you have JDK 17 installed on your development machine and CI/CD environments.

- **macOS (Homebrew):**
  ```bash
  brew install openjdk@17
  ```
- **Windows/Linux:** Download from [Adoptium (Eclipse Temurin)](https://adoptium.net/) or your preferred vendor.

#### 2. Update your Environment Variables
Set your `JAVA_HOME` to point to the JDK 17 installation.

**macOS/Linux:**
```bash
export JAVA_HOME="/path/to/jdk-17"
```

#### 3. Update Gradle Settings (Optional but Recommended)
If you have a `gradle.properties` file in your project's `android` folder, you can specify the Java home there:

```properties
org.gradle.java.home=/path/to/jdk-17
```

#### 4. Verify the Configuration
Run the following command to ensure Gradle is using the correct Java version:

```bash
./gradlew --version
```
The output should show `JVM: 17.x.x`.
