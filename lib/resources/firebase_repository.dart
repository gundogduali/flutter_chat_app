import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/enum/user_state.dart';
import 'package:flutter_chat_app/models/message.dart';
import 'package:flutter_chat_app/models/user.dart';
import 'package:flutter_chat_app/provider/image_upload_provider.dart';
import 'package:flutter_chat_app/resources/firebase_methods.dart';
import 'package:meta/meta.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<FirebaseUser> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<FirebaseUser> signIn() => _firebaseMethods.signIn();

  Future<User> getUserDetails() => _firebaseMethods.getUserDetails();

  Future<bool> authenticateUser(FirebaseUser user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addDataToDb(FirebaseUser user) =>
      _firebaseMethods.addDataToDb(user);

  ///responsible for signing out
  Future<bool> signOut() => _firebaseMethods.signOut();

  Future<List<User>> fetchAllUsers(FirebaseUser user) =>
      _firebaseMethods.fetchAllUsers(user);

  Future<void> addMessageToDb(Message message, User sender, User receiver) =>
      _firebaseMethods.addMessageToDb(message, sender, receiver);

  Future<String> uploadImageToStorage(File imageFile) =>
      _firebaseMethods.uploadImageToStorage(imageFile);

  // void showLoading(String receiverId, String senderId) =>
  //     _firebaseMethods.showLoading(receiverId, senderId);

  // void hideLoading(String receiverId, String senderId) =>
  //     _firebaseMethods.hideLoading(receiverId, senderId);

  void uploadImageMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setImageMsg(url, receiverId, senderId);

  void uploadImage(
          {@required File image,
          @required String receiverId,
          @required String senderId,
          @required ImageUploadProvider imageUploadProvider}) =>
      _firebaseMethods.uploadImage(
          image, receiverId, senderId, imageUploadProvider);

  DocumentReference getContactsDocument({String of, String forContact}) =>
      _firebaseMethods.getContactsDocument(of: of, forContact: forContact);

  Future<void> addToSendersContact(
          String senderId, String receiverId, currentTime) =>
      _firebaseMethods.addToSendersContact(senderId, receiverId, currentTime);

  Future<void> addToReceiversContact(
          String senderId, String receiverId, currentTime) =>
      _firebaseMethods.addToReceiversContact(senderId, receiverId, currentTime);

  void addToContacts({String senderId, String receiverId}) => _firebaseMethods
      .addToContacts(senderId: senderId, receiverId: receiverId);

  Stream<QuerySnapshot> fetchContacts({String userId}) =>
      _firebaseMethods.fetchContacts(userId: userId);

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {@required String senderId, @required String receiverId}) =>
      _firebaseMethods.fetchLastMessageBetween(
          senderId: senderId, receiverId: receiverId);

  Future<User> getUserDetailsById(String id) =>
      _firebaseMethods.getUserDetailsById(id);

  void setUserState({@required String userId, @required UserState userState}) =>
      _firebaseMethods.setUserState(userId: userId, userState: userState);

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _firebaseMethods.getUserStream(uid: uid);

  getChats(String groupId) => _firebaseMethods.getChats(groupId);

  sendGroupMessage(String groupId, chatMessageData) =>
      _firebaseMethods.sendGroupMessage(groupId, chatMessageData);

  void uploadImageGroup(File image, String senderId,
          ImageUploadProvider imageUploadProvider) =>
      _firebaseMethods.uploadImageGroup(image, senderId, imageUploadProvider);

  void setGroupImageMsg(String url, String senderId) =>
      _firebaseMethods.setGroupImageMsg(url, senderId);

  getUserGroups(String uid) => _firebaseMethods.getUserGroups(uid);

  Future<void> addGroupToDb(String name, List<User> members) =>
      _firebaseMethods.addGroupToDb(name, members);
}
