import 'package:cloud_firestore/cloud_firestore.dart';

import 'posts.dart';
import 'package:uuid/uuid.dart';
class PostsService{
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String _downloadURL;
  void putPost(Posts posts, id){
      _fireStore.collection("posts").doc(id).set(posts.makeData());
  }


}

