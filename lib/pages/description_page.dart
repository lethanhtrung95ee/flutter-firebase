import 'package:flutter/material.dart';
import 'package:flutter_interview/classes/product_class.dart';

class DescriptionPage extends StatefulWidget {
  const DescriptionPage({
    super.key,
    required this.data,
  });
  final ProductClass data;

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  String _selectedImageUrl = '';

  @override
  Widget build(BuildContext context) {
    final product = widget.data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the big image
            GestureDetector(
              onTap: () {
                // Handle tap on big image
              },
              child: Image.network(
                _selectedImageUrl.isNotEmpty
                    ? _selectedImageUrl
                    : product.images.isNotEmpty
                        ? product.images[0]
                        : '', // Display first image or a placeholder
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Display the small images
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: product.images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageUrl = url;
                        });
                      },
                      child: Image.network(
                        url,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Display product details
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: ${product.category}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Text(
              'Owner: ${product.createdBy}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              '\$${product.price}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
