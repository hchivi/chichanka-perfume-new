import 'package:chichanka_perfume/screens/user-panel/all-categories-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/all-flash-sale-products.dart';
import 'package:chichanka_perfume/screens/user-panel/all-products-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/cart-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:chichanka_perfume/widgets/all-products-widget.dart';
import 'package:chichanka_perfume/widgets/banner-widget.dart';
import 'package:chichanka_perfume/widgets/category-widget.dart';
import 'package:chichanka_perfume/widgets/custom-drawer-widget.dart';
import 'package:chichanka_perfume/widgets/flash-sale-widget.dart';
import 'package:chichanka_perfume/widgets/heading-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppConstant.appScendoryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: AppConstant.appMainColor,
        title: Text(AppConstant.appMainName),
        centerTitle: true,
        actions: [
          GestureDetector(
            // onTap: () => Get.to(() => CartScreen()),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: Get.height / 90.0,
              ),
              //banners
              BannerWidget(),

              // //heading
              HeadingWidget(
                headingTitle: "Phân loại",
                headingSubTitle: "Danh mục nổi bật",
                onTap: () => Get.to(() => AllCategoriesScreen()),
                buttonText: "Xem thêm >",
              ),

              CategoriesWidget(),

              // //heading
              HeadingWidget(
                headingTitle: "Flash Sale",
                headingSubTitle: "Sale sốc - Ưu đãi hàng ngày",
                onTap: () => Get.to(() => AllFlashSaleProductScreen()),
                buttonText: "Xem thêm >",
              ),

              FlashSaleWidget(),

              // //heading
              HeadingWidget(
                headingTitle: "Tất cả sản phẩm",
                headingSubTitle: "Đa dạng các loại nước hoa",
                onTap: () => Get.to(() => AllProductsScreen()),
                buttonText: "Xem thêm >",
              ),

              AllProductsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
