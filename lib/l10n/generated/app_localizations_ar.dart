// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get languageName => 'العربية';

  @override
  String get themeLabel => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get search => 'بحث';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get noOptions => 'لا توجد خيارات متاحة';

  @override
  String noResultsFor(String query) {
    return 'لا توجد نتائج لـ «$query»';
  }

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get errorUnknown => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorServer =>
      'تعذّر على الخادم إكمال طلبك. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNoConnection =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundMessage => 'الصفحة التي تبحث عنها غير موجودة.';

  @override
  String get goBack => 'رجوع';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get acceptToContinue => 'يرجى الموافقة للمتابعة';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get validationFieldRequired => 'هذا الحقل مطلوب';

  @override
  String validationRequired(String field) {
    return '$field مطلوب';
  }

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validationEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String validationPasswordTooShort(int min) {
    return 'يجب ألا تقل كلمة المرور عن $min أحرف';
  }

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get signOutConfirmMessage =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام التطبيق.';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String homeGreeting(String name) {
    return 'مرحبًا، $name 👋';
  }

  @override
  String get homeGreetingGuest => 'مرحبًا 👋';

  @override
  String get pushTitle => 'الإشعارات الفورية';

  @override
  String get pushConfigured => 'مُهيّأ';

  @override
  String get pushNotConfigured => 'غير مُهيّأ';

  @override
  String get pushConfiguredMessage => 'تمت تهيئة Firebase.';

  @override
  String get pushNotConfiguredMessage =>
      'لم يتم إعداد Firebase. راجع قسم \"Firebase setup\" في ملف README.';

  @override
  String get pushCopyToken => 'نسخ رمز FCM';

  @override
  String get pushTokenCopied => 'تم نسخ رمز FCM';

  @override
  String get pushEnable => 'تفعيل الإشعارات';
}
