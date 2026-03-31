import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/screen/upload_product_screen/upload_product_screen.dart';

class StripeConnectManager {
  StripeConnectManager._();

  static final StripeConnectManager shared = StripeConnectManager._();

  bool _started = false;
  StreamSubscription<Uri>? _sub;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final links = AppLinks();

    // Handle cold-start deep link.
    try {
      final initial = await links.getInitialLink();
      if (initial != null) {
        unawaited(_handleUri(initial));
      }
    } catch (e) {
      Loggers.error('StripeConnectManager initial link error: $e');
    }

    // Handle foreground/background deep links.
    _sub = links.uriLinkStream.listen(
      (uri) => unawaited(_handleUri(uri)),
      onError: (e) => Loggers.error('StripeConnectManager link stream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _started = false;
  }

  bool _isStripeReturn(Uri uri) {
    final scheme = (uri.scheme).toLowerCase();
    if (scheme != 'stakbread') return false;

    final host = (uri.host).toLowerCase();
    if (host != 'stripe') return false;

    final path = (uri.path).toLowerCase();
    return path == '/success' || path == '/refresh';
  }

  Future<void> _handleUri(Uri uri) async {
    if (!_isStripeReturn(uri)) return;

    Loggers.info('Stripe return url received: $uri');

    // If user isn't logged in, we can't complete the flow.
    if (!SessionManager.instance.isLogin()) return;

    // Let navigation stack settle (esp. during Splash → Dashboard).
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final completed =
          await StoreService.instance.getStripeConnectIsSetupCompleted();
      if (!completed) {
        BaseController.share.showSnackBar('Stripe setup not completed');
        return;
      }

      BaseController.share.showSnackBar('Stripe setup completed');
      Get.to(() => const UploadProductScreen());
    } catch (e) {
      BaseController.share
          .showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

