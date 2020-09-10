import 'package:flutter/material.dart';

class BusRoute extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "แผนที่การเดินรถ",
          textScaleFactor: 1.2,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
        child: Container(
          child: Image.asset(
            'asset/images/bus_route.jpg',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
