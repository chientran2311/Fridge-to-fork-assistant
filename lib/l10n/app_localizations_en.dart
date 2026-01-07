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
  String get recipetab => 'AI suggestion';

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

  @override
  String get account => 'Account';

  @override
  String get household => 'Household & Sharing';

  @override
  String get filterTitle => 'Filter Recipes';

  @override
  String get reset => 'Reset';

  @override
  String get difficulty => 'Difficulty Level';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get mealType => 'Meal Type';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get cuisine => 'Cuisine';

  @override
  String get italian => 'Italian';

  @override
  String get mexican => 'Mexican';

  @override
  String get asian => 'Asian';

  @override
  String get vegan => 'Vegan';

  @override
  String get prepTime => 'Max Prep Time';

  @override
  String get min => 'min';

  @override
  String get hours => 'hours';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get schedule => 'Schedule';

  @override
  String get cooknow => 'Cook Now';

  @override
  String get discovermore => 'Discover more';

  @override
  String get browseai => 'Browse AI suggestions';

  @override
  String get favoriterecipe => 'Favorite Recipe';

  @override
  String get fridgeManagement => 'FRIDGE MANAGEMENT';

  @override
  String get createNewFridge => 'Create New Fridge';

  @override
  String get joinFridge => 'Join Fridge';

  @override
  String get fridgeList => 'Fridge List';

  @override
  String get currentFridge => 'Current Fridge';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get youAreOwner => 'You are the owner';

  @override
  String get youAreMember => 'You are a member';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get creatingData => 'Creating sample data... Please wait!';

  @override
  String get dataCreatedSuccess => '✅ Data created successfully! Check Home.';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get inviteCodeCopied => 'Invite code copied!';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get fridgeName => 'Fridge name';

  @override
  String get fridgeNameHint => 'Ex: Home in New York';

  @override
  String get create => 'Create';

  @override
  String get join => 'Join';

  @override
  String get fridgeCreated => 'New fridge created!';

  @override
  String get cannotCreate => 'Cannot create';

  @override
  String get joinedSuccess => 'Joined successfully!';

  @override
  String get invalidCode => 'Invalid invite code';

  @override
  String get alreadyMember => 'You are already a member';

  @override
  String get cannotJoin => 'Cannot join';

  @override
  String get noFridgesYet => 'No fridges yet';

  @override
  String get switchFridge => 'Switch';

  @override
  String get enterInviteCode => 'Enter 6-character code';

  @override
  String get close => 'Close';

  @override
  String get shareCodeToInvite => 'Share this code to invite members:';

  @override
  String get developerTools => 'DEVELOPER TOOLS';

  @override
  String get seedDatabase => 'Seed Database (Create sample data)';

  @override
  String get members => 'Members';

  @override
  String get viewMembers => 'View Members';

  @override
  String get removeMember => 'Remove';

  @override
  String get memberRemoved => 'Member removed';

  @override
  String get cannotRemoveMember => 'Cannot remove member';

  @override
  String get leaveFridge => 'Leave Fridge';

  @override
  String get leaveConfirm => 'Are you sure you want to leave this fridge?';

  @override
  String get leftFridge => 'Left fridge successfully';

  @override
  String get ownerCannotLeave =>
      'Owner cannot leave. Transfer ownership first.';

  @override
  String get alreadyOwnFridge =>
      'You already own a fridge. Each user can only own one.';

  @override
  String get owner => 'Owner';

  @override
  String get member => 'Member';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String helloGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String foundRecipes(int count) {
    return 'Found $count recipes';
  }

  @override
  String get searchingRecipes => 'Searching for recipes...';

  @override
  String get noRecipesFound => 'No recipes found yet.';

  @override
  String get rescueIngredients => ' to rescue your ingredients.';

  @override
  String readyToCook(int count) {
    return 'Ready to cook with $count items from your fridge!';
  }

  @override
  String get addItemsToStart => 'Add items to your fridge to start!';

  @override
  String get editDisplayName => 'Edit Name';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get nameUpdated => 'Name updated successfully!';

  @override
  String get nameEmpty => 'Name cannot be empty';
}
