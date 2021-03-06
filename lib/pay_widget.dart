import 'package:auto_size_text/auto_size_text.dart';
import 'package:block_trade/main.dart';
import 'package:block_trade/rest_api.dart';
import 'package:block_trade/tradelist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'klay.dart';
import 'user.dart';

class PayWidget extends StatefulWidget {
  PayWidget({
    Key key,
    this.productName,
    this.seller,
    this.klay,
    this.address,
    this.trade = false,
    this.receipt,
    this.createAt,
  }) : super(key: key);

  final String productName;
  final String seller;
  final String klay;
  final String address;
  final Receipt receipt;
  final String createAt;
  bool trade = false;
  @override
  _PayWidgetState createState() => _PayWidgetState();
}

class _PayWidgetState extends State<PayWidget> {
  String sellerAddress;
  @override
  void initState(){
    initializeDateFormatting();
    super.initState();
  }
  Widget _usernameText(){
    return StreamBuilder(
      stream: collection.where('id', isEqualTo: widget.seller).snapshots(),
      builder: (context, snapShots){
        if(!snapShots.hasData){
          return CircularProgressIndicator();
        }
        final items = snapShots.data.docs;
        return Container(
          padding: EdgeInsets.only( bottom: 8),
          child: AutoSizeText(
            'ํ๋งค์: ${items[0]['username']}',
            style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
        ),
        ),
        );
      },
    );

  }
  Future<String> getAddress(String id) async{
    var data = await collection.where('id', isEqualTo: id).snapshots().first;
    var author = data.docs.elementAt(0).data();
    return author['wallet_address'];
  }
  Future<bool> _canTrade(String address, String klay) async {
    String balance = await getBalance(address);
    return(double.parse(balance)>double.parse(klay));
  }
  Future<void> _payKlay(String sellerAddress, String buyerAddress) async{
    String klayHash = await transferKlay(sellerAddress, buyerAddress, double.parse(widget.receipt.klay), widget.receipt);
    String nftHash = await mintNFT();
    transferTCT(sellerAddress, double.parse(widget.receipt.trustToken));
    transferTCT(buyerAddress, double.parse(widget.receipt.trustToken));
    ///update receipt
    widget.receipt.updateHash(klayHash, nftHash, DateTime.now().toUtc().millisecondsSinceEpoch);
    FirebaseFirestore.instance.collection('receipt').doc(widget.receipt.id).update(widget.receipt.toMap());
  }

  Widget _payTrade(){
    return FutureBuilder(
      future: getTCTBalance(widget.address),
      builder: (context,snapshot) {
        if (snapshot.data == null) {
          return CircularProgressIndicator();
        } else {
          return Container(
            decoration: BoxDecoration(color: Colors.blueAccent,
              borderRadius: BorderRadius.all(
                Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(color: Colors.grey[500],
                  offset: Offset(4.0, 4.0),
                  blurRadius: 15.0,
                  spreadRadius: 1.0,),
                BoxShadow(color: Colors.white,
                  offset: Offset(-4.0, -4.0),
                  blurRadius: 15.0,
                  spreadRadius: 1.0,),
              ],
            ),
            child: TextButton(
                child: AutoSizeText("๊ฑฐ๋ํ๊ธฐ", style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),),
                onPressed: () {
                  if (widget.trade) {
                    if (double.parse(snapshot.data) < 100) {
                      showDialog(
                          context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: AutoSizeText(
                            "๊ฑฐ๋๊ฐ ๋ถ๊ฐ๋ฅํฉ๋๋ค",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AutoSizeText("์?๋ขฐํ?ํฐ์ ๋ณด์?๋์ด ๊ธฐ์ค์น ๋ณด๋ค ์์ต๋๋ค."),
                              AutoSizeText(
                                'ํ์ฌ TCT: ${snapshot.data} / ๊ฑฐ๋๊ฐ๋ฅ TCT: 100',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                             TextButton(
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              child: Text("Close",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            )
                          ],
                        );
                      });
                    } else {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          title: AutoSizeText(
                            "์?๋ง๋ก ๊ฑฐ๋๋ฅผ ์งํํ์๊ฒ?์ต๋๊น?", style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Loader.show(context,
                                        isBottomBarOverlay: false,
                                        progressIndicator: CircularProgressIndicator(),
                                      );
                                      Future<String> sellerAddress = getAddress(widget.receipt.seller);
                                      _canTrade(widget.address, widget.receipt.klay).then((trade){
                                        if(trade){
                                          sellerAddress.then((value){
                                            _payKlay(value,widget.address).then((value){
                                              Loader.hide();
                                              final snackBar = SnackBar(
                                                  content: Text("๊ฑฐ๋๊ฐ ์๋ฃ๋์์ต๋๋ค."),
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    onPressed: () {},
                                                  )
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                            });
                                          });
                                        }else{
                                          Loader.hide();
                                          showDialog(context: context, builder: (context){
                                            return AlertDialog(
                                              title: AutoSizeText("๋ณด์?ํ๊ณ? ์๋ KLAY๊ฐ ๋ถ์กฑํ์ฌ ๊ฒฐ์?ํ?์ ์์ต๋๋ค."),
                                              actions: [
                                                TextButton(onPressed: (){
                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                }, child:Text("Close",
                                                  style: TextStyle(color: Colors.blueAccent),
                                                ),)
                                              ],
                                            );
                                          });
                                        }
                                      });
                                    },
                                    child: AutoSizeText("๊ฒฐ์?", style: TextStyle(
                                        color: Colors.blueAccent),)
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    },
                                    child: AutoSizeText("์ทจ์", style: TextStyle(
                                        color: Colors.redAccent),)
                                )
                              ],
                            )
                          ],
                        );
                      });
                    }
                  }
                }
            ),
          );
        }
      }
    );
  }
  Widget _getTCT(amount, tct, createAt, tradeAt) {
    return FutureBuilder(
        future: getTCTBalance(widget.address),
        builder: (context,snapshot){
          if(snapshot.hasData == null){
            return CircularProgressIndicator();
          }
          else{
            return Container(
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
                child: AutoSizeText("๊ฑฐ๋ํ๊ธฐ", style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),),
                onPressed: () {
                  if (widget.trade) {
                      showDialog(
                          context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: AutoSizeText(
                            "๊ฑฐ๋๊ฐ ๋ถ๊ฐ๋ฅํฉ๋๋ค",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AutoSizeText("์?๋ขฐํ?ํฐ์ ๋ณด์?๋์ด ๊ธฐ์ค์น ๋ณด๋ค ์์ต๋๋ค."),
                              AutoSizeText(
                                'ํ์ฌ TCT: ${snapshot.data} / ๊ฑฐ๋๊ฐ๋ฅ TCT: 100',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            new TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: new Text("Close", style: TextStyle(color: Colors.blueAccent),
                              ),
                            )
                          ],
                        );
                    });
                    }else {
                    var uuid = Uuid();
                    var r = Receipt(
                      id: uuid.v1().toString(),
                      productName: widget.productName,
                      seller: widget.seller,
                      buyer: FirebaseAuth.instance.currentUser.uid,
                      klay: amount,
                      trustToken: tct,
                      createdAt: createAt
                          .toUtc()
                          .millisecondsSinceEpoch,
                      tradeAt: tradeAt
                          .toUtc()
                          .millisecondsSinceEpoch,
                      trade: false,
                      nftHash: "",
                      klayTransferHash: "",
                    );
                    FirebaseFirestore.instance.collection('receipt').doc(r.id).set(
                        r.toMap());
                    final snackBar = SnackBar(
                        content: Text("๊ฑฐ๋๊ฐ ์์ฝ๋์์ต๋๋ค."),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {},
                        )
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            );
          }
        });
  }
  Widget _buildBody(){
    var dateFormatter = DateFormat.yMd();
    var timeFormatter = DateFormat.Hm();
    if(widget.trade){
      return SafeArea(
          child:Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: AutoSizeText("๊ฑฐ๋๋ด์ฉ"
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
                  child: AutoSizeText("๋ฌผํ: ${widget.receipt.productName} "
                    , style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: AutoSizeText("๊ธ์ก(์์๋ฃํฌํจ): ${widget.receipt.klay} "
                    , style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: AutoSizeText("์?๋ขฐ๋น์ฉ: ${widget.receipt.trustToken}"
                    , style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: AutoSizeText("๊ณ์ฝ ์์ฑ ์ผ์:${widget.createAt} "
                    , style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: AutoSizeText("๊ฑฐ๋์ผ์:${dateFormatter.format(DateTime.now())} ${timeFormatter.format(DateTime.now())}"
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
                        child: AutoSizeText("์ทจ์", style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    _payTrade()
                  ],
                )
              ],
            ) ,
          )

      );
    }else{
      return _buildList();
    }
  }
  Widget _buildList(){
    var tct =  int.parse(widget.klay)*0.004<1? 1.toString():(int.parse(widget.klay)*0.004).toStringAsFixed(2);
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
                child: AutoSizeText("๊ฑฐ๋๋ด์ฉ"
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
                child: AutoSizeText("๋ฌผํ: ${widget.productName} "
                , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("๊ธ์ก: ${widget.klay} "
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("์?๋ขฐ๋น์ฉ: $tct"
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("๊ฑฐ๋์์๋ฃ:$fee"
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("๊ฑฐ๋์ผ์:${dateFormatter.format(createAt)} ${timeFormatter.format(createAt)} "
                  , style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: AutoSizeText("(์๋)๊ฑฐ๋ ์ผ์:${dateFormatter.format(tradeAt)} ${timeFormatter.format(tradeAt)}"
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
                      child: AutoSizeText("์ทจ์", style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),),
                      onPressed: (){

                        Navigator.pop(context);
                      },
                    ),
                  ),
                  _getTCT(amount, tct, createAt, tradeAt),
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
        title: Text("๊ฑฐ๋์์? ์?๋ณด"),
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




