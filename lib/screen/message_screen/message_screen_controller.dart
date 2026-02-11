import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/controller/firebase_firestore_controller.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/widget/confirmation_dialog.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/chat/chat_thread.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:stakBread/utilities/const_res.dart';
import 'package:stakBread/utilities/firebase_const.dart';

class MessageScreenController extends BaseController {
  List<String> chatCategories = [LKey.chats.tr, LKey.requests.tr];
  RxInt selectedChatCategory = 0.obs;
  FirebaseFirestore db = FirebaseFirestore.instance;
  PageController pageController = PageController();
  User? myUser = SessionManager.instance.getUser();
  RxList<ChatThread> chatsUsers = <ChatThread>[].obs;
  RxList<ChatThread> requestsUsers = <ChatThread>[].obs;
  final dashboardController = Get.find<DashboardScreenController>();
  final firebaseFirestoreController = Get.find<FirebaseFirestoreController>();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedChatCategory.value);
    if (useDummyApi) {
      _loadDummyChats();
    } else {
      _listenToUserChatsAndRequests();
    }
  }

  /// Dummy chat list when [useDummyApi] is true.
  void _loadDummyChats() {
    isLoading.value = true;
    final convId = 'dummy_conv_';
    final threads = <ChatThread>[
      ChatThread.fromJson({
        'user_id': 2,
        'id': '${DateTime.now().millisecondsSinceEpoch - 2}',
        'msg_count': 3,
        'chat_type': 'approved',
        'request_type': null,
        'last_msg': 'Hey! How are you?',
        'conversation_id': '${convId}1_2',
        'deleted_id': 0,
        'is_deleted': false,
        'i_am_blocked': false,
        'i_blocked': false,
      }),
      ChatThread.fromJson({
        'user_id': 3,
        'id': '${DateTime.now().millisecondsSinceEpoch - 1}',
        'msg_count': 1,
        'chat_type': 'approved',
        'request_type': null,
        'last_msg': 'See you tomorrow',
        'conversation_id': '${convId}1_3',
        'deleted_id': 0,
        'is_deleted': false,
        'i_am_blocked': false,
        'i_blocked': false,
      }),
      ChatThread.fromJson({
        'user_id': 4,
        'id': '${DateTime.now().millisecondsSinceEpoch}',
        'msg_count': 0,
        'chat_type': 'request',
        'request_type': null,
        'last_msg': 'Hi, want to connect?',
        'conversation_id': '${convId}1_4',
        'deleted_id': 0,
        'is_deleted': false,
        'i_am_blocked': false,
        'i_blocked': false,
      }),
    ];
    for (final t in threads) {
      if (t.chatType == ChatType.approved) {
        chatsUsers.add(t);
      } else {
        requestsUsers.add(t);
      }
      firebaseFirestoreController.fetchUserIfNeeded(t.userId ?? -1);
    }
    isLoading.value = false;
    Loggers.info('Dummy chats loaded: ${chatsUsers.length} chats, ${requestsUsers.length} requests');
  }

  void onPageChanged(int index) {
    selectedChatCategory.value = index;
  }

  Future<void> _listenToUserChatsAndRequests() async {
    isLoading.value = true;
    db
        .collection(FirebaseConst.users)
        .doc(myUser?.id.toString())
        .collection(FirebaseConst.usersList)
        .withConverter(
            fromFirestore: (snapshot, options) => ChatThread.fromJson(snapshot.data()!),
            toFirestore: (ChatThread value, options) => value.toJson())
        .where(FirebaseConst.isDeleted, isEqualTo: false)
        .orderBy(FirebaseConst.id, descending: true)
        .snapshots()
        .listen((event) {
      isLoading.value = false;
      for (var change in event.docChanges) {
        final ChatThread? chatUser = change.doc.data();
        if (chatUser == null) continue;

        switch (change.type) {
          case DocumentChangeType.added:
            if (chatUser.userId != -1) {
              firebaseFirestoreController.fetchUserIfNeeded(chatUser.userId ?? -1);
            }
            if (chatUser.chatType == ChatType.approved) {
              chatsUsers.add(chatUser);
            } else {
              requestsUsers.add(chatUser);
            }

            break;
          case DocumentChangeType.modified:
            // Remove the user from their current list
            final userId = chatUser.userId;
            chatsUsers.removeWhere((user) => user.userId == userId);
            requestsUsers.removeWhere((user) => user.userId == userId);

            (chatUser.chatType == ChatType.approved ? chatsUsers : requestsUsers).add(chatUser);
          case DocumentChangeType.removed:
            // Remove the user from their current list
            final userId = chatUser.userId;
            chatsUsers.removeWhere((user) => user.userId == userId);
            requestsUsers.removeWhere((user) => user.userId == userId);
            break;
        }
      }

      chatsUsers.sort(
        (a, b) {
          return (b.id ?? '0').compareTo(a.id ?? '0');
        },
      );
      requestsUsers.sort(
        (a, b) {
          return (b.id ?? '0').compareTo(a.id ?? '0');
        },
      );

      // Loggers.success('CHAT USER: ${chatsUsers.length}');
      // Loggers.success('REQUEST USER: ${requestsUsers.length}');
    });
  }

  void onLongPress(ChatThread chatConversation) {
    Get.bottomSheet(ConfirmationSheet(
      title: LKey.deleteChatUserTitle.trParams({'user_name': chatConversation.chatUser?.username ?? ''}),
      description: LKey.deleteChatUserDescription.tr,
      onTap: () async {
        if (useDummyApi) {
          chatsUsers.removeWhere((c) => c.userId == chatConversation.userId);
          requestsUsers.removeWhere((c) => c.userId == chatConversation.userId);
          return;
        }
        int time = DateTime.now().millisecondsSinceEpoch;
        showLoader();
        await db
            .collection(FirebaseConst.users)
            .doc(myUser?.id.toString())
            .collection(FirebaseConst.usersList)
            .doc(chatConversation.userId.toString())
            .update({
          FirebaseConst.deletedId: time,
          FirebaseConst.isDeleted: true,
        }).catchError((error) {
          Loggers.error('USER NOT DELETE : $error');
        });
        stopLoader();
      },
    ));
  }
}
