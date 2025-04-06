import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import '../../models/product-model.dart';
import '../../utils/app-constant.dart';

class AllFlashSaleProductScreen extends StatelessWidget {
  const AllFlashSaleProductScreen({super.key});

  // Hàm định dạng tiền tệ với dấu chấm và ký hiệu đ
  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        title: Text(
          'Flash Sale - Khuyến Mãi',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .where('isSale', isEqualTo: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: Get.height / 5,
              child: const Center(child: CupertinoActivityIndicator()),
            );
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(
                child: Text('Không tìm thấy sản phẩm khuyến mãi!'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.61, // Adjusted to give more vertical space
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];
              final productModel = ProductModel.fromMap(
                  productData.data() as Map<String, dynamic>);

              double discountPercent = ((double.parse(productModel.fullPrice) -
                          double.parse(productModel.salePrice)) /
                      double.parse(productModel.fullPrice)) *
                  100;

              return GestureDetector(
                onTap: () => Get.to(
                    () => ProductDetailsScreen(productModel: productModel)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.hardEdge, // Clip any overflowing content
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image section
                          Expanded(
                            child: FillImageCard(
                              borderRadius: 10.0,
                              width: double.infinity,
                              heightImage: Get.height * 0.21, // Reduced height
                              imageProvider: CachedNetworkImageProvider(
                                productModel.productImages[0],
                              ),
                            ),
                          ),
                          // Text section with minimal padding to reduce gap
                          Container(
                            padding: const EdgeInsets.only(
                                top: 2.0,
                                bottom: 5.5,
                                left: 8.0,
                                right: 8.0), // Reduced top padding to 2.0
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  productModel.productName,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5), // Minimal spacing
                                Text(
                                  formatPrice(productModel.fullPrice),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  formatPrice(productModel.salePrice),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Discount badge
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${discountPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}

// Giả định ProductModel có phương thức fromMap
extension ProductModelExtension on ProductModel {
  static ProductModel fromMap(Map<String, dynamic> data) {
    return ProductModel(
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
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }
}
