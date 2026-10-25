# Firebase setup

## 1. Create the project

1. Open the [Firebase Console](https://console.firebase.google.com/) in Chrome.
2. Sign in with a Google account you control.
3. Click **Create a project**, **Add project**, or the equivalent new-project button.
4. Enter **Campus Bobo** as the project name.
5. Accept the required terms if prompted, then click **Continue**.
6. Skip optional Gemini features if they are offered. They are not needed for this app.
7. Turn off **Enable Google Analytics for this project** if offered.
8. Click **Create project** and wait for creation to finish.
9. Click **Continue** to open the project dashboard.

The console may group optional features differently; the goal is a Firebase project without optional Analytics or AI services.

## 2. Enable email/password sign-in

1. Find **Authentication** in the project's left navigation menu. Expand its section if necessary.
2. Click **Get started** if prompted.
3. Open **Sign-in method** or **Sign-in providers**.
4. Click **Email/Password**.
5. Enable the **Email/Password** switch.
6. Leave **Email link (passwordless sign-in)** disabled.
7. Click **Save**.

Email verification will be implemented in the Flutter app. Student and staff permissions will be enforced separately; enabling this provider does not grant staff privileges.

## 3. Find the project ID

1. Click the gear beside **Project Overview**.
2. Click **Project settings**.
3. Open the **General** tab.
4. Copy the **Project ID**, rather than the project name or project number.

The project ID is a public identifier. Account passwords, access tokens, and service-account keys are not needed for this step.

## 4. Install the local tools and sign in

The Firebase project ID for Campus Bobo is `campus-bobo`. It is recorded as the default project in `.firebaserc`.

Firebase CLI and FlutterFire CLI are installed on the development computer. To set them up on another computer, run:

```powershell
npm.cmd install -g firebase-tools
dart pub global activate flutterfire_cli
```

To sign in from your own VS Code terminal, run:

```powershell
firebase.cmd login
```

1. If optional Gemini or CLI usage-reporting prompts appear, answer **No** to skip them.
2. If Chrome opens, select the Google account that owns `campus-bobo`.
3. Review the requested access and approve it to connect the CLI.
4. If a sign-in link is printed instead, open it in Chrome and follow the terminal instructions.
5. Complete any authorization-code step in your own terminal.
6. Wait for the terminal to confirm successful login.

Login may behave differently when launched by an agent. Complete Google sign-in in your own terminal/browser session; it does not require sharing account credentials in chat.

## 5. Connect Android after login

The Android application ID is currently `com.example.campus_bobo` in `android/app/build.gradle.kts`. FlutterFire CLI will register or match that Android app and generate its Firebase configuration after the project exists.

From the project root, the configuration command is:

```powershell
& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure --project=campus-bobo --platforms=android --android-package-name=com.example.campus_bobo
```

Using the executable's full path avoids changing Windows PATH for FlutterFire. Only Android is selected for this assignment's initial setup.

After configuration:

1. Inspect the generated `lib/firebase_options.dart`, `android/app/google-services.json`, and any Gradle or Firebase configuration changes.
2. Initialize Firebase before starting the Flutter app.
3. Run analysis and the widget test.
4. Check that the app still launches on the Android emulator.

Keep browser login and consent in your own session. The Firebase SDK dependencies are already installed; Firebase has not yet been initialized in `main.dart`.

## Billing and later services

Start on **Spark** for now. Cloud Storage for incident photos requires **Blaze**, which involves linking a billing account and can incur usage charges. Handle that step separately before implementing photo uploads. Firestore and its access rules will also be configured in a later stage.

## References

- [Official Flutter setup](https://firebase.google.com/docs/flutter/setup)
- [Email/password authentication](https://firebase.google.com/docs/auth/flutter/password-auth)
- [Cloud Storage requirements](https://firebase.google.com/docs/storage/flutter/start)
