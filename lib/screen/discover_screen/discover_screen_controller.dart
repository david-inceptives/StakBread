import 'package:get/get.dart';

class DiscoverScreenController extends GetxController {
  RxInt selectedTabIndex = 0.obs;

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
  }
}
