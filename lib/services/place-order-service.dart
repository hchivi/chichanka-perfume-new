// ignore_for_file: file_names, avoid_print, unused_local_variable, prefer_const_constructors

import 'package:chichanka_perfume/models/order-model.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/services/generate-order-id-server.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void placeOrder({
  required BuildContext context,
  required String customerName,
  required String customerPhone,
  required String customerAddress,
  required String customerDeviceToken,
  required String paymentMethod, // Thêm hình thức thanh toán
  String? couponCode, // Thêm mã giảm giá (có thể null)
}) async {
  final user = FirebaseAuth.instance.currentUser;
  EasyLoading.show(status: "Vui lòng chờ...");
  if (user != null) {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('cartOrders')
          .get();

      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      if (documents.isEmpty) {
        EasyLoading.dismiss();
        Get.snackbar(
          "Lỗi",
          "Giỏ hàng trống!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      for (var doc in documents) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>;

        String orderId = generateOrderId();

        OrderModel cartModel = OrderModel(
          productId: data['productId'],
          categoryId: data['categoryId'],
          productName: data['productName'],
          categoryName: data['categoryName'],
          salePrice: data['salePrice'],
          fullPrice: data['fullPrice'],
          productImages: List<String>.from(data['productImages']),
          deliveryTime: data['deliveryTime'],
          isSale: data['isSale'],
          productDescription: data['productDescription'],
          createdAt: DateTime.now(),
          updatedAt: data['updatedAt'],
          productQuantity: data['productQuantity'],
          productTotalPrice: double.parse(data['productTotalPrice'].toString()),
          customerId: user.uid,
          status: false,
          customerName: customerName,
          customerPhone: customerPhone,
          customerAddress: customerAddress,
          customerDeviceToken: customerDeviceToken,
          paymentMethod: paymentMethod, // Thêm vào model nếu cần
          couponCode: couponCode ?? '', // Thêm vào model nếu cần
        );

        // Lưu thông tin đơn hàng chung
        await FirebaseFirestore.instance.collection('orders').doc(user.uid).set(
          {
            'uId': user.uid,
            'customerName': customerName,
            'customerPhone': customerPhone,
            'customerAddress': customerAddress,
            'customerDeviceToken': customerDeviceToken,
            'orderStatus': false,
            'createdAt': DateTime.now(),
            'paymentMethod': paymentMethod, // Lưu hình thức thanh toán
            'couponCode': couponCode ?? '', // Lưu mã giảm giá
          },
          SetOptions(merge: true), // Sử dụng merge để không ghi đè dữ liệu cũ
        );

        // Lưu chi tiết đơn hàng
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(user.uid)
            .collection('confirmOrders')
            .doc(orderId)
            .set(cartModel.toMap());

        // Xóa sản phẩm khỏi giỏ hàng
        await FirebaseFirestore.instance
            .collection('cart')
            .doc(user.uid)
            .collection('cartOrders')
            .doc(cartModel.productId.toString())
            .delete()
            .then((value) {
          print('Đã xóa ${cartModel.productId.toString()}');
        });
      }

      print("Đơn hàng đã được xác nhận");
      Get.snackbar(
        "Đơn hàng đã được xác nhận",
        "Cảm ơn bạn đã đặt hàng!",
        backgroundColor: AppConstant.appMainColor,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      EasyLoading.dismiss();
      Get.offAll(() => MainScreen());
    } catch (e) {
      print("Lỗi $e");
      EasyLoading.dismiss();
      Get.snackbar(
        "Lỗi",
        "Không thể đặt hàng: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } else {
    EasyLoading.dismiss();
    Get.snackbar(
      "Lỗi",
      "Vui lòng đăng nhập để đặt hàng!",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
