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

  /// No description provided for @recipetab.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion'**
  String get recipetab;

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

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Recipes'**
  String get filterTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @cuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get cuisine;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @mexican.
  ///
  /// In en, this message translates to:
  /// **'Mexican'**
  String get mexican;

  /// No description provided for @asian.
  ///
  /// In en, this message translates to:
  /// **'Asian'**
  String get asian;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Max Prep Time'**
  String get prepTime;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @cooknow.
  ///
  /// In en, this message translates to:
  /// **'Cook Now'**
  String get cooknow;

  /// No description provided for @discovermore.
  ///
  /// In en, this message translates to:
  /// **'Discover more'**
  String get discovermore;

  /// No description provided for @browseai.
  ///
  /// In en, this message translates to:
  /// **'Browse AI suggestions'**
  String get browseai;

  /// No description provided for @favoriterecipe.
  ///
  /// In en, this message translates to:
  /// **'Favorite Recipe'**
  String get favoriterecipe;

  /// No description provided for @fridgeManagement.
  ///
  /// In en, this message translates to:
  /// **'FRIDGE MANAGEMENT'**
  String get fridgeManagement;

  /// No description provided for @createNewFridge.
  ///
  /// In en, this message translates to:
  /// **'Create New Fridge'**
  String get createNewFridge;

  /// No description provided for @joinFridge.
  ///
  /// In en, this message translates to:
  /// **'Join Fridge'**
  String get joinFridge;

  /// No description provided for @fridgeList.
  ///
  /// In en, this message translates to:
  /// **'Fridge List'**
  String get fridgeList;

  /// No description provided for @currentFridge.
  ///
  /// In en, this message translates to:
  /// **'Current Fridge'**
  String get currentFridge;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @youAreOwner.
  ///
  /// In en, this message translates to:
  /// **'You are the owner'**
  String get youAreOwner;

  /// No description provided for @youAreMember.
  ///
  /// In en, this message translates to:
  /// **'You are a member'**
  String get youAreMember;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @creatingData.
  ///
  /// In en, this message translates to:
  /// **'Creating sample data... Please wait!'**
  String get creatingData;

  /// No description provided for @dataCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Data created successfully! Check Home.'**
  String get dataCreatedSuccess;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied!'**
  String get inviteCodeCopied;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @fridgeName.
  ///
  /// In en, this message translates to:
  /// **'Fridge name'**
  String get fridgeName;

  /// No description provided for @fridgeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Home in New York'**
  String get fridgeNameHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @fridgeCreated.
  ///
  /// In en, this message translates to:
  /// **'New fridge created!'**
  String get fridgeCreated;

  /// No description provided for @cannotCreate.
  ///
  /// In en, this message translates to:
  /// **'Cannot create'**
  String get cannotCreate;

  /// No description provided for @joinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Joined successfully!'**
  String get joinedSuccess;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code'**
  String get invalidCode;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already a member'**
  String get alreadyMember;

  /// No description provided for @cannotJoin.
  ///
  /// In en, this message translates to:
  /// **'Cannot join'**
  String get cannotJoin;

  /// No description provided for @noFridgesYet.
  ///
  /// In en, this message translates to:
  /// **'No fridges yet'**
  String get noFridgesYet;

  /// No description provided for @switchFridge.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchFridge;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-character code'**
  String get enterInviteCode;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @shareCodeToInvite.
  ///
  /// In en, this message translates to:
  /// **'Share this code to invite members:'**
  String get shareCodeToInvite;

  /// No description provided for @developerTools.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPER TOOLS'**
  String get developerTools;

  /// No description provided for @seedDatabase.
  ///
  /// In en, this message translates to:
  /// **'Seed Database (Create sample data)'**
  String get seedDatabase;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @viewMembers.
  ///
  /// In en, this message translates to:
  /// **'View Members'**
  String get viewMembers;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get memberRemoved;

  /// No description provided for @cannotRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove member'**
  String get cannotRemoveMember;

  /// No description provided for @leaveFridge.
  ///
  /// In en, this message translates to:
  /// **'Leave Fridge'**
  String get leaveFridge;

  /// No description provided for @leaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this fridge?'**
  String get leaveConfirm;

  /// No description provided for @leftFridge.
  ///
  /// In en, this message translates to:
  /// **'Left fridge successfully'**
  String get leftFridge;

  /// No description provided for @ownerCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'Owner cannot leave. Transfer ownership first.'**
  String get ownerCannotLeave;

  /// No description provided for @alreadyOwnFridge.
  ///
  /// In en, this message translates to:
  /// **'You already own a fridge. Each user can only own one.'**
  String get alreadyOwnFridge;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @helloGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloGreeting(String name);

  /// No description provided for @foundRecipes.
  ///
  /// In en, this message translates to:
  /// **'Found {count} recipes'**
  String foundRecipes(int count);

  /// No description provided for @searchingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Searching for recipes...'**
  String get searchingRecipes;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found yet.'**
  String get noRecipesFound;

  /// No description provided for @rescueIngredients.
  ///
  /// In en, this message translates to:
  /// **' to rescue your ingredients.'**
  String get rescueIngredients;

  /// No description provided for @readyToCook.
  ///
  /// In en, this message translates to:
  /// **'Ready to cook with {count} items from your fridge!'**
  String readyToCook(int count);

  /// No description provided for @addItemsToStart.
  ///
  /// In en, this message translates to:
  /// **'Add items to your fridge to start!'**
  String get addItemsToStart;

  /// No description provided for @editDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editDisplayName;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated successfully!'**
  String get nameUpdated;

  /// No description provided for @nameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameEmpty;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @mealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal Plans'**
  String get mealPlans;

  /// No description provided for @noMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned for this day'**
  String get noMealsPlanned;

  /// No description provided for @noRecipesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recipes available. Search for recipes in the Recipe tab.'**
  String get noRecipesAvailable;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to add a plan'**
  String get loginRequired;

  /// No description provided for @addedToPlan.
  ///
  /// In en, this message translates to:
  /// **'Added to plan'**
  String get addedToPlan;

  /// No description provided for @errorAddingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Error adding recipe'**
  String get errorAddingRecipe;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// No description provided for @produce.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get produce;

  /// No description provided for @dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// No description provided for @pantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantry;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noItemsNeeded.
  ///
  /// In en, this message translates to:
  /// **'No items needed for upcoming meals\n\nPull to refresh'**
  String get noItemsNeeded;

  /// No description provided for @addedToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to shopping list'**
  String addedToShoppingList(String name);

  /// No description provided for @addCustomItem.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Item'**
  String get addCustomItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @grains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get grains;

  /// No description provided for @condiments.
  ///
  /// In en, this message translates to:
  /// **'Condiments'**
  String get condiments;

  /// No description provided for @addItemButton.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemButton;
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
