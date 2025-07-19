import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../service/consent_manager.dart';

/// App Open Ad Manager for showing ads when app is opened
class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static bool _isLoadingAd = false;
  static bool _isShowingAd = false;
  static DateTime? _appOpenLoadTime;
  static int _numAppOpenLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;
  static const Duration maxCacheDuration = Duration(hours: 4);

  // Ad Unit IDs for different platforms
  static final String _adUnitId = Platform.isAndroid
      ? kReleaseMode 
          ? 'ca-app-pub-8068332503400690/5678901234' // Replace with your Android App Open Ad Unit ID
          : 'ca-app-pub-3940256099942544/9257395921' // Test Ad Unit ID
      : kReleaseMode 
          ? 'ca-app-pub-8068332503400690/4321098765' // Replace with your iOS App Open Ad Unit ID
          : 'ca-app-pub-3940256099942544/5575463023'; // Test Ad Unit ID

  /// Load an app open ad
  static Future<void> loadAd() async {
    if (_isLoadingAd || isAdAvailable) return;

    try {
      final canRequestAds = await consentManager.canRequestAds();
      if (!canRequestAds) {
        debugPrint('Cannot request ads - consent not given');
        return;
      }

      _isLoadingAd = true;

      await AppOpenAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (AppOpenAd ad) {
            debugPrint('App open ad loaded');
            _appOpenAd = ad;
            _appOpenLoadTime = DateTime.now();
            _isLoadingAd = false;
            _numAppOpenLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('App open ad failed to load: $error');
            _isLoadingAd = false;
            _numAppOpenLoadAttempts += 1;
            
            if (_numAppOpenLoadAttempts < maxFailedLoadAttempts) {
              // Retry loading after a delay
              Future.delayed(const Duration(seconds: 10), () => loadAd());
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading app open ad: $e');
      _isLoadingAd = false;
    }
  }

  /// Check if ad is available and not expired
  static bool get isAdAvailable {
    return _appOpenAd != null && !_isAdExpired();
  }

  /// Check if the ad has expired
  static bool _isAdExpired() {
    if (_appOpenLoadTime == null) return true;
    
    return DateTime.now().difference(_appOpenLoadTime!) > maxCacheDuration;
  }

  /// Show the app open ad
  static Future<void> showAdIfAvailable({
    VoidCallback? onAdShown,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (!isAdAvailable || _isShowingAd) {
      debugPrint('App open ad not available or already showing');
      onAdFailed?.call();
      // Try to load a new ad for next time
      if (!_isLoadingAd) loadAd();
      return;
    }

    try {
      _isShowingAd = true;

      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (AppOpenAd ad) {
          debugPrint('App open ad showed');
          onAdShown?.call();
        },
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          debugPrint('App open ad dismissed');
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          onAdClosed?.call();
          // Load next ad for future use
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
          debugPrint('App open ad failed to show: $error');
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          onAdFailed?.call();
          // Load next ad for future use
          loadAd();
        },
      );

      await _appOpenAd?.show();
    } catch (e) {
      debugPrint('Error showing app open ad: $e');
      _isShowingAd = false;
      onAdFailed?.call();
    }
  }

  /// Dispose the current ad
  static void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isShowingAd = false;
    _isLoadingAd = false;
    _appOpenLoadTime = null;
  }

  /// Initialize app open ads (call this once in app startup)
  static Future<void> initialize() async {
    await loadAd();
  }

  /// Check if currently showing an ad
  static bool get isShowingAd => _isShowingAd;
}

/// App Lifecycle Manager for handling app open ads
class AppLifecycleAdManager extends WidgetsBindingObserver {
  static final AppLifecycleAdManager _instance = AppLifecycleAdManager._internal();
  factory AppLifecycleAdManager() => _instance;
  AppLifecycleAdManager._internal();

  static AppLifecycleAdManager get instance => _instance;

  bool _isInitialized = false;
  DateTime? _lastPauseTime;
  static const Duration minimumInterval = Duration(minutes: 5);

