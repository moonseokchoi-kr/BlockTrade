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
      ),
      body: Center(
        child: Column(
          children: <Widget>[Text('Click the Button'), Text('0')],
        ),
      ),
    );
  }
}
