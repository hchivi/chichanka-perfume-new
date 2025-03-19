import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chichanka_perfume/controllers/cart-controller.dart';
import 'package:chichanka_perfume/controllers/rating-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/models/review-model.dart';
import 'package:chichanka_perfume/screens/user-panel/cart-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  const ProductDetailsScreen({super.key, required this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String selectedCapacity = '50ml';
  final List<String> capacities = ['50ml', '75ml', '100ml'];
  bool isFavorite = false;
  final CartController cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user!.uid)
          .collection('items')
          .doc(widget.productModel.productId)
          .get();
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (user == null) {
      Get.snackbar("Lỗi", "Vui lòng đăng nhập để sử dụng tính năng này");
      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(user!.uid)
        .collection('items')
        .doc(widget.productModel.productId);

    if (isFavorite) {
      await favoriteRef.delete();
      setState(() {
        isFavorite = false;
      });
      Get.snackbar("Đã xóa", "Đã xóa khỏi danh sách yêu thích");
    } else {
      await favoriteRef.set({
        'productId': widget.productModel.productId,
        'productName': widget.productModel.productName,
        'productImages': widget.productModel.productImages,
        'fullPrice': widget.productModel.fullPrice,
        'salePrice': widget.productModel.salePrice,
        'isSale': widget.productModel.isSale,
        'createdAt': Timestamp.now(),
      });
      setState(() {
        isFavorite = true;
      });
      Get.snackbar("Thành công", "Đã thêm vào danh sách yêu thích");
    }
  }

  String getPriceBasedOnCapacity(String capacity) {
    double basePrice = double.parse(widget.productModel.isSale
        ? widget.productModel.salePrice
        : widget.productModel.fullPrice);
    switch (capacity) {
      case '50ml':
        return basePrice.toString();
      case '75ml':
        return (basePrice * 1.3).toString();
      case '100ml':
        return (basePrice * 1.6).toString();
      default:
        return basePrice.toString();
    }
  }

  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(double.parse(price));
  }

  @override
  Widget build(BuildContext context) {
    CalculateProductRatingController calculateProductRatingController = Get.put(
        CalculateProductRatingController(widget.productModel.productId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        backgroundColor: AppConstant.navy,
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: AppConstant.appTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => Stack(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => CartScreen()),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedScale(
                        scale: cartController.isAddingToCart.value ? 1.2 : 1.0,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.shopping_cart,
                          color: AppConstant.appTextColor,
                        ),
                      ),
                    ),
                  ),
                  if (cartController.cartItemCount.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '${cartController.cartItemCount.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstant.appMainColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height / 60),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: CarouselSlider(
                  items: widget.productModel.productImages
                      .map(
                        (imageUrls) => ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: CachedNetworkImage(
                            imageUrl: imageUrls,
                            fit: BoxFit.cover,
                            width: Get.width - 16,
                            placeholder: (context, url) => const ColoredBox(
                              color: Colors.white,
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                    scrollDirection: Axis.horizontal,
                    autoPlay: true,
                    aspectRatio: 1.0,
                    viewportFraction: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                widget.productModel.productName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: toggleFavorite,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingBar.builder(
                              glow: false,
                              ignoreGestures: true,
                              initialRating: double.parse(
                                  calculateProductRatingController.averageRating
                                      .toString()),
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 25,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (value) {},
                            ),
                            const SizedBox(width: 8),
                            Text(
                              calculateProductRatingController.averageRating
                                  .toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Dung tích:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          children: capacities.map((capacity) {
                            return ChoiceChip(
                              label: Text(capacity),
                              selected: selectedCapacity == capacity,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCapacity = capacity;
                                  });
                                }
                              },
                              selectedColor: AppConstant.appMainColor,
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(
                                color: selectedCapacity == capacity
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "Giá: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "${formatPrice(getPriceBasedOnCapacity(selectedCapacity))} VNĐ",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Danh mục: ${widget.productModel.categoryName}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.productModel.productDescription,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton(
                              text: "Zalo",
                              onPressed: () {},
                            ),
                            const SizedBox(width: 10),
                            _buildButton(
                              text: "Thêm vào giỏ",
                              onPressed: () async {
                                if (user != null) {
                                  await checkProductExistence(uId: user!.uid);
                                  cartController.triggerAddToCartAnimation();
                                } else {
                                  Get.snackbar("Lỗi",
                                      "Vui lòng đăng nhập để thêm vào giỏ hàng");
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('products')
                      .doc(widget.productModel.productId)
                      .collection('review')
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Lỗi"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: Get.height / 5,
                        child:
                            const Center(child: CupertinoActivityIndicator()),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Chưa có đánh giá"));
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index];
                        ReviewModel reviewModel = ReviewModel(
                          customerName: data['customerName'],
                          customerPhone: data['customerPhone'],
                          customerDeviceToken: data['customerDeviceToken'],
                          customerId: data['customerId'],
                          feedback: data['feedback'],
                          rating: data['rating'],
                          createdAt: data['createdAt'],
                        );
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppConstant.appMainColor,
                              child: Text(
                                reviewModel.customerName[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(reviewModel.customerName),
                            subtitle: Text(reviewModel.feedback),
                            trailing: Text(
                              reviewModel.rating,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstant.appScendoryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppConstant.appTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> checkProductExistence({
    required String uId,
    int quantityIncrement = 1,
  }) async {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(uId)
        .collection('cartOrders')
        .doc("${widget.productModel.productId}_$selectedCapacity");

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      int currentQuantity = snapshot['productQuantity'];
      int updatedQuantity = currentQuantity + quantityIncrement;
      double totalPrice =
          double.parse(getPriceBasedOnCapacity(selectedCapacity)) *
              updatedQuantity;

      await documentReference.update({
        'productQuantity': updatedQuantity,
        'productTotalPrice': totalPrice,
        'capacity': selectedCapacity,
      });

      Get.snackbar("Thành công", "Đã cập nhật số lượng sản phẩm");
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(uId).set(
        {
          'uId': uId,
          'createdAt': DateTime.now(),
        },
      );

      CartModel cartModel = CartModel(
        productId: "${widget.productModel.productId}_$selectedCapacity",
        categoryId: widget.productModel.categoryId,
        productName: "${widget.productModel.productName} ($selectedCapacity)",
        categoryName: widget.productModel.categoryName,
        salePrice: getPriceBasedOnCapacity(selectedCapacity),
        fullPrice: getPriceBasedOnCapacity(selectedCapacity),
        productImages: widget.productModel.productImages,
        deliveryTime: widget.productModel.deliveryTime,
        isSale: widget.productModel.isSale,
        productDescription: widget.productModel.productDescription,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productQuantity: 1,
        productTotalPrice:
            double.parse(getPriceBasedOnCapacity(selectedCapacity)),
      );

      await documentReference.set(cartModel.toMap());
      Get.snackbar("Thành công", "Đã thêm sản phẩm vào giỏ hàng");
    }
    cartController.fetchCartItemCount();
  }
}
