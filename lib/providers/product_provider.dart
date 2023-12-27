import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_interview/classes/product_class.dart';

final productsProvider = FutureProvider<List<ProductClass>>((ref) async {
  final products =
      await getProducts(); // Assuming getProducts is defined similarly as in your code
  return products;
});

Future<List<ProductClass>> getProducts() async {
  final List<ProductClass> products = [];
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      if (document.exists) {
        Map<String, dynamic> productData = document.data();
        ProductClass product = ProductClass.fromMap(productData);
        products.add(product);
      } else {
        print('Document does not exist');
      }
    }
  } catch (e) {
    print('Error fetching document: $e');
  }
  return products;
}
