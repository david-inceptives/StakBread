import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:stakBread/common/manager/firebase_notification_manager.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
// import 'package:stakBread/common/service/subscription/subscription_manager.dart'; // RevenueCat hidden
import 'package:stakBread/common/widget/restart_widget.dart';
import 'package:stakBread/languages/dynamic_translations.dart';
import 'package:stakBread/screen/splash_screen/splash_screen.dart';
import 'package:stakBread/utilities/stripe_keys.dart';
import 'package:stakBread/utilities/theme_res.dart';

import 'common/service/network_helper/network_helper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Loggers.success("Handling a background message: ${message.data}");
  await Firebase.initializeApp();
  if (Platform.isIOS) {
    FirebaseNotificationManager.instance.showNotification(message);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await GetStorage.init('stakBread');

    // RevenueCat - commented/hidden (enable in const_res.dart when needed)
    // try {
    //   await SubscriptionManager.shared.initPlatformState();
    // } catch (e, st) {
    //   Loggers.error('SubscriptionManager init error: $e\n$st');
    // }
    (await AudioSession.instance).configure(const AudioSessionConfiguration.speech());

    // Init Ads (ignore async wait if needed)
    MobileAds.instance.initialize();

    NetworkHelper().initialize();

    try {
      final stripePk = await resolveStripePublishableKey();
      if (stripePk.isEmpty) {
        Loggers.error('Stripe: STRIPE_KEY is empty (check assets/config/stripe.env or --dart-define)');
      } else {
        Stripe.publishableKey = stripePk;
        Stripe.urlScheme = 'stakbread';
        if (Platform.isAndroid) {
          Stripe.setReturnUrlSchemeOnAndroid = true;
        }
        await Stripe.instance.applySettings();
      }
    } catch (e, st) {
      Loggers.error('Stripe init failed: $e\n$st');
    }

    // Load Translations
    Get.put(DynamicTranslations());

    // Run app
    runApp(const RestartWidget(child: MyApp()));

   /* runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const RestartWidget(child: MyApp()), // Wrap your app
      ),
    );*/
  } catch (e, st) {
    Loggers.error('Fatal crash during app startup $st');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          builder: (context, child) => ScrollConfiguration(behavior: MyBehavior(), child: child!),
          translations: Get.find<DynamicTranslations>(),
          locale: Locale(SessionManager.instance.getLang()),
          //builder: DevicePreview.appBuilder,
          fallbackLocale: Locale(SessionManager.instance.getFallbackLang()),
          themeMode: ThemeMode.light,
          darkTheme: ThemeRes.darkTheme(),
          theme: ThemeRes.lightTheme(),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
