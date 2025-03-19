import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/models/order-model.dart';
import 'package:chichanka_perfume/screens/user-panel/add_reviews_screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final ProductPriceController productPriceController =
      Get.put(ProductPriceController());
  String _filterStatus = 'all'; // Trạng thái lọc: 'all', 'pending', 'delivered'

  Future<void> _refreshOrders() async {
    setState(() {}); // Tải lại StreamBuilder
    Get.snackbar('Thành công', 'Danh sách đơn hàng đã được làm mới');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .doc(user!.uid)
                    .collection('confirmOrders')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorWidget("Đã xảy ra lỗi");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return _buildEmptyWidget();
                  }
                  final filteredDocs = _filterOrders(snapshot.data!.docs);
                  if (filteredDocs.isEmpty) {
                    return _buildEmptyWidget(
                        message: "Không có đơn hàng phù hợp!");
                  }
                  return _buildOrderList(filteredDocs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstant.navy,
      elevation: 0,
      title: const Text(
        "Tất cả đơn hàng",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshOrders,
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterButton("Tất cả", 'all'),
          _buildFilterButton("Đang chờ", 'pending'),
          _buildFilterButton("Đã giao", 'delivered'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filterValue) {
    final isSelected = _filterStatus == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstant.appMainColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConstant.appMainColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConstant.appMainColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CupertinoActivityIndicator(radius: 20),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyWidget({String message = "Bạn chưa có đơn hàng nào!"}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterOrders(List<QueryDocumentSnapshot> docs) {
    if (_filterStatus == 'all') return docs;
    return docs.where((doc) {
      final status = doc['status'] as bool;
      return _filterStatus == 'delivered' ? status : !status;
    }).toList();
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final productData = docs[index];
        final orderModel =
            OrderModel.fromMap(productData.data() as Map<String, dynamic>);
        return _buildOrderCard(orderModel);
      },
    );
  }

  Widget _buildOrderCard(OrderModel orderModel) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetails(orderModel),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(orderModel.productImages[0]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderModel.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstant.navy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tổng tiền: ${formatter.format(orderModel.productTotalPrice)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusChip(orderModel.status),
                    const SizedBox(height: 8),
                    Text(
                      "Ngày đặt: ${DateFormat('dd/MM/yyyy').format(orderModel.createdAt.toDate())}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildActionButton(orderModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(bool status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ? "Đã giao" : "Đang chờ...",
        style: TextStyle(
          color: status ? Colors.green : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(OrderModel orderModel) {
    return orderModel.status
        ? ElevatedButton(
            onPressed: () =>
                Get.to(() => AddReviewScreen(orderModel: orderModel)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstant.appMainColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              "Đánh giá",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        : const SizedBox.shrink();
  }

  void _showOrderDetails(OrderModel orderModel) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Chi tiết đơn hàng",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstant.navy,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Tên sản phẩm", orderModel.productName),
            _buildDetailRow("Danh mục", orderModel.categoryName),
            _buildDetailRow("Số lượng", orderModel.productQuantity.toString()),
            _buildDetailRow(
                "Tổng tiền", formatter.format(orderModel.productTotalPrice)),
            _buildDetailRow(
                "Trạng thái", orderModel.status ? "Đã giao" : "Đang chờ..."),
            _buildDetailRow(
                "Ngày đặt",
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(orderModel.createdAt.toDate())),
            _buildDetailRow("Tên khách hàng", orderModel.customerName),
            _buildDetailRow("Số điện thoại", orderModel.customerPhone),
            _buildDetailRow("Địa chỉ", orderModel.customerAddress),
            const SizedBox(height: 16),
            if (orderModel.status)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => AddReviewScreen(orderModel: orderModel));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.appMainColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đánh giá đơn hàng",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

extension OrderModelExtension on OrderModel {
  static OrderModel fromMap(Map<String, dynamic> map) {
    return OrderModel(
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
      customerId: map['customerId'],
      status: map['status'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      customerAddress: map['customerAddress'],
      customerDeviceToken: map['customerDeviceToken'],
      paymentMethod: '',
    );
  }
}
