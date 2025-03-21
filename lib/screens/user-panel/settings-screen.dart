import 'package:chichanka_perfume/models/user-model.dart';
import 'package:chichanka_perfume/screens/user-panel/all-products-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Default notification state
  bool _isDarkMode = false; // Default theme state
  UserModel? _userModel;
  int _selectedIndex = 2; // Mặc định chọn "Cài đặt"

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          });
        }
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải thông tin người dùng");
    }
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    Get.snackbar(
      "Thông báo",
      value ? "Đã bật thông báo" : "Đã tắt thông báo",
      backgroundColor: AppConstant.appMainColor,
      colorText: Colors.white,
    );
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
    Get.snackbar(
      "Giao diện",
      value ? "Đã chuyển sang chế độ tối" : "Đã chuyển sang chế độ sáng",
      backgroundColor: AppConstant.appMainColor,
      colorText: Colors.white,
    );
  }

  // Hàm hiển thị dialog chỉnh sửa thông tin cá nhân
  void _showEditProfileDialog() {
    final TextEditingController usernameController =
        TextEditingController(text: _userModel?.username);
    final TextEditingController phoneController =
        TextEditingController(text: _userModel?.phone);
    final TextEditingController addressController =
        TextEditingController(text: _userModel?.userAddress);
    final TextEditingController streetController =
        TextEditingController(text: _userModel?.street);
    final TextEditingController cityController =
        TextEditingController(text: _userModel?.city);
    final TextEditingController countryController =
        TextEditingController(text: _userModel?.country);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa thông tin cá nhân"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration:
                      const InputDecoration(labelText: "Tên người dùng"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Số điện thoại"),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Địa chỉ"),
                ),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: "Đường"),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "Thành phố"),
                ),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: "Quốc gia"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .update({
                      'username': usernameController.text,
                      'phone': phoneController.text,
                      'userAddress': addressController.text,
                      'street': streetController.text,
                      'city': cityController.text,
                      'country': countryController.text,
                    });
                    setState(() {
                      _userModel = _userModel?.copyWith(
                        username: usernameController.text,
                        phone: phoneController.text,
                        userAddress: addressController.text,
                        street: streetController.text,
                        city: cityController.text,
                        country: countryController.text,
                      );
                    });
                    Get.snackbar("Thành công", "Thông tin đã được cập nhật");
                    Navigator.pop(context);
                  }
                } catch (e) {
                  Get.snackbar("Lỗi", "Không thể cập nhật thông tin");
                }
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cài đặt",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstant.navy,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tùy chọn cài đặt",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.appMainColor,
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tài khoản",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.person,
                            color: AppConstant.appMainColor),
                        title: Text(_userModel?.username ?? "Đang tải..."),
                        subtitle: Text(_userModel?.email ?? ""),
                        trailing: const Icon(Icons.edit),
                        onTap: _showEditProfileDialog,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferences Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tùy chọn",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        activeColor: AppConstant.appMainColor,
                        title: const Text("Thông báo"),
                        secondary: const Icon(Icons.notifications,
                            color: AppConstant.appMainColor),
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                      ),
                      SwitchListTile(
                        activeColor: AppConstant.appMainColor,
                        title: const Text("Chế độ tối"),
                        secondary: const Icon(Icons.color_lens,
                            color: AppConstant.appMainColor),
                        value: _isDarkMode,
                        onChanged: _toggleTheme,
                      ),
                      ListTile(
                        leading: const Icon(Icons.language,
                            color: AppConstant.appMainColor),
                        title: const Text("Ngôn ngữ"),
                        trailing: DropdownButton<String>(
                          value: "Tiếng Việt",
                          items: const [
                            DropdownMenuItem(
                                value: "Tiếng Việt", child: Text("Tiếng Việt")),
                            DropdownMenuItem(
                                value: "English", child: Text("English")),
                          ],
                          onChanged: (value) {
                            Get.snackbar(
                                "Thông báo", "Thay đổi ngôn ngữ - Sắp ra mắt!");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(double.infinity, 70),
                painter: BottomNavPainter(selectedIndex: _selectedIndex),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  label: 'Sản phẩm',
                  index: 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    Get.to(() => const AllProductsScreen());
                  },
                ),
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Trang chủ',
                  index: 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Get.to(() => const MainScreen());
                  },
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Cài đặt',
                  index: 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppConstant.navy : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppConstant.navy : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Class BottomNavPainter
class BottomNavPainter extends CustomPainter {
  final int selectedIndex;

  BottomNavPainter({required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    double width = size.width;
    double height = size.height;
    double itemWidth = width / 3;
    double circleRadius = 30;
    double circleCenterX = itemWidth * selectedIndex + itemWidth / 2;

    path.moveTo(0, 0);
    path.lineTo(circleCenterX - circleRadius, 0);
    path.quadraticBezierTo(
      circleCenterX - circleRadius / 2,
      0,
      circleCenterX - circleRadius / 2,
      circleRadius / 2,
    );
    path.quadraticBezierTo(
      circleCenterX,
      circleRadius * 1.5,
      circleCenterX + circleRadius / 2,
      circleRadius / 2,
    );
    path.quadraticBezierTo(
      circleCenterX + circleRadius / 2,
      0,
      circleCenterX + circleRadius,
      0,
    );
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cập nhật UserModel để hỗ trợ copyWith
extension UserModelExtension on UserModel {
  UserModel copyWith({
    String? username,
    String? email,
    String? phone,
    String? userImg,
    String? userDeviceToken,
    String? country,
    String? userAddress,
    String? street,
    bool? isAdmin,
    bool? isActive,
    dynamic createdOn,
    String? city,
  }) {
    return UserModel(
      uId: this.uId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userImg: userImg ?? this.userImg,
      userDeviceToken: userDeviceToken ?? this.userDeviceToken,
      country: country ?? this.country,
      userAddress: userAddress ?? this.userAddress,
      street: street ?? this.street,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      createdOn: createdOn ?? this.createdOn,
      city: city ?? this.city,
    );
  }
}
