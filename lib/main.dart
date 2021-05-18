import 'package:flutter/material.dart';
import 'songs_tab.dart';

void main() => runApp(BlockTradeApp());

class BlockTradeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockTrade',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: UsedTradingHomePage(),
    );
  }
}

class UsedTradingHomePage extends StatefulWidget {
  @override
  _UsedTradingHomePageState createState() => _UsedTradingHomePageState();
}

class _UsedTradingHomePageState extends State<UsedTradingHomePage> {
  @override
  Widget build(BuildContext context) {
    return SongsTab(
      androidDrawer: _AndroidDrawer(),
    );
  }
}

class _AndroidDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.account_circle,
                color: Colors.green.shade800,
                size: 96,
              ),
            ),
          ),
          ListTile(
            leading: SongsTab.androidIcon,
            title: Text(SongsTab.title),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Long drawer contents are often segmented.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
