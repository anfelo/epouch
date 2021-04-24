import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/spider_web.png',
            width: size.width,
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: Text(
            "This room is Empty",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
