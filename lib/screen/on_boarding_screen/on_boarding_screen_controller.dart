import 'dart:async';

import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/screen/auth_screen/login_screen.dart';
import 'package:stakBread/screen/auth_screen/sign_up_options_screen.dart';

class OnBoardingScreenController extends BaseController {
  RxInt selectedPage = RxInt(0);

  static const int pageCount = 3;
  static const Duration autoChangeDuration = Duration(seconds: 1);

  Timer? _autoChangeTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoChange();
  }

  void _startAutoChange() {
    _autoChangeTimer?.cancel();
    _autoChangeTimer = Timer.periodic(autoChangeDuration, (_) {
      selectedPage.value = (selectedPage.value + 1) % pageCount;
    });
  }

  void onPageTap(int index) {
    selectedPage.value = index;
    _startAutoChange();
  }

  void onSkipTap() {
    SessionManager.instance.setBool(SessionKeys.isOnBoardingScreenSelect, true);
    Get.off(() => const LoginScreen());
  }

  void onGetStartedTap() {
    SessionManager.instance.setBool(SessionKeys.isOnBoardingScreenSelect, true);
    Get.to(() => const SignUpOptionsScreen());
  }

  void onLoginTap() {
    SessionManager.instance.setBool(SessionKeys.isOnBoardingScreenSelect, true);
    Get.off(() => const LoginScreen());
  }

  @override
  void onClose() {
    _autoChangeTimer?.cancel();
    super.onClose();
  }
}
