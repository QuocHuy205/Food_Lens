// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Food Lens';

  @override
  String get settings => 'Cài đặt';

  @override
  String get general => 'Chung';

  @override
  String get chooseTheme => 'Chọn giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeSystemSubtitle => 'Tự động theo cài đặt thiết bị';

  @override
  String get themeLight => 'Chế độ sáng';

  @override
  String get themeLightSubtitle => 'Giao diện sáng tiêu chuẩn';

  @override
  String get themeDark => 'Chế độ tối';

  @override
  String get themeDarkSubtitle => 'Giao diện tối giảm chói ban đêm';

  @override
  String get chooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get languageSystem => 'Theo ngôn ngữ hệ thống';

  @override
  String get languageSystemSubtitle => 'Tự động theo ngôn ngữ thiết bị';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'Dùng tiếng Anh cho toàn bộ ứng dụng';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageVietnameseSubtitle =>
      'Dùng tiếng Việt cho toàn bộ ứng dụng';

  @override
  String get notifications => 'Thông báo';

  @override
  String get notificationsSubtitle => 'Nhắc bữa ăn và cập nhật tiến độ';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageDefaultSubtitle => 'Tiếng Việt (mặc định)';

  @override
  String get home => 'Trang chủ';

  @override
  String get scan => 'Quét';

  @override
  String get history => 'Lịch sử';

  @override
  String get stats => 'Thống kê';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get historyTitle => 'Lịch sử';

  @override
  String get statsTitle => 'Thống kê';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get scanTitle => 'Quét AI';

  @override
  String get scanResultTitle => 'Kết quả quét';

  @override
  String get searchHistoryPlaceholder => 'Tìm trong lịch sử...';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get last7Days => '7 ngày gần đây';

  @override
  String get last30Days => '30 ngày gần đây';

  @override
  String get last90Days => '90 ngày gần đây';

  @override
  String get last1Year => '1 năm';

  @override
  String get scanDeleted => 'Đã xóa bản quét';

  @override
  String get undo => 'HOÀN TÁC';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String get focusNutritiousBreakfast => 'Tập trung: Bữa sáng dinh dưỡng';

  @override
  String get focusBalancedLunch => 'Tập trung: Bữa trưa cân bằng';

  @override
  String get focusLightDinner => 'Tập trung: Bữa tối nhẹ';

  @override
  String hiName(Object name) {
    return 'Chào, $name!';
  }

  @override
  String get onTrack => 'Đang đúng tiến độ';

  @override
  String get dailyCalories => 'Calo hằng ngày';

  @override
  String get recentScans => 'Bản quét gần đây';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get averageDaily => 'Trung bình mỗi ngày';

  @override
  String get goalRemaining => 'Còn lại so với mục tiêu';

  @override
  String get calorieTrend => 'Xu hướng calo';

  @override
  String get macroBreakdownAverage => 'Phân bổ macro (trung bình)';

  @override
  String goalCaloriesPerDay(Object calories) {
    return 'Mục tiêu: $calories kcal/ngày';
  }

  @override
  String get todayCalories => 'Calo hôm nay';

  @override
  String get kcal => 'kcal';

  @override
  String get unknown => 'Không rõ';

  @override
  String get protein => 'Đạm';

  @override
  String get carbs => 'Tinh bột';

  @override
  String get fat => 'Chất béo';

  @override
  String get fiber => 'Chất xơ';

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';

  @override
  String get scanYourFood => 'Quét món ăn của bạn';

  @override
  String get scanSubtitle =>
      'Chụp ảnh hoặc tải ảnh lên để phân tích thông tin dinh dưỡng';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get chooseFromGallery => 'Chọn từ thư viện';

  @override
  String get cameraFeatureComingSoon => 'Tính năng camera sắp ra mắt';

  @override
  String get galleryFeatureComingSoon => 'Tính năng thư viện sắp ra mắt';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String foodIdentifiedPrefix(Object food) {
    return 'Món được nhận diện: $food';
  }

  @override
  String matchPercent(Object percent) {
    return 'Khớp $percent%';
  }

  @override
  String get totalCalories => 'Tổng calo';

  @override
  String get portionSize => 'Khẩu phần';

  @override
  String get quantity => 'Số lượng';

  @override
  String get nutritionFactsPerServing => 'Giá trị dinh dưỡng (mỗi khẩu phần)';

  @override
  String get savedToHistory => 'Đã lưu vào lịch sử!';

  @override
  String get saveToHistory => 'Lưu vào lịch sử';

  @override
  String get sampleFoodName => 'Bánh mì bơ';

  @override
  String get profileNoData => 'Không có dữ liệu hồ sơ';

  @override
  String get bmi => 'BMI';

  @override
  String get tdee => 'TDEE';

  @override
  String get kcalPerDay => 'kcal/ngày';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get updatePersonalInfo => 'Cập nhật thông tin cá nhân';

  @override
  String get appSettings => 'Cài đặt ứng dụng';

  @override
  String get themeAppearancePreferences => 'Giao diện, màu sắc và tùy chọn';

  @override
  String get goal => 'Mục tiêu';

  @override
  String get activityLevel => 'Mức độ hoạt động';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get personalInformation => 'Thông tin cá nhân';

  @override
  String get physicalMeasurements => 'Số đo cơ thể';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get age => 'Tuổi';

  @override
  String get gender => 'Giới tính';

  @override
  String get heightCm => 'Chiều cao (cm)';

  @override
  String get weightKg => 'Cân nặng (kg)';

  @override
  String get activityGoal => 'Hoạt động & Mục tiêu';

  @override
  String get discard => 'Hủy';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get editProfileTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get tapCameraChangeAvatar => 'Chạm vào camera để đổi ảnh đại diện';

  @override
  String get underweight => 'Thiếu cân';

  @override
  String get normalWeight => 'Bình thường';

  @override
  String get overweight => 'Thừa cân';

  @override
  String get obese => 'Béo phì';

  @override
  String get sedentary => 'Ít vận động';

  @override
  String get light => 'Nhẹ';

  @override
  String get moderate => 'Trung bình';

  @override
  String get active => 'Năng động';

  @override
  String get veryActive => 'Rất năng động';

  @override
  String get male => 'Nam';

  @override
  String get female => 'Nữ';

  @override
  String get loseWeight => 'Giảm cân';

  @override
  String get maintain => 'Duy trì';

  @override
  String get gainWeight => 'Tăng cân';

  @override
  String basedOnActivity(Object level) {
    return 'Dựa trên mức hoạt động $level';
  }

  @override
  String get profileUpdatedSuccessfully => 'Cập nhật hồ sơ thành công';

  @override
  String get uploadAvatarFailed =>
      'Tải ảnh đại diện thất bại. Vui lòng thử lại.';

  @override
  String get confirmLogout => 'Bạn có chắc muốn đăng xuất không?';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get breakfast => 'Bữa sáng';

  @override
  String get lunch => 'Bữa trưa';

  @override
  String get dinner => 'Bữa tối';

  @override
  String get snack => 'Bữa phụ';

  @override
  String get todayLabel => 'Hôm nay';

  @override
  String get yesterdayLabel => 'Hôm qua';
}
