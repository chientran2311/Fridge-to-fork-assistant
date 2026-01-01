// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Bếp Trợ Lý';

  @override
  String get fridgeTab => 'Tủ Lạnh';

  @override
  String get recipeTab => 'Công Thức';

  @override
  String get planTab => 'Kế Hoạch';

  @override
  String get settingsTitle => 'Cài Đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get emptyFridge => 'Tủ lạnh trống trơn!';

  @override
  String get addFirstItem => 'Hãy thêm nguyên liệu đầu tiên.';

  @override
  String get eatMeFirst => 'Sắp hết hạn ⚠️';

  @override
  String get inStock => 'Trong tủ lạnh 🥑';

  @override
  String get addItem => 'Thêm Món';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get notifications => 'Thông báo';

  @override
  String get emailLabel => 'Địa chỉ Email';

  @override
  String get emailHint => 'hello@example.com';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordHint => '........';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng Nhập';

  @override
  String get loginSuccess => 'Đăng nhập thành công!';

  @override
  String get loginErrorMissing => 'Vui lòng nhập đầy đủ Email và Mật khẩu';

  @override
  String get registerTitle => 'Tạo Tài Khoản';

  @override
  String get registerSubtitle => 'Bắt đầu tiết kiệm thực phẩm ngay hôm nay';

  @override
  String get fullNameLabel => 'Họ và Tên';

  @override
  String get fullNameHint => 'Nguyễn Văn A';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get signupButton => 'Đăng Ký';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get loginLink => 'Đăng nhập';

  @override
  String get registerSuccess => 'Tạo tài khoản thành công! Vui lòng đăng nhập.';

  @override
  String get registerErrorMissing => 'Vui lòng điền đầy đủ thông tin';

  @override
  String get registerErrorMatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get devAreaTitle => 'Khu vực Developer (Xóa sau)';

  @override
  String get devSeedDatabase => 'Tạo Database Mẫu (Firestore)';

  @override
  String get devSeeding => 'Đang khởi tạo dữ liệu...';

  @override
  String get devSeedSuccess => 'Xong! Kiểm tra Firebase Console ngay.';

  @override
  String get searchingredients => 'Tìm kiếm nguyên liệu...';

  @override
  String itemSelected(String name) {
    return 'Đã chọn: $name';
  }

  @override
  String get itemsDeleted => 'Đã xóa các mục đã chọn';

  @override
  String get weeklyPlan => 'Kế Hoạch Tuần';

  @override
  String get shoppingList => 'Danh Sách Mua Sắm';

  @override
  String get general => 'Cài đặt chung';

  @override
  String get inviteMember => 'Mời thành viên mới';

  @override
  String get logOut => 'Đăng xuất';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get deleteAccountWarning =>
      'Hành động này sẽ xóa vĩnh viễn dữ liệu của bạn. Bạn có chắc không?';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get account => 'Tài khoản';

  @override
  String get household => 'Gia đình & Chia sẻ';

  @override
  String get filterTitle => 'Lọc Công Thức';

  @override
  String get reset => 'Đặt lại';

  @override
  String get difficulty => 'Độ khó';

  @override
  String get easy => 'Dễ';

  @override
  String get medium => 'Vừa';

  @override
  String get hard => 'Khó';

  @override
  String get mealType => 'Loại bữa ăn';

  @override
  String get breakfast => 'Bữa sáng';

  @override
  String get lunch => 'Bữa trưa';

  @override
  String get dinner => 'Bữa tối';

  @override
  String get snack => 'Ăn vặt';

  @override
  String get cuisine => 'Ẩm thực';

  @override
  String get italian => 'Ý';

  @override
  String get mexican => 'Mexico';

  @override
  String get asian => 'Châu Á';

  @override
  String get vegan => 'Chay';

  @override
  String get prepTime => 'Thời gian chuẩn bị';

  @override
  String get min => 'phút';

  @override
  String get hours => 'giờ';

  @override
  String get applyFilters => 'Áp dụng bộ lọc';

  @override
  String get recipetab => 'Trợ lý AI gợi ý';

  @override
  String get schedule => 'Lên lịch';

  @override
  String get cooknow => 'Nấu ngay';

  @override
  String get discovermore => 'Khám phá thêm';

  @override
  String get browseai => 'Các gợi ý từ AI';

  @override
  String get favoriterecipe => 'Món ăn yêu thích';
}
