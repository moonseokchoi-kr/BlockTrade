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
            return SongsTab(
              androidDrawer: _AndroidDrawer(),
              author: FirebaseAuth.instance.currentUser.uid,
            );
          }
        },
      ),
    );
  }
}

class _AndroidDrawer extends StatelessWidget {
 final _currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Icon(
                    Icons.account_circle,
                    color: Colors.green.shade800,
                    size: 96,
                  ),
                ),
                StreamBuilder(
                    stream: collection.where('id', isEqualTo: _currentUser.uid).snapshots(),
                    builder: (context, snapshot){
                      final items = snapshot.data.docs;
                      return Text('${items[0]['username']}님 환영합니다');
                    }
                ),
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
