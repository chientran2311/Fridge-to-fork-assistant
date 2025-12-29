// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kitchen Assistant';

  @override
  String get fridgeTab => 'Fridge';

  @override
  String get recipeTab => 'Recipes';

  @override
  String get planTab => 'Plan';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get emptyFridge => 'Your fridge is empty!';

  @override
  String get addFirstItem => 'Add your first item now.';

  @override
  String get eatMeFirst => 'Eat Me First ⚠️';

  @override
  String get inStock => 'In Stock 🥑';

  @override
  String get addItem => 'Add Item';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get notifications => 'Notifications';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'hello@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '........';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginErrorMissing => 'Please enter both Email and Password';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Start saving food today';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Jane Doe';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginLink => 'Log in';

  @override
  String get registerSuccess => 'Account created! Please log in.';

  @override
  String get registerErrorMissing => 'Please fill in all fields';

  @override
  String get registerErrorMatch => 'Passwords do not match';

  @override
  String get devAreaTitle => 'Developer Area (Delete later)';

  @override
  String get devSeedDatabase => 'Seed Sample Database (Firestore)';

  @override
  String get devSeeding => 'Seeding data...';

  @override
  String get devSeedSuccess => 'Done! Check Firebase Console.';

  @override
  String get searchingredients => 'Search ingredients...';

  @override
  String itemSelected(String name) {
    return 'Selected: $name';
  }

  @override
  String get itemsDeleted => 'Deleted selected items';

  @override
  String get weeklyPlan => 'Weekly Plan';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get general => 'GENERAL';

  @override
  String get inviteMember => 'Invite Member';

  @override
  String get logOut => 'Log Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action will permanently delete your data. Are you sure?';

  @override
  String get confirm => 'Confirm';
}
