import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/settings-screen.dart';
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
  String sortBy = 'name_asc';
  int _selectedIndex = 0;
  int _currentPage = 1; // Trang hiện tại
  final int _itemsPerPage = 6; // Số sản phẩm mỗi trang

  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  List<ProductModel> filterAndSortProducts(List<QueryDocumentSnapshot> docs) {
    List<ProductModel> products = docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    if (searchQuery.isNotEmpty) {
      products = products
          .where((product) => product.productName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

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

  // Lấy danh sách sản phẩm cho trang hiện tại
  List<ProductModel> getPaginatedProducts(List<ProductModel> products) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return products.sublist(
      startIndex,
      endIndex > products.length ? products.length : endIndex,
    );
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
                      _currentPage = 1; // Reset về trang 1 khi tìm kiếm
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
                      _currentPage = 1; // Reset về trang 1 khi sắp xếp
                    });
                  },
                ),
              ],
            ),
          ),
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

                final allProducts = filterAndSortProducts(snapshot.data!.docs);
                final paginatedProducts = getPaginatedProducts(allProducts);
                final totalPages = (allProducts.length / _itemsPerPage).ceil();

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(5.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: paginatedProducts.length,
                        itemBuilder: (context, index) {
                          final productModel = paginatedProducts[index];

                          return GestureDetector(
                            onTap: () => Get.to(() => ProductDetailsScreen(
                                productModel: productModel)),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
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
                      ),
                    ),
                    // Điều khiển phân trang
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_left),
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            'Trang $_currentPage / $totalPages',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_right),
                            onPressed: _currentPage < totalPages
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(double.infinity, 70),
                painter: BottomNavPainter(selectedIndex: _selectedIndex),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  label: 'Sản phẩm',
                  index: 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Trang chủ',
                  index: 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Get.to(() => const MainScreen());
                  },
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Cài đặt',
                  index: 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Get.to(() => SettingsScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppConstant.navy : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppConstant.navy : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Các class/extension khác giữ nguyên
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

class BottomNavPainter extends CustomPainter {
  final int selectedIndex;

  BottomNavPainter({required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    double width = size.width;
    double height = size.height;
    double itemWidth = width / 3;
    double circleRadius = 30;
    double circleCenterX = itemWidth * selectedIndex + itemWidth / 2;

    path.moveTo(0, 0);
    path.lineTo(circleCenterX - circleRadius, 0);

    path.quadraticBezierTo(
      circleCenterX - circleRadius / 2,
      0,
      circleCenterX - circleRadius / 2,
      circleRadius / 2,
    );
    path.quadraticBezierTo(
      circleCenterX,
      circleRadius * 1.5,
      circleCenterX + circleRadius / 2,
      circleRadius / 2,
    );
    path.quadraticBezierTo(
      circleCenterX + circleRadius / 2,
      0,
      circleCenterX + circleRadius,
      0,
    );

    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
