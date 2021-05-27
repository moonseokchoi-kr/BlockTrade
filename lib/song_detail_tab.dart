// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layouts/flutter_layouts.dart';
import 'widgets.dart';

/// Page shown when a card in the songs tab is tapped.
///
/// On Android, this page sits at the top of your app. On iOS, this page is on
/// top of the songs tab's content but is below the tab bar itself.
class SongDetailTab extends StatelessWidget {
  const SongDetailTab({
    @required this.id,
    @required this.title,
    @required this.image,
  });

  final int id;
  final String title;
  final Image image;

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
              tag: id,
              child: HeroAnimatingSongCard(
                title: title,
                image: image,
                heroAnimation: AlwaysStoppedAnimation(1),
              ),
              // This app uses a flightShuttleBuilder to specify the exact widget
              // to build while the hero transition is mid-flight.
              //
              // It could either be specified here or in SongsTab.
              flightShuttleBuilder: (context, animation, flightDirection,
                  fromHeroContext, toHeroContext) {
                return HeroAnimatingSongCard(
                  title: title,
                  image: image,
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
                              Text("userNickname",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 180),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children:[
                                      Text("100",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("신뢰토큰",
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
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                child: Text(
                                  'time',
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
                            child: Text(
                              '5번정도 신고 보관만 해온 제품입니다~\n유행타지 않는 기본 디자인에말린장미 색상이라 여기저기 잘 어울려요.\n37.5인데 조금 작게 나와서 240정도 되는것같습니다.\n밑창은 제가 따로 안하고 신어서\n수선집가서 하시면 새것처럼 신으실수있을것 같아요^^',
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
                            child: Text(
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
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              Text('10,000원'),
              TextButton(onPressed: () {}, child: Text('거래하기'))
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
      appBar: AppBar(title: Text(title)),
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
