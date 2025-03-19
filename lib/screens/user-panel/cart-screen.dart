import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/screens/user-panel/checkout-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
          'Giỏ hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
                  'Giỏ hàng trống!',
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
                return _buildCartItem(cartModel);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCartItem(CartModel cartModel) {
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
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row chứa ảnh và thông tin cơ bản
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh sản phẩm
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
                    // Thông tin cơ bản
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
                // Thông tin chi tiết
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Giá và trạng thái sale
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
                        _buildQuantityControls(cartModel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Thời gian giao hàng
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
                    // Mô tả ngắn
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
    );
  }

  Widget _buildQuantityControls(CartModel cartModel) {
    return Row(
      children: [
        _buildQuantityButton(
          icon: Icons.remove,
          onTap: cartModel.productQuantity > 1
              ? () => _updateQuantity(cartModel, -1)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            cartModel.productQuantity.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _buildQuantityButton(
          icon: Icons.add,
          onTap: () => _updateQuantity(cartModel, 1),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppConstant.appMainColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
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
            onPressed: () => Get.to(() => const CheckOutScreen()),
            child: const Text(
              'Thanh toán',
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

  Future<void> _updateQuantity(CartModel cartModel, int change) async {
    final newQuantity = cartModel.productQuantity + change;
    final newTotalPrice = double.parse(cartModel.fullPrice) * newQuantity;

    await FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('cartOrders')
        .doc(cartModel.productId)
        .update({
      'productQuantity': newQuantity,
      'productTotalPrice': newTotalPrice,
    }).then((_) {
      productPriceController.fetchProductPrice();
    });
  }
}

extension CartModelExtension on CartModel {
  static CartModel fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'],
      categoryId: map['categoryId'],
      productName: map['productName'],
      categoryName: map['categoryName'],
      salePrice: map['salePrice'],
      fullPrice: map['fullPrice'],
      productImages: List<String>.from(map['productImages']),
      deliveryTime: map['deliveryTime'],
      isSale: map['isSale'],
      productDescription: map['productDescription'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      productQuantity: map['productQuantity'],
      productTotalPrice: double.parse(map['productTotalPrice'].toString()),
    );
  }
}
