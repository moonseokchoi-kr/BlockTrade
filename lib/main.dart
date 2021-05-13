import 'package:flutter/material.dart';

void main() => runApp(BlockTradeApp());

class BlockTradeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockTrade',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlockTradeHome(),
    );
  }
}

class BlockTradeHome extends StatefulWidget {
  @override
  _BlockTradeHomeState createState() => _BlockTradeHomeState();
}

class _BlockTradeHomeState extends State<BlockTradeHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Block Trade'),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              print('cart button is clicked');
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print('search button is clicked');
            },
          )
        ],
        //위젯 왼쪽에 위치하도록 만듬
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('test'),
              accountEmail: Text('mmonseok@gmail.com'),
              onDetailsPressed: () {
                print('arrow is clicked');
              },
              decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0))),
            )
          ],
        ),
      ),
    );
  }
}
