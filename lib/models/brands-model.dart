// ignore_for_file: file_names

class BrandModel {
  final String brandId;
  final String brandName;

  BrandModel({
    required this.brandId,
    required this.brandName,
  });

  Map<String, dynamic> toMap() {
    return {
      'brandId': brandId,
      'brandName': brandName,
    };
  }

  factory BrandModel.fromMap(Map<String, dynamic> json) {
    return BrandModel(
      brandId: json['brandId'],
      brandName: json['brandName'],
    );
  }
}
