import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';

class FavouriteProductScreen extends StatefulWidget {
  const FavouriteProductScreen({super.key});

  @override
  _FavouriteProductScreenState createState() => _FavouriteProductScreenState();
}

class _FavouriteProductScreenState extends State<FavouriteProductScreen> {
  String searchQuery = '';
  String sortBy = 'name_asc'; // Mặc định sắp xếp theo tên A-Z
  User? user = FirebaseAuth.instance.currentUser;

  // Hàm định dạng tiền tệ
  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  // Hàm lọc và sắp xếp danh sách sản phẩm yêu thích
  List<ProductModel> filterAndSortProducts(List<QueryDocumentSnapshot> docs) {
    List<ProductModel> products = docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return ProductModel(
        productId: data['productId'],
        productName: data['productName'],
        productImages: List<String>.from(data['productImages']),
        fullPrice: data['fullPrice'],
        salePrice: data['salePrice'],
        isSale: data['isSale'],
        categoryId: '',
        categoryName: '',
        productDescription: '',
        deliveryTime: '',
        createdAt: data['createdAt'],
        updatedAt: data['createdAt'],
      );
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
        title: const Text('Sản phẩm yêu thích'),
        backgroundColor: AppConstant.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập để xem mục yêu thích'))
          : Column(
              children: [
                // Thanh tìm kiếm và bộ lọc
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm yêu thích...',
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
                              value: 'price_asc',
                              child: Text('Giá: Thấp đến Cao')),
                          DropdownMenuItem(
                              value: 'price_desc',
                              child: Text('Giá: Cao đến Thấp')),
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
                // Danh sách sản phẩm yêu thích
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('favorites')
                        .doc(user!.uid)
                        .collection('items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Chưa có sản phẩm yêu thích'));
                      }

                      final filteredProducts =
                          filterAndSortProducts(snapshot.data!.docs);

                      return GridView.builder(
                        padding: const EdgeInsets.all(5.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];

                          return GestureDetector(
                            onTap: () => Get.to(() =>
                                ProductDetailsScreen(productModel: product)),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Stack(
                                children: [
                                  FillImageCard(
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
                                        product.isSale
                                            ? formatPrice(product.salePrice)
                                            : formatPrice(product.fullPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('favorites')
                                            .doc(user!.uid)
                                            .collection('items')
                                            .doc(product.productId)
                                            .delete();
                                      },
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
              ],
            ),
    );
  }
}
