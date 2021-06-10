import 'package:auto_size_text/auto_size_text.dart';
import 'package:block_trade/rest_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'songs_tab.dart';
import 'login.dart';
import 'user.dart';
void main() => runApp(BlockTradeApp());

class BlockTradeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockTrade',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: LoginHomePage(),
    );
  }
}

class LoginHomePage extends StatelessWidget {
  const LoginHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context,snapshot){
          if(snapshot.hasError){
            return Center(
              child: Text("firebase load fail"),
            );
          }
          if(snapshot.connectionState == ConnectionState.done){
            return UsedTradingHomePage();
          }
          return CircularProgressIndicator();
        }
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
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot){
          if(snapshot.data == null){
            return LoginWidget();
          }else{
            createUser(FirebaseAuth.instance.currentUser);
            return StreamBuilder(
              stream: collection.where('id', isEqualTo: FirebaseAuth.instance.currentUser.uid).snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData){
                    return CircularProgressIndicator();
                  }else{
                    final items = snapshot.data.docs;
                    print("wallet_address: ${items[0]["wallet_address"]}");
                    return SongsTab(
                      androidDrawer: _AndroidDrawer(currentUser: FirebaseAuth.instance.currentUser, address: items[0]["wallet_address"],),
                      author: FirebaseAuth.instance.currentUser.uid,
                    );
                  }
                });
          }
        },
      ),
    );
  }
}

class _AndroidDrawer extends StatefulWidget {
  const _AndroidDrawer({Key key, this.currentUser, @required this.address}) : super(key: key);
  final currentUser;
  final address;
  @override
  _AndroidDrawerState createState() => _AndroidDrawerState();
}

class _AndroidDrawerState extends State<_AndroidDrawer> {
  @override
  void initState(){

    super.initState();
  }
  Widget _getKlay() {
    return FutureBuilder(
      future: getBalance(widget.address),
        builder: (context,snapshot){
          if(snapshot.hasData == null){
            return CircularProgressIndicator();
          }
          else{
            return AutoSizeText(
              '${snapshot.data} KLAY',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            );
          }
        });
  }
  Widget _getTCT() {
    return FutureBuilder(
        future: getTCTBalance(widget.address),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          else{
            return AutoSizeText(
              '${snapshot.data} TCT',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
              decoration: BoxDecoration( color: Colors.grey[300],
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow( color: Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0, ),
                  BoxShadow( color: Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0, ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  AutoSizeText(
                    "${widget.currentUser.displayName}님",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image(image: AssetImage('assets/trust_token_icon.png'), height: 50, width: 50,),
                            _getTCT(),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image(image: AssetImage('assets/klay_icon.png')),
                            _getKlay(),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
          ),
          ListTile(
            leading: SongsTab.androidIcon,
            title: Text(SongsTab.title),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text("구매내역"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("판매내역"),
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

