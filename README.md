# App Boilerplate

A Flutter starter project for new mobile apps. Copy it, rename it, connect your API
and start adding features. Login, API calls, error messages, themes, languages, push
notifications, crash reports and CI/CD are already set up.

**Repository:** <https://github.com/asad219/flutter_boiler_plate>

| | |
|---|---|
| Flutter / Dart | 3.44+ / `^3.12.2` |
| Android | minSdk 24 |
| iOS | 15.0+, Swift Package Manager (no CocoaPods) |
| Languages | English and Arabic (right-to-left) |
| Default ids | Android `com.starter.boilerplate.app_boilerplate`, iOS `com.starter.boilerplate.appBoilerplate` |

## What's included

| Area | What you get |
|---|---|
| Structure | Feature folders with data / domain / presentation layers, BLoC, `get_it` |
| API | Dio client that adds the token, refreshes it on 401 and logs requests (passwords and tokens hidden) |
| Errors | Clear error messages in the user's language. Messages from your server are shown as they are |
| Login | Login, logout, remember the session, sign out when the session expires |
| Widgets | Buttons, inputs, dropdowns, date picker, dialogs, snackbars, loaders, empty and error screens |
| Theme | Light and dark mode, saved choice, `ThemeSwitcher` widget |
| Languages | English and Arabic, saved choice, `LanguageSwitcher` widget, a different font per language |
| Firebase (optional) | Push notifications, Analytics and Crashlytics. The app also runs without Firebase |
| Tools | Rename script, app icon script, env files, Codemagic CI/CD |

## Contents

**Part 1: Start a new project**

