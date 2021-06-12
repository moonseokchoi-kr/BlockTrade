import 'package:http/http.dart' as http;
import 'klay.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
final auth = '';
final chainId= '1001';

/// 추가적으로 만들것들
///

/// 2. User 등록 시퀀스 만들기(firebase에 유저데이터 등록 하기, 등록할 정보,  doc: uuid, field: username, address, tct

/// 4. 드로어 UI, 거래 진행 UI 제작
/// 5. 영수증 데이터베이스 제작
/// 6. 거래 시퀀스 제작(거래예약->택배배송완료버튼->거래진행->NFT발행과 함께 2차영수증 발행)

///클레이전송
/// 입력 보낼 계정, 받는 계정, 클레이의 양, 영수증의 데이터
/// https://refs.klaytnapi.com/ko/wallet/latest#operation/ValueTransferTransaction

Future<String> transferKlay(String to, String from, num value, Receipt recipient) async{
  final request = jsonEncode({"from": from,
    "to": to,
    "value": '0x${calKLayAmount(value)}',
    "memo":jsonEncode(recipient.toMap()),
    "submit": true});
  final response = await http.post(Uri.parse('https://wallet-api.klaytnapi.com/v2/tx/value'),
    headers: {HttpHeaders.authorizationHeader: auth,
      'x-chain-id': chainId,
      'Content-Type': 'application/json'
    },
    body: request,
  );
  if(response.statusCode == 200){
    TransferResult tr = TransferResult.fromJson(jsonDecode(response.body));
    print("klay_transaction: ${tr.transaction}");
    return tr.transaction;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print(response.body);
    return "";
  }
}
///TCT토큰 잔액 조회
Future<String> getTCTBalance(String owner) async{
  final contract = "trustcoin";
  final response = await http.get(Uri.parse("https://kip7-api.klaytnapi.com/v1/contract/$contract/account/$owner/balance")
      ,headers: {HttpHeaders.authorizationHeader: auth,
        'x-chain-id': chainId,
        'Content-Type': 'application/json'
      }
  );
  if (response.statusCode == 200){
    final json = jsonDecode(response.body);
    return calKLAYValue(json['balance']);
  }else{
    print(response.body);
    throw Exception("Failed to get TCT balance");
  }
}

///계정생성
Future<Account> createAccount() async{
  final response = await http.post(Uri.parse("https://wallet-api.klaytnapi.com/v2/account"),
      headers: {HttpHeaders.authorizationHeader: auth,
        'x-chain-id': chainId,
        'Content-Type': 'application/json'
      }
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Account.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<String> getBalance(String account) async{
  final request = jsonEncode({"method":"klay_getBalance","params":["$account", "latest"] ,"id":1});
  final response =  await http.post(
      Uri.parse('https://node-api.klaytnapi.com/v1/klaytn'),
      headers: {
        HttpHeaders.authorizationHeader: auth,
        'x-chain-id': chainId,
        'Content-Type':'application/json'
      },
      body: request
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final json = jsonDecode(response.body);
    print(json['result']);
    return calKLAYValue(json['result']);
  }else {
    print(response.body);
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

//TCT토큰 발행
/*
입력 받을계정
 */
Future<TCT> createTCT(String to, num value) async{
  final auth = 'Basic S0FTS0NLRDJRTzE1RE4yRVBGR1JIVEhPOjdvZmFGMnlQYmR4VkFKMjAwRU53OStGQ1ZoV01MeUJrc2twSGxGN28=';
  final contractAddress = 'trustcoin';
  final amount = calKLayAmount(value);
  final request = jsonEncode({"to":to, "amount":"0x$amount"});
  final response = await http.post(Uri.parse('https://kip7-api.klaytnapi.com/v1/contract/$contractAddress/mint')
      ,headers: {
        HttpHeaders.authorizationHeader: auth,
        'x-chain-id': "1001",
        'Content-Type':'application/json'
      },
      body: request
  );
  if(response.statusCode == 200){
    return TCT.fromJson(jsonDecode(response.body));
  }else{
    print(response.body);
    throw Exception("Faild to createTCT");
  }
}

//TCT토큰 전송
/*
입력 받을계정 토큰의 양
https://refs.klaytnapi.com/ko/kip7/latest#operation/TransferToken
 */
Future<String> transferTCT(String to, num value) async{
  final contractAddress = 'trustcoin';
  final amount = calKLayAmount(value);
  final request = jsonEncode({
    "to":to,
    "amount":"0x$amount"});
  final response = await http.post(Uri.parse('https://kip7-api.klaytnapi.com/v1/contract/$contractAddress/transfer')
      ,headers: {
        HttpHeaders.authorizationHeader: auth,
        'x-chain-id': "1001",
        'Content-Type':'application/json'
      },
      body: request
  );
  if(response.statusCode == 200){
    TCT tct = TCT.fromJson(jsonDecode(response.body));
    return tct.transaction;
  }else{
    print(response.body);
    return "";
  }
}

//NFT발행
/*
입력 받을계정의 주소, 토큰에 포함될 데이터 정보
https://refs.klaytnapi.com/ko/kip17/latest#operation/ListContractsInDeployerPool
 */
//영수증 블록체인에 등록


Future<String> mintNFT() async{
  final contract = 'blockreceipt';
  int id = await _getNFTSize();
  final request = jsonEncode({
    "to" : "0xA0E20bf364865540da3A655c4412Ab75980480F6",
    "id" : "0x${id.toRadixString(16)}",
    "uri" : "/posts/1"
  });
  final response = await http.post(Uri.parse('https://kip17-api.klaytnapi.com/v1/contract/$contract/token')
    ,headers: {
      HttpHeaders.authorizationHeader: auth,
      'x-chain-id': chainId,
      'Content-Type':'application/json'
    },
    body: request,
  );
  if(response.statusCode == 200){
    TCT tct=  TCT.fromJson(jsonDecode(response.body));
    return tct.transaction;
  }else{
    print(response.body);
    throw Exception("Failed to mintNFT");
  }
}

/// 1. NFT id자동생성(NFT목록을 조회해서 길이를 계산하여 id생성)
Future<int> _getNFTSize() async{
  final response = await http.get(Uri.parse("https://kip17-api.klaytnapi.com/v1/contract/blockreceipt/token"),
      headers: {
        HttpHeaders.authorizationHeader: auth,
        'x-chain-id': chainId,
        'Content-Type':'application/json'
      }
  );

  if(response.statusCode == 200){
    final json = jsonDecode(response.body);
    int size = json['items'].length;
    print(json['items'].length);
    return size+1;
  }else{
    print(response.body);
    throw Exception("Failed to get size");
  }
}

/// 3. 클레이 단위 자동계산 함수 제작
String calKLAYValue(String radixString) {
  if(radixString == '0x0')
    return '0';
  return (BigInt.parse(radixString.substring(2,radixString.length), radix: 16).toDouble()/BigInt.from(10).pow(18).toDouble()).toStringAsFixed(2);
}

String calKLayAmount(num value){
  return (BigInt.from(value)*BigInt.from(10).pow(18)).toRadixString(16);
}