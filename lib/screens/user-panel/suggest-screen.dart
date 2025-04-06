import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SuggestionsScreen extends StatefulWidget {
  final String
      selectedScent; // Mùi hương được chọn từ PersonalizedSuggestionsScreen

  const SuggestionsScreen({super.key, required this.selectedScent});

  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  // Hàm định dạng tiền tệ
  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  // Hàm lấy tất cả sản phẩm ngẫu nhiên (không giới hạn số lượng)
  Future<List<ProductModel>> getRandomProducts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('isSale', isEqualTo: false)
        .get();

    List<ProductModel> products = snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // Xáo trộn toàn bộ danh sách sản phẩm
    products.shuffle(Random());

    return products; // Trả về tất cả sản phẩm đã xáo trộn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        title: Text(
          'Gợi ý nước hoa - Mùi ${widget.selectedScent}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sản phẩm gợi ý cho mùi ${widget.selectedScent}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstant.navy,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: getRandomProducts(), // Gọi hàm lấy sản phẩm ngẫu nhiên
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không tìm thấy sản phẩm'));
                  }

                  final products = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: products.length, // Hiển thị tất cả sản phẩm
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () => Get.to(
                            () => ProductDetailsScreen(productModel: product)),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: FillImageCard(
                            borderRadius: 10.0,
                            width: double.infinity,
                            heightImage: Get.height / 5,
                            imageProvider: CachedNetworkImageProvider(
                              product.productImages[0],
                            ),
                            title: Center(
                              child: Text(
                                product.productName,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            footer: Center(
                              child: Text(
                                formatPrice(product.fullPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
