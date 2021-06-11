import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'klay.dart';
import 'user.dart';

class PayWidget extends StatefulWidget {
  PayWidget({
    Key key,
    @required this.productName,
    @required this.seller,
    @required this.klay,
  }) : super(key: key);
  final String productName;
  final String seller;
  String _trustToken;
  final String klay;
  bool _trade = false;
  @override
  _PayWidgetState createState() => _PayWidgetState();
}

class _PayWidgetState extends State<PayWidget> {
  @override
  void initState(){
    initializeDateFormatting();
    super.initState();
  }
  Widget _usernameText(){
    return StreamBuilder(
      stream: collection.where('id', isEqualTo: widget.seller).snapshots(),
      builder: (context, snapShots){
        final items = snapShots.data.docs;
        return Container(
          padding: EdgeInsets.only( bottom: 8),
          child: AutoSizeText(
            '판매자: ${items[0]['username']}',
            style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
        ),
        ),
        );
      },
    );

  }
  Widget _buildBody(){
    var tct =  int.parse(widget.klay)*0.004<0.01? 0.01.toString():(int.parse(widget.klay)*0.004).toStringAsFixed(2);
    var fee = (int.parse(widget.klay)*0.002).toString();
    var amount = (double.parse(widget.klay)+double.parse(fee)).toString();
    var createAt = DateTime.now();
    var tradeAt = createAt.add(const Duration(days: 7));
    var dateFormatter = DateFormat.yMd();
    var timeFormatter = DateFormat.Hm();
    return SafeArea(
        child:Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: AutoSizeText("거래내용"
                  ,style: TextStyle(
                    fontSize: 30,
                    color: Colors.black87,
                  ),
                ),
              ),
              Divider(height: 0, color: Colors.grey,),
              _usernameText(),
              Container(
                padding: EdgeInsets.only( bottom: 8),
                child: AutoSizeText("물품: ${widget.productName} "
                , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("금액: ${widget.klay} "
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("신뢰비용: $tct}"
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("거래수수료:$fee"
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("거래일시:${dateFormatter.format(createAt)} ${timeFormatter.format(createAt)} "
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("(자동)거래 일시:${dateFormatter.format(tradeAt)} ${timeFormatter.format(tradeAt)}"
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Divider(height: 0, color: Colors.grey,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
              decoration: BoxDecoration( color: Colors.redAccent,
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                    ),
                boxShadow: [
                  BoxShadow( color: Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0, ),
                  BoxShadow( color: Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0, ),
                ],
                  ),
                    child: TextButton(
                      child: AutoSizeText("취소", style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),),
                      onPressed: (){

                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration( color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow( color: Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0, ),
                        BoxShadow( color: Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0, ),
                      ],
                    ),
                    child: TextButton(
                      child: AutoSizeText("거래하기", style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),),
                      onPressed: (){
                        var uuid = Uuid();
                        var r = Receipt(
                            id: uuid.v1().toString(),
                            productName: widget.productName,
                            seller: widget.seller,
                            buyer: FirebaseAuth.instance.currentUser.uid,
                            klay: amount,
                            trustToken: tct,
                            createdAt: createAt.toUtc().millisecondsSinceEpoch,
                            tradeAt: tradeAt.toUtc().millisecondsSinceEpoch,
                            trade: false,
                            nftHash: "",
                            klayTransferHash: "",
                        );
                        FirebaseFirestore.instance.collection('receipt').doc().set(r.toMap());
                        final snackBar = SnackBar(
                          content: Text("거래가 예약되었습니다."),
                          action:SnackBarAction(
                            label: 'Undo',
                            onPressed: (){},
                          )
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              )
            ],
          ) ,
        )

    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("결제"),
        actions :<Widget>[
      IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed:() {
        Navigator.pop(context);
      },)
    ],
      ),
      body: _buildBody(),
    );
  }
}

