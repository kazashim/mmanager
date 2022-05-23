import 'dart:io' show Platform;

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsHelper {
  //var eventListener = null;
  final String appId = Platform.isAndroid
      ? (isInDebugMode
          ? 'ca-app-pub-3940256099942544~3347511713'
          : 'ca-app-pub-0154172666410102~3304754720')
      : 'ca-app-pub-0154172666410102~9835052792';

  static const KEYWORDS = <String>[
    'money',
    'mmanager',
    'manager',
    'finance',
    'fintech',
    'payment',
    'moneymanager',
  ];

  static const CONTENT_URL = 'https://';
  static const String? TEST_DEVICE = 'Samsung_Galaxy_SII_API_26:5554';

  static final AdRequest request = AdRequest(
    testDevices: TEST_DEVICE != null ? <String>[TEST_DEVICE!] : null,
    keywords: KEYWORDS,
    contentUrl: CONTENT_URL,
    nonPersonalizedAds: true,
  );

  static bool _interstitialReady = false;
  static bool _bannerReady = false;

  static final AdListener listenerInters = AdListener(
    onAdLoaded: (Ad ad) {
      print('${ad.runtimeType} loaded.');
      _interstitialReady = true;
    },
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      print('${ad.runtimeType} failed to load: $error.');
      ad.dispose();
      _interstitialAd = null;
      createInterstitialAd();
    },
    onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
    onAdClosed: (Ad ad) {
      print('${ad.runtimeType} closed.');
      ad.dispose();
      createInterstitialAd();
    },
    onApplicationExit: (Ad ad) => print('${ad.runtimeType} onApplicationExit.'),
  );

  static final AdListener listenerBanner = AdListener(
    onAdLoaded: (Ad ad) {
      print('${ad.runtimeType} loaded.');
      _bannerReady = true;
    },
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      print('${ad.runtimeType} failed to load: $error.');
      ad.dispose();
      _bannerAd = null;
      createBannerAd();
    },
    onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
    onAdClosed: (Ad ad) {
      print('${ad.runtimeType} closed.');
      ad.dispose();
      createBannerAd();
    },
    onApplicationExit: (Ad ad) => print('${ad.runtimeType} onApplicationExit.'),
  );

  static BannerAd? _bannerAd;
  BannerAd get bannerAd => _bannerAd!;

  static InterstitialAd? _interstitialAd;
  InterstitialAd get interstitialAd => _interstitialAd!;

  AdsHelper._internal() {
    init();

    print("_interstitialReady $_interstitialReady");
    print("_bannerReady $_bannerReady");
  }

  static final AdsHelper _instance = AdsHelper._internal();
  static AdsHelper get instance => _instance;

  init() {
    print("[AdsHelper] initialization...");
    MobileAds.instance.initialize().then((InitializationStatus status) {
      print('Initialization done: ${status.adapterStatuses}');
      MobileAds.instance
          .updateRequestConfiguration(RequestConfiguration(
              tagForChildDirectedTreatment:
                  TagForChildDirectedTreatment.unspecified))
          .then((value) {
        //prepare init ad unit

        createBannerAd();
        createInterstitialAd();
      });
    });

    print("Ads initialization done...");
  }

  static createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? (isInDebugMode
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-0154172666410102/8365509719')
          : 'ca-app-pub-0154172666410102/5825323893',
      size: AdSize.banner,
      request: request,
      listener: listenerBanner,
    )..load();
  }

  static createInterstitialAd() {
    _interstitialAd = InterstitialAd(
      adUnitId: Platform.isAndroid
          ? (isInDebugMode
              ? 'ca-app-pub-3940256099942544/1033173712'
              : 'ca-app-pub-0154172666410102/8415472998')
          : 'ca-app-pub-0154172666410102/2630994978',
      request: request,
      listener: listenerInters,
    )..load();
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
