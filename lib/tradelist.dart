import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'klay.dart';
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
      body: Container(
        padding: EdgeInsets.all(12),
        child: _buildExpansionPanelList(),
      )
    );
  }

  Widget _usernameText(String id) {
    return StreamBuilder(
      stream: collection.where('id', isEqualTo: id).snapshots(),
      builder: (context, snapShots) {
        if (snapShots.data == null) {
          return CircularProgressIndicator();
        } else {
          final items = snapShots.data.docs;
          return AutoSizeText(
            '판매자: ${items[0]['username']}',
            style: TextStyle(
              fontSize: 16,
            ),
          );
        }
      }
    );
  }
  Widget _setChangeButton(int time){
    var now = DateTime.now().toUtc().millisecondsSinceEpoch;
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
  Widget _buildExpansionPanelList(){
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('receipt').where('buyer', isEqualTo: widget.user ).snapshots(),
        builder: (context,snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final items = snapshot.data.docs;
            List<ReceiptNode> itemData = generateItems(items);
            return ListView.builder(
              itemCount: itemData.length,
              itemBuilder: (BuildContext context, int index) {
                print("chandge1 : ${itemData[index].isExpanded}");
                return ExpansionPanelList(
                  animationDuration: Duration(milliseconds: 1000),
                  dividerColor: Colors.red,
                  elevation: 1,
                  children: [
                    ExpansionPanel(
                      body: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AutoSizeText(
                              '금액:${itemData[index].receipt.klay} KLAY',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                  height: 1.3),
                            ),
                            _usernameText(itemData[index].receipt.seller),
                            AutoSizeText(
                              '구매시간:${_convertUnixTime(itemData[index].receipt.createdAt)} ',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                  height: 1.3),
                            ),
                            AutoSizeText(
                              '거래(예정)시간:${_convertUnixTime(itemData[index].receipt.tradeAt)}',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                  height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            itemData[index].receipt.productName,
                            style: TextStyle(
                              color: Colors.grey
                              ,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      isExpanded: true,
                    )
                  ],
                  expansionCallback: (int item, bool status) {
                    print("chandge2 : ${itemData[index].isExpanded}");
                    setState(() {
                      itemData[index].isExpanded = !itemData[index].isExpanded;
                      print("chandge3 : ${itemData[index].isExpanded}");

                    },
                    );
                  },
                );
              },
            );
          }
        }
    );
  }
}
/// TODO 거래완료 상태에따라, hash 표현되도록 하기
/// TODO 거래진행 페이지 만들고, 거래를 통해 나온 결과 업데이트 하기
class ReceiptNode {
  Receipt receipt;
  bool isExpanded;

  ReceiptNode({this.receipt, this.isExpanded: false});
}

List<ReceiptNode>generateItems(items){
  return List.generate(items.length, (index) {
    return ReceiptNode(
       receipt: Receipt.fromJson(items[index].data())
    );
  }
  );
}