  /// Initialize the lifecycle manager
  void initialize() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    
    // Initialize app open ads
    AppOpenAdManager.initialize();
  }

  /// Dispose the lifecycle manager
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
    }
    AppOpenAdManager.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        _lastPauseTime = DateTime.now();
        debugPrint('App paused at: $_lastPauseTime');
        break;
        
      case AppLifecycleState.resumed:
        final now = DateTime.now();
        debugPrint('App resumed at: $now');
        
        if (_lastPauseTime != null) {
          final pauseDuration = now.difference(_lastPauseTime!);
          debugPrint('App was paused for: ${pauseDuration.inMinutes} minutes');
          
          // Show app open ad if app was paused for minimum interval
          if (pauseDuration >= minimumInterval && !AppOpenAdManager.isShowingAd) {
            _showAppOpenAd();
          }
        } else {
          // First time opening the app
          _showAppOpenAd();
        }
        break;
        
      case AppLifecycleState.detached:
        dispose();
        break;
        
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Do nothing for these states
        break;
    }
  }

  void _showAppOpenAd() {
    AppOpenAdManager.showAdIfAvailable(
      onAdShown: () {
        debugPrint('App open ad shown successfully');
      },
      onAdClosed: () {
        debugPrint('App open ad closed');
      },
      onAdFailed: () {
        debugPrint('App open ad failed to show');
      },
    );
  }
}

/// App Open Ad Widget for manual control
class AppOpenAdWidget extends StatefulWidget {
  final Widget child;
  final bool showOnInit;
  final VoidCallback? onAdShown;
  final VoidCallback? onAdClosed;
  final VoidCallback? onAdFailed;

  const AppOpenAdWidget({
    super.key,
    required this.child,
    this.showOnInit = false,
    this.onAdShown,
    this.onAdClosed,
    this.onAdFailed,
  });

  @override
  State<AppOpenAdWidget> createState() => _AppOpenAdWidgetState();
}

class _AppOpenAdWidgetState extends State<AppOpenAdWidget> {
  @override
  void initState() {
    super.initState();
    
    if (widget.showOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAppOpenAd();
      });
    }
  }

  void _showAppOpenAd() {
    AppOpenAdManager.showAdIfAvailable(
      onAdShown: widget.onAdShown,
      onAdClosed: widget.onAdClosed,
      onAdFailed: widget.onAdFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// App Open Ad Configuration
class AppOpenAdConfig {
  final bool enabled;
  final Duration minimumInterval;
  final Duration maxCacheDuration;
  final int maxFailedLoadAttempts;
  final bool showOnAppStart;
  final bool showOnAppResume;

  const AppOpenAdConfig({
    this.enabled = true,
    this.minimumInterval = const Duration(minutes: 5),
    this.maxCacheDuration = const Duration(hours: 4),
    this.maxFailedLoadAttempts = 3,
    this.showOnAppStart = true,
    this.showOnAppResume = true,
  });
}

/// Enhanced App Open Ad Manager with configuration
class ConfigurableAppOpenAdManager {
  static AppOpenAdConfig _config = const AppOpenAdConfig();
  static bool _isConfigured = false;

  /// Configure the app open ad manager
  static void configure(AppOpenAdConfig config) {
    _config = config;
    _isConfigured = true;
  }

  /// Initialize with configuration
  static Future<void> initializeWithConfig() async {
    if (!_isConfigured || !_config.enabled) {
      debugPrint('App open ads disabled or not configured');
      return;
    }

    await AppOpenAdManager.initialize();
    
    if (_config.showOnAppStart || _config.showOnAppResume) {
      AppLifecycleAdManager.instance.initialize();
    }
  }

  /// Show ad with configuration checks
  static Future<void> showAd({
    VoidCallback? onAdShown,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (!_config.enabled) {
      onAdFailed?.call();
      return;
    }

    await AppOpenAdManager.showAdIfAvailable(
      onAdShown: onAdShown,
      onAdClosed: onAdClosed,
      onAdFailed: onAdFailed,
    );
  }
}

/// Usage example:
/// 
/// ```dart
/// // Configure and initialize in main()
/// ConfigurableAppOpenAdManager.configure(
///   AppOpenAdConfig(
///     enabled: true,
///     minimumInterval: Duration(minutes: 3),
///     showOnAppStart: true,
///     showOnAppResume: true,
///   ),
/// );
/// await ConfigurableAppOpenAdManager.initializeWithConfig();
/// 
/// // Manual control
/// AppOpenAdWidget(
///   showOnInit: true,
///   onAdShown: () => print('App open ad shown'),
///   child: MyApp(),
/// )
/// 
/// // Show programmatically
/// await AppOpenAdManager.showAdIfAvailable(
///   onAdClosed: () => continueAppFlow(),
/// );
/// ```
