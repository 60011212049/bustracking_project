import 'package:bustracking_project/model/busstop_model.dart';
import 'package:bustracking_project/page/home.dart';
import 'package:flutter/material.dart';

class BusStopPage extends StatefulWidget {
  @override
  _BusStopPageState createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  List<BusstopModel> bus = HomePage.busstop;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: bus.length,
            itemBuilder: (BuildContext buildContext, int index) {
              return ListTile(
                title: Text(bus[index].sName, style: TextStyle(fontSize: 22)),
                leading: CircleAvatar(
                  backgroundColor: Colors.yellow[700],
                  radius: 22,
                  child: Text(bus[index].sid),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Detail(bus[index]),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}

class Detail extends StatefulWidget {
  BusstopModel bus;
  Detail(BusstopModel string) {
    this.bus = string;
  }
  @override
  DetailState createState() => DetailState(bus);
}

class DetailState extends State<Detail> {
  var status = {};
  BusstopModel bustop;
  bool _isLoading = false;
  String id;
  List busList;

  DetailState(BusstopModel idx) {
    this.bustop = idx;
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('จุดจอดรถ'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext buildContext, int index) {
                return Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Center(
                            child: Image.asset(
                              'asset/backgrounds/msu_pic.JPG',
                              fit: BoxFit.cover,
                              width: 300,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        bustop.sName,
                        style: TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
