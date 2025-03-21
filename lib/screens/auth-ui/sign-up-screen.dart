import 'package:chichanka_perfume/controllers/sign-up-controller.dart';
import 'package:chichanka_perfume/screens/auth-ui/sign-in-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController signUpController = Get.put(SignUpController());
  TextEditingController username = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userCity = TextEditingController();
  TextEditingController userPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppConstant.navy,
          elevation: 0, // Loại bỏ bóng đổ để giao diện phẳng hơn
          centerTitle: true,
          title: Text(
            "Đăng Ký",
            style: TextStyle(
              color: AppConstant.appTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 20.0), // Thêm padding cho đẹp
            child: Column(
              children: [
                SizedBox(height: Get.height / 20),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Chào mừng đến với Chichanka",
                    style: TextStyle(
                      color: AppConstant.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                SizedBox(height: Get.height / 20),
                _buildTextField(
                  controller: userEmail,
                  hintText: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  controller: username,
                  hintText: "Tên người dùng",
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                ),
                _buildTextField(
                  controller: userPhone,
                  hintText: "Số điện thoại",
                  icon: Icons.phone,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: userCity,
                  hintText: "Thành phố",
                  icon: Icons.location_pin,
                  keyboardType: TextInputType.streetAddress,
                ),
                _buildPasswordField(),
                SizedBox(height: Get.height / 20),
                _buildSignUpButton(),
                SizedBox(height: Get.height / 20),
                _buildSignInRow(),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Hàm tạo TextField tùy chỉnh
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        cursorColor: AppConstant.navy,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppConstant.navy),
          filled: true,
          fillColor: Colors.grey[100], // Màu nền nhẹ
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // Loại bỏ viền mặc định
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppConstant.navy),
          ),
        ),
      ),
    );
  }

  // Hàm tạo trường mật khẩu
  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Obx(
        () => TextFormField(
          controller: userPassword,
          obscureText: signUpController.isPasswordVisible.value,
          cursorColor: AppConstant.navy,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: "Mật khẩu",
            prefixIcon: Icon(Icons.password, color: AppConstant.navy),
            suffixIcon: GestureDetector(
              onTap: () => signUpController.isPasswordVisible.toggle(),
              child: Icon(
                signUpController.isPasswordVisible.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppConstant.navy,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppConstant.navy),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm tạo nút Đăng Ký
  Widget _buildSignUpButton() {
    return Material(
      elevation: 5, // Thêm bóng đổ cho nút
      borderRadius: BorderRadius.circular(25.0),
      child: Container(
        width: Get.width / 2,
        height: Get.height / 16,
        decoration: BoxDecoration(
          color: AppConstant.navy,
          borderRadius: BorderRadius.circular(25.0),
          gradient: LinearGradient(
            colors: [AppConstant.navy, AppConstant.navy.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TextButton(
          onPressed: () async {
            String name = username.text.trim();
            String email = userEmail.text.trim();
            String phone = userPhone.text.trim();
            String city = userCity.text.trim();
            String password = userPassword.text.trim();
            String? userDeviceToken = '';

            if (name.isEmpty ||
                email.isEmpty ||
                phone.isEmpty ||
                city.isEmpty ||
                password.isEmpty) {
              Get.snackbar(
                "Lỗi",
                "Vui lòng nhập đầy đủ thông tin",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppConstant.navy,
                colorText: AppConstant.appTextColor,
              );
            } else {
              UserCredential? userCredential =
                  await signUpController.signUpMethod(
                name,
                email,
                phone,
                city,
                password,
                userDeviceToken,
              );

              if (userCredential != null) {
                Get.snackbar(
                  "Email xác nhận đã được gửi",
                  "Vui lòng kiểm tra email của bạn",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppConstant.navy,
                  colorText: AppConstant.appTextColor,
                );
                FirebaseAuth.instance.signOut();
                Get.offAll(() => SignInScreen());
              }
            }
          },
          child: Text(
            "ĐĂNG KÝ",
            style: TextStyle(
              color: AppConstant.appTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Hàm tạo dòng "Đã có tài khoản? Đăng nhập"
  Widget _buildSignInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Đã có tài khoản? ",
          style: TextStyle(color: AppConstant.navy),
        ),
        GestureDetector(
          onTap: () => Get.offAll(() => SignInScreen()),
          child: Text(
            "Đăng nhập",
            style: TextStyle(
              color: AppConstant.navy,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
