import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Assistant'**
  String get appTitle;

  /// No description provided for @fridgeTab.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get fridgeTab;

  /// No description provided for @recipeTab.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipeTab;

  /// No description provided for @planTab.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planTab;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @emptyFridge.
  ///
  /// In en, this message translates to:
  /// **'Your fridge is empty!'**
  String get emptyFridge;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add your first item now.'**
  String get addFirstItem;

  /// No description provided for @eatMeFirst.
  ///
  /// In en, this message translates to:
  /// **'Eat Me First ⚠️'**
  String get eatMeFirst;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock 🥑'**
  String get inStock;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'hello@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'........'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginErrorMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter both Email and Password'**
  String get loginErrorMissing;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start saving food today'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Jane Doe'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginLink;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please log in.'**
  String get registerSuccess;

  /// No description provided for @registerErrorMissing.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get registerErrorMissing;

  /// No description provided for @registerErrorMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerErrorMatch;

  /// No description provided for @devAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Area (Delete later)'**
  String get devAreaTitle;

  /// No description provided for @devSeedDatabase.
  ///
  /// In en, this message translates to:
  /// **'Seed Sample Database (Firestore)'**
  String get devSeedDatabase;

  /// No description provided for @devSeeding.
  ///
  /// In en, this message translates to:
  /// **'Seeding data...'**
  String get devSeeding;

  /// No description provided for @devSeedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Done! Check Firebase Console.'**
  String get devSeedSuccess;

  /// No description provided for @searchingredients.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients...'**
  String get searchingredients;

  /// No description provided for @itemSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String itemSelected(String name);

  /// No description provided for @itemsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted selected items'**
  String get itemsDeleted;

  /// No description provided for @weeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly Plan'**
  String get weeklyPlan;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite Member'**
  String get inviteMember;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete your data. Are you sure?'**
  String get deleteAccountWarning;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @household.
  ///
  /// In en, this message translates to:
  /// **'Household & Sharing'**
  String get household;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
