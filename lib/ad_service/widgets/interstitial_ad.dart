import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../service/consent_manager.dart';

/// Interstitial Ad Manager for full-screen ads
class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isLoaded = false;
  static bool _isLoading = false;
  static int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  // Ad Unit IDs for different platforms
  static final String _adUnitId = Platform.isAndroid
      ? kReleaseMode 
          ? 'ca-app-pub-8068332503400690/1234567890' // Replace with your Android Interstitial Ad Unit ID
          : 'ca-app-pub-3940256099942544/1033173712' // Test Ad Unit ID
      : kReleaseMode 
          ? 'ca-app-pub-8068332503400690/0987654321' // Replace with your iOS Interstitial Ad Unit ID
          : 'ca-app-pub-3940256099942544/4411468910'; // Test Ad Unit ID

  /// Load an interstitial ad
  static Future<void> loadAd() async {
    if (_isLoading || _isLoaded) return;

    try {
      final canRequestAds = await consentManager.canRequestAds();
      if (!canRequestAds) {
        debugPrint('Cannot request ads - consent not given');
        return;
      }

      _isLoading = true;

      await InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('Interstitial ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _isLoaded = true;
            _isLoading = false;
            _setFullScreenContentCallback();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Interstitial ad failed to load: $error');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            _isLoaded = false;
            _isLoading = false;
            
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              // Retry loading after a delay
              Future.delayed(const Duration(seconds: 5), () => loadAd());
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isLoading = false;
    }
  }

  /// Set full screen content callback
  static void _setFullScreenContentCallback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('Interstitial ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('Interstitial ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        _isLoaded = false;
        // Load next ad for future use
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('Interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        _isLoaded = false;
        // Load next ad for future use
        loadAd();
      },
    );
  }

  /// Show the interstitial ad
  static Future<void> showAd({
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (_interstitialAd == null || !_isLoaded) {
      debugPrint('Interstitial ad not ready');
      onAdFailed?.call();
      // Try to load ad for next time
      if (!_isLoading) loadAd();
      return;
    }

    try {
      // Update callback if needed
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          debugPrint('Interstitial ad showed');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('Interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          _isLoaded = false;
          onAdClosed?.call();
          // Load next ad
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('Failed to show interstitial ad: $error');
          ad.dispose();
          _interstitialAd = null;
          _isLoaded = false;
          onAdFailed?.call();
          // Load next ad
          loadAd();
        },
      );

      await _interstitialAd?.show();
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      onAdFailed?.call();
    }
  }

  /// Check if ad is ready to show
  static bool get isAdReady => _isLoaded && _interstitialAd != null;

  /// Dispose the current ad
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Initialize interstitial ads (call this once in app startup)
  static Future<void> initialize() async {
    await loadAd();
  }
}

/// Interstitial Ad Widget for easy integration
class InterstitialAdWidget extends StatefulWidget {
  final Widget child;
  final bool showOnInit;
  final VoidCallback? onAdClosed;
  final VoidCallback? onAdFailed;

  const InterstitialAdWidget({
    super.key,
    required this.child,
    this.showOnInit = false,
    this.onAdClosed,
    this.onAdFailed,
  });

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.showOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showInterstitialAd();
      });
    }
  }

  void showInterstitialAd() {
    InterstitialAdManager.showAd(
      onAdClosed: widget.onAdClosed,
      onAdFailed: widget.onAdFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Usage example:
/// 
/// ```dart
/// // Initialize in main()
/// await InterstitialAdManager.initialize();
/// 
/// // Show ad programmatically
/// await InterstitialAdManager.showAd(
///   onAdClosed: () => print('Ad closed'),
///   onAdFailed: () => print('Ad failed'),
/// );
/// 
/// // Or use widget wrapper
/// InterstitialAdWidget(
///   showOnInit: true,
///   onAdClosed: () => navigateToNextScreen(),
///   child: YourContentWidget(),
/// )
/// ```
