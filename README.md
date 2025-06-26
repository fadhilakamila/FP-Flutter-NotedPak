# NotedPak App

## 📝 1. Project Overview

**NotedPak** is a note-taking application designed to help users manage notes efficiently. It features basic CRUD operations, tagging for categorization, flexible sorting by date, and **OCR (Optical Character Recognition)** for extracting text from images via camera or gallery. It runs well on Android.

## 🚀 2. How to Run the Application

This guide provides direct steps to set up and run the NotedPak application from its source code.

### Prerequisites

* **Flutter SDK:** Installed (`^3.8.0` or newer). Verify with `flutter doctor`.
* **Android Development Environment:** Android Studio (SDK, NDK, ADB).
* **Firebase CLI:** Node.js & npm for installation.
* **Google Account & Firebase Project:** For data storage and user authentication.
* **USB Cable:** For Android device debugging.
* **Internet Connection:** For all installations and data fetching.

### Setup and Running Steps

1.  **Get the Code:**
    ```bash
    git clone [https://github.com/mas663/FP-Flutter-NotedPak.git](https://github.com/mas663/FP-Flutter-NotedPak.git)
    cd FP-Flutter-NotedPak
    ```

2.  **Install Flutter Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Install Firebase CLI:**
    ```bash
    npm install -g firebase-tools
    ```
    *If `'flutterfire' is not recognized` or "running scripts is disabled" on Windows:*
    * **Add Pub Cache to Path:** Add `%LOCALAPPDATA%\Pub\Cache\bin` to your system's `Path` environment variable. (Restart terminal).
    * **Set PowerShell Policy:** Run `Set-ExecutionPolicy RemoteSigned` in **Windows PowerShell (Admin)**.

4.  **Connect to Firebase Project:**
    * Login: `firebase login` (follow browser prompts).
    * Configure App: `flutterfire configure` (select your Firebase project).

5.  **Configure Android Build Settings:**
    * **Open `android/app/build.gradle.kts`** and ensure:
        ```kotlin
        android {
            // ...
            compileSdk = flutter.compileSdkVersion // Ensure this line is correctly formatted
            ndkVersion = "27.0.12077973"
            // ...
            defaultConfig {
                // ...
                minSdk = 23 // Required by Firebase libraries
                // ...
            }
            // ...
        }
        ```
    * **Open `android/app/src/main/AndroidManifest.xml`** and ensure necessary permissions are present within `<manifest>` and `<application>` tags:
        ```xml
        <uses-permission android:name="android.permission.CAMERA" />
        <uses-permission android:name="android.permission.INTERNET"/>
        <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
        <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
        <uses-feature android:name="android.hardware.camera.any" android:required="true" />
        
        <application android:requestLegacyExternalStorage="true" ...>
            </application>
        ```

6.  **Setup Android Device for Debugging:**
    * **Enable Developer Options:** Go to **Settings** > **About phone** > Tap **Build number** 7 times.
    * **Enable USB Debugging:** Go to **Settings** > **Developer options** > Enable **USB debugging**.
    * **Connect Device:** Plug your Android phone into your computer via USB. Allow USB debugging when prompted. (Alternatively, use wireless debugging: `adb tcpip 5555` then `adb connect [YOUR_PHONE_IP_ADDRESS]:5555`).
    * **Verify Device:** Run `flutter devices` to ensure your device is detected.

7.  **Clean Project:**
    ```bash
    flutter clean
    ```

8.  **Run Application:**
    ```bash
    flutter run
    ```
    The app will build and launch on your connected Android device.

## 👥 3. Group Members

* Fadhila Kamila Ismail - [5026221026]
* Sintiarani Febyan Putri - [5026221044]
* Qoyyimil Jamilah - [5026221115]
* Mohammad Affan Shofi - [5026221134]
* Aryasatya Widyatna - [5026221207]

---