1. [Prerequisites](#step-1-prerequisites)
2. [Copy the boilerplate](#step-2-copy-the-boilerplate)
3. [Rename the app](#step-3-rename-the-app)
4. [Set your Apple team](#step-4-set-your-apple-team)
5. [Create the env files](#step-5-create-the-env-files)
6. [Run the app](#step-6-run-the-app)
7. [Connect your backend](#step-7-connect-your-backend)
8. [Change the look](#step-8-change-the-look)
9. [Choose languages](#step-9-choose-languages)
10. [Set up Firebase (or turn it off)](#step-10-set-up-firebase-or-turn-it-off)
11. [Set up release signing](#step-11-set-up-release-signing)
12. [Set up CI/CD](#step-12-set-up-cicd)
13. [Final check](#step-13-final-check)

**Part 2: Working on the app**

- [Folder structure](#folder-structure)
- [Rules](#rules)
- [App startup](#app-startup)
- [API calls](#api-calls)
- [Errors](#errors)
- [Login flow](#login-flow)
- [Screens and routes](#screens-and-routes)
- [Logs and crash reports](#logs-and-crash-reports)
- [Push notifications](#push-notifications)
- [Add a new feature](#add-a-new-feature)
- [Shared widgets](#shared-widgets)
  - [List of widgets](#list-of-widgets)
  - [Rules for screens](#rules-for-screens)
  - [Widget reference](#widget-reference): how to use each widget
  - [Full screen examples](#full-screen-examples)
- [Theme and language](#theme-and-language)
- [Fonts and images](#fonts-and-images)
- [App icon](#app-icon)
- [Code checks](#code-checks)

**Part 3: Services**

- [Firebase setup](#firebase-setup)
- [CI/CD with Codemagic](#cicd-with-codemagic)
- [Common problems](#common-problems)
- [Toolchain notes](#toolchain-notes)

### Try it quickly

```bash
git clone https://github.com/asad219/flutter_boiler_plate.git
cd flutter_boiler_plate
cp env/dev.json.example env/dev.json        # then set BASE_URL
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

There is no demo account. Login calls your own backend (`POST /users/login`).

---

# Part 1: Start a new project

Do the steps in order. In the examples, replace `my_app`, `com.acme.myapp`, `My App`
and `YOURTEAMID` with your own values.

<details>
<summary><b>All commands in one place</b></summary>

```bash
# Step 2: copy the boilerplate with a new git history
git clone --depth 1 https://github.com/asad219/flutter_boiler_plate.git my_app
cd my_app
rm -rf .git
git init && git add -A && git commit -m "Start from flutter_boiler_plate"

# Step 3: rename the app
./tool/rename_app.sh --package my_app --android-id com.acme.myapp \
  --ios-id com.acme.myapp --name "My App"

# Step 4: your Apple team
perl -pi -e 's/E65WYSUT4Y/YOURTEAMID/g' ios/Runner.xcodeproj/project.pbxproj

# Step 5: env files (then set BASE_URL in each one)
for e in dev staging prod; do cp env/$e.json.example env/$e.json; done

# Step 6: check and run
flutter analyze
flutter run --dart-define-from-file=env/dev.json
git add -A && git commit -m "Rename to My App"
```

Then go on with [step 7](#step-7-connect-your-backend).

</details>

## Step 1: Prerequisites

- **Flutter 3.44 or newer** (stable channel). Check with `flutter doctor`.
- **For iOS:** a Mac with Xcode, and an Apple Developer account for real devices,
  push notifications and App Store builds. You don't need CocoaPods.
- **For Android:** Android Studio (or the Android SDK) and JDK 17.
- **`perl` and `bash`** for the scripts in `tool/`. Both come with macOS and Linux.
- VS Code or Android Studio with the Flutter plugin. VS Code run settings are already
  in `.vscode/launch.json`.

## Step 2: Copy the boilerplate

Clone it into a folder with your app's name and start a new git history. This way
your app doesn't carry the boilerplate's old commits:

```bash
git clone --depth 1 https://github.com/asad219/flutter_boiler_plate.git my_app
cd my_app
rm -rf .git
git init && git add -A && git commit -m "Start from flutter_boiler_plate"
```

To push it to your own GitHub repo, create an **empty** repo on GitHub (no README,
`.gitignore` or license), then run:

```bash
git remote add origin https://github.com/<you>/my_app.git
git branch -M main
git push -u origin main
```

<details>
<summary>Copying a local folder instead of cloning</summary>

Delete the files that only belong to your machine or contain secrets:

```bash
cp -R flutter_boiler_plate my_app && cd my_app
rm -rf .git build .dart_tool .idea app_boilerplate.iml \
  android/.gradle android/local.properties android/key.properties \
  ios/Flutter/ephemeral ios/Flutter/Generated.xcconfig ios/Flutter/flutter_export_environment.sh \
  env/dev.json env/staging.json env/prod.json \
  android/app/google-services.json ios/Runner/GoogleService-Info.plist
git init && git add -A && git commit -m "Start from flutter_boiler_plate"
```

Flutter creates the missing files again on the next `flutter pub get`.

</details>

## Step 3: Rename the app

Pick your names first. You can't change the ids after the app is in the stores.

| Name | Rules | Example |
|---|---|---|
| Dart package | lowercase letters, numbers and `_` | `my_app` |
| Android application id | like a reversed domain; each part starts with a letter; letters, numbers and `_` | `com.acme.myapp` |
| iOS bundle id | like a reversed domain; letters, numbers, `-` and `.`; **no `_`** | `com.acme.myapp` |
| Display name | any text, shown under the icon | `My App` |

Using the same id for Android and iOS makes Firebase and store setup easier.

**Option A: use the script (recommended)**

```bash
./tool/rename_app.sh \
  --package my_app \
  --android-id com.acme.myapp \
  --ios-id com.acme.myapp \
  --name "My App"
```

The script changes:

- the package name in `pubspec.yaml` and all `package:app_boilerplate/` imports
- the Android `namespace`, `applicationId`, `android:label`, and moves `MainActivity.kt`
  to the new folder
- the iOS bundle id, `CFBundleDisplayName` and `CFBundleName`
- the iOS `bundle_identifier` in `codemagic.yaml`
- `AppConstants.appName`

Then it runs `flutter clean && flutter pub get`. Check the changes with `git diff`.
The script only works on the original names. To run it again, first undo with
`git checkout .`.

<details>
<summary><b>Option B: rename by hand</b></summary>

1. `pubspec.yaml`: set `name: my_app`. Then replace `package:app_boilerplate/` with
   `package:my_app/` in `lib/`.
2. `android/app/build.gradle.kts`: change `namespace` and `applicationId`.
3. Move `android/app/src/main/kotlin/com/starter/boilerplate/app_boilerplate/MainActivity.kt`
   to the new folder (e.g. `kotlin/com/acme/myapp/`) and change its `package` line.
4. `android/app/src/main/AndroidManifest.xml`: change `android:label`.
5. `ios/Runner.xcodeproj/project.pbxproj`: change every `PRODUCT_BUNDLE_IDENTIFIER`
   (Runner and `RunnerTests`). You can also do this in Xcode under
   *Signing & Capabilities*.
6. `ios/Runner/Info.plist`: change `CFBundleDisplayName` and `CFBundleName`.
7. `lib/core/constants/app_constants.dart`: change `appName`.
8. `codemagic.yaml`: change `bundle_identifier` under `ios-release`.
9. Run `flutter clean && flutter pub get`.

</details>

Also update `description` in `pubspec.yaml`, and change the title and first lines of
this README to describe your app.

## Step 4: Set your Apple team

The Xcode project still uses the boilerplate's team (`DEVELOPMENT_TEAM = E65WYSUT4Y`).
The rename script doesn't change it. Without your own team, iOS builds for devices and
the App Store won't sign.

- **In Xcode:** open `ios/Runner.xcworkspace`, select the **Runner** target, open
  *Signing & Capabilities*, keep *Automatically manage signing* on and choose your
  **Team**.
- **Or from the terminal.** Find your Team ID at <https://developer.apple.com/account>
  under *Membership details*:

  ```bash
  perl -pi -e 's/E65WYSUT4Y/YOURTEAMID/g' ios/Runner.xcodeproj/project.pbxproj
  ```

## Step 5: Create the env files

Settings like the API address come from a JSON file per environment. The app reads
them in `lib/core/config/env_config.dart`.

```bash
for e in dev staging prod; do cp env/$e.json.example env/$e.json; done
```

The real files (`env/dev.json`, `staging.json`, `prod.json`) are not committed to git.
Only the `.example` files are. Open each file and set your values:

```json
{
  "ENV": "dev",
  "BASE_URL": "http://10.0.2.2:5005/api/",
  "API_VERSION": "v1",
  "ENABLE_FIREBASE": true
}
```

| Key | Required | Notes |
|---|---|---|
| `ENV` | No (default `dev`) | `dev`, `staging` or `prod`. Read it with `EnvConfig.isDev` etc. |
| `BASE_URL` | **Yes** | Full address with `http://` or `https://`. If it's missing or wrong, the app shows a *Configuration error* screen |
| `API_VERSION` | No (default `v1`) | Added to the end of `BASE_URL`, e.g. `.../api/v1`. Use `""` for none |
| `ENABLE_FIREBASE` | No (default `true`) | `false` turns off Firebase (push, analytics, crash reports) |

If your backend runs on your own computer, the address depends on where the app runs:

| App runs on | `BASE_URL` |
|---|---|
| Android emulator | `http://10.0.2.2:<port>/api/` (`10.0.2.2` means "my computer" inside the emulator) |
| iOS simulator | `http://localhost:<port>/api/` |
| Real phone | `http://<your-computer-IP>:<port>/api/` (same Wi-Fi) |

Plain `http://` works on Android only in debug builds. Release builds and iOS expect
`https://`. If iOS blocks `http://` calls to your computer's IP, use `https://` (for
example with a tunnel like ngrok), or add `NSAllowsLocalNetworking` to `Info.plist`
for debug.

> Don't put secrets in env files (passwords, private API keys). The values are built
> into the app and can be read by anyone who has the app.

## Step 6: Run the app

```bash
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

In VS Code you can also choose **dev**, **staging** or **prod (release)** in the
*Run and Debug* panel. In Android Studio, add `--dart-define-from-file=env/dev.json`
to *Additional run args* in the run configuration.

What you should see:

- The splash screen, then the login screen.
- If your backend isn't running yet, login shows an error like *"Please check your
  internet connection…"*. That's expected.
- If Firebase isn't set up, the app prints a warning and works normally.
- If you see a **Configuration error** screen, the app was started without the env
  file, or `BASE_URL` is wrong.

## Step 7: Connect your backend

1. **API paths:** edit `lib/core/constants/api_endpoints.dart`.
2. **Response format:** the login feature expects the format in
   [Login flow](#login-flow). If your API is different, change the models:
   - `features/auth/data/models/login_response_model.dart` reads `token` (or
     `accessToken`), `refreshToken` and `user`. They can also be inside `data`.
   - `features/auth/data/models/user_model.dart` reads `id` (or `_id`), `email`,
     `firstName`, `lastName`, `profilePicUrl` and `isVerified`. Add or remove fields
     here and in `domain/entities/user_entity.dart`.
3. **Error messages:** the app looks for the server's message in `message`, `error`,
   `detail` or `errors`. If your API uses another key, add it in `_extractMessage` in
   `core/error/exceptions.dart`.
4. **No refresh token endpoint?** Leave it as it is. If there's no refresh token, the
   app just signs the user out when the token expires.
5. **No device registration endpoint?** Change or remove the `POST /devices` call in
   `core/services/notification/fcm_token_registrar.dart`.
6. **Timeout:** `AppConstants.requestTimeout` (20 seconds). You can also pass
   `timeout:` to a single call.

## Step 8: Change the look

| What | Where |
|---|---|
| App name in the app switcher and splash | `AppConstants.appName` in `lib/core/constants/app_constants.dart` |
| Name under the icon | `android:label` in `AndroidManifest.xml`, `CFBundleDisplayName` in `Info.plist` (the rename script sets both) |
| Colors | `lib/core/constants/app_colors.dart` (light and dark) |
| Font | `AppTypography.fontFamily` (see [Fonts and images](#fonts-and-images)) |
| Text sizes | `AppTypography.textTheme` |
| Spacing and corner radius | `lib/core/constants/app_dimens.dart` |
| Buttons, inputs, cards style | `lib/core/theme/app_theme.dart` |
| App icon | `./tool/generate_app_icons.sh path/to/icon.png` (see [App icon](#app-icon)) |
| Images | `assets/images/` and `AppAssets` (see [Images](#images)) |
| Screen rotation | `AppConstants.orientations` (portrait by default) **and** `UISupportedInterfaceOrientations` in `ios/Runner/Info.plist` |

All shared widgets read their style from the theme, so changing these files changes
the whole app, in light and dark mode.

**Splash screen:** edit `android/app/src/main/res/drawable/launch_background.xml` (and
`drawable-v21/`), `ios/Runner/Base.lproj/LaunchScreen.storyboard` and
`Assets.xcassets/LaunchImage.imageset`. Or use the
[`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) package.

**Android notification icon:** local notifications use the app icon, which Android
shows as a plain white square in the status bar. For a real app, add a white icon on
a transparent background as `res/drawable/ic_notification.png`, use
`@drawable/ic_notification` in `local_notification_service.dart`, and add this to
`AndroidManifest.xml` so Firebase notifications use it too:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
```

**Notification channel:** you can rename the `'General'` channel in
`local_notification_service.dart`. If you change the id `default_channel`, change it
in `AndroidManifest.xml` too.

## Step 9: Choose languages

The app comes with English (`app_en.arb`) and Arabic (`app_ar.arb`). It follows the
phone's language, and users can change it with `LanguageSwitcher`.

- **Keep both:** nothing to do.
- **Add a language:** see [Translations](#translations).
- **English only:**
  1. Delete `lib/l10n/arb/app_ar.arb`.
  2. Remove `<string>ar</string>` from `CFBundleLocalizations` in `ios/Runner/Info.plist`.
  3. Remove `'ar'` from `AppTypography.fontFamilyByLanguage`.
  4. Run `flutter gen-l10n`.
  5. If you don't need the Dubai font anymore, remove it from `fontFamilyFallback`,
     from `fonts:` in `pubspec.yaml` and from the `fonts/` folder.

## Step 10: Set up Firebase (or turn it off)

Firebase is used for push notifications, Analytics and Crashlytics. The Firebase
files are linked to your app ids, so do this after renaming.

- **To use Firebase:** follow [Firebase setup](#firebase-setup) with your **new** ids.
- **Not now:** set `"ENABLE_FIREBASE": false` in your env files. Push, analytics and
  crash reports are skipped and everything else works.

## Step 11: Set up release signing

**Android.** Release builds are signed with the keystore in `android/key.properties`.
Without that file, the debug key is used. That's fine for testing, but Google Play
won't accept it.

1. Create a keystore. Keep it and its passwords somewhere safe outside the project,
   and back them up. If you lose it, you can't update your app:

   ```bash
   keytool -genkey -v -keystore ~/keys/my_app-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties`:

   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=/Users/<you>/keys/my_app-upload.jks
   ```

   This file and `.jks` files are already ignored by git. To check which key a
   release build uses, run `cd android && ./gradlew -q :app:signingReport` and look for
   `Variant: release`.

3. Add the release SHA-1 and SHA-256 to your Firebase Android app. If you use Play App
   Signing, also add the fingerprints from Play Console (*Setup > App signing*).

**iOS.** With automatic signing and your team set ([step 4](#step-4-set-your-apple-team)),
Xcode handles certificates for you. Before your first upload, create the app in
[App Store Connect](https://appstoreconnect.apple.com) with the same bundle id.

**Store builds.** Increase `version: x.y.z+build` in `pubspec.yaml` before every
upload:

```bash
flutter build appbundle --release --dart-define-from-file=env/prod.json
flutter build ipa --release --dart-define-from-file=env/prod.json
```

## Step 12: Set up CI/CD

`codemagic.yaml` checks every push and pull request (format and analyze). When you
push a `v*` tag, it builds signed apps and uploads them to Google Play (internal
track) and TestFlight. For the one-time setup, see
[CI/CD with Codemagic](#cicd-with-codemagic). You can skip this step and build on your
own computer.

## Step 13: Final check

```bash
flutter analyze
flutter run --dart-define-from-file=env/dev.json

# Should find nothing except README.md and tool/rename_app.sh:
grep -rnE "app_boilerplate|com\.starter\.boilerplate|appBoilerplate|App Boilerplate|E65WYSUT4Y" \
  --exclude-dir={build,.dart_tool,.git,.gradle} .
```

- [ ] New git history, pushed to your own repo
- [ ] Package name, Android id, iOS bundle id and display name changed
- [ ] Apple team set
- [ ] `env/*.json` created with your `BASE_URL`; API paths and models match your API
- [ ] Colors, font, icon, splash and notification icon changed
- [ ] Languages chosen
- [ ] Firebase set up for the new ids, or `ENABLE_FIREBASE: false`
- [ ] Android keystore created; app created in App Store Connect
- [ ] `flutter analyze` shows no issues
- [ ] Optional: Codemagic connected and the `ci` build is green

---

# Part 2: Working on the app

## Folder structure

```
lib/
├── main.dart                      # calls bootstrap()
├── app/
│   ├── bootstrap.dart             # startup steps and error handlers
│   ├── app.dart                   # MaterialApp + login/logout listener
│   └── routes/                    # RoutesName, AppRouter, NotFoundPage
├── core/
│   ├── config/                    # EnvConfig (values from env/*.json)
│   ├── constants/                 # app constants, API paths, storage keys, assets,
│   │                              # colors, fonts, spacing
│   ├── di/service_locator.dart    # get_it setup
│   ├── error/                     # ApiException, Failure, ErrorHandler, FailureL10n
│   ├── extensions/                # context.colors, context.textTheme, context.l10n
│   ├── localization/              # LocaleCubit (saved language)
│   ├── network/                   # ApiClient (Dio), interceptors, ApiResponseParser, Result
│   ├── services/
│   │   ├── analytics/             # Firebase Analytics
│   │   ├── crash/                 # Crashlytics
│   │   ├── firebase/              # starts Firebase if it's set up
│   │   ├── navigation/            # navigation and snackbars without context
│   │   ├── notification/          # push and local notifications
│   │   ├── session/               # session expired event
│   │   └── storage/               # secure storage, tokens, shared preferences
│   ├── theme/                     # light and dark theme, ThemeCubit
│   ├── usecase/                   # UseCase base class
│   ├── utils/                     # AppLogger, Validators
│   └── widgets/                   # shared widgets (import widgets.dart)
├── l10n/
│   ├── arb/                       # app_en.arb, app_ar.arb: edit these
│   └── generated/                 # created by `flutter gen-l10n`, don't edit
└── features/
    ├── auth/                      # splash and login
    ├── home/                      # sample home screen
    └── settings/                  # ThemeSwitcher, LanguageSwitcher
```

Outside `lib/`:

| Path | What's in it |
|---|---|
| `env/` | Env files (`.example` files are committed, real ones aren't) |
| `fonts/` | Font files |
| `assets/images/` | Images used in the app |
| `assets/icon/` | App icon source image |
| `tool/` | `rename_app.sh`, `generate_app_icons.sh`, CI scripts |
| `l10n.yaml` | Translation settings |
| `codemagic.yaml` | CI/CD setup |

There is no `test/` folder yet. Add one when you start writing tests.

## Rules

```
Widget ──event──▶ Bloc ──▶ UseCase ──▶ Repository (interface, domain)
                                           │
                               RepositoryImpl (data)
                              ┌────────────┴────────────┐
                    RemoteDataSource              LocalDataSource
                      (ApiClient / Dio)      (secure storage / prefs)
```

- `domain/` doesn't import `data/`, `presentation/` or Flutter. It only uses
  `equatable` and `Result` / `UseCase` from `core`.
- Data sources throw `ApiException` (API) or `CacheException` (local storage).
- Repositories don't throw. They return `Result<T>`, which is `Success(data)` or
  `Failed(failure)`. Use `ErrorHandler.guard(() async { ... })`.
- BLoCs only talk to use cases. Events and states go in `part` files, states use
  `copyWith`, and handlers are named `_onEventName`.
- Pages don't navigate after login or logout. `app/app.dart` does that (see
  [Login flow](#login-flow)).
- In `get_it`, BLoCs and cubits are factories. Everything else is a lazy singleton.
- Don't use `print`. Use [`AppLogger`](#logs-and-crash-reports).
- Don't write user-facing text in code. Use `context.l10n`.

## App startup

`lib/app/bootstrap.dart` runs these steps before the first screen:

1. Set up error handlers, so errors are printed and sent to Crashlytics.
2. Check the env values. If `BASE_URL` is wrong, show the *Configuration error*
   screen and stop.
3. Start Firebase (if it's on and set up), then Crashlytics and the background push
   handler.
4. Register dependencies (`setupLocator()`) and load the saved tokens.
5. Start push notifications and ask for permission (without waiting for the answer).
6. Lock the screen rotation (`AppConstants.orientations`) and start the app.

Put new startup code in `bootstrap()`, not in `main.dart`.

## API calls

```dart
final json = await apiClient.get(
  ApiEndpoints.currentUser,
  queryParameters: {'include': 'roles'},
);
final user = ApiResponseParser.parseObject(json, UserModel.fromJson);
```

- `get`, `post`, `put`, `patch` and `delete` accept `queryParameters`,
  `requiresAuth`, `successCodes`, `timeout` and `cancelToken`. All except `get` also
  accept `body`.
- Every call returns a `Map<String, dynamic>`. If the API returns a list, you get
  `{'data': [...]}`. `ApiResponseParser.parseObject`, `parseList` and
  `parseListOrSingle` take care of the `data` wrapper.
- `requiresAuth` is `true` by default. Pass `false` for public endpoints like login.
- `successCodes` is `[200, 201]` by default (`[200, 202, 204]` for `delete`).

Interceptors in `core/network/api_interceptors.dart`:

| Interceptor | What it does |
|---|---|
| `AuthInterceptor` | Adds `Authorization: Bearer <token>`. On a 401 it calls `POST /users/refresh-token` once and retries the request. If that's not possible, it clears the tokens and the user is signed out |
| `ErrorInterceptor` | Turns every Dio error into an `ApiException` |
| `LoggingInterceptor` | Debug builds only. Prints each request and response. Hides `Authorization`, cookies, `password`, `token`, `accessToken`, `refreshToken`, `otp` and `pin` (add more in `_sensitiveKeys`) |

Messages from your server are shown as they are. If you want them in the user's
language, send the language to your API (for example in an `Accept-Language` header)
from an interceptor.

## Errors

Errors move up as types. Only the screen turns them into text:

```
Dio error ──▶ ApiException ──▶ Failure ──▶ failure.localizedMessage(l10n)
(data source)                  (repository)  (screen)
```

| What happened | `Failure` | Text shown |
|---|---|---|
| Server error (4xx / 5xx) | `ServerFailure` | The server's message, or `errorServer` |
| 401 (wrong login, expired session) | `UnauthorizedFailure` | The server's message, or `errorSessionExpired` |
| No internet | `NetworkFailure` | `errorNoConnection` |
| Timeout | `TimeoutFailure` | `errorTimeout` |
| Bad response, cancelled, anything else | `UnknownFailure` | `errorUnknown` |
| Local storage error | `CacheFailure` | `errorUnknown` |

- `Failure.message` is only the server's message. Raw JSON, stack traces and other
  technical text are removed before it gets there.
- Show a failure like this (`core/error/failure_l10n.dart`):

  ```dart
  AppSnackBar.show(context, failure.localizedMessage(context.l10n), type: AppSnackBarType.error);
  ```

- Keep the `Failure` in your BLoC state, not a `String`. Then the text changes when
  the user changes the language.
- To add a new type (e.g. `ValidationFailure`), add it to `failures.dart`, handle it in
  `ErrorHandler.toFailure` and in `FailureL10n`. The analyzer shows you every place
  that needs it.

## Login flow

`AuthState` has `status`, `user` and `failure`:

- `status`: `initial`, `loading`, `authenticated` or `unauthenticated`.
- `failure`: why the user is signed out (wrong login, expired session). `copyWith`
  clears it unless you pass it again.
- Use `clearUser: true` to remove the user.

`_AuthNavigationListener` in `app/app.dart` is the one place that reacts to login and
logout. It opens the home or login screen, shows the error, updates the push token,
sets the user id for Analytics and Crashlytics, and opens a notification's screen
once the user is logged in.

The backend API used by the login feature (paths are in `api_endpoints.dart`):

| Endpoint | Request | Response |
|---|---|---|
| `POST /users/login` | `{email, password}` | `{token, refreshToken?, user}` (can be inside `data`) |
| `POST /users/logout` | nothing | anything (the app signs out even if this fails) |
| `GET /users/me` | nothing | the user (directly, or inside `user` / `data`) |
| `POST /users/refresh-token` | `{refreshToken}` | `{token, refreshToken?}` |
| `POST /devices` | `{token, platform}` | anything (saves the push token) |

## Screens and routes

The app uses named routes:

1. Add a name in `app/routes/routes_name.dart`:
   `static const String profile = '/profile';`
2. Add the screen to `AppRouter._routes` in `app/routes/app_router.dart`. Create the
   screen's BLoC here:

   ```dart
   RoutesName.profile: (_) => BlocProvider(
     create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
     child: const ProfilePage(),
   ),
   ```

3. Open it with `Navigator.pushNamed(context, RoutesName.profile)`. Outside widgets,
   use `getIt<NavigationService>().pushNamed(...)`.

If a route name doesn't exist (a typo, or an old notification link), the app shows a
"Page not found" screen.

## Logs and crash reports

Use `AppLogger` (`core/utils/app_logger.dart`). Don't use `print`.

| Method | Use for | Debug build | Release build |
|---|---|---|---|
| `AppLogger.debug(msg)` | Details while developing | Printed | Nothing |
| `AppLogger.warning(msg, error:, stackTrace:)` | Expected problems (offline, refresh failed) | Printed | Nothing |
| `AppLogger.error(msg, error:, stackTrace:, fatal:)` | Real bugs | Printed | Printed and sent to Crashlytics |

```dart
try {
  await doSomething();
} catch (e, stackTrace) {
  AppLogger.error('Export failed', name: 'ExportService', error: e, stackTrace: stackTrace);
}
```

Crashlytics (`core/services/crash/crash_reporter.dart`):

- Gets app crashes, Flutter UI errors and every `AppLogger.error`.
- Is **off in debug builds**, so testing on your machine doesn't fill the dashboard.
  To test it, use `flutter run --release`.
- Does nothing if Firebase isn't set up.
- Gets the user id on login and clears it on logout. Only the id is sent, never the
  email or name.
- `CrashReporter.log('Opened checkout')` adds a note to the next crash report.

## Push notifications

| App state | Handled by |
|---|---|
| Open | `FirebaseMessaging.onMessage`. Android shows a local notification, iOS shows it by itself |
| In background, user taps | `FirebaseMessaging.onMessageOpenedApp` |
| Closed, user taps | `getInitialMessage()` (push) / `getNotificationAppLaunchDetails()` (local) |
| In background or closed, message arrives | `firebaseMessagingBackgroundHandler`. Data-only messages with `title` and `body` are shown as local notifications |

- **Open a screen from a notification:** send `data: {"route": "/home", ...}`. Other
  keys are passed to the screen. If the user isn't logged in yet, it waits until they
  are.
- **Permission:** asked at startup, and again from the *Enable notifications* button
  on the home screen.
- **Token:** sent to the backend after login and when it changes. Deleted on logout.

## Add a new feature

Example: a `profile` feature that loads `GET /users/me`. Copy the structure of
`features/auth`.

```
lib/features/profile/
├── data/
│   ├── datasources/profile_remote_ds.dart
│   ├── models/profile_model.dart
│   └── repositories/profile_repository_impl.dart
├── domain/
│   ├── entities/profile_entity.dart
│   ├── repositories/profile_repository.dart
│   └── usecases/get_profile_usecase.dart
└── presentation/
    ├── bloc/profile_bloc.dart, profile_event.dart, profile_state.dart
    ├── pages/profile_page.dart
    └── widgets/
```

**1. API path** in `core/constants/api_endpoints.dart`:

```dart
static const String profile = '/users/me';
```

**2. Domain:** entity, repository interface and use case:

```dart
class ProfileEntity extends Equatable {
  const ProfileEntity({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

abstract interface class ProfileRepository {
  Future<Result<ProfileEntity>> getProfile();
}

class GetProfileUseCase implements UseCase<ProfileEntity, NoParams> {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;
  @override
  Future<Result<ProfileEntity>> call(NoParams params) => _repository.getProfile();
}
```

**3. Data:** model, remote data source (can throw) and repository (returns `Result`):

```dart
class ProfileModel extends ProfileEntity {
  const ProfileModel({required super.id, required super.name});
  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    name: json['name'] as String? ?? '',
  );
}

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<ProfileModel> getProfile() async {
    final json = await _apiClient.get(ApiEndpoints.profile);
    return ApiResponseParser.parseObject(json, ProfileModel.fromJson);
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);
  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ProfileEntity>> getProfile() =>
      ErrorHandler.guard(_remoteDataSource.getProfile);
}
```

**4. BLoC:** the state has a `status` and keeps the `Failure`:

```dart
// profile_bloc.dart
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this._getProfileUseCase}) : super(const ProfileState()) {
    on<ProfileRequested>(_onProfileRequested);
  }

  final GetProfileUseCase _getProfileUseCase;

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _getProfileUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, failure: failure)),
      (profile) => emit(state.copyWith(status: ProfileStatus.success, profile: profile)),
    );
  }
}

// profile_event.dart
part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

// profile_state.dart
part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({this.status = ProfileStatus.initial, this.profile, this.failure});

  final ProfileStatus status;
  final ProfileEntity? profile;
  final Failure? failure;

  /// `failure` is reset on every copy unless you pass it again.
  ProfileState copyWith({ProfileStatus? status, ProfileEntity? profile, Failure? failure}) =>
      ProfileState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, profile, failure];
}
```

**5. Screen**, using the [shared widgets](#shared-widgets):

```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.profileTitle,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) => switch (state.status) {
          ProfileStatus.initial || ProfileStatus.loading => const AppLoader(),
          ProfileStatus.failure => AppErrorState(
            message: state.failure!.localizedMessage(context.l10n),
            onRetry: () => context.read<ProfileBloc>().add(const ProfileRequested()),
          ),
          ProfileStatus.success => Text(state.profile!.name),
        },
      ),
    );
  }
}
```

**6. Text:** add `profileTitle` (and any other text) to every `.arb` file.

**7. Register it** in `core/di/service_locator.dart` and call the function from
`setupLocator()`:

```dart
void _registerProfileFeature() {
  getIt
    ..registerLazySingleton(() => ProfileRemoteDataSource(getIt<ApiClient>()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetProfileUseCase(getIt<ProfileRepository>()))
    ..registerFactory(() => ProfileBloc(getProfileUseCase: getIt<GetProfileUseCase>()));
}
```

**8. Route:** see [Screens and routes](#screens-and-routes).

**9. Check:** `dart format lib && flutter analyze`.

---

## Shared widgets

The shared widgets are in `lib/core/widgets/`. Import this one file:

```dart
import 'package:app_boilerplate/core/widgets/widgets.dart';
```

They take their colors, borders and text styles from the theme. Change
`app_colors.dart`, `app_typography.dart`, `app_dimens.dart` and `app_theme.dart`, and
every screen changes. Dark mode works without extra code.

### List of widgets

Click a name to see how to use it.

| Widget | Group | Use it for |
|---|---|---|
| [`AppButton`](#appbutton) | Buttons | All buttons: main, secondary, text link, delete |
| [`AppTextField`](#apptextfield) | Inputs | Text, email, number, phone and multi-line inputs (the "textbox") |
| [`AppPasswordField`](#apppasswordfield) | Inputs | Passwords, with a show/hide button |
| [`AppSearchField`](#appsearchfield) | Inputs | Search boxes on list screens |
| [`AppDropdown`](#appdropdown) | Inputs | Short lists (up to about 10 items) |
| [`AppSearchableDropdown`](#appsearchabledropdown) | Inputs | Long lists with a search box (countries, cities) |
| [`AppDateField`](#appdatefield) | Inputs | Picking a date |
| [`AppCheckboxField`](#appcheckboxfield) | Inputs | Checkboxes, like "I accept the terms" |
| [`AppPickerField`](#apppickerfield) | Inputs | Building your own picker (time, file, color) |
| [`AppFieldLabel`](#appfieldlabel) | Inputs | Field label with a red `*` (used inside the inputs) |
| [`AppSnackBar`](#appsnackbar-toasts) | Messages | Toast messages: success, error, warning, info |
| [`AppDialog`](#appdialog) | Messages | Yes/no questions and info popups |
| [`AppLoader`](#apploader) | Loading | Spinner while a page loads |
| [`AppLoadingOverlay`](#apploadingoverlay) | Loading | Blocking the screen while saving |
| [`AppScaffold`](#appscaffold) | Layout | Base layout for every screen |
| [`AppCard`](#appcard) | Layout | A box that groups content, can be tapped |
| [`AppSectionHeader`](#appsectionheader) | Layout | Section title with an optional "View all" |
| [`AppEmptyState`](#appemptystate) | States | "Nothing here yet" screens |
| [`AppErrorState`](#apperrorstate) | States | Error screens with a retry button |
| [`AppBadge`](#appbadge) | Display | Status labels like "Approved" or "Pending" |
| [`AppInfoRow`](#appinforow) | Display | Label and value on detail screens |

Helpers used with the widgets: [`Validators`](#validators),
[`AppSpacing` and `AppRadius`](#appspacing-and-appradius) and
[context shortcuts](#context-shortcuts).

Default texts in these widgets (dialog buttons, "Search", "Loading…", "… is
required") are already translated. You can pass your own text if you want.

### Rules for screens

1. **Use the shared widgets, not plain Material widgets.**

   | Instead of | Use |
   |---|---|
   | `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton` | `AppButton` |
   | `TextFormField` / `TextField` | `AppTextField`, `AppPasswordField`, `AppSearchField` |
   | `DropdownButtonFormField` | `AppDropdown<T>` or `AppSearchableDropdown<T>` |
   | `CircularProgressIndicator` | `AppLoader`, `AppLoadingOverlay`, or `AppButton(isLoading: true)` |
   | `ScaffoldMessenger.of(context).showSnackBar` | `AppSnackBar.show` (or `NavigationService.showSnackBar` outside widgets) |
   | `showDialog` + `AlertDialog` for yes/no | `AppDialog.confirm` |

   If something is missing, add it to the shared widgets (see rule 9) instead of
   styling it in one screen.

2. **Take styles from the theme.** Don't hard-code colors, font sizes or borders, and
   don't check for dark mode yourself. Use `context.colors` and `context.textTheme`.
3. **Use spacing values, not numbers.** `AppSpacing.lg` instead of `16`,
   `AppRadius.md` instead of `12`.
4. **Use typed dropdowns.** Pass a `List<T>` and an `itemLabel`. `T` needs a working
   `==` (for example, extend `Equatable`).
5. **Keep form values in your state.** The selected value lives in your `State` or
   BLoC and changes in `onChanged`. Create text controllers in `State` and dispose
   them in `dispose()`, never in `build`.
6. **Validate with `Form`.** Wrap fields in a `Form` with a `GlobalKey<FormState>` and
   call `validate()` on submit. Use `Validators` (`core/utils/validators.dart`) with
   `context.l10n`. `isRequired: true` adds the `*` and an "is required" check.
7. **Shared widgets only show things.** Code in `core/widgets` must not read BLoCs,
   `getIt` or navigation. Pass data and callbacks in. (`ThemeSwitcher` and
   `LanguageSwitcher` read cubits, so they live in `features/settings`.)
8. **Put widgets in the right place.** A widget used by one feature goes in that
   feature's `presentation/widgets/`. When a second feature needs it, move it to
   `core/widgets/`.
9. **Adding a shared widget:**
   - Name starts with `App`, has a `const` constructor and a short comment.
   - Styles come from the theme, spacing from `AppSpacing`.
   - Icon-only buttons have a `tooltip`, tap areas are at least 48 dp, and text still
     fits with large font sizes.
   - Default text comes from `context.l10n`.
   - Export it from `core/widgets/widgets.dart` and add it to the list above.
10. **No hard-coded text on screens.** Add it to the `.arb` files and use
    `context.l10n` (see [Translations](#translations)). The examples below use plain
    text only to keep them short.

### Widget reference

Each widget below has:

- **What it is:** what it shows on screen.
- **Type:** the kind of Flutter widget. A **form field** works inside a `Form`: it
  shows its error under the field when you call `_formKey.currentState!.validate()`.
- **When to use:** where it fits.
- **Parameters:** everything you can pass. Parameters without a default are optional
  unless marked **required**.
- **Examples** you can copy.

The examples use plain text to keep them short. In real screens, use
`context.l10n.yourKey` (see [Translations](#translations)). Names like
`RequestsBloc`, `CountryEntity` or `RoutesName.requests` stand for your own feature
code.

---

#### AppButton

**What it is:** a button with a label, an optional icon and an optional loading
spinner.

**Type:** stateless widget. Not a form field.

**When to use:** for every button in the app. Pick the style with a named
constructor:

| Constructor | Looks like | Use for | Default size | Full width |
|---|---|---|---|---|
| `AppButton(...)` | Filled, brand color | The main action on a screen (one per screen) | large | yes |
| `AppButton.secondary(...)` | Outlined | Other actions next to the main one ("Cancel", "Back") | large | yes |
| `AppButton.text(...)` | Text only | Links like "Forgot password?" or "Skip" | medium | no |
| `AppButton.danger(...)` | Filled, red | Actions that can't be undone ("Delete") | large | yes |

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `label` | `String` | **required** | Button text |
| `onPressed` | `VoidCallback?` | **required** | Called on tap. Pass `null` to disable the button |
| `size` | `AppButtonSize` | see table above | `small` (36 high), `medium` (44) or `large` (52) |
| `icon` | `IconData?` | | Icon before the text |
| `trailingIcon` | `IconData?` | | Icon after the text |
| `isLoading` | `bool` | `false` | Shows a spinner and ignores taps |
| `isExpanded` | `bool` | see table above | `true` fills the width, `false` fits the text |

```dart
// Main action with loading
AppButton(
  label: 'Save',
  isLoading: state.status == ProfileStatus.saving,
  onPressed: _save,
);

// Other styles
AppButton.secondary(label: 'Cancel', onPressed: () => Navigator.pop(context));
AppButton.text(label: 'Forgot password?', onPressed: _openForgotPassword);
AppButton.danger(label: 'Delete account', icon: Icons.delete_outline, onPressed: _delete);

// Icon after the text, smaller button
AppButton(
  label: 'Next',
  trailingIcon: Icons.arrow_forward,
  size: AppButtonSize.medium,
  onPressed: _next,
);

// Disabled until the form is valid
AppButton(label: 'Submit', onPressed: _canSubmit ? _submit : null);

// Two buttons side by side
Row(
  children: [
    Expanded(child: AppButton.secondary(label: 'Back', onPressed: _back)),
    const SizedBox(width: AppSpacing.md),
    Expanded(child: AppButton(label: 'Next', onPressed: _next)),
  ],
);
```

Tips:

- Inside a `Row`, wrap each button in `Expanded`, or pass `isExpanded: false`.
  Otherwise Flutter shows a layout error.
- Don't show a separate spinner next to the button. Use `isLoading: true`.

---

#### AppTextField

**What it is:** a text box with a label, hint, icons and error message.

**Type:** stateless widget, **form field** (built on `TextFormField`).

**When to use:** any text input in a form: name, email, phone, amount, notes,
address.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `controller` | `TextEditingController?` | | Reads and sets the text. Don't use together with `initialValue` |
| `initialValue` | `String?` | | Starting text when you don't use a controller |
| `label` | `String?` | | Label above the field |
| `hint` | `String?` | | Grey text when the field is empty |
| `helperText` | `String?` | | Small text under the field |
| `isRequired` | `bool` | `false` | Adds a red `*`. If there's no `validator`, it also shows "{label} is required" when empty |
| `validator` | `FormFieldValidator<String>?` | | Your own check. Return an error text, or `null` if OK |
| `prefixIcon` | `IconData?` | | Icon at the start |
| `suffix` | `Widget?` | | Widget at the end (e.g. an `IconButton`) |
| `keyboardType` | `TextInputType?` | | Keyboard type: email, number, phone... |
| `textInputAction` | `TextInputAction?` | | Keyboard button: `next`, `done`, `search`... |
| `textCapitalization` | `TextCapitalization` | `none` | e.g. `words` for names |
| `obscureText` | `bool` | `false` | Hides the text (use `AppPasswordField` for passwords) |
| `enabled` | `bool` | `true` | `false` greys it out |
| `readOnly` | `bool` | `false` | Shows the text but can't be edited |
| `autofocus` | `bool` | `false` | Opens the keyboard when the screen opens |
| `minLines` | `int?` | | Minimum height in lines |
| `maxLines` | `int?` | `1` | More than 1 (or `null`) makes it multi-line |
| `maxLength` | `int?` | | Max characters, shows a counter |
| `inputFormatters` | `List<TextInputFormatter>?` | | Limit what can be typed (e.g. digits only) |
| `autofillHints` | `Iterable<String>?` | | Lets the phone fill it (email, name, address...) |
| `focusNode` | `FocusNode?` | | Control focus yourself |
| `autovalidateMode` | `AutovalidateMode?` | | When to check: e.g. `onUserInteraction` checks while typing |
| `onChanged` | `ValueChanged<String>?` | | Called on every change |
| `onSubmitted` | `ValueChanged<String>?` | | Called when the keyboard button is pressed |
| `onTap` | `VoidCallback?` | | Called when the field is tapped |

```dart
// Required name
AppTextField(
  controller: _nameController,
  label: 'Full name',
  isRequired: true,                        // * and "Full name is required"
  prefixIcon: Icons.person_outline,
  textCapitalization: TextCapitalization.words,
  textInputAction: TextInputAction.next,
);

// Email with the email check
AppTextField(
  controller: _emailController,
  label: 'Email',
  isRequired: true,
  keyboardType: TextInputType.emailAddress,
  autofillHints: const [AutofillHints.email],
  validator: (value) => Validators.email(value, context.l10n),
);

// Phone: digits only, max 10
// needs: import 'package:flutter/services.dart';
AppTextField(
  controller: _phoneController,
  label: 'Mobile number',
  prefixIcon: Icons.phone_outlined,
  keyboardType: TextInputType.phone,
  maxLength: 10,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
);

// Notes: multi-line with a counter
AppTextField(
  controller: _notesController,
  label: 'Notes',
  hint: 'Anything we should know?',
  maxLines: 4,
  maxLength: 500,
);

// Read-only value
AppTextField(initialValue: user.email, label: 'Email', readOnly: true);

// Your own check
AppTextField(
  controller: _amountController,
  label: 'Amount',
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  validator: (value) {
    final amount = double.tryParse(value ?? '');
    if (amount == null || amount <= 0) return 'Enter an amount above 0';
    return null;
  },
);
```

Tips:

- Create controllers in your `State` (`late final _nameController = TextEditingController();`)
  and call `_nameController.dispose()` in `dispose()`. Never create them in `build`.
- Read the value with `_nameController.text.trim()`.
- If you pass a `validator`, `isRequired` only adds the `*`. Your validator must also
  check for empty values.

---

#### AppPasswordField

**What it is:** a password box with a lock icon and a show/hide button.

**Type:** stateful widget, **form field** (uses `AppTextField` inside).

**When to use:** login, sign up, change password.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `controller` | `TextEditingController?` | | Reads the password |
| `label` | `String?` | translated "Password" | Label above the field |
| `hint` | `String?` | | Grey text when empty |
| `isRequired` | `bool` | `false` | Adds a red `*` |
| `validator` | `FormFieldValidator<String>?` | `Validators.password` (min 6 characters) | Your own check |
| `enabled` | `bool` | `true` | `false` greys it out |
| `textInputAction` | `TextInputAction` | `done` | Keyboard button |
| `autofillHints` | `Iterable<String>` | `[AutofillHints.password]` | Use `[AutofillHints.newPassword]` on sign-up forms |
| `focusNode` | `FocusNode?` | | Control focus yourself |
| `onChanged` | `ValueChanged<String>?` | | Called on every change |
| `onSubmitted` | `ValueChanged<String>?` | | Called when the keyboard button is pressed (e.g. submit the form) |

```dart
// Login
AppPasswordField(
  controller: _passwordController,
  onSubmitted: (_) => _submit(),
);

// Sign up: new password with at least 8 characters
AppPasswordField(
  controller: _passwordController,
  label: 'New password',
  isRequired: true,
  autofillHints: const [AutofillHints.newPassword],
  textInputAction: TextInputAction.next,
  validator: (value) => Validators.password(value, context.l10n, minLength: 8),
);

// Confirm password
AppPasswordField(
  controller: _confirmController,
  label: 'Confirm password',
  isRequired: true,
  autofillHints: const [AutofillHints.newPassword],
  validator: (value) =>
      value != _passwordController.text ? 'Passwords do not match' : null,
);
```

---

#### AppSearchField

**What it is:** a search box with a search icon and a clear (x) button.

**Type:** stateful widget. **Not** a form field.

**When to use:** to filter a list, or to search through an API.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `controller` | `TextEditingController?` | | Optional. The widget makes its own if you don't pass one |
| `hint` | `String?` | translated "Search" | Grey text when empty |
| `onChanged` | `ValueChanged<String>?` | | Called when the text changes. Also called with `''` when the user taps clear |
| `onSubmitted` | `ValueChanged<String>?` | | Called when the keyboard search button is pressed |
| `debounce` | `Duration` | `Duration.zero` | Waits until the user stops typing before calling `onChanged` |
| `autofocus` | `bool` | `false` | Opens the keyboard when the screen opens |
| `enabled` | `bool` | `true` | `false` greys it out |
| `focusNode` | `FocusNode?` | | Control focus yourself |

```dart
// Filter a list that is already loaded
AppSearchField(
  hint: 'Search contacts',
  onChanged: (query) => setState(() => _query = query),
);

// Search through the API: wait 400 ms after typing stops
AppSearchField(
  hint: 'Search requests',
  debounce: const Duration(milliseconds: 400),
  onChanged: (query) => context.read<RequestsBloc>().add(RequestsSearched(query)),
);
```

---

#### AppDropdown

**What it is:** a classic dropdown. Tap it and a small menu with all options opens.

**Type:** stateless widget, **form field** (built on `DropdownButtonFormField`).
Generic: `AppDropdown<T>`, where `T` is the type of each option.

**When to use:** short lists, up to about 10 options (gender, status, type). For
longer lists use [`AppSearchableDropdown`](#appsearchabledropdown).

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `items` | `List<T>` | **required** | All options |
| `itemLabel` | `String Function(T)` | **required** | Text shown for each option |
| `onChanged` | `ValueChanged<T?>?` | **required** | Called with the picked option. `null` disables the dropdown |
| `value` | `T?` | | The selected option (keep it in your state) |
| `label` | `String?` | | Label above the field |
| `hint` | `String?` | | Text when nothing is selected |
| `isRequired` | `bool` | `false` | Adds a red `*` and an "is required" check |
| `validator` | `FormFieldValidator<T>?` | | Your own check |
| `prefixIcon` | `IconData?` | | Icon at the start |
| `isLoading` | `bool` | `false` | Shows a spinner and "Loading…" while options load |
| `enabled` | `bool` | `true` | `false` greys it out |

```dart
// With an enum
enum Gender {
  male('Male'),
  female('Female');

  const Gender(this.label);
  final String label;
}

AppDropdown<Gender>(
  label: 'Gender',
  isRequired: true,
  items: Gender.values,
  itemLabel: (gender) => gender.label,
  value: _gender,
  onChanged: (gender) => setState(() => _gender = gender),
);

// With objects loaded from the API
AppDropdown<DepartmentEntity>(
  label: 'Department',
  items: state.departments,
  isLoading: state.isLoadingDepartments,
  itemLabel: (department) => department.name,
  value: _department,
  onChanged: (department) => setState(() => _department = department),
);
```

Tips:

- The dropdown doesn't remember the choice. Save it in `onChanged` and pass it back
  as `value`.
- `T` needs a working `==`. Enums and `Equatable` classes work. If `value` isn't found
  in `items`, nothing is shown as selected.

---

#### AppSearchableDropdown

**What it is:** looks like a dropdown, but opens a bottom sheet with a search box
and the list of options. Typing filters the list (not case sensitive). The selected
option has a check mark.

**Type:** stateless widget, **form field**. Generic: `AppSearchableDropdown<T>`.

**When to use:** long lists: countries, cities, banks, products, employees.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `items` | `List<T>` | **required** | All options |
| `itemLabel` | `String Function(T)` | **required** | Text shown for each option. Search also uses this text |
| `onChanged` | `ValueChanged<T>?` | **required** | Called with the picked option. `null` disables it |
| `value` | `T?` | | The selected option (keep it in your state) |
| `label` | `String?` | | Label above the field. Also the title of the bottom sheet |
| `hint` | `String?` | | Text when nothing is selected |
| `searchHint` | `String?` | translated "Search" | Hint in the search box |
| `isRequired` | `bool` | `false` | Adds a red `*` and an "is required" check |
| `validator` | `FormFieldValidator<T>?` | | Your own check |
| `prefixIcon` | `IconData?` | | Icon at the start |
| `isLoading` | `bool` | `false` | Shows a spinner and blocks taps while options load |
| `enabled` | `bool` | `true` | `false` greys it out |

```dart
AppSearchableDropdown<CountryEntity>(
  label: 'Country',
  hint: 'Select your country',
  searchHint: 'Type a country name',
  isRequired: true,
  prefixIcon: Icons.public,
  items: state.countries,
  isLoading: state.status == CountriesStatus.loading,
  itemLabel: (country) => country.name,
  value: _country,
  onChanged: (country) => setState(() {
    _country = country;
    _city = null;                         // reset the city when the country changes
  }),
);

// A second dropdown that depends on the first
AppSearchableDropdown<CityEntity>(
  label: 'City',
  isRequired: true,
  items: _country?.cities ?? const [],
  itemLabel: (city) => city.name,
  value: _city,
  onChanged: _country == null ? null : (city) => setState(() => _city = city),
);
```

Tips:

- If there are no options, the sheet shows "No options available". If nothing
  matches the search, it shows "No results for ...".
- Same rules as `AppDropdown`: keep `value` in your state, and `T` needs a working
  `==`.

---

#### AppDateField

**What it is:** a field that opens the date picker when tapped and shows the picked
date.

**Type:** stateless widget, **form field**.

**When to use:** date of birth, start date, due date.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `onChanged` | `ValueChanged<DateTime>?` | **required** | Called with the picked date. `null` disables it |
| `firstDate` | `DateTime` | **required** | Earliest date that can be picked |
| `lastDate` | `DateTime` | **required** | Latest date that can be picked |
| `value` | `DateTime?` | | The selected date (keep it in your state) |
| `label` | `String?` | | Label above the field |
| `hint` | `String?` | | Text when no date is picked |
| `isRequired` | `bool` | `false` | Adds a red `*` and an "is required" check |
| `validator` | `FormFieldValidator<DateTime>?` | | Your own check |
| `format` | `String Function(DateTime)` | `yyyy-MM-dd` | How the date is shown |
| `enabled` | `bool` | `true` | `false` greys it out |

```dart
AppDateField(
  label: 'Date of birth',
  isRequired: true,
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  value: _birthDate,
  onChanged: (date) => setState(() => _birthDate = date),
);

// Nicer format, e.g. "Oct 6, 2026"
// needs: import 'package:intl/intl.dart';
AppDateField(
  label: 'Start date',
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(const Duration(days: 365)),
  value: _startDate,
  format: (date) => DateFormat.yMMMd().format(date),
  onChanged: (date) => setState(() => _startDate = date),
);

// Your own check: must be 18 or older
AppDateField(
  label: 'Date of birth',
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  value: _birthDate,
  onChanged: (date) => setState(() => _birthDate = date),
  validator: (date) {
    if (date == null) return 'Date of birth is required';
    final eighteen = DateTime(date.year + 18, date.month, date.day);
    return eighteen.isAfter(DateTime.now()) ? 'You must be 18 or older' : null;
  },
);
```

---

#### AppCheckboxField

**What it is:** a checkbox with a label. The label is tappable too.

**Type:** stateless widget, **form field**.

**When to use:** "I accept the terms", "Remember me", "Send me emails".

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `label` | `String` | **required** | Text next to the checkbox |
| `value` | `bool` | **required** | Checked or not (keep it in your state) |
| `onChanged` | `ValueChanged<bool>?` | **required** | Called when tapped. `null` disables it |
| `mustBeChecked` | `bool` | `false` | Shows an error on `validate()` if not checked |
| `requiredMessage` | `String?` | translated "Please accept to continue" | Error text when `mustBeChecked` fails |
| `enabled` | `bool` | `true` | `false` greys it out |

```dart
AppCheckboxField(
  label: 'I accept the terms and conditions',
  value: _accepted,
  mustBeChecked: true,
  onChanged: (value) => setState(() => _accepted = value),
);

AppCheckboxField(
  label: 'Remember me',
  value: _rememberMe,
  onChanged: (value) => setState(() => _rememberMe = value),
);
```

---

#### AppPickerField

**What it is:** a field that looks like a text box but can't be typed in. Tapping it
calls your `onTap`, where you open any picker you like. `AppDateField` and
`AppSearchableDropdown` are built with it.

**Type:** stateless widget. **Not** a form field by itself. To validate it, wrap it in
a `FormField` (see the example).

**When to use:** to build your own picker: time, file, color, location.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `onTap` | `VoidCallback` | **required** | Called when tapped. Open your picker here |
| `valueText` | `String?` | | Text of the current value. Empty shows the `hint` |
| `label` | `String?` | | Label above the field |
| `hint` | `String?` | | Text when there's no value |
| `isRequired` | `bool` | `false` | Adds a red `*` (only the look; add a validator yourself) |
| `errorText` | `String?` | | Error text under the field |
| `prefixIcon` | `IconData?` | | Icon at the start |
| `suffixIcon` | `IconData` | `Icons.arrow_drop_down` | Icon at the end |
| `isLoading` | `bool` | `false` | Shows a spinner and blocks taps |
| `enabled` | `bool` | `true` | `false` greys it out and blocks taps |

```dart
// Time picker with validation
FormField<TimeOfDay>(
  initialValue: _time,
  validator: (time) => time == null ? 'Pick a time' : null,
  builder: (field) => AppPickerField(
    label: 'Pickup time',
    isRequired: true,
    suffixIcon: Icons.access_time,
    valueText: field.value?.format(context),
    errorText: field.errorText,
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: field.value ?? TimeOfDay.now(),
      );
      if (picked == null) return;
      field.didChange(picked);
      setState(() => _time = picked);
    },
  ),
);
```

---

#### AppFieldLabel

**What it is:** the label text used by all inputs. Adds a red `*` when the field is
required.

**Type:** stateless widget.

**When to use:** you rarely need it directly. The inputs above use it. Use it if you
build a new input and want the same label style.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `text` | `String` | **required** (first argument) | Label text |
| `isRequired` | `bool` | `false` | Adds a red `*` |

```dart
InputDecoration(label: AppFieldLabel('Company', isRequired: true));
```

The same file has `requiredMessage(context, label)`, which returns the translated
"{label} is required" text.

---

#### AppSnackBar (toasts)

**What it is:** a short message that floats at the bottom of the screen and hides by
itself after a few seconds. This is the app's **toast**. It has a color and icon for
each type:

| Type | Color | Icon | Use for |
|---|---|---|---|
| `AppSnackBarType.success` | green | check | "Saved", "Request sent" |
| `AppSnackBarType.error` | red | error | Something failed |
| `AppSnackBarType.warning` | orange | warning | Something needs attention |
| `AppSnackBarType.info` (default) | blue | info | General messages |

**Type:** helper class with static methods (not a widget you put in `build`).

**When to use:** to confirm an action or show an error without blocking the user.
For questions that need an answer, use [`AppDialog`](#appdialog).

| Method | What it does |
|---|---|
| `AppSnackBar.show(context, message, {type})` | Shows the message. Hides the current one first, so they don't pile up |
| `AppSnackBar.build(message, {type})` | Returns the `SnackBar` widget, if you want to show it yourself |
| `getIt<NavigationService>().showSnackBar(message, {type})` | Same as `show`, but without a `BuildContext` (for services and app-level listeners) |

```dart
// Success after saving
AppSnackBar.show(context, 'Profile updated', type: AppSnackBarType.success);

// Error from a failure
AppSnackBar.show(
  context,
  failure.localizedMessage(context.l10n),
  type: AppSnackBarType.error,
);

// Info (default type)
AppSnackBar.show(context, 'Link copied');

// Outside widgets (no context)
getIt<NavigationService>().showSnackBar('Session refreshed');

// From a BLoC listener
BlocListener<ProfileBloc, ProfileState>(
  listenWhen: (previous, current) => previous.status != current.status,
  listener: (context, state) {
    if (state.status == ProfileStatus.saved) {
      AppSnackBar.show(context, 'Saved', type: AppSnackBarType.success);
    }
    if (state.status == ProfileStatus.failure) {
      AppSnackBar.show(
        context,
        state.failure!.localizedMessage(context.l10n),
        type: AppSnackBarType.error,
      );
    }
  },
  child: ...,
);
```

Tips:

- After an `await`, check `if (!context.mounted) return;` before calling
  `AppSnackBar.show(context, ...)`.
- The floating style and rounded corners come from `snackBarTheme` in
  `app_theme.dart`. Colors come from `app_colors.dart`.

---

#### AppDialog

**What it is:** popup dialogs in the app style. Button texts are translated by
default.

**Type:** helper class with static methods. Both methods return a `Future`, so you
can `await` the answer.

**When to use:** `confirm` to ask yes/no before an action. `alert` to show
information the user must read.

**`AppDialog.confirm`** returns `true` only if the user taps the confirm button.
Tapping cancel or outside returns `false`.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `context` | `BuildContext` | **required** | |
| `title` | `String` | **required** | Dialog title |
| `message` | `String?` | | Text under the title |
| `confirmLabel` | `String?` | translated "Confirm" | Confirm button text |
| `cancelLabel` | `String?` | translated "Cancel" | Cancel button text |
| `isDestructive` | `bool` | `false` | Makes the confirm button red |

**`AppDialog.alert`** shows a message with one button.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `context` | `BuildContext` | **required** | |
| `title` | `String` | **required** | Dialog title |
| `message` | `String?` | | Text under the title |
| `buttonLabel` | `String?` | translated "OK" | Button text |

```dart
// Ask before deleting
final confirmed = await AppDialog.confirm(
  context,
  title: 'Delete request?',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  isDestructive: true,
);
if (!confirmed || !context.mounted) return;
context.read<RequestsBloc>().add(RequestDeleted(request.id));

// Show information
await AppDialog.alert(
  context,
  title: 'Request sent',
  message: 'We will reply within 2 working days.',
);
```

---

#### AppLoader

**What it is:** a spinner in the middle of the space, with optional text under it.

**Type:** stateless widget.

**When to use:** while a page or a section loads its data.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `message` | `String?` | | Text under the spinner |
| `size` | `double` | `32` | Spinner size |

```dart
BlocBuilder<ProfileBloc, ProfileState>(
  builder: (context, state) => switch (state.status) {
    ProfileStatus.loading => const AppLoader(),
    // ...
  },
);

const AppLoader(message: 'Loading your requests…');
```

---

#### AppLoadingOverlay

**What it is:** puts a dark layer and a spinner over its child and blocks all taps.

**Type:** stateless widget.

**When to use:** while saving or uploading, so the user can't tap twice. On a full
screen, use `AppScaffold(isLoading: ...)` instead. It uses this overlay inside.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `isLoading` | `bool` | **required** | Shows the overlay when `true` |
| `child` | `Widget` | **required** | The content under the overlay |
| `message` | `String?` | | Text under the spinner |

```dart
AppLoadingOverlay(
  isLoading: _isUploading,
  message: 'Uploading…',
  child: _DocumentPreview(file: _file),
);
```

---

#### AppScaffold

**What it is:** the base layout for a screen. It adds the app bar, safe area,
padding, hides the keyboard when you tap outside a field, and can scroll or show a
loading overlay.

**Type:** stateless widget.

**When to use:** as the root widget of every screen, instead of `Scaffold`.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `body` | `Widget` | **required** | Screen content |
| `title` | `String?` | | Creates a simple app bar with this title |
| `appBar` | `PreferredSizeWidget?` | | Your own app bar (then `title` and `actions` are ignored) |
| `actions` | `List<Widget>?` | | Buttons on the right of the app bar |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | Space around the body |
| `scrollable` | `bool` | `false` | Makes the body scroll (use for forms) |
| `maxContentWidth` | `double?` | | Max width of the content, useful on tablets |
| `isLoading` | `bool` | `false` | Shows a loading overlay and blocks taps |
| `loadingMessage` | `String?` | | Text in the loading overlay |
| `floatingActionButton` | `Widget?` | | Round button at the bottom right |
| `bottomNavigationBar` | `Widget?` | | Bottom bar |
| `backgroundColor` | `Color?` | | Background color (normally from the theme) |

```dart
// Simple screen
AppScaffold(
  title: 'Profile',
  body: const ProfileView(),
);

// Form screen: scrolls, blocks taps while saving
AppScaffold(
  title: 'Edit profile',
  scrollable: true,
  isLoading: state.status == ProfileStatus.saving,
  loadingMessage: 'Saving…',
  body: const ProfileForm(),
);

// List screen: the list scrolls and pads itself
AppScaffold(
  title: 'Requests',
  padding: EdgeInsets.zero,
  actions: const [LanguageSwitcher.menu(), ThemeSwitcher.menu()],
  floatingActionButton: FloatingActionButton(
    onPressed: _newRequest,
    child: const Icon(Icons.add),
  ),
  body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [...]),
);
```

Tips:

- If `body` is a `ListView` or another scrolling widget, keep `scrollable: false` and
  pass `padding: EdgeInsets.zero`. Put the padding on the list.

---

#### AppCard

**What it is:** a box with rounded corners that groups content. Can be tapped.

**Type:** stateless widget.

**When to use:** list items, summary boxes, settings groups.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `child` | `Widget` | **required** | Card content |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | Space inside the card |
| `onTap` | `VoidCallback?` | | Makes the whole card tappable (with a ripple) |
| `color` | `Color?` | | Background color (normally from the theme) |

```dart
AppCard(
  onTap: () => Navigator.pushNamed(context, RoutesName.requestDetails, arguments: request.id),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(request.title, style: context.textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      AppInfoRow(label: 'Reference', value: request.referenceNo),
    ],
  ),
);
```

---

#### AppSectionHeader

**What it is:** a section title, with an optional small text button on the right.

**Type:** stateless widget.

**When to use:** above a group of items ("Recent requests", "Personal details").

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `title` | `String` | **required** | Section title |
| `actionLabel` | `String?` | | Text of the button on the right |
| `onAction` | `VoidCallback?` | | Called when the button is tapped. The button only shows if both `actionLabel` and `onAction` are set |

```dart
AppSectionHeader(
  title: 'Recent requests',
  actionLabel: 'View all',
  onAction: () => Navigator.pushNamed(context, RoutesName.requests),
);

const AppSectionHeader(title: 'Personal details');
```

---

#### AppEmptyState

**What it is:** a big icon, a title, optional text and an optional button, in the
middle of the space.

**Type:** stateless widget.

**When to use:** when a list is empty, or a screen has nothing to show yet.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `title` | `String` | **required** | Main text |
| `message` | `String?` | | Smaller text under the title |
| `icon` | `IconData` | `Icons.inbox_outlined` | Big icon on top |
| `actionLabel` | `String?` | | Button text |
| `onAction` | `VoidCallback?` | | Button action. The button only shows if both are set |

```dart
AppEmptyState(
  icon: Icons.assignment_outlined,
  title: 'No requests yet',
  message: 'Requests you submit will appear here.',
  actionLabel: 'New request',
  onAction: _newRequest,
);
```

---

#### AppErrorState

**What it is:** like `AppEmptyState`, but with an error icon and a "Try again"
button.

**Type:** stateless widget.

**When to use:** when loading data failed and the user can try again.

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `message` | `String` | **required** | Error text. Use `failure.localizedMessage(context.l10n)` |
| `title` | `String?` | translated "Something went wrong" | Main text |
| `onRetry` | `VoidCallback?` | | Called when "Try again" is tapped. No button if `null` |
| `retryLabel` | `String?` | translated "Try again" | Button text |

```dart
AppErrorState(
  message: state.failure!.localizedMessage(context.l10n),
  onRetry: () => context.read<RequestsBloc>().add(const RequestsRequested()),
);
```

---

#### AppBadge

**What it is:** a small rounded label with a light background, in one of five
colors.

**Type:** stateless widget.

**When to use:** to show a status: "Approved", "Pending", "Rejected", "New".

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `label` | `String` | **required** | Badge text |
| `tone` | `AppBadgeTone` | `neutral` | Color: `neutral` (grey), `info` (blue), `success` (green), `warning` (orange), `error` (red) |
| `icon` | `IconData?` | | Small icon before the text |

```dart
const AppBadge(label: 'Approved', tone: AppBadgeTone.success, icon: Icons.check);
const AppBadge(label: 'Pending', tone: AppBadgeTone.warning);

// Pick the tone in your feature, not inside AppBadge
extension RequestStatusX on RequestStatus {
  AppBadgeTone get tone => switch (this) {
    RequestStatus.approved => AppBadgeTone.success,
    RequestStatus.pending => AppBadgeTone.warning,
    RequestStatus.rejected => AppBadgeTone.error,
  };
}

AppBadge(label: request.status.label, tone: request.status.tone);
```

---

#### AppInfoRow

**What it is:** a label on the left and its value on the right (or under it).
Empty values show `-`.

**Type:** stateless widget.

**When to use:** detail and review screens ("Reference: REQ-001").

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `label` | `String` | **required** | Label text (grey) |
| `value` | `String?` | **required** | Value text (bold). `null` or empty shows `-` |
| `stacked` | `bool` | `false` | `true` puts the value under the label, for long values |

```dart
Column(
  children: [
    AppInfoRow(label: 'Reference', value: request.referenceNo),
    const SizedBox(height: AppSpacing.sm),
    AppInfoRow(label: 'Submitted on', value: request.submittedOn),
    const SizedBox(height: AppSpacing.sm),
    AppInfoRow(label: 'Address', value: request.address, stacked: true),
  ],
);
```

---

#### Validators

**What it is:** ready-made checks for form fields. They return a translated error
text, or `null` if the value is OK.

**Type:** helper class with static methods (`core/utils/validators.dart`).

| Method | Checks |
|---|---|
| `Validators.required(value, l10n, {fieldName})` | Not empty. Message: "{fieldName} is required" or "This field is required" |
| `Validators.email(value, l10n)` | Not empty and a valid email |
| `Validators.password(value, l10n, {minLength = 6})` | Not empty and at least `minLength` characters |

```dart
AppTextField(
  label: 'Email',
  validator: (value) => Validators.email(value, context.l10n),
);

// Combine checks: required first, then your own rule
AppTextField(
  label: 'Username',
  validator: (value) =>
      Validators.required(value, context.l10n, fieldName: 'Username') ??
      (value!.contains(' ') ? 'No spaces allowed' : null),
);
```

---

#### AppSpacing and AppRadius

**What it is:** fixed sizes for spacing and rounded corners
(`core/constants/app_dimens.dart`). Use them instead of typing numbers, so all
screens look the same.

| `AppSpacing` | Value | | `AppRadius` | Value |
|---|---|---|---|---|
| `xxs` | 2 | | `sm` | 8 |
| `xs` | 4 | | `md` | 12 |
| `sm` | 8 | | `lg` | 16 |
| `md` | 12 | | `pill` | 999 (fully round) |
| `lg` | 16 | | | |
| `xl` | 24 | | | |
| `xxl` | 32 | | | |
| `xxxl` | 48 | | | |

```dart
const SizedBox(height: AppSpacing.md);                  // gap between fields
const EdgeInsets.all(AppSpacing.lg);                     // screen padding
BorderRadius.circular(AppRadius.md);                     // rounded corners
```

---

#### Context shortcuts

From `core/extensions/context_extensions.dart`:

| Shortcut | Same as | Example |
|---|---|---|
| `context.colors` | `Theme.of(context).colorScheme` | `context.colors.primary` |
| `context.textTheme` | `Theme.of(context).textTheme` | `context.textTheme.titleMedium` |
| `context.theme` | `Theme.of(context)` | `context.theme.brightness` |
| `context.l10n` | `AppLocalizations.of(context)` | `context.l10n.signIn` |

---

### Full screen examples

**A form screen.** Text fields, a searchable dropdown, a date, a checkbox and a
submit button, with validation:

```dart
class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  CountryEntity? _country;
  DateTime? _date;
  bool _accepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<NewRequestBloc>().add(
      NewRequestSubmitted(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        country: _country!,
        date: _date!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewRequestBloc, NewRequestState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == NewRequestStatus.success) {
          AppSnackBar.show(context, 'Request sent', type: AppSnackBarType.success);
          Navigator.pop(context);
        }
        if (state.status == NewRequestStatus.failure) {
          AppSnackBar.show(
            context,
            state.failure!.localizedMessage(context.l10n),
            type: AppSnackBarType.error,
          );
        }
      },
      builder: (context, state) => AppScaffold(
        title: 'New request',
        scrollable: true,
        isLoading: state.status == NewRequestStatus.submitting,
        loadingMessage: 'Sending…',
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader(title: 'Your details'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameController,
                label: 'Full name',
                isRequired: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => Validators.email(value, context.l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSearchableDropdown<CountryEntity>(
                label: 'Country',
                isRequired: true,
                items: state.countries,
                isLoading: state.isLoadingCountries,
                itemLabel: (country) => country.name,
                value: _country,
                onChanged: (country) => setState(() => _country = country),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppDateField(
                label: 'Preferred date',
                isRequired: true,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                value: _date,
                onChanged: (date) => setState(() => _date = date),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCheckboxField(
                label: 'I accept the terms and conditions',
                value: _accepted,
                mustBeChecked: true,
                onChanged: (value) => setState(() => _accepted = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Send request', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
```

**A list screen.** Loading, error, empty and list states:

```dart
class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My requests',
      padding: EdgeInsets.zero,
      body: BlocBuilder<RequestsBloc, RequestsState>(
        builder: (context, state) => switch (state.status) {
          RequestsStatus.initial || RequestsStatus.loading => const AppLoader(),
          RequestsStatus.failure => AppErrorState(
            message: state.failure!.localizedMessage(context.l10n),
            onRetry: () => context.read<RequestsBloc>().add(const RequestsRequested()),
          ),
          RequestsStatus.success when state.requests.isEmpty => const AppEmptyState(
            title: 'No requests yet',
            message: 'Requests you submit will appear here.',
          ),
          RequestsStatus.success => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final request = state.requests[index];
              return AppCard(
                onTap: () => Navigator.pushNamed(
                  context,
                  RoutesName.requestDetails,
                  arguments: request.id,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(request.title, style: context.textTheme.titleMedium),
                        ),
                        AppBadge(label: request.status.label, tone: request.status.tone),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppInfoRow(label: 'Reference', value: request.referenceNo),
                  ],
                ),
              );
            },
          ),
        },
      ),
    );
  }
}
```

Real examples in the app: `features/auth/presentation/widgets/login_form.dart`,
`features/home/presentation/pages/home_page.dart` and
`features/home/presentation/widgets/push_status_card.dart`.

---

## Theme and language

Both are saved and come back when the app opens again. By default the app follows
the phone (system theme, phone language, English if the language isn't supported).

| Part | File | Saved as |
|---|---|---|
| `ThemeCubit` | `core/theme/theme_cubit.dart` | `system`, `light` or `dark` |
| `LocaleCubit` (`null` = phone language) | `core/localization/locale_cubit.dart` | language code, e.g. `ar` |

Both are created in `app/app.dart`, above `MaterialApp`.

### Switcher widgets

In `features/settings/presentation/widgets/`. Each one has a full version for a
settings screen and a small `.menu()` version for the app bar:

```dart
// App bar
AppScaffold(
  title: context.l10n.homeTitle,
  actions: const [LanguageSwitcher.menu(), ThemeSwitcher.menu()],
  body: ...,
);

// Settings screen
ListView(
  padding: const EdgeInsets.all(AppSpacing.lg),
  children: [
    AppSectionHeader(title: context.l10n.themeLabel),
    const SizedBox(height: AppSpacing.md),
    const ThemeSwitcher(),                 // System / Light / Dark
    const SizedBox(height: AppSpacing.xl),
    AppSectionHeader(title: context.l10n.languageLabel),
    const LanguageSwitcher(),              // "System default" + each language
  ],
);
```

From code: `context.read<ThemeCubit>().setThemeMode(ThemeMode.dark)` and
`context.read<LocaleCubit>().setLocale(const Locale('ar'))` (`null` = phone language).

### Translations

Texts are in `lib/l10n/arb/`. `app_en.arb` is the main file. Other files have the same
keys, translated. Use them with `context.l10n`:

```dart
Text(context.l10n.loginTitle);
Text(context.l10n.homeGreeting(user.fullName));   // {name} becomes a parameter
```

**Add a text:** add the key to `app_en.arb` (with an `@key` entry if it has
parameters) and to every other `.arb` file. The code is created again on
`flutter pub get` or `flutter run`, or run `flutter gen-l10n`.

**Add a language** (e.g. French):

1. Create `lib/l10n/arb/app_fr.arb` with `"@@locale": "fr"` and all keys from
   `app_en.arb`. Set `languageName` to `"Français"`. That's the name the switcher
   shows.
2. Add `<string>fr</string>` to `CFBundleLocalizations` in `ios/Runner/Info.plist`.
3. If it needs its own font, add it to `AppTypography.fontFamilyByLanguage`.
4. Run `flutter gen-l10n`. The language now shows up in `LanguageSwitcher`.

Arabic and other right-to-left languages flip the layout by themselves. In your own
widgets, use `EdgeInsetsDirectional` and `AlignmentDirectional` (`start` / `end`)
instead of `left` / `right`.

---

## Fonts and images

### Fonts

Two fonts are included:

| Family | Files | Weights | Used for |
|---|---|---|---|
| `ProximaNova` | `fonts/proximanova_*` | 400, 700 | The whole app |
| `DubaiFont` | `fonts/Dubai-*.ttf` | 300, 400, 500, 700 | Arabic, and Arabic letters in English text |

All font settings are in `lib/core/constants/app_typography.dart`:

```dart
class AppFonts {                       // one name per `family:` in pubspec.yaml
  static const String proximaNova = 'ProximaNova';
  static const String dubai = 'DubaiFont';
}

class AppTypography {
  // Font for the whole app. Change this to switch fonts.
  static const String fontFamily = AppFonts.proximaNova;

  // Font per language. Other languages use fontFamily.
  static const Map<String, String> fontFamilyByLanguage = {
    'ar': AppFonts.dubai,
  };

  // Used when the main font doesn't have a letter (e.g. Arabic in English text).
  static const List<String> fontFamilyFallback = [AppFonts.dubai];
}
```

When the user changes the language, the font changes right away on every screen,
dialog and snackbar.

| I want to... | Change |
|---|---|
| Use one font for all languages | `fontFamilyByLanguage = {}` |
| Use Dubai for the whole app | `fontFamily = AppFonts.dubai` |
| Use a font for a new language | Add e.g. `'fr': AppFonts.someFont` |

**Add a new font** (e.g. Cairo):

1. Put the files in `fonts/`, e.g. `Cairo-Regular.ttf`, `Cairo-Medium.ttf`,
   `Cairo-Bold.ttf`.
2. Add it under `fonts:` in `pubspec.yaml`, one `asset` per file with its weight:

   ```yaml
   fonts:
     - family: Cairo
       fonts:
         - asset: fonts/Cairo-Regular.ttf
           weight: 400
         - asset: fonts/Cairo-Medium.ttf
           weight: 500
         - asset: fonts/Cairo-Bold.ttf
           weight: 700
         # italic files: add `style: italic`
   ```

3. Add `static const String cairo = 'Cairo';` to `AppFonts` (same name as `family`).
   Then use it in `fontFamily` or `fontFamilyByLanguage`.
4. Stop the app and run it again. Hot reload doesn't load new fonts.
5. Delete fonts you don't use. Each font makes the app bigger.

Good to know:

- Proxima Nova has no Arabic letters. Keep an Arabic font (Dubai, Cairo, Tajawal,
  IBM Plex Sans Arabic) for `'ar'` and in `fontFamilyFallback`.
- The theme uses weights 400, 600 and 700. If a weight has no file, the closest one
  is used (Proxima Nova and Dubai have no 600, so Bold is used).
- **Check the font license before you publish**, especially in a public repo. Fonts
  like Proxima Nova and Dubai usually can't be shared freely. Most Google Fonts can.

### Images

Files in `assets/images/` are included in the app automatically.

1. Add the file, e.g. `assets/images/logo.png`. For sharp images on all screens, also
   add `assets/images/2.0x/logo.png` and `assets/images/3.0x/logo.png`.
2. Add a constant in `lib/core/constants/app_assets.dart`:

   ```dart
   static const String logo = '$images/logo.png';
   ```

3. Use it: `Image.asset(AppAssets.logo, height: 48)`.

A new folder (e.g. `assets/animations/`) must be added under `assets:` in
`pubspec.yaml`. Subfolders are not included automatically (except `2.0x/` and
`3.0x/`). Then restart the app.

Don't put secrets in assets. Anyone can open the app and read them.

---

## App icon

All app icons are made from one PNG with
[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons). It's only a
dev tool, so it doesn't make the app bigger.

| File | What it is |
|---|---|
| `assets/icon/app_icon.png` | Your icon. Starts as the Flutter logo |
| `flutter_launcher_icons:` in `pubspec.yaml` | Icon settings |
| `tool/generate_app_icons.sh` | Checks the image and creates all icons |

### Change the app icon

1. **Prepare the image:**
   - PNG, **1024×1024**, square.
   - **No rounded corners.** iOS and Android round them for you.
   - No transparency. iOS doesn't allow it, so transparent parts become white
     (`background_color_ios` in `pubspec.yaml`).
   - Keep the logo away from the edges, because corners get cut off.
2. **Create the icons:**

   ```bash
   ./tool/generate_app_icons.sh ~/Downloads/my_icon.png
   ```

   This copies your file to `assets/icon/app_icon.png` and creates all sizes. If you
   already replaced `assets/icon/app_icon.png`, run the script without a file.
3. **Check** with `git diff`. It changes:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
4. **See it on a phone:** uninstall the app first (phones cache icons), then run it
   again. On iOS, run `flutter clean` if you still see the old icon.
5. **Commit** your PNG and the created files.

You can also run `dart run flutter_launcher_icons`. The script does the same, but
also checks your image and fixes a small bug in `flutter_launcher_icons` 0.14 that
changes a setting in `ios/Runner.xcodeproj/project.pbxproj`.

### Android adaptive icon (recommended)

On Android 8 and newer, icons are cut into circles or other shapes. Without an
adaptive icon, your square icon is made smaller and put on a white shape. To fix it:

1. Create `assets/icon/app_icon_foreground.png`: 1024×1024, **transparent background**,
   with the logo in the middle 66% (about 680×680 px).
2. In `flutter_launcher_icons:` in `pubspec.yaml`, remove the `#` from:

   ```yaml
   adaptive_icon_background: "#FFFFFF"   # your brand color, or an image
   adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
   ```

3. Optional, for Android 13 themed icons: add a one-color logo on transparent as
   `assets/icon/app_icon_monochrome.png` and remove the `#` from
   `adaptive_icon_monochrome`.
4. Run `./tool/generate_app_icons.sh`.

A different icon per environment (e.g. with a "DEV" label) needs Android flavors and
iOS schemes first.

---

## Code checks

```bash
dart format lib        # format the code (CI fails if it's not formatted)
flutter analyze        # find problems
```

`analysis_options.yaml` adds extra rules on top of `flutter_lints`, like package
imports only, sorted imports, `final` local variables and no forgotten `Future`s.
`dart fix --apply lib` fixes most of them for you. Files in `lib/l10n/generated/`
are skipped.

---

# Part 3: Services

## Firebase setup

Firebase is optional. If `ENABLE_FIREBASE` is `false` or the Firebase files are
missing, the app prints a warning and runs without push, analytics and crash
reports. On Android, the Firebase build plugins are only used when
`google-services.json` exists.

1. **Create a project** at <https://console.firebase.google.com>. Turn on Google
   Analytics if you want analytics. Open **Crashlytics** in the console once so it
   starts collecting reports.
2. **Android**
   - Add an Android app with your `applicationId` (e.g. `com.acme.myapp`).
   - Download **`google-services.json`** and put it in **`android/app/`**.
   - Optional: add your SHA-1 and SHA-256 fingerprints
     (`cd android && ./gradlew signingReport`).
3. **iOS**
   - Add an iOS app with your bundle id.
   - Download **`GoogleService-Info.plist`** and put it in **`ios/Runner/`**. A build
     step copies it into the app if it exists. **Don't** drag it into Xcode. That adds
     it to the project, and builds then fail on every machine that doesn't have the
     file.
   - In Xcode, Runner target, *Signing & Capabilities*:
     - Add **Push Notifications**.
     - Add **Background Modes** and tick *Remote notifications* and
       *Background fetch*.
   - In the Apple Developer portal, under *Keys*, create an **APNs key (.p8)**. Upload
     it in Firebase Console under *Project settings > Cloud Messaging > Apple app
     configuration*, with your Key ID and Team ID.
   - Push only works on a **real iPhone** (or a simulator on an Apple silicon Mac with
     a recent Xcode).
4. **Run** with `ENABLE_FIREBASE: true`. The push card on the home screen should say
   *"Firebase is configured"*. Tap **Enable notifications**, copy the token, and send a
   test message from *Firebase Console > Messaging*.
5. **Test Crashlytics** in a release build (it's off in debug): run
   `flutter run --release --dart-define-from-file=env/dev.json`, add a button that
   throws an error (e.g. `throw StateError('Crashlytics test')`), tap it, open the
   app again, and check the Crashlytics page after a few minutes.

**Better iOS crash details (optional).** Dart errors already show the Dart stack
trace. For native iOS crashes, Crashlytics needs dSYM files. In Xcode, add a
*Run Script* build phase to Runner (as the last phase) with
`"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"`,
and set *Debug Information Format* to *DWARF with dSYM File* for Release. See the
[Crashlytics docs](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter).

The Firebase files are ignored by git. Remove them from `.gitignore` if you want to
commit them.

**Using the FlutterFire CLI instead:** run
`dart pub global activate flutterfire_cli && flutterfire configure`. It creates
`lib/firebase_options.dart`. Then pass
`options: DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp` in
`core/services/firebase/firebase_bootstrap.dart`.

---

## CI/CD with Codemagic

[Codemagic](https://codemagic.io) builds the app using `codemagic.yaml`:

| Workflow | When | What it does |
|---|---|---|
| `ci` | Every push and pull request | Checks format, runs `flutter analyze` |
| `android-release` | Tags starting with `v` | Signed `.aab` uploaded to Google Play (internal track, as draft) |
| `ios-release` | Tags starting with `v` | Signed `.ipa` uploaded to TestFlight |

Release builds need files that are not in git. `tool/ci/write_config.sh prod` creates
them from Codemagic environment variables: `env/prod.json`, the Firebase files and
`android/key.properties`. The build number comes from Codemagic (`$BUILD_NUMBER`), the
version name from `pubspec.yaml`.

`ci` works as soon as you connect the repo. The release builds need the setup below.
Names like `app_env`, `upload_keystore` and `asc_api_key` must be exactly the same as
in `codemagic.yaml`.

### 1. Connect the repo

1. Sign in at <https://codemagic.io> with GitHub and allow access to the repo.
2. Click **Add application**, pick the repo and choose **Flutter App**. Codemagic finds
   `codemagic.yaml` and starts builds on pushes, pull requests and tags.
3. Push a commit and check that `ci` passes.

### 2. Environment variables

In your app in Codemagic, open **Environment variables** and add these to the groups
below. Mark everything as **Secret** except `API_VERSION` and `ENABLE_FIREBASE`.

| Group | Variable | Value |
|---|---|---|
| `app_env` | `BASE_URL` | Your live API, e.g. `https://api.acme.com/api/` (**required**) |
| `app_env` | `API_VERSION` | e.g. `v1` (optional) |
| `app_env` | `ENABLE_FIREBASE` | `true` or `false` (optional) |
| `firebase` | `GOOGLE_SERVICES_JSON` | `google-services.json` as base64 |
| `firebase` | `GOOGLE_SERVICE_INFO_PLIST` | `GoogleService-Info.plist` as base64 |
| `google_play` | `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | Google Play service account JSON (paste as is, not base64) |

Turn the Firebase files into base64 on one line:

```bash
base64 -i android/app/google-services.json | pbcopy        # macOS (copies it)
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy
base64 -w0 android/app/google-services.json                 # Linux
```

Not using Firebase on CI? Keep the `firebase` group but leave it empty. The app will
run without Firebase.

### 3. Android: keystore and Google Play

1. **Keystore.** In Codemagic, go to **Teams**, your team, **Code signing identities**,
   **Android keystores**. Upload your keystore (from
   [step 11](#step-11-set-up-release-signing)) with its passwords and alias. Name it
   **`upload_keystore`**.
2. **Service account.** In [Google Cloud Console](https://console.cloud.google.com),
   turn on the **Google Play Android Developer API**, create a service account and a
   JSON key. Put the JSON in `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`.
3. **Give access.** In [Play Console](https://play.google.com/console), open **Users and
   permissions** and invite the service account's email with release permissions.
4. **Upload the first build by hand.** Create the app in Play Console and upload the
   first `.aab` yourself (from Codemagic's artifacts, or built on your computer).
   Google Play doesn't allow the first upload through the API.

### 4. iOS: App Store Connect and signing

1. **Create the app** in [App Store Connect](https://appstoreconnect.apple.com) with
   your bundle id.
2. **API key.** In App Store Connect, go to **Users and Access**, **Integrations**,
   **App Store Connect API**, and create a key with the **App Manager** role. Download
   the `.p8` file (you can only do this once) and note the **Issuer ID** and **Key ID**.
3. **Add the key to Codemagic.** Go to **Teams**, your team, **Team integrations**,
   **Developer Portal**, **Manage keys**, and add it with the name **`asc_api_key`**.
4. **Certificate and profile.** In **Code signing identities**, create (or upload) an
   **Apple Distribution** certificate. Then under **iOS provisioning profiles**, fetch
   the **App Store** profile for your bundle id.
5. **Push notifications.** If you use push, turn on **Push Notifications** for your App
   ID in the
   [Apple Developer portal](https://developer.apple.com/account/resources/identifiers/list)
   **before** you fetch the profile. Fetch the profile again whenever you change
   capabilities.

The `bundle_identifier` in `codemagic.yaml` must match your app. The rename script
changes it for you.

### 5. Release a version

```bash
# change `version:` in pubspec.yaml (e.g. 1.2.0+1), commit, then:
git tag v1.2.0
git push origin v1.2.0
```

Both release builds start. Android goes to the internal track as a draft. iOS goes to
TestFlight after Apple processes it (usually 10 to 30 minutes). You can also start any
build by hand with **Start new build**.

**Staging builds:** copy `android-release` / `ios-release` into new workflows, change
`write_config.sh prod` to `staging` and `env/prod.json` to `env/staging.json`, and use
a group with your staging `BASE_URL`.

---

## Common problems

### On your computer

- **"Configuration error" screen:** the app was started without
  `--dart-define-from-file`, the env file is missing, or `BASE_URL` isn't a full
  address. Check [step 5](#step-5-create-the-env-files) and
  [step 6](#step-6-run-the-app).
- **"Please check your internet connection" but the server is running:** the address
  is wrong for where the app runs (`10.0.2.2` on the Android emulator, `localhost` on
  the iOS simulator, your computer's IP on a real phone). Also check that your server
  listens on `0.0.0.0` (not only `127.0.0.1`) and that you're not using `http://` in a
  release build or on iOS.
- **Login always says "session expired":** your login API returns 401 without a
  `message`. Return a message like "Wrong email or password".
- **New text key not found:** run `flutter gen-l10n` and check the key is in **every**
  `.arb` file.
- **New font or image doesn't show:** stop the app and run it again. Check the
  `family:` name matches `AppFonts`.
- **Old app icon:** uninstall the app. On iOS, also run `flutter clean`.
- **Android crash "Crashlytics build ID is missing":** the Crashlytics plugin isn't
  applied. It's only applied when `android/app/google-services.json` exists.
- **iOS "No profiles for ... were found":** set your team
  ([step 4](#step-4-set-your-apple-team)) and use a bundle id nobody else uses.
- **No push token on iOS:** use a real iPhone, add the Push Notifications capability
  and upload the APNs key to Firebase.

### On Codemagic

Look at the log of the step that failed. `write_config.sh` prints `✓` for each file it
created and `!` for each one it skipped.

**Builds don't start**

- *Nothing happens on push or tag:* check **Webhooks** in your Codemagic app. If
  there's no webhook, connect the repo again.
- *Tag pushed but no release build:* `git push` doesn't push tags. Use
  `git push origin v1.2.0`. The tag must start with `v`.
- *"No workflows found" or YAML errors:* `codemagic.yaml` must be in the root of the
  branch or tag you build.

**`ci` build**

- *Format check fails:* run `dart format lib` and commit.
- *Works on my computer, fails on CI:* compare `flutter --version` with `flutter:` in
  `codemagic.yaml`. Update both when you upgrade Flutter.

**Settings**

- *Release app shows "Configuration error":* the `app_env` group is missing, has a
  different name, or has no `BASE_URL`.
- *`base64: invalid input`:* the value has line breaks. Encode it again with the
  commands above and paste the whole value.
- *Release app has no Firebase:* the log shows `! GOOGLE_SERVICES_JSON not set` or
  `! GOOGLE_SERVICE_INFO_PLIST not set`. Add them to the `firebase` group. The
  Firebase apps must use the same ids as the build.

**Android**

- *"No keystore with reference upload_keystore":* the keystore name in Codemagic
  doesn't match `codemagic.yaml`.
- *Play says the bundle is debug-signed:* `key.properties` wasn't created (no
  `✓ android/key.properties` in the log). Check the keystore setup.
- *"Keystore was tampered with, or password was incorrect":* a password or the alias
  in Codemagic is wrong.
- *"Package not found: com.acme.myapp":* the app isn't in Play Console yet, or the
  first build wasn't uploaded by hand.
- *"The caller does not have permission":* the service account wasn't invited in Play
  Console, or doesn't have release permission. New access can take some time.
- *"Only releases with status draft may be created on draft app":* keep
  `submit_as_draft: true` until the app is published once.
- *"Version code N has already been used":* the build number is too low. Use the
  latest number from Play plus one:

  ```bash
  LATEST=$(google-play get-latest-build-number --package-name com.acme.myapp)
  flutter build appbundle --release --build-number=$((LATEST + 1)) \
    --dart-define-from-file=env/prod.json
  ```

**iOS**

- *"No matching profiles found for bundle identifier":* `bundle_identifier` in
  `codemagic.yaml` doesn't match, or no App Store profile was fetched.
- *No valid signing certificate:* add an Apple Distribution certificate. Apple allows
  only a few per team, so remove old ones if needed.
- *"Provisioning profile doesn't include the aps-environment entitlement":* turn on
  Push Notifications for the App ID, then fetch the profile again.
- *"The bundle version must be higher than the previously uploaded version":* use the
  latest TestFlight number plus one:

  ```bash
  LATEST=$(app-store-connect get-latest-testflight-build-number "<App Store app id>")
  flutter build ipa --release --build-number=$((LATEST + 1)) \
    --export-options-plist=/Users/builder/export_options.plist \
    --dart-define-from-file=env/prod.json
  ```

- *Build waits on "Missing Compliance":* if the app only uses normal HTTPS, add
  `ITSAppUsesNonExemptEncryption` = `NO` to `ios/Runner/Info.plist`.
- *Swift packages fail to download:* usually a network problem. Run the build again.
  If it keeps failing, clear the cache (**Caching** in your Codemagic app).
- *Push works on my phone but not in TestFlight:* upload the APNs key to Firebase and
  turn on Push Notifications for the App ID.
- *Build takes too long:* increase `max_build_duration` (in minutes). The first iOS
  build is slower because it downloads all Swift packages.

---

## Toolchain notes

- **Xcode 27 + Flutter 3.44.5:** `flutter build ios --simulator` fails with *"Exited
  with status code 255"* in the `lipo -verify_arch` step. This is a Flutter bug, not a
  project problem. `flutter run` and `flutter build ipa` work fine. To build for the
  simulator by hand:
  `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -sdk iphonesimulator ARCHS=arm64 CODE_SIGNING_ALLOWED=NO build`.
- Gradle shows a *Kotlin Gradle Plugin* warning for some Firebase plugins. It comes
  from those plugins and is safe to ignore for now.
- iOS uses **Swift Package Manager** only. If you add a plugin that only supports
  CocoaPods, Flutter creates a `Podfile`. Set `platform :ios, '15.0'` in it.
