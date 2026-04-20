// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Food Lens';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get themeSystem => 'Use system theme';

  @override
  String get themeSystemSubtitle => 'Follow your device settings';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeLightSubtitle => 'Standard bright interface';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get themeDarkSubtitle => 'Low-glare dark interface';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageSystem => 'Use system language';

  @override
  String get languageSystemSubtitle => 'Follow your device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'Use English across the app';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageVietnameseSubtitle => 'Use Vietnamese across the app';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Meal reminder and progress updates';

  @override
  String get language => 'Language';

  @override
  String get languageDefaultSubtitle => 'Vietnamese (default)';

  @override
  String get home => 'Home';

  @override
  String get scan => 'Scan';

  @override
  String get history => 'History';

  @override
  String get stats => 'Stats';

  @override
  String get profile => 'Profile';

  @override
  String get historyTitle => 'History';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get profileTitle => 'Profile';

  @override
  String get scanTitle => 'AI Scan';

  @override
  String get scanResultTitle => 'Scan Result';

  @override
  String get searchHistoryPlaceholder => 'Search your history...';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get last1Year => '1 Year';

  @override
  String get scanDeleted => 'Scan deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get focusNutritiousBreakfast => 'Focus: Nutritious breakfast';

  @override
  String get focusBalancedLunch => 'Focus: Balanced lunch';

  @override
  String get focusLightDinner => 'Focus: Light dinner';

  @override
  String hiName(Object name) {
    return 'Hi, $name!';
  }

  @override
  String get onTrack => 'On track';

  @override
  String get dailyCalories => 'Daily Calories';

  @override
  String get recentScans => 'Recent Scans';

  @override
  String get viewAll => 'View All';

  @override
  String get averageDaily => 'Average Daily';

  @override
  String get goalRemaining => 'Goal Remaining';

  @override
  String get calorieTrend => 'Calorie Trend';

  @override
  String get macroBreakdownAverage => 'Macro Breakdown (Average)';

  @override
  String goalCaloriesPerDay(Object calories) {
    return 'Goal: $calories kcal/day';
  }

  @override
  String get todayCalories => 'Today\'s Calories';

  @override
  String get kcal => 'kcal';

  @override
  String get unknown => 'Unknown';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get fiber => 'Fiber';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get scanYourFood => 'Scan Your Food';

  @override
  String get scanSubtitle =>
      'Take a photo or upload an image to analyze nutritional information';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get cameraFeatureComingSoon => 'Camera feature coming soon';

  @override
  String get galleryFeatureComingSoon => 'Gallery feature coming soon';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String foodIdentifiedPrefix(Object food) {
    return 'Food Identified: $food';
  }

  @override
  String matchPercent(Object percent) {
    return '$percent% Match';
  }

  @override
  String get totalCalories => 'Total Calories';

  @override
  String get portionSize => 'Portion Size';

  @override
  String get quantity => 'Quantity';

  @override
  String get nutritionFactsPerServing => 'Nutrition Facts (per serving)';

  @override
  String get savedToHistory => 'Saved to history!';

  @override
  String get saveToHistory => 'Save to History';

  @override
  String get sampleFoodName => 'Avocado Toast';

  @override
  String get profileNoData => 'No profile data available';

  @override
  String get bmi => 'BMI';

  @override
  String get tdee => 'TDEE';

  @override
  String get kcalPerDay => 'kcal/day';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updatePersonalInfo => 'Update personal information';

  @override
  String get appSettings => 'App Settings';

  @override
  String get themeAppearancePreferences => 'Theme, appearance, and preferences';

  @override
  String get goal => 'Goal';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get logout => 'Logout';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get physicalMeasurements => 'Physical Measurements';

  @override
  String get fullName => 'Full Name';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get activityGoal => 'Activity & Goal';

  @override
  String get discard => 'Discard';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get tapCameraChangeAvatar => 'Tap camera to change avatar';

  @override
  String get underweight => 'Underweight';

  @override
  String get normalWeight => 'Normal weight';

  @override
  String get overweight => 'Overweight';

  @override
  String get obese => 'Obese';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get light => 'Light';

  @override
  String get moderate => 'Moderate';

  @override
  String get active => 'Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get loseWeight => 'Lose Weight';

  @override
  String get maintain => 'Maintain';

  @override
  String get gainWeight => 'Gain Weight';

  @override
  String basedOnActivity(Object level) {
    return 'Based on $level activity';
  }

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get uploadAvatarFailed => 'Upload avatar failed. Please try again.';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';
}
