import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'rest_api.dart';
import 'klay.dart';
///사용자 클래스
///google에서 제공하는 id로 인덱싱
///
class TradeUser {
  final id;//구글 제공id;
  String username;
  final email;
  final walletAddress;
  var createdAt = FieldValue.serverTimestamp();
  final pubKey;
  FieldValue updatedAt = FieldValue.serverTimestamp();
  bool transfer = true;

  TradeUser({
    @required this.id,
    @required this.username,
    @required this.email,
    @required this.walletAddress,
    @required this.pubKey,
    this.createdAt,
    this.transfer,
    this.updatedAt,
  });

  Map<String, dynamic> toMap(){
    return {"id": id, "username":username, "email":email, "wallet_address":walletAddress, "pubKey": pubKey, "createdAt": createdAt,"updatedAt": updatedAt,"transfer?": transfer };
  }
  factory TradeUser.fromJson(Map<String, dynamic> json){
    return TradeUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      walletAddress: json['walletAddress'],
      pubKey: json['pubKey'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      transfer: json['transfer?'],
    );
  }
  void update(String username, bool transfer){
    this.username = username;
    this.transfer = transfer;
    updatedAt = FieldValue.serverTimestamp();
  }

}
final collection = FirebaseFirestore.instance.collection("user");

void addUser(TradeUser user) async{
  collection.doc().set(user.toMap());
}

void createUser(currentUser) async {
  var account;
  var tct;
  collection.where('id', isEqualTo: currentUser.uid).get().then((QuerySnapshot querySnapshot) async =>{
    if(querySnapshot.docs.isEmpty){
      account = await createAccount(),
      tct = await createTCT(account.address, 100),
        addUser(TradeUser(id: currentUser.uid,
                username: currentUser.displayName,
                email: currentUser.email,
                walletAddress: account.address,
                pubKey: account.publicKey,
                createdAt: FieldValue.serverTimestamp(),
                updatedAt: FieldValue.serverTimestamp(),
                transfer: true,
      ))
    }

  });
}

///id를 통한 유저정보 가져오기
Future<String> getUser(String id) async{
  var data = await collection.where('id', isEqualTo: id).snapshots().first;
  var author = data.docs.elementAt(0).data();
  return author['username'];
}

