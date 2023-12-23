import 'package:flutter/material.dart';
import 'package:flutter_interview/classes/item_class.dart';
import 'package:flutter_interview/widgets/card_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("This is Trung's application")),
      body: SingleChildScrollView(
        child: Column(
          // when user refresh the app or this page, this will regenerate but if it 'const', it doesn't reload
          children: [
            Card(
              child: CardWidget(
                box: ItemClass(
                    title: 'Something',
                    description: 'descrption',
                    image: '07bf79639e8237dc6e93.jpg'),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CardWidget(
                    box: ItemClass(
                        title: 'Something',
                        description: 'descrption',
                        image: '07bf79639e8237dc6e93.jpg'),
                  ),
                ),
                Expanded(
                  child: CardWidget(
                    box: ItemClass(
                        title: 'Something',
                        description: 'descrption',
                        image: '07bf79639e8237dc6e93.jpg'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CardWidget(
                    box: ItemClass(
                        title: 'Something',
                        description: 'descrption',
                        image: '07bf79639e8237dc6e93.jpg'),
                  ),
                ),
                Expanded(
                  child: CardWidget(
                    box: ItemClass(
                        title: 'Something',
                        description: 'descrption',
                        image: '07bf79639e8237dc6e93.jpg'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
