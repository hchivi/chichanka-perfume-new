import 'package:chichanka_perfume/models/user-model.dart';
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
    // Here you could add logic to update notification settings in Firestore
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
    // Apply theme change
    Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
    Get.snackbar(
      "Giao diện",
      value ? "Đã chuyển sang chế độ tối" : "Đã chuyển sang chế độ sáng",
      backgroundColor: AppConstant.appMainColor,
      colorText: Colors.white,
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
                        onTap: () {
                          // Add edit profile functionality here
                          Get.snackbar(
                              "Thông báo", "Chỉnh sửa hồ sơ - Sắp ra mắt!");
                        },
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
                            // Add language change logic here
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
    );
  }
}
