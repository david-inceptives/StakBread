import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_search_text_field.dart';
import 'package:stakBread/common/widget/custom_tab_switcher.dart';
import 'package:stakBread/common/widget/loader_widget.dart';
import 'package:stakBread/common/widget/no_data_widget.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/chat/chat_thread.dart';
import 'package:stakBread/screen/message_screen/message_screen_controller.dart';
import 'package:stakBread/screen/message_screen/widget/chat_conversation_user_card.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: LKey.messages.tr,
            titleStyle: TextStyleCustom.unboundedSemiBold600(
                fontSize: 15, color: ColorRes.textDarkGrey),
          ),
          Expanded(
            child: Column(
              children: [

                Container(
                  color: ColorRes.whitePure,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomTabSwitcher(
                    items: controller.chatCategories,
                    onTap: (index) {
                      controller.onPageChanged(index);
                      controller.pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                    },
                    selectedIndex: controller.selectedChatCategory,
                    widget: Obx(() {
                      int length = controller.dashboardController.requestUnReadCount.value;
                      if (length <= 0) {
                        return const SizedBox();
                      }
                      return Container(
                        height: 22,
                        width: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: ColorRes.likeRed),
                        alignment: Alignment.center,
                        child: Text(
                          '$length',
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 12, color: ColorRes.whitePure),
                        ),
                      );
                    }),
                    widgetTabIndex: 1,
                    margin: EdgeInsets.zero,
                  ),
                ),
                const CustomSearchTextField(),
                Expanded(
                  child: Obx(
                    () => controller.isLoading.value &&
                            (controller.selectedChatCategory.value == 0
                                ? controller.chatsUsers.isEmpty
                                : controller.requestsUsers.isEmpty)
                        ? const LoaderWidget()
                        : PageView(
                            controller: controller.pageController,
                            onPageChanged: controller.onPageChanged,
                            children: const [
                              ChatsListView(),
                              RequestsListView(),
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageScreenController controller = Get.find();
    return Obx(() {
      return NoDataView(
        showShow: controller.chatsUsers.isEmpty,
        title: LKey.chatListEmptyTitle.tr,
        description: LKey.chatListEmptyDescription.tr,
        child: ListView.builder(
          itemCount: controller.chatsUsers.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            ChatThread chatConversation = controller.chatsUsers[index];
            chatConversation.bindChatUser();
            return ChatConversationUserCard(chatConversation: chatConversation);
          },
        ),
      );
    });
  }
}

class RequestsListView extends StatelessWidget {
  const RequestsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageScreenController controller = Get.find();

    return Obx(
      () => NoDataView(
        showShow: controller.requestsUsers.isEmpty,
        title: LKey.chatRequestEmptyTitle.tr,
        description: LKey.chatRequestEmptyDescription.tr,
        child: ListView.builder(
          itemCount: controller.requestsUsers.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            ChatThread chatConversation = controller.requestsUsers[index];
            chatConversation.bindChatUser();
            return ChatConversationUserCard(chatConversation: chatConversation);
          },
        ),
      ),
    );
  }
}
