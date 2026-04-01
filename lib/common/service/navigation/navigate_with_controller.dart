import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/enum/chat_enum.dart';
import 'package:stakBread/common/extensions/list_extension.dart';
import 'package:stakBread/common/extensions/user_extension.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/model/chat/chat_thread.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/chat_screen/chat_screen.dart';
import 'package:stakBread/screen/profile_screen/profile_screen.dart';

Future<T?> navigateWithController<T, C extends GetxController>({
  required String tag,
  required C Function() controllerBuilder,
  required Widget Function() screenBuilder,
}) async {
  if (Get.isRegistered<C>(tag: tag)) {
    Get.delete<C>(tag: tag, force: true); // ✅ ensures correct controller type
  }

  Get.put<C>(controllerBuilder(), tag: tag);
  return Get.to<T>(() => screenBuilder(), preventDuplicates: false);
}

class NavigationService {
  static final NavigationService shared = NavigationService._();

  NavigationService._(); // ✅ private constructor

  Future<void> openProfileScreen(User? user,
      {bool isTopBarVisible = true, Function(User? user)? onUserUpdate}) async {
    await Get.to(
        () => ProfileScreen(
            user: user,
            isTopBarVisible: isTopBarVisible,
            onUserUpdate: onUserUpdate),
        preventDuplicates: false);
  }

  /// Same flow as profile “Message”: [ChatScreen] with approved thread + [User.appUser].
  void openChatWithUser(User otherUser) {
    final uid = otherUser.id;
    if (uid == null || uid <= 0) return;

    final conversation = ChatThread(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastMsg: '',
      msgCount: 0,
      isDeleted: false,
      deletedId: 0,
      iAmBlocked: false,
      iBlocked: otherUser.isBlock ?? false,
      requestType: UserRequestAction.accept.title,
      chatType: ChatType.approved,
      conversationId: [
        SessionManager.instance.getUserID(),
        uid,
      ].conversationId,
      userId: uid,
    );
    conversation.chatUser = otherUser.appUser;
    Get.to(
      () => ChatScreen(conversationUser: conversation, user: otherUser),
      preventDuplicates: false,
    );
  }
}
