import 'package:flutter/material.dart';
import 'package:flutter_interview/classes/item_class.dart';
import 'package:flutter_interview/core/const.dart';

class DescriptionPage extends StatefulWidget {
  const DescriptionPage({
    super.key,
    required this.box,
  });
  final ItemClass box;

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  double fontSizeCustom = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.box.title),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clicked info icon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.info)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kdouble10),
          child: Column(children: [
            Image.asset('$pathImageFolder${widget.box.image}'),
            Wrap(
              spacing: kdouble10,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        fontSizeCustom = 20;
                      });
                    },
                    child: const Text('Small')),
                OutlinedButton(
                    onPressed: () {
                      setState(() {
                        fontSizeCustom = 40;
                      });
                    },
                    child: const Text('Medium')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        fontSizeCustom = 100;
                      });
                    },
                    child: const Text('Large')),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        fontSizeCustom = 200;
                      });
                    },
                    child: const Text('Huge')),
              ],
            ),
            FittedBox(
              child: Text(widget.box.title,
                  style: TextStyle(
                    fontSize: fontSizeCustom,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(height: kdouble10),
            const FittedBox(
              child: Text(
                DummyDescription,
                style: TextStyle(
                  fontSize: kdouble10,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: kdouble10),
            const FittedBox(
              child: Text(
                DummyDescription,
                style: TextStyle(
                  fontSize: kdouble10,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
