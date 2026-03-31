import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Never put [STRIPE_SECRET] in the app bundle — server only.
///
/// Resolution order:
/// 1. `--dart-define=STRIPE_KEY=pk_...` (non-empty only)
/// 2. `assets/config/stripe.env` → `STRIPE_KEY=...`
/// 3. [stripePublishableKeyFallback]
Future<String> resolveStripePublishableKey() async {
  const fromDefine = String.fromEnvironment('STRIPE_KEY');
  if (fromDefine.isNotEmpty) return fromDefine;

  try {
    await dotenv.load(fileName: 'assets/config/stripe.env');
  } catch (_) {
    // Asset missing or invalid; fall through.
  }
  final fromFile = dotenv.env['STRIPE_KEY']?.trim() ?? '';
  if (fromFile.isNotEmpty) return fromFile;

  return stripePublishableKeyFallback;
}

/// Last-resort test key if no define and no env file.
const String stripePublishableKeyFallback =
    'pk_test_51SaNkIPf6zS39mxKhpnHwxZjfY7wsN1sGz1C7PCtCNghAHuPUrwk1Zi4uzPmnMLhbWgN5jvUiEONbrdy55AS39I9009HXbz57N';
