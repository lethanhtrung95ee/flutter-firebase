import 'package:flutter/material.dart';
import 'package:flutter_interview/classes/product_class.dart';
import 'package:flutter_interview/core/const.dart';
import 'package:flutter_interview/pages/description_page.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.data,
  });
  final ProductClass data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DescriptionPage(data: data);
            },
          ),
        );
      },
      child: Card(
          child: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(children: [
          const SizedBox(height: kdouble5),
          Image.network(
            data.images[0],
           width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.cover,
          ),
          Text(
            data.name,
            style: const TextStyle(
              fontSize: kdouble20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      )),
    );
  }
}
