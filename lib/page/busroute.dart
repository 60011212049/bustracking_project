import 'package:flutter/material.dart';

class BusRoute extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "แผนที่การเดินรถ",
          ),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Expanded(
                child: Image.asset('asset/images/bus_route.jpg'),
              )
            ],
          ),
        ));
  }
}
