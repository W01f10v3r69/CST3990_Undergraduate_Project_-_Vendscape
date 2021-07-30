import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendscape/models/user_model.dart';

//All Firebase related services for user
class UserServices{

  String collection = 'users';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

//  Create new user
Future<void> createUserData(Map<String, dynamic> values)async {
  String id = values['id'];
  await _firestore.collection(collection).doc(id).set(values);
}

//  Update user data
Future<void> updateUserData(Map<String, dynamic> values)async{
  String id = values['id'];
  await _firestore.collection(collection).doc(id).update(values);
}

//  Get user data by user ID
Future<void> getUserById(Map<String, dynamic> values)async{
  String id = values['id'];
  await _firestore.collection(collection).doc(id).get()
  .then((doc) {
    if (doc.data()==null) {
      return null;
    }

    return UserModel.fromSnapshot(doc);
  });
}

}