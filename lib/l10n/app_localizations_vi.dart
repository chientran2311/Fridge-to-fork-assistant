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
  String get fridgeTab => 'Fridge';

  @override
  String get recipetab => 'Trợ lý AI gợi ý';

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
  String get fullNameLabel => 'Tên hiển thị';

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
  String get general => 'CÀI ĐẶT CHUNG';

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
  String get schedule => 'Lên lịch';

  @override
  String get cooknow => 'Nấu ngay';

  @override
  String get discovermore => 'Khám phá thêm';

  @override
  String get browseai => 'Các gợi ý từ AI';

  @override
  String get favoriterecipe => 'Món ăn yêu thích';

  @override
  String get fridgeManagement => 'QUẢN LÝ TỦ LẠNH';

  @override
  String get createNewFridge => 'Tạo Tủ Lạnh Mới';

  @override
  String get joinFridge => 'Tham Gia Tủ Lạnh';

  @override
  String get fridgeList => 'Danh Sách Tủ Lạnh';

  @override
  String get currentFridge => 'Tủ Lạnh Hiện Tại';

  @override
  String get inviteCode => 'Mã mời';

  @override
  String get youAreOwner => 'Bạn là chủ nhà';

  @override
  String get youAreMember => 'Bạn là thành viên';

  @override
  String get selectLanguage => 'Chọn Ngôn Ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get creatingData => 'Đang tạo dữ liệu mẫu... Vui lòng đợi!';

  @override
  String get dataCreatedSuccess =>
      '✅ Đã tạo dữ liệu thành công! Hãy kiểm tra Home.';

  @override
  String get codeCopied => 'Đã sao chép mã!';

  @override
  String get inviteCodeCopied => 'Đã sao chép mã mời!';

  @override
  String get accountDeleted => 'Đã xóa tài khoản thành công';

  @override
  String get notificationsEnabled => 'Đã bật thông báo';

  @override
  String get notificationsDisabled => 'Đã tắt thông báo';

  @override
  String get fridgeName => 'Tên tủ lạnh';

  @override
  String get fridgeNameHint => 'Ví dụ: Nhà ở Hà Nội';

  @override
  String get create => 'Tạo';

  @override
  String get join => 'Tham gia';

  @override
  String get fridgeCreated => 'Đã tạo tủ lạnh mới!';

  @override
  String get cannotCreate => 'Không thể tạo';

  @override
  String get joinedSuccess => 'Đã tham gia thành công!';

  @override
  String get invalidCode => 'Mã mời không hợp lệ';

  @override
  String get alreadyMember => 'Bạn đã là thành viên';

  @override
  String get cannotJoin => 'Không thể tham gia';

  @override
  String get noFridgesYet => 'Chưa có tủ lạnh nào';

  @override
  String get switchFridge => 'Chuyển';

  @override
  String get enterInviteCode => 'Nhập mã 6 ký tự';

  @override
  String get close => 'Đóng';

  @override
  String get shareCodeToInvite => 'Chia sẻ mã này để mời thành viên:';

  @override
  String get developerTools => 'DEVELOPER TOOLS';

  @override
  String get seedDatabase => 'Seed Database (Tạo dữ liệu mẫu)';

  @override
  String get members => 'Thành viên';

  @override
  String get viewMembers => 'Xem thành viên';

  @override
  String get removeMember => 'Xóa';

  @override
  String get memberRemoved => 'Đã xóa thành viên';

  @override
  String get cannotRemoveMember => 'Không thể xóa thành viên';

  @override
  String get leaveFridge => 'Rời Tủ Lạnh';

  @override
  String get leaveConfirm => 'Bạn có chắc muốn rời khỏi tủ lạnh này?';

  @override
  String get leftFridge => 'Đã rời khỏi tủ lạnh';

  @override
  String get ownerCannotLeave =>
      'Chủ nhà không thể rời đi. Hãy chuyển quyền trước.';

  @override
  String get alreadyOwnFridge =>
      'Bạn đã sở hữu một tủ lạnh. Mỗi người chỉ được sở hữu một.';

  @override
  String get owner => 'Chủ nhà';

  @override
  String get member => 'Thành viên';

  @override
  String get changeProfilePhoto => 'Đổi ảnh đại diện';

  @override
  String get chooseFromGallery => 'Chọn từ thư viện';

  @override
  String get takePhoto => 'Chụp ảnh mới';

  @override
  String get removePhoto => 'Xóa ảnh';

  @override
  String helloGreeting(String name) {
    return 'Xin chào, $name';
  }

  @override
  String foundRecipes(int count) {
    return 'Tìm thấy $count công thức';
  }

  @override
  String get searchingRecipes => 'Đang tìm kiếm công thức...';

  @override
  String get noRecipesFound => 'Chưa tìm thấy công thức nào.';

  @override
  String get rescueIngredients => ' để cứu nguyên liệu của bạn.';

  @override
  String readyToCook(int count) {
    return 'Sẵn sàng nấu với $count nguyên liệu từ tủ lạnh!';
  }

  @override
  String get addItemsToStart => 'Thêm nguyên liệu vào tủ lạnh để bắt đầu!';

  @override
  String get editDisplayName => 'Chỉnh sửa tên';

  @override
  String get enterNewName => 'Nhập tên mới';

  @override
  String get nameUpdated => 'Cập nhật tên thành công!';

  @override
  String get nameEmpty => 'Tên không được để trống';

  @override
  String get fridge => 'Tủ lạnh';

  @override
  String get recipes => 'Công thức';

  @override
  String get plan => 'Lập lịch';

  @override
  String get selected => 'Đã chọn';

  @override
  String get add_food_title => 'Thêm thực phẩm';

  @override
  String get ingredient_name_label => 'Tên nguyên liệu';

  @override
  String get ingredient_name_hint => 'Nhập tên (VD: Sữa tươi, Thịt bò...)';

  @override
  String get quantity_label => 'Số lượng';

  @override
  String get expiry_date_label => 'Hết hạn';

  @override
  String get select_date => 'Chọn ngày';

  @override
  String get category_label => 'Phân loại';

  @override
  String get add_tag => '+ Thêm tag';

  @override
  String get scan_barcode => 'Quét mã vạch';

  @override
  String get add_to_fridge => 'Thêm vào Tủ Lạnh';

  @override
  String get adding => 'Đang thêm...';

  @override
  String get error_empty_name => 'Vui lòng nhập tên thực phẩm';

  @override
  String get error_empty_expiry => 'Vui lòng chọn ngày hết hạn';

  @override
  String get error => 'Lỗi';

  @override
  String item_added(Object item) {
    return '$item đã được thêm!';
  }

  @override
  String barcode_found(Object item) {
    return 'Đã tìm thấy: $item';
  }

  @override
  String barcode_not_found(Object barcode) {
    return 'Không tìm thấy sản phẩm: $barcode';
  }

  @override
  String get category_vegetable => 'Rau củ';

  @override
  String get category_dairy => 'Sữa/Trứng';

  @override
  String get category_meat => 'Thịt';

  @override
  String get category_fruit => 'Trái cây';

  @override
  String get category_other => 'Khác';

  @override
  String get loginRequired => 'Vui lòng đăng nhập để thêm kế hoạch';

  @override
  String get addedToPlan => 'Đã thêm vào kế hoạch';

  @override
  String get errorAddingRecipe => 'Lỗi khi thêm công thức';

  @override
  String get selectDate => 'Chọn ngày';

  @override
  String get confirmButton => 'Xác nhận';

  @override
  String get mealPlans => 'Kế Hoạch Bữa Ăn';

  @override
  String get noRecipesAvailable => 'Không có công thức nào';

  @override
  String get noMealsPlanned => 'Chưa có bữa ăn nào được lên kế hoạch';

  @override
  String get allItems => 'Tất Cả';

  @override
  String get produce => 'Rau Củ';

  @override
  String get dairy => 'Sữa';

  @override
  String get pantry => 'Tạp Hóa';

  @override
  String get noItemsNeeded => 'Không có mục nào cần mua';

  @override
  String addedToShoppingList(String name) {
    return '✅ Đã thêm $name vào danh sách mua sắm';
  }

  @override
  String get protein => 'Protein';

  @override
  String get vegetables => 'Rau Củ';

  @override
  String get fruits => 'Trái Cây';

  @override
  String get grains => 'Ngũ Cốc';

  @override
  String get condiments => 'Gia Vị';

  @override
  String get other => 'Khác';

  @override
  String get addCustomItem => 'Thêm Mục';

  @override
  String get itemName => 'Tên Mục';

  @override
  String get quantity => 'Số Lượng';

  @override
  String get category => 'Danh Mục';

  @override
  String get addItemButton => 'Thêm Mục';
}
