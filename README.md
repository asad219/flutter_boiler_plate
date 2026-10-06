# App Boilerplate

Production-ready Flutter starter with feature-first clean architecture, BLoC,
`get_it` DI, a Dio network layer with user-safe error handling and token refresh,
secure token storage, and Firebase (Core, Messaging, Analytics) with local
notifications.

**Repository:** <https://github.com/asad219/flutter_boiler_plate>

| | |
|---|---|
| Flutter / Dart | 3.44+ / `^3.12.2` |
| Android | minSdk 24, desugaring enabled |
| iOS | 15.0+, Swift Package Manager (no CocoaPods) |
| Default ids | Android `com.starter.boilerplate.app_boilerplate`, iOS `com.starter.boilerplate.appBoilerplate` |

Starting a real app? Follow
[Create a new project from this boilerplate](#create-a-new-project-from-this-boilerplate).

- [Quick start](#quick-start)
- [Create a new project from this boilerplate](#create-a-new-project-from-this-boilerplate)
- [Project structure](#project-structure)
- [Architecture](#architecture)
- [Firebase setup](#firebase-setup)
- [Scaffold a new feature](#scaffold-a-new-feature)
- [Quality](#quality)
- [CI/CD with Codemagic](#cicd-with-codemagic)
- [Toolchain notes](#toolchain-notes)

---

## Quick start

Runs the boilerplate as is, to try it out:

```bash
git clone https://github.com/asad219/flutter_boiler_plate.git
cd flutter_boiler_plate
cp env/dev.json.example env/dev.json        # set BASE_URL for your backend
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

VS Code users can pick **dev / staging / prod** from the Run panel (`.vscode/launch.json`).

The app runs without Firebase until you add the native config files; push and
analytics simply stay disabled (see [Firebase setup](#firebase-setup)).

There is no built-in demo account: login calls your backend's `POST /users/login`
(see [Auth flow](#auth-flow)).

### Environment files

Compile-time config is injected with `--dart-define-from-file` and read in
`lib/core/config/env_config.dart`. Real files (`env/dev.json`, `staging.json`,
`prod.json`) are git-ignored; commit only the `*.json.example` templates.

| Key | Example | Notes |
|---|---|---|
| `ENV` | `dev` | `dev` / `staging` / `prod` |
| `BASE_URL` | `https://api.example.com/api/` | Required. `EnvConfig.validate()` fails fast if missing. |
| `API_VERSION` | `v1` | Joined to `BASE_URL` → `…/api/v1` |
| `ENABLE_FIREBASE` | `true` | `false` skips Firebase entirely (CI, early dev) |

> Android emulator → host machine is `http://10.0.2.2`. Cleartext HTTP is allowed
> in **debug builds only** (`android/app/src/debug/AndroidManifest.xml`).

---

## Create a new project from this boilerplate

### TL;DR

Replace `my_app`, `com.acme.myapp`, `My App` and `YOURTEAMID` with your own values:

```bash
# 1. Clone the boilerplate into a new folder and start a fresh git history
git clone --depth 1 https://github.com/asad219/flutter_boiler_plate.git my_app
cd my_app
rm -rf .git
git init && git add -A && git commit -m "Start from flutter_boiler_plate"

# 2. Rename the package, Android id, iOS bundle id and display name
./tool/rename_app.sh \
  --package my_app \
  --android-id com.acme.myapp \
  --ios-id com.acme.myapp \
  --name "My App"

# 3. Use your Apple Developer team (Team ID: developer.apple.com/account → Membership)
perl -pi -e 's/E65WYSUT4Y/YOURTEAMID/g' ios/Runner.xcodeproj/project.pbxproj

# 4. Create env files, then set BASE_URL in each one
for e in dev staging prod; do cp env/$e.json.example env/$e.json; done

# 5. Check and run
flutter analyze && flutter test
flutter run --dart-define-from-file=env/dev.json
git add -A && git commit -m "Rename to My App"
```

The app now runs under your name and ids. Push and analytics stay off until you add
Firebase. To finish, do [Firebase](#6-configure-firebase-or-turn-it-off),
[branding](#7-brand-the-app) and [release signing](#8-set-up-release-signing).

The steps below explain each part in detail. Do them in order: renaming comes
before Firebase because Firebase config files are tied to the package name and
bundle id.

### 1. Prerequisites

- Flutter 3.44+ on the stable channel (Dart `^3.12.2`). Check with `flutter doctor`.
- **iOS:** macOS with a recent Xcode, plus an Apple Developer account for devices,
  push and release builds. CocoaPods isn't needed (Swift Package Manager is used).
- **Android:** Android Studio (or the Android SDK command-line tools) and JDK 17.
- `perl` and `bash`, used by `tool/rename_app.sh`. Both are preinstalled on macOS and Linux.

### 2. Get a copy of the boilerplate

Clone [asad219/flutter_boiler_plate](https://github.com/asad219/flutter_boiler_plate)
into a folder named after your app, then replace its git history with a fresh one.
Your new app shouldn't carry the boilerplate's commits, and a clean first commit
makes the rename show up as a reviewable diff:

```bash
git clone --depth 1 https://github.com/asad219/flutter_boiler_plate.git my_app
cd my_app
rm -rf .git
git init && git add -A && git commit -m "Start from flutter_boiler_plate"
```

To push the new app to its own GitHub repo, create an **empty** repository on GitHub
(no README, `.gitignore` or license), then:

```bash
git remote add origin https://github.com/<you>/my_app.git
git branch -M main
git push -u origin main
```

**Copying a local folder instead of cloning?** Also remove the generated,
machine-specific and secret files, which a fresh clone never contains:

```bash
cp -R flutter_boiler_plate my_app && cd my_app
rm -rf .git build .dart_tool .idea app_boilerplate.iml \
  android/.gradle android/local.properties \
  ios/Flutter/ephemeral ios/Flutter/Generated.xcconfig ios/Flutter/flutter_export_environment.sh \
  env/dev.json env/staging.json env/prod.json \
  android/app/google-services.json ios/Runner/GoogleService-Info.plist
git init && git add -A && git commit -m "Start from flutter_boiler_plate"
```

Flutter recreates all the generated files on the next `flutter pub get`.

### 3. Rename the app

Choose the identifiers first. They're permanent once the app is published to a store.

| Value | Rules | Example |
|---|---|---|
| Dart package | `snake_case`: lowercase letters, digits, `_` | `my_app` |
| Android application id | Reverse domain. Each segment starts with a letter; letters, digits and `_` only | `com.acme.myapp` |
| iOS bundle id | Reverse domain. Letters, digits, `-` and `.`; **no underscores** | `com.acme.myapp` |
| Display name | Free text shown under the icon | `My App` |

Using the same id on both platforms keeps Firebase and store setup simpler.

**Option A: script (recommended)**

```bash
./tool/rename_app.sh \
  --package my_app \
  --android-id com.acme.myapp \
  --ios-id com.acme.myapp \
  --name "My App"
```

It updates:

- the `pubspec.yaml` name and every `package:app_boilerplate/` import in `lib/` and `test/`
- the Android `namespace` and `applicationId`, moves `MainActivity.kt` to the new package path, and updates `android:label`
- the iOS `PRODUCT_BUNDLE_IDENTIFIER` (including `RunnerTests`), `CFBundleDisplayName` and `CFBundleName`
- the iOS `bundle_identifier` in `codemagic.yaml`
- `AppConstants.appName`

Then it runs `flutter clean && flutter pub get`. Review the result with `git diff`.

The script only works on the original boilerplate ids. To rename again, revert
with `git checkout .` first.

**Option B: manual**

1. `pubspec.yaml` → `name: my_app`, then find & replace `package:app_boilerplate/` →
   `package:my_app/` in `lib/` and `test/`.
2. `android/app/build.gradle.kts` → `namespace` and `applicationId`.
3. Move `android/app/src/main/kotlin/com/starter/boilerplate/app_boilerplate/MainActivity.kt`
   to the new package folder (e.g. `kotlin/com/acme/myapp/`) and update its `package` line.
4. `android/app/src/main/AndroidManifest.xml` → `android:label`.
5. `ios/Runner.xcodeproj/project.pbxproj` → every `PRODUCT_BUNDLE_IDENTIFIER` (Runner and
   `RunnerTests`), or set it in Xcode → Runner target → *Signing & Capabilities*.
6. `ios/Runner/Info.plist` → `CFBundleDisplayName` and `CFBundleName`.
7. `lib/core/constants/app_constants.dart` → `appName`.
8. `codemagic.yaml` → `bundle_identifier` under `ios-release`.
9. `flutter clean && flutter pub get`.

Also update `description` (and `version` if needed) in `pubspec.yaml`, and the
title and intro of this README.

### 4. Set your Apple team

The Xcode project still has the boilerplate's team (`DEVELOPMENT_TEAM = E65WYSUT4Y`),
and the rename script doesn't change it. Set your own team, or iOS device and
release builds won't sign:

- In Xcode, open `ios/Runner.xcworkspace` → **Runner** target → *Signing & Capabilities*,
  keep *Automatically manage signing* on and choose your **Team**. Xcode registers the
  bundle id for you.
- Or replace it from the command line. Your Team ID is on
  <https://developer.apple.com/account> under *Membership details*:

  ```bash
  perl -pi -e 's/E65WYSUT4Y/YOURTEAMID/g' ios/Runner.xcodeproj/project.pbxproj
  ```

### 5. Connect your backend

1. Create the env files from the templates and set `BASE_URL` / `API_VERSION`:

   ```bash
   for e in dev staging prod; do cp env/$e.json.example env/$e.json; done
   ```

   Which `BASE_URL` to use for a local server depends on where the app runs:

   | Running on | Use |
   |---|---|
   | Android emulator | `http://10.0.2.2:<port>/api/` |
   | iOS simulator | `http://localhost:<port>/api/` |
   | Physical device | `http://<your-computer-LAN-IP>:<port>/api/` (same Wi-Fi) |

2. Change the paths in `lib/core/constants/api_endpoints.dart` to match your API.
3. If your response shapes differ from the [backend contract](#auth-flow), adapt the parsers:
   - `features/auth/data/models/login_response_model.dart` reads `token` or `accessToken`,
     `refreshToken` and `user`, optionally wrapped in `data`.
   - `features/auth/data/models/user_model.dart` reads `id` / `_id`, `email`, `firstName`,
     `lastName`, `profilePicUrl` and `isVerified`. Add or remove fields here and in
     `domain/entities/user_entity.dart`.
4. No refresh-token endpoint? Leave the interceptor as is (see [Networking](#networking)).
5. No device registration endpoint? Change or remove the `POST /devices` call in
   `core/services/notification/fcm_token_registrar.dart`.

### 6. Configure Firebase (or turn it off)

Follow [Firebase setup](#firebase-setup) using your **new** Android application id
and iOS bundle id. To skip Firebase for now, set `"ENABLE_FIREBASE": false` in your
env files. The app runs normally with push and analytics disabled.

### 7. Brand the app

- **Colors and fonts:** `lib/core/constants/app_colors.dart`, `app_typography.dart`, and
  `lib/core/theme/app_theme.dart`.
- **App icon:** replace `android/app/src/main/res/mipmap-*/ic_launcher.png` and
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/`. Or generate them with
  [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) and a 1024×1024 PNG:

  ```yaml
  # pubspec.yaml
  dev_dependencies:
    flutter_launcher_icons: ^0.14.0

  flutter_launcher_icons:
    android: true
    ios: true
    image_path: assets/icon/app_icon.png
    remove_alpha_ios: true
  ```

  ```bash
  flutter pub get && dart run flutter_launcher_icons
  ```

- **Splash screen:** `android/app/src/main/res/drawable/launch_background.xml` (and
  `drawable-v21/`), plus `ios/Runner/Base.lproj/LaunchScreen.storyboard` and
  `Assets.xcassets/LaunchImage.imageset`. Or use
  [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash).
- **Android notification icon:** local notifications use `@mipmap/ic_launcher`
  (`local_notification_service.dart`), which Android shows as a solid square in the status
  bar. For production, add a white-on-transparent `res/drawable/ic_notification.png`,
  point `AndroidInitializationSettings` at `@drawable/ic_notification`, and add this to
  `AndroidManifest.xml` so FCM notifications use it too:

  ```xml
  <meta-data
      android:name="com.google.firebase.messaging.default_notification_icon"
      android:resource="@drawable/ic_notification" />
  ```

- **Notification channel:** rename the user-visible `'General'` channel in
  `local_notification_service.dart` if you like. If you change the id `default_channel`,
  change it in `AndroidManifest.xml` too.

### 8. Set up release signing

**Android.** `android/app/build.gradle.kts` signs release builds with the keystore
described in `android/key.properties`. Without that file it falls back to the debug
key, which is fine for `flutter run --release` but rejected by Google Play.

1. Create an upload keystore. Keep it and its passwords outside the repo and back them up.
   Losing it means you can't publish updates (unless Play App Signing resets it):

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

   `key.properties`, `*.jks` and `*.keystore` are already git-ignored (`android/.gitignore`).
   Check which key a release build uses with
   `cd android && ./gradlew -q :app:signingReport` (look for `Variant: release`).

3. For CI, upload the same keystore to Codemagic instead
   (see [CI/CD with Codemagic](#cicd-with-codemagic)). The build writes `key.properties` for you.

4. Add the release SHA-1 / SHA-256 to your Firebase Android app. If you use Play App
   Signing, also add the app signing key's fingerprints from Play Console
   (*Setup → App signing*).

**iOS.** With automatic signing and your team set ([step 4](#4-set-your-apple-team)),
Xcode creates the certificates and profiles. Create the app in
[App Store Connect](https://appstoreconnect.apple.com) with the same bundle id before
uploading.

**Build for the stores.** Bump `version: x.y.z+build` in `pubspec.yaml` for every upload:

```bash
flutter build appbundle --release --dart-define-from-file=env/prod.json
flutter build ipa --release --dart-define-from-file=env/prod.json
```

Or let Codemagic build, sign and upload both on every `v*` tag
(see [CI/CD with Codemagic](#cicd-with-codemagic)).

### 9. Verify

```bash
flutter analyze && flutter test
flutter run --dart-define-from-file=env/dev.json

# Nothing should be left except README.md and tool/rename_app.sh:
grep -rnE "app_boilerplate|com\.starter\.boilerplate|appBoilerplate|App Boilerplate|E65WYSUT4Y" \
  --exclude-dir={build,.dart_tool,.git,.gradle} .
```

Final checklist:

- [ ] Template copied, fresh git history
- [ ] Package, Android id, iOS bundle id and display name renamed
- [ ] Apple team set
- [ ] `env/*.json` created with your `BASE_URL`; endpoints and models match your API
- [ ] Firebase configured for the new ids, or `ENABLE_FIREBASE: false`
- [ ] Icon, splash, colors and notification icon replaced
- [ ] Android release keystore set up; app created in App Store Connect
- [ ] `flutter analyze` and `flutter test` pass
- [ ] Optional: Codemagic connected, and the `ci` workflow is green

---

## Project structure

```
lib/
├── main.dart                      # bootstrap: env → Firebase → DI → push → runApp
├── app/
│   ├── app.dart                   # MaterialApp + app-wide auth listener
│   └── routes/                    # RoutesName + AppRouter (onGenerateRoute)
├── core/
│   ├── config/                    # EnvConfig (dart-define)
│   ├── constants/                 # api_endpoints, app_keys, colors, typography
│   ├── di/service_locator.dart    # get_it registrations
│   ├── error/                     # exceptions (ApiException), failures, error_handler
│   ├── network/                   # api_client (Dio), api_interceptors, network_info,
│   │                              # api_response_parser, result
│   ├── services/
│   │   ├── storage/               # secure storage, token service, shared prefs
│   │   ├── notification/          # FCM, local notifications, payload routing, token registrar
│   │   ├── analytics/             # Firebase Analytics wrapper (no-op without Firebase)
│   │   ├── firebase/              # guarded Firebase initialization
│   │   ├── navigation/            # navigatorKey, snackbars, current route tracking
│   │   └── session/               # SessionExpiredNotifier
│   ├── theme/                     # light & dark ThemeData
│   ├── usecase/                   # UseCase<T, Params>, NoParams
│   └── utils/                     # validators, logger
└── features/
    ├── auth/
    │   ├── data/        datasources/ (auth_remote_ds, auth_local_ds), models/, repositories/
    │   ├── domain/      entities/, repositories/ (contract), usecases/
    │   └── presentation/ bloc/ (auth_bloc + part files), pages/ (splash, login), widgets/
    └── home/            placeholder starter feature
```

---

## Architecture

```
Widget ──event──▶ Bloc ──▶ UseCase ──▶ Repository (contract)
                                           │
                               RepositoryImpl (data)
                              ┌────────────┴────────────┐
                    RemoteDataSource              LocalDataSource
                       (ApiClient/Dio)        (secure storage / prefs)
```

Rules that keep features consistent:

- **Data sources throw**: `ApiException` (network) or `CacheException` (local).
- **Repositories never throw**: they return `Result<T>` = `Success(data)` | `Failed(failure)`,
  usually via `ErrorHandler.guard(() async { … })`.
- **`Failure.message` is always UI-safe.** `ApiException` extracts the best message from
  Nest/Zod-style bodies (`message`, `error`, `detail`, `errors`, nested arrays) and
  `sanitizeDisplayMessage` replaces raw JSON or technical text with a generic fallback.
- **BLoCs** depend on use cases only, use `part` files for events/states, extend
  `Equatable`, and name handlers `_onEventName`.
- **DI**: services, data sources, repositories and use cases are lazy singletons; BLoCs
  are factories (`registerFactory`) so the widget tree owns their lifecycle.

### Networking

```dart
final json = await apiClient.get(
  ApiEndpoints.currentUser,
  defaultErrorMessage: 'Failed to fetch user profile',
);
final user = ApiResponseParser.parseObject(json, UserModel.fromJson);
```

- Every call returns `Map<String, dynamic>`. Top-level arrays are wrapped as `{'data': [...]}`.
  `ApiResponseParser.parseObject / parseList / parseListOrSingle` unwrap `data` for you.
- `requiresAuth` defaults to `true`; pass `false` for public endpoints (login, register).
- `successCodes` (default `[200, 201]`) decides what counts as success.
- Interceptors (`core/network/api_interceptors.dart`):
  - **`AuthInterceptor`** injects `Authorization: Bearer <token>`. On a 401 it calls
    `POST /users/refresh-token {refreshToken}` → `{token, refreshToken?}` once (queued,
    so parallel 401s share a single refresh) and retries the request. If no refresh is
    possible it clears tokens and fires `SessionExpiredNotifier`, and `AuthBloc` emits
    `Unauthenticated('Your session expired…')`.
  - **`ErrorInterceptor`** normalizes `DioException.error` to an `ApiException`.
  - **`LoggingInterceptor`** (debug only) redacts `Authorization` and `Cookie`.

If your backend has no refresh endpoint, leave it as is: without a stored refresh
token the interceptor falls back to session expiry.

### Auth flow

`AuthBloc` states: `AuthInitial` → `AuthLoading` → `Authenticated(user)` |
`Unauthenticated(message?)`.

Navigation is **not** done in pages. `_AuthNavigationListener` in `app/app.dart`
reacts to state changes. It routes to home or login, shows error snackbars, syncs or
deletes the FCM token, sets the analytics user id, and releases deferred notification
deep links once the user is authenticated.

Backend contract used by the auth feature (change paths in `api_endpoints.dart`):

| Endpoint | Request | Response |
|---|---|---|
| `POST /users/login` | `{email, password}` | `{token, refreshToken?, user}` (optionally under `data`) |
| `POST /users/logout` | — | any (best-effort) |
| `GET /users/me` | — | user object (direct, or under `user` / `data`) |
| `POST /users/refresh-token` | `{refreshToken}` | `{token, refreshToken?}` |
| `POST /devices` | `{token, platform}` | any (FCM token upsert) |

### Push notifications

| App state | Handled by |
|---|---|
| Foreground | `FirebaseMessaging.onMessage`. Android shows a local notification; iOS uses the presentation options. |
| Background (tap) | `FirebaseMessaging.onMessageOpenedApp` |
| Terminated (tap) | `getInitialMessage()` (FCM) / `getNotificationAppLaunchDetails()` (local) |
| Background / terminated (receive) | top-level `firebaseMessagingBackgroundHandler`. Data-only messages with `title` / `body` are shown as local notifications. |

- **Deep links:** send `data: {"route": "/home", ...}`. `NotificationPayloadHandler` pushes
  the route (extra keys become route arguments) and holds it until the user is authenticated.
- **Permissions:** requested at startup without blocking `runApp`, and again from the
  Home "Enable notifications" button.
- **Tokens:** registered with the backend after login and on `onTokenRefresh`; deleted on logout.
- Android channel id `default_channel` must match the manifest meta-data.

---

## Firebase setup

Firebase is optional at runtime. `FirebaseBootstrap.initialize()` skips Firebase when
`ENABLE_FIREBASE=false` and logs a warning (without crashing) when config files are
missing. On Android, the Google Services Gradle plugin is applied only once
`google-services.json` exists.

1. **Create a project** at <https://console.firebase.google.com> (enable Google
   Analytics if you want the analytics wrapper to report).
2. **Android app**
   - Add an Android app with your `applicationId` (e.g. `com.acme.myapp`).
   - Download **`google-services.json`** → place at **`android/app/google-services.json`**.
   - Optional: add your debug/release SHA-1 / SHA-256 fingerprints (`cd android && ./gradlew signingReport`).
3. **iOS app**
   - Add an iOS app with your bundle id.
   - Download **`GoogleService-Info.plist`** → place at **`ios/Runner/GoogleService-Info.plist`**.
     The Runner target's *Copy GoogleService-Info.plist* build phase bundles it when it
     exists and skips it otherwise. **Don't** drag it into Xcode: that adds a project
     reference, and builds then fail on any clone or CI machine without the file.
   - Runner target → *Signing & Capabilities*:
     - **+ Capability → Push Notifications**
     - **+ Capability → Background Modes** → tick *Remote notifications* and *Background fetch*
       (already declared in `Info.plist`).
   - Apple Developer portal → *Keys* → create an **APNs Auth Key (.p8)**. Then in Firebase
     Console → *Project settings → Cloud Messaging → Apple app configuration*, upload it
     with your Key ID and Team ID.
   - Push only works on a **real device** (or simulators that support remote push on Apple
     silicon with a recent Xcode). Simulators without APNs return no token.
4. **Run** with `ENABLE_FIREBASE: true`. On Home, the push card should show
   *"Firebase is configured"*. Tap **Enable notifications** to get and copy the FCM token,
   then send a test message from *Firebase Console → Messaging*.

Both config files are git-ignored by default. Remove them from `.gitignore` if you
prefer to commit per-environment configs.

**FlutterFire CLI alternative:** `dart pub global activate flutterfire_cli && flutterfire configure`
generates `lib/firebase_options.dart`. Pass `options: DefaultFirebaseOptions.currentPlatform`
to `Firebase.initializeApp` in `core/services/firebase/firebase_bootstrap.dart`.

---

## Scaffold a new feature

Example: a `profile` feature that loads `GET /users/me`. Mirror `features/auth`.

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

**1. Endpoint:** add to `core/constants/api_endpoints.dart`:

```dart
static const String profile = '/users/me';
```

**2. Domain:** entity, repository contract, use case:

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

**3. Data:** model (`fromJson`), remote data source (throws), repository (returns `Result`):

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
    final json = await _apiClient.get(
      ApiEndpoints.profile,
      defaultErrorMessage: 'Failed to load profile',
    );
    return ApiResponseParser.parseObject(json, ProfileModel.fromJson);
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);
  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ProfileEntity>> getProfile() =>
      ErrorHandler.guard(_remoteDataSource.getProfile, fallback: 'Failed to load profile');
}
```

**4. Presentation:** BLoC with a status-based state:

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
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, errorMessage: failure.message)),
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
  const ProfileState({this.status = ProfileStatus.initial, this.profile, this.errorMessage});
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  ProfileState copyWith({ProfileStatus? status, ProfileEntity? profile, String? errorMessage}) =>
      ProfileState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
```

**5. DI:** add a `_registerProfileFeature()` in `core/di/service_locator.dart` and call
it from `setupLocator()`:

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

**6. Route:** add `RoutesName.profile = '/profile'` and an entry in `AppRouter._routes`.
Provide the BLoC at page level:

```dart
RoutesName.profile: (_) => BlocProvider(
  create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
  child: const ProfilePage(),
),
```

**7. Test:** mock the use case with `mocktail` and assert transitions with `blocTest`
(see `test/features/auth/presentation/bloc/auth_bloc_test.dart`).

---

## Quality

```bash
flutter analyze        # lints: flutter_lints + stricter rules in analysis_options.yaml
flutter test           # api_client (interceptors/refresh), api_exception, auth_bloc
dart format lib test
```

CI runs the same checks, with `dart format --output=none --set-exit-if-changed lib test`
so unformatted code fails the build.

---

## CI/CD with Codemagic

[Codemagic](https://codemagic.io) builds the app from `codemagic.yaml` in the repo root:

| Workflow | Runs on | What it does |
|---|---|---|
| `ci` | Every push and pull request (Linux) | Format check, `flutter analyze`, `flutter test` with a test report |
| `android-release` | Tags matching `v*` (Linux) | Signed `.aab` → Google Play **internal** track (as a draft) |
| `ios-release` | Tags matching `v*` (Mac mini M2) | Signed `.ipa` → **TestFlight** |

How the release builds get what's git-ignored: `tool/ci/write_config.sh prod` writes
`env/prod.json`, the Firebase config files and `android/key.properties` from Codemagic
environment variables. Builds use `--build-number=$BUILD_NUMBER` (Codemagic's per-workflow
counter); the version name comes from `pubspec.yaml`.

`ci` works as soon as the repo is connected. The release workflows need the one-time
setup below. Names such as `app_env`, `upload_keystore` and `asc_api_key` must match
`codemagic.yaml` exactly.

### 1. Connect the repository

1. Sign in at <https://codemagic.io> with GitHub and grant access to the repository.
2. **Add application** → pick the repo → project type **Flutter App**. Codemagic finds
   `codemagic.yaml` and creates the webhook, so pushes, pull requests and tags trigger builds.
3. Push any commit and check that `ci` goes green.

### 2. Environment variable groups

In the app → **Environment variables**, add these variables to the listed groups.
Tick **Secret** for every value except `API_VERSION` and `ENABLE_FIREBASE`.

| Group | Variable | Value |
|---|---|---|
| `app_env` | `BASE_URL` | Production API, e.g. `https://api.acme.com/api/` (**required**) |
| `app_env` | `API_VERSION` | e.g. `v1` (optional, default `v1`) |
| `app_env` | `ENABLE_FIREBASE` | `true` or `false` (optional, default `true`) |
| `firebase` | `GOOGLE_SERVICES_JSON` | `google-services.json`, base64-encoded |
| `firebase` | `GOOGLE_SERVICE_INFO_PLIST` | `GoogleService-Info.plist`, base64-encoded |
| `google_play` | `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | Google Play service account JSON key, pasted as is (not base64) |

Encode the Firebase files on one line, with no line breaks:

```bash
base64 -i android/app/google-services.json | pbcopy        # macOS: copies to clipboard
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy
base64 -w0 android/app/google-services.json                 # Linux
```

Skipping Firebase on CI? Leave the `firebase` group empty but keep it (the workflows
reference it). The builds log a warning and the app runs without Firebase.

### 3. Android: keystore and Google Play

1. **Keystore.** Codemagic → **Teams** → your team → **Code signing identities** →
   **Android keystores** → upload your upload keystore (`.jks`, see
   [release signing](#8-set-up-release-signing)) with its passwords and alias. Set the
   reference name to **`upload_keystore`**.
2. **Service account.** In [Google Cloud Console](https://console.cloud.google.com),
   enable the **Google Play Android Developer API**, create a service account, and
   create a JSON key for it. Put the JSON in `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`.
3. **Grant access.** In [Play Console](https://play.google.com/console) → **Users and
   permissions** → invite the service account's email with release permissions for
   your app.
4. **First upload is manual.** Create the app in Play Console and upload the first
   `.aab` by hand (download it from a Codemagic build's artifacts, or build locally).
   Google Play's API can't create an app's first release.

### 4. iOS: App Store Connect and signing

1. **App record.** In [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **+**,
   create the app with your bundle id.
2. **API key.** App Store Connect → **Users and Access** → **Integrations** →
   **App Store Connect API** → generate a key with the **App Manager** role. Download
   the `.p8` (you can only download it once) and note the **Issuer ID** and **Key ID**.
3. **Add the key to Codemagic.** **Teams** → your team → **Team integrations** →
   **Developer Portal** → **Manage keys** → add it with the name **`asc_api_key`**.
4. **Certificate and profile.** **Code signing identities** → **iOS certificates** →
   generate (or upload) an **Apple Distribution** certificate. Then **iOS provisioning
   profiles** → fetch the **App Store** profile for your bundle id.
5. **Push notifications.** If you use push, enable the **Push Notifications** capability
   on the App ID in the [Apple Developer portal](https://developer.apple.com/account/resources/identifiers/list)
   **before** fetching the profile, and add the capability to the Runner target
   (see [Firebase setup](#firebase-setup)). Re-fetch the profile whenever capabilities change.

The bundle id in `codemagic.yaml` (`ios-release` → `ios_signing` → `bundle_identifier`)
must match the app. `tool/rename_app.sh` updates it for you.

### 5. Ship a release

```bash
# bump `version:` in pubspec.yaml (e.g. 1.2.0+1), commit, then:
git tag v1.2.0
git push origin v1.2.0
```

Both release workflows start. Android lands on the internal track as a draft, and iOS
goes to TestFlight after Apple finishes processing (usually 10–30 minutes). You can
also start any workflow by hand: **Start new build** → pick the workflow and a branch or tag.

**Staging builds:** copy `android-release` / `ios-release` to new workflows, change
`write_config.sh prod` to `staging` and `env/prod.json` to `env/staging.json`, and point
them at a group with the staging `BASE_URL`.

### Troubleshooting

Start with the failing step's log in Codemagic. `write_config.sh` prints `✓` for each
file it wrote and `!` for each one it skipped.

**Builds don't start**

- *Push or tag does nothing:* check the app → **Webhooks** for recent deliveries.
  Reconnect the repository if the webhook is missing.
- *Tag pushed but no release build:* tags aren't pushed by `git push`; use
  `git push origin v1.2.0`. The tag must start with `v`.
- *"No workflows found" / YAML errors:* `codemagic.yaml` must sit in the repo root on the
  branch or tag being built. Validate it in the Codemagic YAML editor.

**`ci` workflow**

- *Check formatting fails:* run `dart format lib test` locally and commit the result.
- *Passes locally, fails on CI:* compare `flutter --version` with the `flutter:` value in
  `codemagic.yaml` (`definitions`). Keep them in sync when you upgrade Flutter.

**Configuration**

- *`BASE_URL is not set`:* the `app_env` group is missing, misnamed, or lacks `BASE_URL`.
- *`base64: invalid input`:* the value has line breaks or extra characters. Re-encode it
  with the commands above and paste the whole value.
- *Release app runs without Firebase:* the log shows `! GOOGLE_SERVICES_JSON not set` or
  `! GOOGLE_SERVICE_INFO_PLIST not set`. Add the variables to the `firebase` group. The
  Firebase apps must use the same package name and bundle id as the build.

**Android**

- *"No keystore with reference upload_keystore":* the keystore reference name in
  Codemagic doesn't match `android_signing` in `codemagic.yaml`.
- *Play rejects the bundle as debug-signed:* `key.properties` wasn't written (no
  `✓ android/key.properties` in the log), so `android_signing` isn't set up.
- *"Keystore was tampered with, or password was incorrect" / "Cannot recover key":*
  the store password, key alias or key password in Codemagic is wrong.
- *"Package not found: com.acme.myapp":* the app doesn't exist in Play Console yet, or
  its first release wasn't uploaded manually.
- *"The caller does not have permission":* the service account wasn't invited in Play
  Console, or lacks release permissions. New access can take a while to apply.
- *"Only releases with status draft may be created on draft app":* keep
  `submit_as_draft: true` until the app has been published once.
- *"Version code N has already been used":* `$BUILD_NUMBER` is behind what's on Play.
  Build from the latest Play number instead:

  ```bash
  LATEST=$(google-play get-latest-build-number --package-name com.acme.myapp)
  flutter build appbundle --release --build-number=$((LATEST + 1)) \
    --dart-define-from-file=env/prod.json
  ```

**iOS**

- *"No matching profiles found for bundle identifier":* `bundle_identifier` in
  `codemagic.yaml` doesn't match the app, or no App Store profile was fetched for it.
- *No valid signing certificate:* add an Apple Distribution certificate in Code signing
  identities. Apple allows a limited number per team, so revoke unused ones if needed.
- *"Provisioning profile doesn't include the aps-environment entitlement":* enable Push
  Notifications on the App ID, then re-fetch the profile (iOS step 5 above).
- *"The bundle version must be higher than the previously uploaded version":* raise the
  build number from TestFlight's latest:

  ```bash
  LATEST=$(app-store-connect get-latest-testflight-build-number "<App Store app id>")
  flutter build ipa --release --build-number=$((LATEST + 1)) \
    --export-options-plist=/Users/builder/export_options.plist \
    --dart-define-from-file=env/prod.json
  ```

- *Upload succeeds but the build waits on "Missing Compliance":* if the app only uses
  standard HTTPS, add `ITSAppUsesNonExemptEncryption` = `NO` to `ios/Runner/Info.plist`.
- *Swift package resolution fails or times out:* usually a network blip, so rerun the build.
  If it keeps failing, clear the cache (app → **Caching**) and rerun.
- *Push works locally but not in TestFlight:* upload the APNs key to Firebase (see
  [Firebase setup](#firebase-setup)) and make sure the App ID has Push Notifications enabled.

**Slow or long builds**

- *Build exceeded the time limit:* raise `max_build_duration` (minutes) for the workflow.
  The first iOS build is slower because it downloads every Swift package.

---

## Toolchain notes

- **Xcode 27 + Flutter 3.44.5:** `flutter build ios --simulator` (universal arm64+x86_64)
  fails in Flutter's `lipo -verify_arch` step with *"Exited with status code 255"*. This
  is a Flutter tooling issue, not a project issue. `flutter run` on a device or
  simulator and `flutter build ipa` aren't affected. To build the simulator app manually:
  `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -sdk iphonesimulator ARCHS=arm64 CODE_SIGNING_ALLOWED=NO build`.
- Gradle prints a *Kotlin Gradle Plugin* deprecation warning for `firebase_core` /
  `firebase_analytics`. It's upstream and harmless until those plugins migrate.
- iOS uses **Swift Package Manager** only (all plugins ship SPM packages). If you add a
  CocoaPods-only plugin, Flutter recreates a `Podfile` automatically. Set
  `platform :ios, '15.0'` in it.
