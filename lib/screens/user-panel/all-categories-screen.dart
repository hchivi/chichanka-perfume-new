// ignore_for_file: file_names, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/screens/user-panel/single-category-products-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import '../../models/categories-model.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        backgroundColor: AppConstant.navy,
        title: Text(
          "Tất cả danh mục",
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('categories').get(),
        builder: (context, snapshot) {
          // Xử lý trạng thái lỗi
          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi xảy ra"));
          }

          // Xử lý trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: Get.height / 5,
              child: const Center(child: CupertinoActivityIndicator()),
            );
          }

          // Xử lý khi không có dữ liệu
          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(child: Text("Không tìm thấy danh mục!"));
          }

          // Xử lý khi có dữ liệu
          return GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.all(10.0), // Thêm padding cho toàn bộ Grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85, // Giảm tỷ lệ để tránh tràn
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final categoryData = snapshot.data!.docs[index];
              final categoriesModel = CategoriesModel.fromMap(
                  categoryData.data() as Map<String, dynamic>);

              return GestureDetector(
                onTap: () => Get.to(() => AllSingleCategoryProductsScreen(
                      categoryId: categoriesModel.categoryId,
                    )),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FillImageCard(
                    borderRadius: 10.0,
                    width:
                        double.infinity, // Sử dụng toàn bộ chiều rộng khả dụng
                    heightImage: Get.height / 6, // Tăng chiều cao ảnh một chút
                    imageProvider: CachedNetworkImageProvider(
                      categoriesModel.categoryImg,
                    ),
                    title: Center(
                      child: Text(
                        categoriesModel.categoryName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines:
                            2, // Cho phép tên dài hơn hiển thị trên 2 dòng
                        style: const TextStyle(
                          fontSize: 14.0, // Tăng kích thước chữ một chút
                          fontWeight: FontWeight.bold,
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
    );
  }
}

// Giả định CategoriesModel có phương thức fromMap (nếu chưa có, thêm vào file categories-model.dart)
extension CategoriesModelExtension on CategoriesModel {
  static CategoriesModel fromMap(Map<String, dynamic> data) {
    return CategoriesModel(
      categoryId: data['categoryId'],
      categoryImg: data['categoryImg'],
      categoryName: data['categoryName'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }
}
