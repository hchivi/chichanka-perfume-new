import 'package:chichanka_perfume/controllers/get-customer-device-token-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        elevation: 0,
        title: const Text(
          'Thanh toán',
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
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppConstant.appMainColor.withOpacity(0.1),
                  backgroundImage: NetworkImage(cartModel.productImages[0]),
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
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currencyFormat.format(cartModel.productTotalPrice)} đ',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppConstant.appMainColor,
                              fontWeight: FontWeight.bold,
                            ),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  void showCustomBottomSheet() {
    final TextEditingController couponController = TextEditingController();
    String selectedPaymentMethod =
        'Thanh toán khi nhận hàng'; // Giá trị mặc định

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thông tin giao hàng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.appMainColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: nameController,
                label: 'Họ và tên người mua',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: addressController,
                label: 'Địa chỉ giao hàng',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              // Thông tin miễn phí vận chuyển
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Phí vận chuyển:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Miễn phí',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstant.appMainColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Hình thức thanh toán
              const Text(
                'Hình thức thanh toán:',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: selectedPaymentMethod,
                isExpanded: true,
                items: <String>[
                  'Thanh toán khi nhận hàng',
                  'Thanh toán qua thẻ',
                  'Thanh toán qua ví điện tử'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Khung nhập mã giảm giá
              _buildTextField(
                controller: couponController,
                label: 'Nhập mã giảm giá',
                icon: Icons.discount,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstant.appMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    final customerToken = await getCustomerDeviceToken();
                    placeOrder(
                      context: context,
                      customerName: nameController.text.trim(),
                      customerPhone: phoneController.text.trim(),
                      customerAddress: addressController.text.trim(),
                      customerDeviceToken: customerToken ?? '',
                      paymentMethod:
                          selectedPaymentMethod, // Truyền thêm hình thức thanh toán
                      couponCode:
                          couponController.text.trim(), // Truyền mã giảm giá
                    );
                    Get.back(); // Đóng bottom sheet sau khi đặt hàng thành công
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Vui lòng điền đầy đủ thông tin',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text(
                  'Đặt hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstant.appMainColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstant.appMainColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
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
