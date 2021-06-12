// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:block_trade/pay_widget.dart';
import 'package:block_trade/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layouts/flutter_layouts.dart';
import 'widgets.dart';

/// Page shown when a card in the songs tab is tapped.
///
/// On Android, this page sits at the top of your app. On iOS, this page is on
/// top of the songs tab's content but is below the tab bar itself.
///

class ProductDetailTab extends StatefulWidget {
  const ProductDetailTab({Key key, @required this.id,
    @required this.title,
    @required this.image,
    @required this.price,
    @required this.userName,
    @required this.content,
    @required this.address,
    @required this.time}) : super(key: key);

  final id;
  final title;
  final image;
  final price;
  final userName;
  final content;
  final time;
  final address;
  @override
  _ProductDetailTabState createState() => _ProductDetailTabState();
}

class _ProductDetailTabState extends State<ProductDetailTab> {
  String _setDateTime(DateTime dt){
    DateTime now = DateTime.now();
    if(now.month==dt.month && dt.day == now.day){
      if(now.hour - dt.hour >0){
        return "${now.hour-dt.hour}시간전";
      }
      else{
        if(now.minute-dt.minute>0){
          return "${now.minute-dt.minute}분전";
        }else{
          return "${now.second-dt.second}초전";
        }
      }
    }else if(now.month == dt.month){
      return "${now.day-dt.day}일전";
    }else{
      return "${now.month-dt.month}개월전";
    }

  }
  Widget _usernameText(){
    return StreamBuilder(
      stream: collection.where('id', isEqualTo: widget.userName).snapshots(),
      builder: (context, snapShots) {
        if (snapShots.data == null) {
          return CircularProgressIndicator();
        } else {
          final items = snapShots.data.docs;
          return AutoSizeText(
            items[0]['username'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      }
    );
  }
  Widget _buildBody(BuildContext ctx) {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Footer(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: widget.id,
              child: HeroAnimatingSongCard(
                title: widget.title,
                image: widget.image,
                heroAnimation: AlwaysStoppedAnimation(1),
                price: widget.price,
              ),
              // This app uses a flightShuttleBuilder to specify the exact widget
              // to build while the hero transition is mid-flight.
              //
              // It could either be specified here or in SongsTab.
              flightShuttleBuilder: (context, animation, flightDirection,
                  fromHeroContext, toHeroContext) {
                return HeroAnimatingSongCard(
                  title: widget.title,
                  image: widget.image,
                  price : widget.price,
                  heroAnimation: animation,
                );
              },
            ),
            Divider(
              height: 0,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 15, top: 16, right: 16, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //사용자 정보 표시 하는 곳 닉네임과 신뢰토큰을 표시
                          Row(
                            children: [
                              _usernameText(),
                              Container(
                                margin: EdgeInsets.only(left: 180),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children:[
                                      AutoSizeText("100",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      AutoSizeText("TCT",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ]
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 0,
                            color: Colors.grey.shade300,
                          ),
                          AutoSizeText(
                            widget.title,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                child: AutoSizeText(_setDateTime(widget.time.toDate()),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            height: 0,
                            color: Colors.white,
                          ),
                          Container(
                            child: AutoSizeText(
                              widget.content,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.normal),
                            ),
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                          ),
                          Divider(
                            height: 0,
                            color: Colors.grey,
                          ),
                          Container(
                            child: AutoSizeText(
                              '추천 상품',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                          )
                        ],
                      ),
                    );
                  }

                  // Just a bunch of boxes that simulates loading song choices.
                  return SongPlaceholderTile();
                },
              ),
            ),
          ],
        ),
        footer: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              AutoSizeText("${widget.price} KLAY"),
              Container(
                decoration: BoxDecoration( color: Colors.orangeAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(40),
                  ),
                ),
                child: TextButton(
                    onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> PayWidget(klay:widget.price,productName: widget.title,seller: widget.userName, address: widget.address)));},
                    child:AutoSizeText('거래하기'
                    ,style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
              ),
          ),
        ],
        ),
      ),
    ),
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(context),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
    );
  }
}

