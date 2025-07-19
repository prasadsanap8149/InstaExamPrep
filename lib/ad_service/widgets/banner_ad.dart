import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../service/consent_manager.dart';

/// An example app that loads a banner ad.
class GetBannerAd extends StatefulWidget {
  const GetBannerAd({super.key});

  @override
  GetBannerAdState createState() => GetBannerAdState();
}

class GetBannerAdState extends State<GetBannerAd> 
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  var _isMobileAdsInitializeCalled = false;
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;
  Orientation? _currentOrientation;

  final String _adUnitId = Platform.isAndroid
      ? kReleaseMode? 'ca-app-pub-8068332503400690/7539516965': 'ca-app-pub-3940256099942544/9214589741' //Android Ad Unit ID
      : kReleaseMode? '':'ca-app-pub-3940256099942544/9214589741'; //IOS Ad Unit ID

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAdService();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Pause ad loading when app goes to background
        break;
      case AppLifecycleState.resumed:
        // Resume ad loading when app comes back to foreground
        if (!_isDisposed && mounted && !_isLoaded) {
          _loadAd();
        }
        break;
      case AppLifecycleState.detached:
        _bannerAd?.dispose();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeAdService() async {
    try {
      consentManager.gatherConsent((consentGatheringError) {
        if (consentGatheringError != null) {
          // Consent not obtained in current session.
          debugPrint(
              "${consentGatheringError.errorCode}: ${consentGatheringError.message}");
        }
        // Attempt to initialize the Mobile Ads SDK.
        _initializeMobileAdsSDK();
      });

      // This sample attempts to load ads using consent obtained in the previous session.
      _initializeMobileAdsSDK();
    } catch (e) {
      debugPrint('Error initializing ad service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation != orientation && !_isDisposed) {
          _isLoaded = false;
          _loadAd();
          _currentOrientation = orientation;
        }
        return Stack(
          children: [
            if (_bannerAd != null && _isLoaded && !_isDisposed)
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  /// Loads and shows a banner ad.
  ///
  /// Dimensions of the ad are determined by the width of the screen.
  void _loadAd() async {
    // Only load an ad if the Mobile Ads SDK has gathered consent aligned with
    // the app's configured messages.
    var canRequestAds = await consentManager.canRequestAds();
    if (!canRequestAds) {
      return;
    }

    if (!mounted) {
      return;
    }

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      // Unable to get width of anchored banner.
      return;
    }

    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  /// Initialize the Mobile Ads SDK if the SDK has gathered consent aligned with
  /// the app's configured messages.
  void _initializeMobileAdsSDK() async {
    if (_isMobileAdsInitializeCalled) {
      return;
    }

    if (await consentManager.canRequestAds()) {
      _isMobileAdsInitializeCalled = true;

      // Initialize the Mobile Ads SDK.
      MobileAds.instance.initialize();

      // Load an ad.
      _loadAd();
    }
  }
}
