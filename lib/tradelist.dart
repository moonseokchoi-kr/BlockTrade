import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user.dart';
class BuyListWidget extends StatefulWidget {
  const BuyListWidget({Key key, @required this.user}) : super(key: key);
  final user;
  @override
  _BuyListWidgetState createState() => _BuyListWidgetState();
}

class _BuyListWidgetState extends State<BuyListWidget> {
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
          items[0]['username'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                      Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(item["productName"]),
                        _usernameText(item['seller']),
                      ],
                    ),
                    ],
                  ),
                ),
                );
              });
        }
    );
  }
}