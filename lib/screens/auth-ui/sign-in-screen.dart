import 'package:chichanka_perfume/controllers/get-user-data-controller.dart';
import 'package:chichanka_perfume/controllers/sign-in-controller.dart';
import 'package:chichanka_perfume/screens/admin-panel/admin-main-screen.dart';
import 'package:chichanka_perfume/screens/auth-ui/forget-password-screen.dart';
import 'package:chichanka_perfume/screens/auth-ui/sign-up-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SignInScreen> {
  final SignInController signInController = Get.put(SignInController());
  final GetUserDataController getUserDataController =
      Get.put(GetUserDataController());
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppConstant.navy,
            centerTitle: true,
            title: Text(
              'ĐĂNG NHẬP',
              style: TextStyle(
                  color: AppConstant.appTextColor, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                isKeyboardVisible
                    ? Text("Chào mừng bạn")
                    : Column(
                        children: [
                          Lottie.asset(
                            'assets/images/splash-icon.json',
                            width: Get.width, // Chiếm toàn bộ chiều rộng
                            fit: BoxFit.cover, // Đảm bảo trải rộng
                          ),
                        ],
                      ),
                SizedBox(height: Get.height / 20),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.0), // Padding cho các phần còn lại
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: userEmail,
                        hintText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildPasswordField(),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Get.to(() => ForgetPasswordScreen()),
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: AppConstant.navy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height / 20),
                      _buildSignInButton(),
                      SizedBox(height: Get.height / 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bạn không có tài khoản?',
                            style: TextStyle(color: AppConstant.navy),
                          ),
                          GestureDetector(
                            onTap: () => Get.offAll(() => SignUpScreen()),
                            child: Text(
                              'Đăng ký?',
                              style: TextStyle(
                                color: AppConstant.navy,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm tạo TextField tùy chỉnh cho Email
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
    );
  }

  // Hàm tạo trường Mật khẩu
  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Obx(
        () => TextFormField(
          controller: userPassword,
          obscureText: signInController.isPasswordVisible.value,
          cursorColor: AppConstant.navy,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: 'Mật khẩu',
            prefixIcon: Icon(Icons.password, color: AppConstant.navy),
            suffixIcon: GestureDetector(
              onTap: () => signInController.isPasswordVisible.toggle(),
              child: Icon(
                signInController.isPasswordVisible.value
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

  // Hàm tạo nút Đăng Nhập với hiệu ứng đổ bóng
  Widget _buildSignInButton() {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(25.0),
      child: Container(
        width: Get.width / 2,
        height: Get.height / 16,
        decoration: BoxDecoration(
          color: AppConstant.navy,
          borderRadius: BorderRadius.circular(25.0),
          gradient: LinearGradient(
            colors: [AppConstant.navy, AppConstant.navy.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TextButton(
          onPressed: () async {
            String email = userEmail.text.trim();
            String password = userPassword.text.trim();

            if (email.isEmpty || password.isEmpty) {
              Get.snackbar(
                "Lỗi",
                "Hãy nhập đầy đủ thông tin",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppConstant.appScendoryColor,
                colorText: AppConstant.appTextColor,
              );
            } else {
              UserCredential? userCredential =
                  await signInController.signInMethod(email, password);

              if (userCredential != null) {
                var userData = await getUserDataController
                    .getUserData(userCredential.user!.uid);

                if (userCredential.user!.emailVerified) {
                  if (userData[0]['isAdmin'] == true) {
                    Get.snackbar(
                      "Quản trị viên đăng nhập thành công",
                      "Đăng nhập thành công!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppConstant.navy,
                      colorText: AppConstant.appTextColor,
                    );
                    Get.offAll(() => AdminMainScreen());
                  } else {
                    Get.offAll(() => MainScreen());
                    Get.snackbar(
                      "Người dùng đăng nhập thành công",
                      "Đăng nhập thành công!",
                      backgroundColor: Colors.green,
                      colorText: AppConstant.appTextColor,
                    );
                  }
                } else {
                  Get.snackbar(
                    "Lỗi",
                    "Hãy xác thực email của bạn",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppConstant.navy,
                    colorText: AppConstant.appTextColor,
                  );
                }
              } else {
                Get.snackbar(
                  "Lỗi",
                  "Hãy thử lại",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppConstant.navy,
                  colorText: AppConstant.appTextColor,
                );
              }
            }
          },
          child: Text(
            'ĐĂNG NHẬP',
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
}
