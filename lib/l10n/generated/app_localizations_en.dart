// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading…';

  @override
  String get search => 'Search';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noOptions => 'No options available';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorServer =>
      'The server couldn\'t complete your request. Please try again.';

  @override
  String get errorNoConnection =>
      'Please check your internet connection and try again.';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'The page you\'re looking for doesn\'t exist.';

  @override
  String get goBack => 'Go back';

  @override
  String get tryAgain => 'Try again';

  @override
  String get acceptToContinue => 'Please accept to continue';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get validationFieldRequired => 'This field is required';

  @override
  String validationRequired(String field) {
    return '$field is required';
  }

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String validationPasswordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmMessage =>
      'You will need to sign in again to use the app.';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get homeGreetingGuest => 'Hello 👋';

  @override
  String get pushTitle => 'Push notifications';

  @override
  String get pushConfigured => 'Configured';

  @override
  String get pushNotConfigured => 'Not configured';

  @override
  String get pushConfiguredMessage => 'Firebase is configured.';

  @override
  String get pushNotConfiguredMessage =>
      'Firebase is not set up. See \"Firebase setup\" in the README.';

  @override
  String get pushCopyToken => 'Copy FCM token';

  @override
  String get pushTokenCopied => 'FCM token copied';

  @override
  String get pushEnable => 'Enable notifications';
}
