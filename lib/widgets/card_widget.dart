import 'package:flutter/material.dart';
import 'package:flutter_interview/classes/item_class.dart';
import 'package:flutter_interview/core/const.dart';
import 'package:flutter_interview/pages/description_page.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.box,
  });
  final ItemClass box;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DescriptionPage(box: box);
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
          Image.asset('$pathImageFolder${box.image}'),
          Text(
            box.title,
            style: const TextStyle(
              fontSize: kdouble20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            box.description,
            style: const TextStyle(
              fontSize: kdouble10,
            ),
          ),
        ]),
      )),
    );
  }
}
