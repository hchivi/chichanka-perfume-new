// widgets/drawer-widget.dart
import 'package:chichanka_perfume/screens/user-panel/all-orders-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/all-products-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/contact-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/favorite-product-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/personal-suggest-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/settings-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/auth-ui/welcome-screen.dart';
import '../models/user-model.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  Future<UserModel?> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> _fetchPersonalizedSuggestions() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Lấy lịch sử mua sắm từ Firestore
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        List<String> scentPreferences = [];
        for (var doc in orderSnapshot.docs) {
          Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
          List<dynamic> products = orderData['products'] ?? [];
          for (var product in products) {
            scentPreferences.add(product['scentType'] ?? 'Unknown');
          }
        }

        // Loại bỏ trùng lặp và trả về danh sách
        return scentPreferences.isNotEmpty
            ? scentPreferences.toSet().toList()
            : ['Floral', 'Woody', 'Citrus']; // Mặc định nếu không có dữ liệu
      }
      return ['Floral', 'Woody', 'Citrus']; // Mặc định nếu không có người dùng
    } catch (e) {
      print('Error fetching suggestions: $e');
      return ['Floral', 'Woody', 'Citrus']; // Mặc định khi có lỗi
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "G";
    List<String> nameParts = name.split(' ');
    return nameParts
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      backgroundColor: AppConstant.navy,
      child: FutureBuilder<UserModel?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          String displayName = "Guest";
          String initials = "G";

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            displayName = snapshot.data!.username;
            initials = _getInitials(displayName);
          }

          return Column(
            children: [
              _buildHeader(context, displayName, initials),
              const Divider(
                indent: 16,
                endIndent: 16,
                thickness: 1,
                color: Colors.grey,
              ),
              Expanded(
                child: _buildMenuItems(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String displayName, String initials) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstant.appMainColor.withValues(alpha: 0.9),
            AppConstant.navy,
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  color: AppConstant.appTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Version 1.0.1",
                style: TextStyle(
                  color: AppConstant.appTextColor.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        _buildMenuItem(
          context: context,
          title: "Trang chủ",
          icon: Icons.home,
          textColor: Colors.black,
        ),
        _buildMenuItem(
          context: context,
          title: "Sản phẩm",
          icon: Icons.production_quantity_limits,
          textColor: Colors.black,
          onTap: () {
            Get.back();
            Get.to(() => const AllProductsScreen());
          },
        ),
        _buildMenuItem(
          context: context,
          title: "Sản phẩm yêu thích",
          icon: Icons.favorite,
          textColor: Colors.black,
          onTap: () {
            Get.back();
            Get.to(() => const FavouriteProductScreen());
          },
        ),
        _buildMenuItem(
          context: context,
          title: "Đơn hàng",
          icon: Icons.shopping_bag,
          textColor: Colors.black,
          onTap: () {
            Get.back();
            Get.to(() => const AllOrdersScreen());
          },
        ),
        _buildMenuItem(
          context: context,
          title: "Gợi ý nước hoa",
          icon: Icons.recommend,
          textColor: Colors.black,
          onTap: () async {
            Get.back();
            List<String> suggestions = await _fetchPersonalizedSuggestions();
            Get.to(
                () => PersonalizedSuggestionsScreen(suggestions: suggestions));
          },
        ),
        _buildMenuItem(
          context: context,
          title: "Liên hệ",
          icon: Icons.help,
          textColor: Colors.black,
          onTap: () {
            Get.back();
            Get.to(() => const ContactScreen());
          },
        ),
        _buildMenuItem(
          context: context,
          title: "Cài đặt",
          icon: Icons.settings,
          textColor: Colors.black,
          onTap: () {
            Get.back();
            Get.to(() => SettingsScreen());
          },
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          context: context,
          title: "Đăng xuất",
          icon: Icons.logout,
          onTap: () async {
            GoogleSignIn googleSignIn = GoogleSignIn();
            FirebaseAuth auth = FirebaseAuth.instance;
            await auth.signOut();
            await googleSignIn.signOut();
            Get.offAll(() => WelcomeScreen());
          },
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    bool isLogout = false,
    Color? textColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : AppConstant.appMainColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isLogout ? Colors.red : (textColor ?? AppConstant.appTextColor),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.red : AppConstant.appTextColor,
        ),
        tileColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
