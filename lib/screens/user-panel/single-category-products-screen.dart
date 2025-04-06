// ignore_for_file: file_names, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, must_be_immutable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';

class AllSingleCategoryProductsScreen extends StatelessWidget {
  final String categoryId;

  const AllSingleCategoryProductsScreen({super.key, required this.categoryId});

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
          'Sản phẩm',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
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
            return const Center(child: Text('Không tìm thấy sản phẩm!'));
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

              return GestureDetector(
                onTap: () => Get.to(
                    () => ProductDetailsScreen(productModel: productModel)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FillImageCard(
                          borderRadius: 10.0,
                          width: double.infinity,
                          heightImage: Get.height * 0.21,
                          imageProvider: CachedNetworkImageProvider(
                            productModel.productImages[0],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            top: 2.0, bottom: 5.5, left: 8.0, right: 8.0),
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
                            const SizedBox(height: 5),
                            if (productModel.isSale) ...[
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
                            ] else ...[
                              Text(
                                formatPrice(productModel.fullPrice),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
    );
  }
}

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
