import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'user.dart';
class BuyListWidget extends StatefulWidget {
  const BuyListWidget({Key key, @required this.user}) : super(key: key);
  final user;
  @override
  _BuyListWidgetState createState() => _BuyListWidgetState();
}

class _BuyListWidgetState extends State<BuyListWidget> {
  @override
  void initState() {
    // TODO: implement initState
    initializeDateFormatting();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("구매내역"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:() {
              Navigator.pop(context);
            },)
        ],
      ),
      body: _list(),
    );
  }

  Widget _usernameText(String id) {
    return StreamBuilder(
      stream: collection.where('id', isEqualTo: id).snapshots(),
      builder: (context, snapShots) {
        final items = snapShots.data.docs;
        return AutoSizeText(
          '판매자: ${items[0]['username']}',
          style: TextStyle(
            fontSize: 16,
          ),
        );
      },
    );
  }
  Widget _setChangeButton(int time){
    var now = DateTime.now().toUtc().millisecondsSinceEpoch;
    print("now: $now\n trade:$time\n compare:${time<now}");
    if(now<time){
      return Container(
      decoration: BoxDecoration(
            color: Colors.lightGreenAccent,
            borderRadius: BorderRadius.all(
                Radius.circular(30)
            ),
            boxShadow: [
              BoxShadow(color: Colors.grey[500], offset: Offset(1.0, 1.0), blurRadius: 15.0, spreadRadius: 1.0,),
              BoxShadow( color: Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0, )
            ]
          ),
        child: TextButton(
          child:AutoSizeText(
          "거래하기",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),

        ),
          onPressed: (){},
        ),
      );
    }else{
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.all(
              Radius.circular(30)
          ),
        ),
        child: TextButton(
          child:AutoSizeText(
            "거래완료",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),

          ),
          onPressed: (){},
        ),
      );
    }
  }
  String _convertUnixTime(time){
    var unixTime = DateTime.fromMillisecondsSinceEpoch(time);
    var dayFormatter = DateFormat.yMd();
    var timeFormatter = DateFormat.Hms();
    return '${dayFormatter.format(unixTime)} ${timeFormatter.format(unixTime)}';
  }
  Widget _list(){
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('receipt').where('buyer', isEqualTo: widget.user ).snapshots(),
        builder: (context,snapshot){
          final items = snapshot.data.docs;
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index){
                final item = items[index];
                return SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300],
                        width: 1,
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 4),
                          child: AutoSizeText(
                            '상품명: ${item["productName"]}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 4),
                          child:_usernameText(item['seller'])
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 4),
                          child: AutoSizeText("구매일시:${_convertUnixTime(item["createAt"])}")
                        ),
                        Container(
                            padding: EdgeInsets.only(bottom: 4),
                            child: AutoSizeText("거래일시:${_convertUnixTime(item["tradeAt"])}")
                        )
                      ],
                    ),
                    _setChangeButton(item["tradeAt"]),
                    ],
                  ),
                ),
                );
              });
        }
    );
  }
}
///내일 만들곳(06/11)
class BuyListDetailWidget extends StatefulWidget {
  const BuyListDetailWidget({Key key}) : super(key: key);

  @override
  _BuyListDetailWidgetState createState() => _BuyListDetailWidgetState();
}

class _BuyListDetailWidgetState extends State<BuyListDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
