import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../service/consent_manager.dart';

/// Native Ad Widget for seamless integration with app content
class NativeAdWidget extends StatefulWidget {
  final double? height;
  final TemplateType templateType;
  final Color? backgroundColor;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? customActionText;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const NativeAdWidget({
    super.key,
    this.height,
    this.templateType = TemplateType.medium,
    this.backgroundColor,
    this.primaryColor,
    this.secondaryColor,
    this.customActionText,
    this.margin,
    this.padding,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> 
    with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isDisposed = false;

  // Ad Unit IDs for different platforms
  final String _adUnitId = Platform.isAndroid
      ? kReleaseMode 
          ? 'ca-app-pub-8068332503400690/3456789012' // Replace with your Android Native Ad Unit ID
          : 'ca-app-pub-3940256099942544/2247696110' // Test Ad Unit ID
      : kReleaseMode 
          ? 'ca-app-pub-8068332503400690/2109876543' // Replace with your iOS Native Ad Unit ID
          : 'ca-app-pub-3940256099942544/3986624511'; // Test Ad Unit ID

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (_isDisposed) return;

    try {
      final canRequestAds = await consentManager.canRequestAds();
      if (!canRequestAds) {
        debugPrint('Cannot request ads - consent not given');
        return;
      }

      // Load the native ad
      _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        factoryId: 'listTile', // This should match your native ad factory ID
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('Native ad loaded');
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Native ad failed to load: $error');
            ad.dispose();
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoaded = false;
              });
            }
          },
          onAdOpened: (ad) {
            debugPrint('Native ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('Native ad closed');
          },
          onAdImpression: (ad) {
            debugPrint('Native ad impression recorded');
          },
          onAdClicked: (ad) {
            debugPrint('Native ad clicked');
          },
        ),
      );

      await _nativeAd?.load();
    } catch (e) {
      debugPrint('Error loading native ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (!_isLoaded || _nativeAd == null) {
      return _buildPlaceholder();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: widget.padding ?? EdgeInsets.zero,
      height: widget.height ?? _getTemplateHeight(),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: widget.padding ?? EdgeInsets.zero,
      height: widget.height ?? _getTemplateHeight(),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  double _getTemplateHeight() {
    switch (widget.templateType) {
      case TemplateType.small:
        return 80;
      case TemplateType.medium:
        return 300;
    }
  }
}

/// Custom Native Ad Builder for more control
class CustomNativeAdWidget extends StatefulWidget {
  final double? height;
  final Widget Function(NativeAd ad)? adBuilder;
  final Widget? placeholder;
  final EdgeInsetsGeometry? margin;

  const CustomNativeAdWidget({
    super.key,
    this.height = 300,
    this.adBuilder,
    this.placeholder,
    this.margin,
  });

  @override
  State<CustomNativeAdWidget> createState() => _CustomNativeAdWidgetState();
}

class _CustomNativeAdWidgetState extends State<CustomNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isDisposed = false;

  final String _adUnitId = Platform.isAndroid
      ? kReleaseMode 
          ? 'ca-app-pub-8068332503400690/4567890123' // Replace with your Android Native Ad Unit ID
          : 'ca-app-pub-3940256099942544/2247696110' // Test Ad Unit ID
      : kReleaseMode 
          ? 'ca-app-pub-8068332503400690/3210987654' // Replace with your iOS Native Ad Unit ID
          : 'ca-app-pub-3940256099942544/3986624511'; // Test Ad Unit ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (_isDisposed) return;

    try {
      final canRequestAds = await consentManager.canRequestAds();
      if (!canRequestAds) return;

      _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        factoryId: 'customNative',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (!_isDisposed && mounted) {
              setState(() => _isLoaded = true);
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Custom native ad failed to load: $error');
            ad.dispose();
          },
        ),
      );

      await _nativeAd?.load();
    } catch (e) {
      debugPrint('Error loading custom native ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    return Container(
      margin: widget.margin,
      height: widget.height,
      child: widget.adBuilder?.call(_nativeAd!) ?? AdWidget(ad: _nativeAd!),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      margin: widget.margin,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Loading Ad...',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

/// Native Ad Manager for global ad management
class NativeAdManager {
  static final List<NativeAd> _loadedAds = [];
  static bool _isInitialized = false;

  /// Initialize native ad manager
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Preload some native ads for better performance
    await _preloadAds(3);
  }

  /// Preload native ads
  static Future<void> _preloadAds(int count) async {
    try {
      final canRequestAds = await consentManager.canRequestAds();
      if (!canRequestAds) return;

      for (int i = 0; i < count; i++) {
        final ad = NativeAd(
          adUnitId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/2247696110'
              : 'ca-app-pub-3940256099942544/3986624511',
          request: const AdRequest(),
          factoryId: 'listTile',
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              _loadedAds.add(ad as NativeAd);
              debugPrint('Preloaded native ad ${_loadedAds.length}');
            },
            onAdFailedToLoad: (ad, error) {
              debugPrint('Failed to preload native ad: $error');
              ad.dispose();
            },
          ),
        );
        
        await ad.load();
      }
    } catch (e) {
      debugPrint('Error preloading native ads: $e');
    }
  }

  /// Get a preloaded ad
  static NativeAd? getPreloadedAd() {
    if (_loadedAds.isNotEmpty) {
      return _loadedAds.removeAt(0);
    }
    return null;
  }

  /// Dispose all ads
  static void dispose() {
    for (final ad in _loadedAds) {
      ad.dispose();
    }
    _loadedAds.clear();
    _isInitialized = false;
  }
}

/// List Item with Native Ad Widget
class ListWithNativeAds extends StatelessWidget {
  final List<Widget> items;
  final int adFrequency;
  final double? nativeAdHeight;
  final TemplateType templateType;

  const ListWithNativeAds({
    super.key,
    required this.items,
    this.adFrequency = 5,
    this.nativeAdHeight,
    this.templateType = TemplateType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final itemsWithAds = <Widget>[];
    
    for (int i = 0; i < items.length; i++) {
      itemsWithAds.add(items[i]);
      
      // Insert ad after every adFrequency items
      if ((i + 1) % adFrequency == 0 && i != items.length - 1) {
        itemsWithAds.add(
          NativeAdWidget(
            height: nativeAdHeight,
            templateType: templateType,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      }
    }
    
    return ListView.builder(
      itemCount: itemsWithAds.length,
      itemBuilder: (context, index) => itemsWithAds[index],
    );
  }
}

/// Template types for native ads
enum TemplateType {
  small,
  medium,
}

/// Usage example:
/// 
/// ```dart
/// // Initialize in main()
/// await NativeAdManager.initialize();
/// 
/// // Use simple native ad widget
/// NativeAdWidget(
///   height: 300,
///   templateType: TemplateType.medium,
///   backgroundColor: Colors.white,
/// )
/// 
/// // Use in a list
/// ListWithNativeAds(
///   items: yourListItems,
///   adFrequency: 5, // Show ad every 5 items
///   nativeAdHeight: 250,
/// )
/// 
/// // Custom native ad
/// CustomNativeAdWidget(
///   height: 200,
///   adBuilder: (ad) => CustomAdLayout(ad: ad),
///   placeholder: YourCustomPlaceholder(),
/// )
/// ```
