import 'package:chichanka_perfume/controllers/get-customer-device-token-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/screens/user-panel/confirm_checkout.dart';
import 'package:chichanka_perfume/services/place-order-service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart-price-controller.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final ProductPriceController productPriceController =
      Get.put(ProductPriceController());
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .doc(user!.uid)
              .collection('cartOrders')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Có lỗi xảy ra'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CupertinoActivityIndicator(radius: 15));
            }

            if (snapshot.data?.docs.isEmpty ?? true) {
              return const Center(
                child: Text(
                  'Không có sản phẩm để thanh toán!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final productData = snapshot.data!.docs[index];
                final cartModel = CartModel.fromMap(
                    productData.data() as Map<String, dynamic>);
                return _buildCheckoutItem(cartModel);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCheckoutItem(CartModel cartModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SwipeActionCell(
        key: ObjectKey(cartModel.productId),
        trailingActions: [
          SwipeAction(
            title: "Xóa",
            color: Colors.red,
            onTap: (CompletionHandler handler) async {
              await FirebaseFirestore.instance
                  .collection('cart')
                  .doc(user!.uid)
                  .collection('cartOrders')
                  .doc(cartModel.productId)
                  .delete();
              productPriceController.fetchProductPrice();
            },
          ),
        ],
        child: GestureDetector(
          onTap: () => _showProductDetails(context, cartModel),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(cartModel.productImages[0]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartModel.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cartModel.categoryName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cartModel.isSale) ...[
                                Text(
                                  '${_currencyFormat.format(double.parse(cartModel.salePrice))} đ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                '${_currencyFormat.format(cartModel.productTotalPrice)} đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppConstant.appMainColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'x${cartModel.productQuantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Giao hàng: ${cartModel.deliveryTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cartModel.productDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, CartModel cartModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: NetworkImage(cartModel.productImages[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartModel.productName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cartModel.categoryName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (cartModel.isSale) ...[
                            Text(
                              '${_currencyFormat.format(double.parse(cartModel.salePrice))} đ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${_currencyFormat.format(cartModel.productTotalPrice)} đ',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppConstant.appMainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Giao hàng: ${cartModel.deliveryTime}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mô tả sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cartModel.productDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Đóng',
                style: TextStyle(color: AppConstant.appMainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Tổng: ${_currencyFormat.format(productPriceController.totalPrice.value)} đ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstant.appMainColor,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstant.appScendoryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => showCustomBottomSheet(),
            child: const Text(
              'Xác nhận đơn hàng',
              style: TextStyle(
                fontSize: 16,
                color: AppConstant.appTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
