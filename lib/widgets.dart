// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'posts.dart';
import 'postsService.dart';

/// A simple widget that builds different things on different platforms.
class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    @required this.androidBuilder,
  }) : super();

  final WidgetBuilder androidBuilder;

  @override
  Widget build(context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBuilder(context);
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
        return SizedBox.shrink();
    }
  }
}

/// A platform-agnostic card with a high elevation that reacts when tapped.
///
/// This is an example of a custom widget that an app developer might create for
/// use on both iOS and Android as part of their brand's unique design.
class PressableCard extends StatefulWidget {
  const PressableCard({
    this.onPressed,
    @required this.image,
    @required this.flattenAnimation,
    this.child,
  });

  final VoidCallback onPressed;
  final Image image;
  final Animation<double> flattenAnimation;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  bool pressed = false;
  AnimationController controller;
  Animation<double> elevationAnimation;

  @override
  void initState() {
    this.controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 40),
    );
    this.elevationAnimation =
        controller.drive(CurveTween(curve: Curves.easeInOutCubic));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get flatten => 1 - widget.flattenAnimation.value;

  @override
  Widget build(context) {
    return Listener(
      onPointerDown: (details) {
        if (widget.onPressed != null) {
          controller.forward();
        }
      },
      onPointerUp: (details) {
        controller.reverse();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onPressed.call();
        },
        // This widget both internally drives an animation when pressed and
        // responds to an external animation to flatten the card when in a
        // hero animation. You likely want to modularize them more in your own
        // app.
        child: AnimatedBuilder(
          animation:
              Listenable.merge([elevationAnimation, widget.flattenAnimation]),
          child: widget.child,
          builder: (context, child) {
            return Transform.scale(
              // This is just a sample. You likely want to keep the math cleaner
              // in your own app.
              scale: 1 - elevationAnimation.value * 0.03,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16) *
                      flatten,
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      children: [widget.image, child],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                  )),
            );
          },
        ),
      ),
    );
  }
}

/// A platform-agnostic card representing a song which can be in a card state,
/// a flat state or anything in between.
///
/// When it's in a card state, it's pressable.
///
/// This is an example of a custom widget that an app developer might create for
/// use on both iOS and Android as part of their brand's unique design.
class HeroAnimatingSongCard extends StatelessWidget {
  HeroAnimatingSongCard({
    @required this.title,
    @required this.image,
    @required this.heroAnimation,
    @required this.price,
    this.onPressed,
  });

  final String title;
  final String price;
  final Image image;
  final Animation<double> heroAnimation;
  final VoidCallback onPressed;

  @override
  Widget build(context) {
    // This is an inefficient usage of AnimatedBuilder since it's rebuilding
    // the entire subtree instead of passing in a non-changing child and
    // building a transition widget in between.
    //
    // Left simple in this demo because this card doesn't have any real inner
    // content so this just rebuilds everything while animating.
    return AnimatedBuilder(
      animation: heroAnimation,
      builder: (context, child) {
        return PressableCard(
          onPressed: heroAnimation.value == 0 ? onPressed : null,
          image: image,
          flattenAnimation: heroAnimation,
          child: SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The song title banner slides off in the hero animation.
                Positioned(
                  bottom: -80 * heroAnimation.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    color: Colors.black12,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "$price KLAY",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                    )
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A loading song tile's silhouette.
///
/// This is an example of a custom widget that an app developer might create for
/// use on both iOS and Android as part of their brand's unique design.
class SongPlaceholderTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            Container(
              color: Theme.of(context).textTheme.bodyText2.color,
              width: 130,
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 60),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 20, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 40, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 80, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                  Container(
                    height: 9,
                    margin: EdgeInsets.only(right: 50, top: 8),
                    color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Non-shared code below because different interfaces are shown to prompt
// for a multiple-choice answer.
//
// This is a design choice and you may want to do something different in your
// app.
// ===========================================================================
/// This uses a platform-appropriate mechanism to show users multiple choices.
///
/// On Android, it uses a dialog with radio buttons. On iOS, it uses a picker.
void showChoices(BuildContext context, List<String> choices) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      showDialog<void>(
        context: context,
        builder: (context) {
          int selectedRadio = 1;
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 12),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(choices.length, (index) {
                    return RadioListTile<int>(
                      title: Text(choices[index]),
                      value: index,
                      groupValue: selectedRadio,
                      onChanged: (value) {
                        setState(() => selectedRadio = value);
                      },
                    );
                  }),
                );
              },
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    case TargetPlatform.iOS:
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: CupertinoPicker(
              backgroundColor: Theme.of(context).canvasColor,
              useMagnifier: true,
              magnification: 1.1,
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: 1),
              children: List<Widget>.generate(choices.length, (index) {
                return Center(
                  child: Text(
                    choices[index],
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                );
              }),
              onSelectedItemChanged: (value) {},
            ),
          );
        },
      );
      return;
    default:
      assert(false, 'Unexpected platform $defaultTargetPlatform');
  }
}

class WritePosts extends StatefulWidget {
  final String author;
  const WritePosts({Key key, this.author}) : super(key: key);

  @override
  _WritePostsState createState() => _WritePostsState();
}

class _WritePostsState extends State<WritePosts> {

  String productName;
  String content;
  String price;
  File _image;
  PostsService _postsService;
  String _downloadURL;
  @override
  Widget build(BuildContext context) {
    _postsService = PostsService();
    return Scaffold(
      appBar: AppBar(
        title: Text("Write Post"),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        actions: [
          IconButton(
            onPressed: (){
              Posts p = new Posts(productName: productName, author: widget.author, price: price, content: content, picture: _downloadURL);
              _postsService.putPost(p);
              Navigator.pop(context);
            },
            icon:Icon(Icons.save),
            tooltip: "save the post",),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: kTextFieldDecoration.copyWith(hintText: "productName"),
            onChanged: (value){productName = value;},
          ),
          CircleAvatar(
            backgroundImage: (_image != null) ? FileImage(_image):NetworkImage("https://firebasestorage.googleapis.com/v0/b/usedtrading.appspot.com/o/posts%2F1.jpg?alt=media"),
            radius: 30,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Gallery"),
                onPressed: () {
                  _uploadImageToStorage(ImageSource.gallery);
                },
              ),
              RaisedButton(
                child: Text("Camera"),
                onPressed: () {
                  _uploadImageToStorage(ImageSource.camera);
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            decoration: kTextFieldDecoration.copyWith(hintText: "price"),
            onChanged: (value){price = value;},
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(10.0),
            child: new ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200.0,
              ),
              child: new Scrollbar(
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: SizedBox(
                    height: 190.0,
                    child: new TextField(
                      maxLines: 100,
                      decoration: kTextFieldDecoration.copyWith(hintText: "content"),
                      onChanged: (value){content = value;},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _uploadImageToStorage(ImageSource source) async {
    final picker =  ImagePicker();
    final image = await picker.getImage(source: source);

    if (image == null) return;
    setState(() {
      _image = File(image.path);
    });
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('posts')
        .child("${_postsService.getCurrentID()}.jpg");

    firebase_storage.UploadTask uploadTask = ref.putFile(_image);
    Pattern linkPattern = '^.*.media';
    RegExp linkReg = RegExp(linkPattern);
    await uploadTask.whenComplete(() => ref.getDownloadURL().then((value) =>
    _downloadURL =linkReg.stringMatch(value)));

    print(_downloadURL);
  }
}


const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  hintStyle: TextStyle(color: Colors.grey),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide.none,
  ),
);