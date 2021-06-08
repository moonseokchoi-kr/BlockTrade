import 'dart:convert';

import 'package:flutter/material.dart';
///kas 서비스와 관련된 클래스를정의하는곳


///클레이전송 트랜잭션 결과를 받는 클래스
class TransferResult{
  final String from;
  final String input;
  final int nonce;
  final String rip;
  final signature;
  final String status;
  final String to;
  final String transaction;
  final String value;

  TransferResult({
    @required this.from,
    @required this.input,
    @required this.nonce,
    @required this.rip,
    @required this.signature,
    @required this.status,
    @required this.to,
    @required this.transaction,
    @required this.value,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json){
    print(json['transactionHash']);
    return TransferResult(
        from: json['from'],
        input: json['input'],
        nonce: json['nonce'],
        rip: json['rip'],
        signature: json['signature'],
        status: json['status'],
        to: json['to'],
        transaction: json['transactionHash'],
        value: json['value']);
  }
}
/// 영수증 생성클래스
/// 2차 거래 완료시 nft와 klaytransferhash 추가 trade 변수 true로
///
class Recipient{
  final int id;
  final String productName;
  final String seller;
  final String buyer;
  final String trustToken;
  final String nftHash;
  final String klayTransferHash;
  final int createdAt;
  final int tradeTime;
  bool trade = false;

  Recipient({
    @required this.id,
    @required this.productName,
    @required this.seller,
    @required this.buyer,
    @required this.trustToken,
    @required this.createdAt,
    @required this.tradeTime,
    this.nftHash,
    this.klayTransferHash
  });

  factory Recipient.fromJson(Map<String, dynamic> json){
    return Recipient(
        id: json['id'],
        productName: json['productName'],
        seller: json['seller'],
        buyer: json['buyer'],
        trustToken: json['trustToken'],
        createdAt: json['createdAt'],
        tradeTime: json['tradeTime'],
       );
  }
  String toJson(){
    return jsonEncode(this);
  }

}
///KAS 서비스 계정생성결과를 받는 클래스
class Account{
  final String address;
  final int chainId;
  final int createAt;
  final String keyId;
  final String krn;
  final String publicKey;
  final int updatedAt;

  Account({
    @required this.address,
    @required this.chainId,
    @required this.createAt,
    @required this.keyId,
    @required this.krn,
    @required this.publicKey,
    @required this.updatedAt
  });
  factory Account.fromJson(Map<String, dynamic> json){
    return Account(
        address: json['address'],
        chainId: json['chainId'],
        createAt: json['createAt'],
        keyId: json['keyId'],
        krn: json['krn'],
        publicKey: json['publicKey'],
        updatedAt: json['updatedAt']
    );
  }
}
//NodeAPI결과를 받는 클래스
class Block {
  final String jsonRPC;
  final int id;
  final String result;

  Block({
    @required this.jsonRPC,
    @required this.id,
    @required this.result,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    print(json['result']);
    return Block(
      jsonRPC: json['jsonrpc'],
      id: json['id'],
      result: json['result'],
    );
  }
}

class TCT{
  final String status;
  final String transaction;

  TCT({
    @required this.status,
    @required this.transaction
  });
  factory TCT.fromJson(Map<String,dynamic> json){
    print(json['transactionHash']);
    return TCT(
      status: json['status'],
      transaction: json['transactionHash'],
    );
  }
}