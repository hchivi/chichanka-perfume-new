import 'package:chichanka_perfume/models/user-model.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //for password visibilty
  var isPasswordVisible = false.obs;

  Future<UserCredential?> signUpMethod(
    String userName,
    String userEmail,
    String userPhone,
    String userCity,
    String userPassword,
    String userDeviceToken,
  ) async {
    try {
      EasyLoading.show(status: "Vui lòng chờ");
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // send email verification
      await userCredential.user!.sendEmailVerification();

      UserModel userModel = UserModel(
        uId: userCredential.user!.uid,
        username: userName,
        email: userEmail,
        phone: userPhone,
        userImg: '',
        userDeviceToken: userDeviceToken,
        country: '',
        userAddress: '',
        street: '',
        isAdmin: false,
        isActive: true,
        createdOn: DateTime.now(),
        city: userCity,
      );

      // add data into database
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());
      EasyLoading.dismiss();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      String errorMessage;
      switch (e.code) {
        case 'network-request-failed':
          errorMessage =
              "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.";
          break;
        case 'email-already-in-use':
          errorMessage = "Email đã được sử dụng.";
          break;
        case 'invalid-email':
          errorMessage = "Email không hợp lệ.";
          break;
        case 'weak-password':
          errorMessage = "Mật khẩu quá yếu (phải từ 6 ký tự trở lên).";
          break;
        default:
          errorMessage = e.message ?? "Đã có lỗi xảy ra.";
      }
      Get.snackbar(
        "Lỗi",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appScendoryColor,
        colorText: AppConstant.appTextColor,
      );
      return null; // Trả về null nếu có lỗi FirebaseAuthException
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Lỗi",
        "Đã có lỗi xảy ra: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appScendoryColor,
        colorText: AppConstant.appTextColor,
      );
      //return null; // Trả về null nếu có lỗi khác
    }
  }
}
