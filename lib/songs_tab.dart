// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'song_detail_tab.dart';
import 'utils.dart';
import 'widgets.dart';

class SongsTab extends StatefulWidget {
  static const title = 'Products';
  static const androidIcon = Icon(Icons.shopping_bag_outlined);
  static const iosIcon = Icon(CupertinoIcons.music_note);
  final String author;
  const SongsTab({this.androidDrawer,this.author}) : super();

  final Widget androidDrawer;

  @override
  _SongsTabState createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  static const _itemsLength = 50;

  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

  List<MaterialColor> colors;
  List<String> songNames;

  @override
  void initState() {
    super.initState();
  }

  Widget _listBuilder(){
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,snapshot){
            if(snapshot.hasError){
              return Text('Something went wrong');
            }
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loding");
            }
            final items= snapshot.data.docs;
            return ListView.builder(
                itemCount: items.length,
                itemBuilder:(context,index){
                  final item = items[index];
                  return SafeArea(
                    top: false,
                    bottom: false,
                    child: Hero(
                      tag: index,
                      child: HeroAnimatingSongCard(
                        title: item['productName'],
                        image: Image.network(
                          item['picture'],
                          fit: BoxFit.fill,
                          height: 250,
                        ),
                        price: item['price'],
                        heroAnimation: AlwaysStoppedAnimation(0),
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (context) => SongDetailTab(
                              id: index,
                              title: item['productName'],
                              image: Image.network(
                                item['picture'],
                                fit: BoxFit.fill,
                                height: 250,
                              ),
                              price: item['price'],
                              content: item['content'],
                              time: item['time_stamp'],
                              userName: item['author'],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
            );
    }
    );
  }

  void _togglePlatform() {
    TargetPlatform _getOppositePlatform() {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return TargetPlatform.android;
      } else {
        return TargetPlatform.iOS;
      }
    }

    debugDefaultTargetPlatformOverride = _getOppositePlatform();
    // This rebuilds the application. This should obviously never be
    // done in a real app but it's done here since this app
    // unrealistically toggles the current platform for demonstration
    // purposes.
    WidgetsBinding.instance.reassembleApplication();
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are differenc items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SongsTab.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async => await _androidRefreshKey.currentState.show(),
          ),
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: _togglePlatform,
          ),
        ],
      ),
      drawer: widget.androidDrawer,
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>WritePosts(author: widget.author,)));
          },
      ),
      body:_listBuilder(),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
    );
  }
}
