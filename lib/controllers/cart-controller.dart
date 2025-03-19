// controllers/cart_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final RxInt cartItemCount = 0.obs;
  final RxBool isAddingToCart = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItemCount();
  }

  void fetchCartItemCount() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('cartOrders')
          .snapshots()
          .listen((snapshot) {
        cartItemCount.value = snapshot.docs.length;
      });
    }
  }

  void triggerAddToCartAnimation() {
    isAddingToCart.value = true;
    Future.delayed(Duration(milliseconds: 500), () {
      isAddingToCart.value = false;
    });
  }
}
