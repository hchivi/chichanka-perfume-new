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

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String searchQuery = '';
  String sortBy = 'name_asc'; // Mặc định sắp xếp theo tên A-Z

  // Hàm định dạng tiền tệ
  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  // Hàm lọc và sắp xếp danh sách sản phẩm
  List<ProductModel> filterAndSortProducts(List<QueryDocumentSnapshot> docs) {
    List<ProductModel> products = docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    // Lọc theo tìm kiếm
    if (searchQuery.isNotEmpty) {
      products = products
          .where((product) => product.productName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Sắp xếp
    switch (sortBy) {
      case 'name_asc':
        products.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'name_desc':
        products.sort((a, b) => b.productName.compareTo(a.productName));
        break;
      case 'price_asc':
        products.sort((a, b) =>
            double.parse(a.fullPrice).compareTo(double.parse(b.fullPrice)));
        break;
      case 'price_desc':
        products.sort((a, b) =>
            double.parse(b.fullPrice).compareTo(double.parse(a.fullPrice)));
        break;
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        title: Text(
          'Tất cả sản phẩm',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm và bộ lọc
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: sortBy,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                        value: 'name_asc', child: Text('Tên: A-Z')),
                    DropdownMenuItem(
                        value: 'name_desc', child: Text('Tên: Z-A')),
                    DropdownMenuItem(
                        value: 'price_asc', child: Text('Giá: Thấp đến Cao')),
                    DropdownMenuItem(
                        value: 'price_desc', child: Text('Giá: Cao đến Thấp')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          // Danh sách sản phẩm
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('products')
                  .where('isSale', isEqualTo: false)
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

                final filteredProducts =
                    filterAndSortProducts(snapshot.data!.docs);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(5.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final productModel = filteredProducts[index];

                    return GestureDetector(
                      onTap: () => Get.to(() =>
                          ProductDetailsScreen(productModel: productModel)),
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
                            productModel.productImages[0],
                          ),
                          title: Center(
                            child: Text(
                              productModel.productName,
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
                              formatPrice(productModel.fullPrice),
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
