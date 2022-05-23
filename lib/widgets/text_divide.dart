import 'package:flutter/material.dart';

class TextDivide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flexible(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          children: [
            Text("Title"),
            Divider(height: 3),
          ],
        ),
      ),
    );
  }
}
