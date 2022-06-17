import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        await _fireStore.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'bio': bio,
          'followers': [],
          'following': [],
          photoUrl: photoUrl,
        });
        res = "success";
      }
    }
    /*on FirebaseAuthException catch(err){
      if(err.code == 'invalid-email'){
        res = 'The email is invalid.';
      }
      else if(err.code == 'weak-password'){
        res = 'password is weak';
      }
    }*/
    catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred.";
    try {
      if(email.isNotEmpty || password.isNotEmpty){
       await _auth.signInWithEmailAndPassword(email: email, password: password);
       res = "success";
      }else{
        res = "Please enter all the fields.";
      }
    }catch (err) {
      res = err.toString();
    }
    return res;
  }
}
