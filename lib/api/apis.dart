import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_ping/models/chat_user.dart';
import 'package:quick_ping/models/message.dart';

class APIs {
  //static because we can access it without creating its object
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for storing self user
  static late ChatUser me;

  //get current user
  static User get user => auth.currentUser!;

  //for accessing firebase messaging (Push Notification)
  // static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase message token
  // static Future<void> getFirebaseMessagingToken() async {
  //   await fMessaging.requestPermission();
  //   fMessaging.getToken().then((t) {
  //     if (t != null) {
  //       me.pushToken = t;
  //       log('Push Token: $t');
  //     }
  //   });
  // }

  //for check user exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //if user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //if not exists
      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using Quick Ping!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection("users")
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  //for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection("users")
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for adding an user to my user when first msg is send
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg));
  }

  //for updating user information (name ans about)
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      'is_online': isOnline,
      'last_active':
          DateTime.now().millisecondsSinceEpoch.toString(), // Store as string
      'push_token': me.pushToken,
    });
  }

  //chats (collection) -> conversation_id (doc) -> messages (collection) -> message (doc)

  //get conversation_id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true) //order by sent timestamp
        .snapshots();
  }

  //for sending msg
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    //msg send time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //msg to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        formId: user.uid,
        read: '',
        type: Type.text,
        sent: time);

    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.formId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  // Method to stream the current user's data from Firestore in drawer
  static Stream<ChatUser> getUserDataStream() {
    return firestore
        .collection('users')
        .doc(user.uid) // Get the current user's document
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        return ChatUser.fromJson(
            docSnapshot.data()!); // Convert to ChatUser object
      } else {
        throw Exception("User not found");
      }
    });
  }
}
