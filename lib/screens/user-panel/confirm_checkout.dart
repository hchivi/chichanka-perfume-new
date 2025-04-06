import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/controllers/get-customer-device-token-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/services/place-order-service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

void showCustomBottomSheet() {
  final TextEditingController couponController = TextEditingController();
  String selectedPaymentMethod = 'Thanh toán khi nhận hàng'; // Giá trị mặc định
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ProductPriceController productPriceController =
      Get.find<ProductPriceController>();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');
  double discount = 0.0;
  final User? user = FirebaseAuth.instance.currentUser;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        double finalPrice = productPriceController.totalPrice.value - discount;

        return Container(
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
                if (selectedPaymentMethod == 'Thanh toán qua thẻ')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thông tin thẻ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[900]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                'assets/images/visa.jpg',
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 40,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '**** **** **** 1234',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'NGUYEN VAN A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  '12/26',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                _buildTextField(
                  controller: couponController,
                  label: 'Nhập mã giảm giá',
                  icon: Icons.discount,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.appScendoryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    setState(() {
                      if (couponController.text.trim() == 'GIAMGIA100') {
                        discount = 100000.0;
                        Get.snackbar(
                          'Thành công',
                          'Áp dụng mã giảm giá thành công! Giảm 100.000đ',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        // Hiển thị popup danh sách sản phẩm sau khi áp dụng mã
                        _showDiscountedProductsDialog(context, discount);
                      } else {
                        discount = 0.0;
                        Get.snackbar(
                          'Lỗi',
                          'Mã giảm giá không hợp lệ',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    });
                  },
                  child: const Text(
                    'Áp dụng mã giảm giá',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstant.appTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${_currencyFormat.format(finalPrice)} đ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstant.appMainColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        addressController.text.isNotEmpty) {
                      if (selectedPaymentMethod == 'Thanh toán qua thẻ') {
                        _showOtpDialog(
                          context,
                          nameController.text.trim(),
                          phoneController.text.trim(),
                          addressController.text.trim(),
                          couponController.text.trim(),
                        );
                      } else {
                        final customerToken = await getCustomerDeviceToken();
                        placeOrder(
                          context: context,
                          customerName: nameController.text.trim(),
                          customerPhone: phoneController.text.trim(),
                          customerAddress: addressController.text.trim(),
                          customerDeviceToken: customerToken ?? '',
                          paymentMethod: selectedPaymentMethod,
                          couponCode: couponController.text.trim(),
                        );
                        Get.back();
                      }
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
        );
      },
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
        borderSide: const BorderSide(color: AppConstant.appMainColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
  );
}

void _showDiscountedProductsDialog(BuildContext context, double discount) {
  final User? user = FirebaseAuth.instance.currentUser;
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Sản phẩm sau khi giảm giá',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Chiều cao cố định cho dialog
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
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data?.docs.isEmpty ?? true) {
              return const Center(
                  child: Text('Không có sản phẩm trong giỏ hàng'));
            }

            final cartItems = snapshot.data!.docs
                .map((doc) =>
                    CartModel.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            // Tính tổng số lượng sản phẩm để chia đều discount
            double totalQuantity =
                cartItems.fold(0, (sum, item) => sum + item.productQuantity);
            double discountPerItem = discount / totalQuantity;

            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartModel = cartItems[index];
                // Giá sau khi giảm cho từng sản phẩm
                double discountedPricePerItem =
                    cartModel.productTotalPrice / cartModel.productQuantity -
                        discountPerItem;
                double totalDiscountedPrice =
                    discountedPricePerItem * cartModel.productQuantity;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
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
                                'Số lượng: ${cartModel.productQuantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Giá gốc: ${_currencyFormat.format(cartModel.productTotalPrice)} đ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Giá sau giảm: ${_currencyFormat.format(totalDiscountedPrice)} đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstant.appMainColor,
                                ),
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
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Đóng',
            style: TextStyle(color: AppConstant.appMainColor),
          ),
        ),
      ],
    ),
  );
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

void _showOtpDialog(BuildContext context, String customerName,
    String customerPhone, String customerAddress, String couponCode) async {
  Get.dialog(
    const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang xử lý...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black54,
  );

  await Future.delayed(const Duration(seconds: 3));
  Get.back();

  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Get.dialog(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Xác nhận OTP',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Vui lòng nhập mã OTP 6 chữ số để xác nhận thanh toán.'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Mã OTP',
                  hintText: 'Nhập 6 chữ số',
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstant.navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (otpController.text.length == 6) {
                        setState(() {
                          isLoading = true;
                        });

                        await Future.delayed(const Duration(seconds: 3));

                        final customerToken = await getCustomerDeviceToken();
                        placeOrder(
                          context: context,
                          customerName: customerName,
                          customerPhone: customerPhone,
                          customerAddress: customerAddress,
                          customerDeviceToken: customerToken ?? '',
                          paymentMethod: 'Thanh toán qua thẻ',
                          couponCode: couponCode,
                        );
                        Get.back();
                        Get.back();
                        Get.snackbar(
                          'Thành công',
                          'Thanh toán đã được thực hiện thành công!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Lỗi',
                          'Vui lòng nhập đúng 6 chữ số OTP',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ),
    barrierDismissible: false,
  );
}
