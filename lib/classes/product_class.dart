import 'package:cloud_firestore/cloud_firestore.dart';

class ProductClass {
  final String id;
  final String name;
  final String category;
  final String createdBy;
  final DateTime createdDate;
  final String description;
  final List<String> images;
  final double price;

  ProductClass({
    required this.id,
    required this.price,
    required this.name,
    required this.category,
    required this.createdBy,
    required this.createdDate,
    required this.description,
    required this.images,
  });

  factory ProductClass.fromMap(Map<String, dynamic> map) {
    List<dynamic>? imageList = map['images'];
    List<String> imageUrlList = List<String>.from(imageList ?? []);
    return ProductClass(
      id: map['id'] ?? '',
      price: map['price'] ?? 0.0,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdDate: (map['createdDate'] as Timestamp)
          .toDate(), // Convert Timestamp to DateTime
      description: map['description'] ?? '', // Convert Timestamp to DateTime
      images: imageUrlList,
    );
  }
}
