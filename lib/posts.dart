import 'package:cloud_firestore/cloud_firestore.dart';

class Posts{

  final String author;
  final String content;
  final String productName;
  final int price;
  final String picture;
  const Posts({this.author, this.content,this.productName, this.price, this.picture });

  Map<String, dynamic> makeData(){
    Map<String,dynamic> tmp = new Map();
    tmp['author'] = this.author;
    tmp['content'] = this.content;
    tmp['picture'] = this.picture;
    tmp['productName'] = this.productName;
    tmp['price'] = this.price;
    tmp['time_stamp'] = FieldValue.serverTimestamp();
    tmp['sale?'] = false;

    return tmp;
  }

}

class UpdatePosts{

  final String content;
  final String productName;
  final int price;
  final String document;

  const UpdatePosts({this.document, this.content,this.productName, this.price});

  Map<String,dynamic> makeUpdateData(){
    Map<String,dynamic> tmp = new Map();
    tmp['content'] = this.content;
    tmp['productName'] = this.productName;
    tmp['price'] = this.price;
    tmp['time_stamp'] = FieldValue.serverTimestamp();
    return tmp;
  }
}

