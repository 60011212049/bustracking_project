import 'package:flutter/material.dart';

class Contact extends StatefulWidget {
  Contact({Key key}) : super(key: key);

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ติดต่อเรา'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'อาจารย์ที่ปรึกษา',
                  style: TextStyle(fontSize: 26),
                ),
                Container(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Card(
                      color: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 8,
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              margin:
                                  new EdgeInsets.symmetric(horizontal: 10.0),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  image: AssetImage('asset/images/aj.png'),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: new EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    'ชื่อ : ผศ.ดร.มนัสวี แก่นอำพรพันธ์',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'อาจารย์ประจำภาควิชาวิทยาการคอมพิวเตอร์',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'มหาวิทยาลัยมหาสารคาม',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'อีเมลล์ : manasaweek@gmail.com',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'เบอร์ติดต่อ : -',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  'นิสิตผู้จัดทำ',
                  style: TextStyle(fontSize: 26),
                ),
                Container(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Card(
                      color: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 8,
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              margin:
                                  new EdgeInsets.symmetric(horizontal: 10.0),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  image: AssetImage('asset/images/tar.png'),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: new EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    'ชื่อ : นาย ธนพล บุญประคม',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'นิสิตคณะวิทยาการสารสนเทศ (CS)',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'มหาวิทยาลัยมหาสารคาม',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'อีเมลล์ : 60011212049@msu.ac.th',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'เบอร์ติดต่อ : 093-369-2540',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Card(
                      color: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 8,
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              margin:
                                  new EdgeInsets.symmetric(horizontal: 10.0),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  image: AssetImage('asset/images/joker.png'),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: new EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    'ชื่อ : นาย สุรสิทธิ์ สุวรรณระ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'นิสิตคณะวิทยาการสารสนเทศ (CS)',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'มหาวิทยาลัยมหาสารคาม',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'อีเมลล์ : 60011212214@msu.ac.th',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'เบอร์ติดต่อ : 087-223-7007',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
