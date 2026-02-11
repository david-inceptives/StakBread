const String baseURL = 'https://shortz.londonauthorhouse.com/';
const String apiURL = '${baseURL}api/';
const String apiKey = 'retry123';

/// When true, all API calls are skipped and dummy/mock data is returned instead.
const bool useDummyApi = true;

/// Dummy share link shown in share sheet when [useDummyApi] is true.
const String dummyShareLink = 'https://stakbread.app/demo/share';

// If you change this topic you also change backend .env file
String notificationTopic = "stakBread";

// Translation / multi-language - disabled for now, enable when needed
const bool kTranslationFeatureEnabled = false;

// RevenueCat - feature hidden, set to true when needed
const bool kRevenueCatEnabled = false;
// String revenueCatAndroidApiKey = "______"; // revenueCat android api
// String revenueCatAppleApiKey = "________"; // revenueCat apple api
String get revenueCatAndroidApiKey => "";
String get revenueCatAppleApiKey => "";
