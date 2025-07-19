import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'widgets/banner_ad.dart';
import 'widgets/interstitial_ad.dart';
import 'widgets/rewarded_ad.dart';
import 'widgets/native_ad.dart' as native;
import 'widgets/app_open_ad.dart';
import 'service/consent_manager.dart';
import '../helper/helper_functions.dart';

/// Comprehensive Ad Manager for all ad types
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  static AdManager get instance => _instance;

  bool _isInitialized = false;
  AdConfig? _config;
  Timer? _adRefreshTimer;

  /// Initialize the ad manager
  static Future<void> initialize({AdConfig? config}) async {
    if (instance._isInitialized) return;

    try {
      // Initialize Mobile Ads SDK
      await MobileAds.instance.initialize();
      debugPrint('Mobile Ads SDK initialized');

      // Set configuration
      instance._config = config ?? const AdConfig();

      // Initialize consent manager
      await _initializeConsent();

      // Initialize individual ad managers
      await _initializeAdManagers();

      // Start ad refresh timer if configured
      if (instance._config!.enableAdRefresh) {
        instance._startAdRefreshTimer();
      }

      instance._isInitialized = true;
      debugPrint('Ad Manager initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Ad Manager: $e');
    }
  }

  /// Initialize consent management
  static Future<void> _initializeConsent() async {
    try {
      final completer = Completer<void>();
      
      consentManager.gatherConsent((consentGatheringError) {
        if (consentGatheringError != null) {
          debugPrint('Consent gathering error: ${consentGatheringError.message}');
        } else {
          debugPrint('Consent gathered successfully');
        }
        completer.complete();
      });

      await completer.future;
    } catch (e) {
      debugPrint('Error initializing consent: $e');
    }
  }

  /// Initialize individual ad managers
  static Future<void> _initializeAdManagers() async {
    final config = instance._config!;

    // Initialize based on configuration
    final futures = <Future>[];

    if (config.enableInterstitialAds) {
      futures.add(InterstitialAdManager.initialize());
    }

    if (config.enableRewardedAds) {
      futures.add(RewardedAdManager.initialize());
    }

    if (config.enableNativeAds) {
      futures.add(native.NativeAdManager.initialize());
    }

    if (config.enableAppOpenAds) {
      futures.add(AppOpenAdManager.initialize());
    }

    await Future.wait(futures);
  }

  /// Start ad refresh timer
  void _startAdRefreshTimer() {
    _adRefreshTimer?.cancel();
    _adRefreshTimer = Timer.periodic(_config!.adRefreshInterval, (timer) {
      _refreshAds();
    });
  }

  /// Refresh ads periodically
  void _refreshAds() {
    debugPrint('Refreshing ads...');
    
    if (_config!.enableInterstitialAds && !InterstitialAdManager.isAdReady) {
      InterstitialAdManager.loadAd();
    }

    if (_config!.enableRewardedAds && !RewardedAdManager.isAdReady) {
      RewardedAdManager.loadAd();
    }
  }

  /// Show interstitial ad with context awareness
  static Future<void> showInterstitialAd({
    required BuildContext context,
    String? placement,
    VoidCallback? onAdShown,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (!instance._isInitialized || !instance._config!.enableInterstitialAds) {
      onAdFailed?.call();
      return;
    }

    // Check placement frequency
    if (placement != null && !instance._shouldShowAd(placement)) {
      onAdFailed?.call();
      return;
    }

    await InterstitialAdManager.showAd(
      onAdClosed: () {
        if (placement != null) {
          instance._recordAdShown(placement);
        }
        onAdClosed?.call();
      },
      onAdFailed: onAdFailed,
    );
  }

  /// Show rewarded ad with reward handling
  static Future<void> showRewardedAd({
    required BuildContext context,
    required Function(RewardItem reward) onRewardEarned,
    String? placement,
    VoidCallback? onAdShown,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (!instance._isInitialized || !instance._config!.enableRewardedAds) {
      onAdFailed?.call();
      return;
    }

    if (!RewardedAdManager.isAdReady) {
      HelperFunctions.showSnackBarMessage(
        context: context,
        message: 'Rewarded ad not available. Please try again later.',
        color: Colors.orange,
      );
      onAdFailed?.call();
      return;
    }

    await RewardedAdManager.showAd(
      onUserEarnedReward: (reward) {
        if (placement != null) {
          instance._recordAdShown(placement);
        }
        onRewardEarned(reward);
      },
      onAdClosed: onAdClosed,
      onAdFailed: onAdFailed,
    );
  }

  /// Show app open ad
  static Future<void> showAppOpenAd({
    VoidCallback? onAdShown,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (!instance._isInitialized || !instance._config!.enableAppOpenAds) {
      onAdFailed?.call();
      return;
    }

    await AppOpenAdManager.showAdIfAvailable(
      onAdShown: onAdShown,
      onAdClosed: onAdClosed,
      onAdFailed: onAdFailed,
    );
  }

  /// Check if should show ad based on frequency
  bool _shouldShowAd(String placement) {
    // Implement frequency capping logic here
    // This is a simplified example
    return true;
  }

  /// Record that an ad was shown
  void _recordAdShown(String placement) {
    // Implement ad tracking logic here
    debugPrint('Ad shown for placement: $placement');
  }

  /// Get banner ad widget
  static Widget getBannerAdWidget() {
    if (!instance._isInitialized || !instance._config!.enableBannerAds) {
      return const SizedBox.shrink();
    }
    return const GetBannerAd();
  }

  /// Get native ad widget
  static Widget getNativeAdWidget({
    double? height,
    native.TemplateType templateType = native.TemplateType.medium,
    EdgeInsetsGeometry? margin,
  }) {
    if (!instance._isInitialized || !instance._config!.enableNativeAds) {
      return const SizedBox.shrink();
    }

    return native.NativeAdWidget(
      height: height,
      templateType: templateType,
      margin: margin,
    );
  }

  /// Dispose all ads and cleanup
  static void dispose() {
    instance._adRefreshTimer?.cancel();
    
    InterstitialAdManager.dispose();
    RewardedAdManager.dispose();
    native.NativeAdManager.dispose();
    AppOpenAdManager.dispose();

    instance._isInitialized = false;
    debugPrint('Ad Manager disposed');
  }

  /// Check if ads are ready
  static bool get isInterstitialReady => InterstitialAdManager.isAdReady;
  static bool get isRewardedReady => RewardedAdManager.isAdReady;
  static bool get isAppOpenReady => AppOpenAdManager.isAdAvailable;

  /// Get ad status
  static AdStatus getAdStatus() {
    return AdStatus(
      isInitialized: instance._isInitialized,
      interstitialReady: isInterstitialReady,
      rewardedReady: isRewardedReady,
      appOpenReady: isAppOpenReady,
      bannerEnabled: instance._config?.enableBannerAds ?? false,
      nativeEnabled: instance._config?.enableNativeAds ?? false,
    );
  }
}

/// Ad configuration class
class AdConfig {
  final bool enableBannerAds;
  final bool enableInterstitialAds;
  final bool enableRewardedAds;
  final bool enableNativeAds;
  final bool enableAppOpenAds;
  final bool enableAdRefresh;
  final Duration adRefreshInterval;
  final bool enableTestAds;
  final Map<String, int> adFrequency;

  const AdConfig({
    this.enableBannerAds = true,
    this.enableInterstitialAds = true,
    this.enableRewardedAds = true,
    this.enableNativeAds = true,
    this.enableAppOpenAds = true,
    this.enableAdRefresh = true,
    this.adRefreshInterval = const Duration(minutes: 5),
    this.enableTestAds = kDebugMode,
    this.adFrequency = const {
      'quiz_complete': 1, // Show ad after every quiz
      'question_form': 3, // Show ad after every 3 question submissions
      'profile_update': 2, // Show ad after every 2 profile updates
    },
  });
}

/// Ad status information
class AdStatus {
  final bool isInitialized;
  final bool interstitialReady;
  final bool rewardedReady;
  final bool appOpenReady;
  final bool bannerEnabled;
  final bool nativeEnabled;

  const AdStatus({
    required this.isInitialized,
    required this.interstitialReady,
    required this.rewardedReady,
    required this.appOpenReady,
    required this.bannerEnabled,
    required this.nativeEnabled,
  });

  @override
  String toString() {
    return 'AdStatus(initialized: $isInitialized, interstitial: $interstitialReady, '
        'rewarded: $rewardedReady, appOpen: $appOpenReady, '
        'banner: $bannerEnabled, native: $nativeEnabled)';
  }
}

/// Ad placement helper
class AdPlacement {
  static const String quizComplete = 'quiz_complete';
  static const String questionSubmit = 'question_submit';
  static const String profileUpdate = 'profile_update';
  static const String appLaunch = 'app_launch';
  static const String levelComplete = 'level_complete';
  static const String rewardRequest = 'reward_request';
  static const String beforeQuiz = 'before_quiz';
  static const String afterQuiz = 'after_quiz';
}

/// Ad Helper Widget for easy integration
class AdHelper extends StatelessWidget {
  final Widget child;
  final String? bannerPlacement;
  final String? nativePlacement;
  final bool showBanner;
  final bool showNative;
  final double? nativeAdHeight;

  const AdHelper({
    super.key,
    required this.child,
    this.bannerPlacement,
    this.nativePlacement,
    this.showBanner = false,
    this.showNative = false,
    this.nativeAdHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBanner) AdManager.getBannerAdWidget(),
        Expanded(child: child),
        if (showNative)
          AdManager.getNativeAdWidget(
            height: nativeAdHeight,
            margin: const EdgeInsets.all(8),
          ),
      ],
    );
  }
}

/// Usage example:
/// 
/// ```dart
/// // Initialize in main()
/// await AdManager.initialize(
///   config: AdConfig(
///     enableBannerAds: true,
///     enableInterstitialAds: true,
///     enableRewardedAds: true,
///     enableNativeAds: true,
///     enableAppOpenAds: true,
///   ),
/// );
/// 
/// // Show interstitial ad
/// await AdManager.showInterstitialAd(
///   context: context,
///   placement: AdPlacement.quizComplete,
///   onAdClosed: () => navigateToNextScreen(),
/// );
/// 
/// // Show rewarded ad
/// await AdManager.showRewardedAd(
///   context: context,
///   placement: AdPlacement.rewardRequest,
///   onRewardEarned: (reward) => addCoins(reward.amount),
/// );
/// 
/// // Use ad helper widget
/// AdHelper(
///   showBanner: true,
///   showNative: true,
///   nativeAdHeight: 250,
///   child: YourContentWidget(),
/// )
/// ```
