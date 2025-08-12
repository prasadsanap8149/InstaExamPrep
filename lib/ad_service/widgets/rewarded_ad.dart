import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../service/consent_manager.dart';
import '../../helper/helper_functions.dart';

/// Rewarded Ad Manager for ads that give users rewards
class RewardedAdManager {
  static RewardedAd? _rewardedAd;
  static bool _isLoaded = false;
  static bool _isLoading = false;
  static int _numRewardedLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  // Ad Unit IDs for different platforms
  static final String _adUnitId = Platform.isAndroid
      ? kReleaseMode 
          ? 'ca-app-pub-8068332503400690/2345678901' // Replace with your Android Rewarded Ad Unit ID
          : 'ca-app-pub-3940256099942544/5224354917' // Test Ad Unit ID
      : kReleaseMode 
          ? 'ca-app-pub-8068332503400690/1098765432' // Replace with your iOS Rewarded Ad Unit ID
          : 'ca-app-pub-3940256099942544/1712485313'; // Test Ad Unit ID

  /// Load a rewarded ad
  static Future<void> loadAd() async {
    if (_isLoading || _isLoaded) return;

    try {
      final canRequestAds = await consentManager.canRequestAds();
      if (!canRequestAds) {
        debugPrint('Cannot request ads - consent not given');
        return;
      }

      _isLoading = true;

      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('Rewarded ad loaded');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            _isLoaded = true;
            _isLoading = false;
            _setFullScreenContentCallback();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Rewarded ad failed to load: $error');
            _numRewardedLoadAttempts += 1;
            _rewardedAd = null;
            _isLoaded = false;
            _isLoading = false;
            
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              // Retry loading after a delay
              Future.delayed(const Duration(seconds: 5), () => loadAd());
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      _isLoading = false;
    }
  }

  /// Set full screen content callback
  static void _setFullScreenContentCallback() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        // Load next ad for future use
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        // Load next ad for future use
        loadAd();
      },
    );
  }

  /// Show the rewarded ad with reward callback
  static Future<void> showAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (_rewardedAd == null || !_isLoaded) {
      debugPrint('Rewarded ad not ready');
      onAdFailed?.call();
      // Try to load ad for next time
      if (!_isLoading) loadAd();
      return;
    }

    try {
      // Update callback if needed
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          debugPrint('Rewarded ad showed');
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          debugPrint('Rewarded ad dismissed');
          ad.dispose();
          _rewardedAd = null;
          _isLoaded = false;
          onAdClosed?.call();
          // Load next ad
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          debugPrint('Failed to show rewarded ad: $error');
          ad.dispose();
          _rewardedAd = null;
          _isLoaded = false;
          onAdFailed?.call();
          // Load next ad
          loadAd();
        },
      );

      await _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward);
      });
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      onAdFailed?.call();
    }
  }

  /// Check if ad is ready to show
  static bool get isAdReady => _isLoaded && _rewardedAd != null;

  /// Dispose the current ad
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Initialize rewarded ads (call this once in app startup)
  static Future<void> initialize() async {
    await loadAd();
  }
}

/// Rewarded Ad Button Widget
class RewardedAdButton extends StatefulWidget {
  final String buttonText;
  final String rewardDescription;
  final Function(RewardItem reward) onRewardEarned;
  final VoidCallback? onAdFailed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enabled;

  const RewardedAdButton({
    super.key,
    this.buttonText = 'Watch Ad for Reward',
    this.rewardDescription = 'Watch a short video to earn rewards',
    required this.onRewardEarned,
    this.onAdFailed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.enabled = true,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reward description
        if (widget.rewardDescription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.rewardDescription,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        // Rewarded ad button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.enabled && !_isLoading && RewardedAdManager.isAdReady
                ? _showRewardedAd
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor ?? Colors.green,
              foregroundColor: widget.textColor ?? Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        RewardedAdManager.isAdReady
                            ? widget.buttonText
                            : 'Loading Ad...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        // Ad availability status
        if (!RewardedAdManager.isAdReady && !_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Ad not available right now. Please try again later.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  void _showRewardedAd() async {
    setState(() {
      _isLoading = true;
    });

    await RewardedAdManager.showAd(
      onUserEarnedReward: (RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        widget.onRewardEarned(reward);
        
        // Show success message
        if (mounted) {
          HelperFunctions.showSnackBarMessage(
            context: context,
            message: 'Reward earned: ${reward.amount} ${reward.type}',
            color: Colors.green,
          );
        }
      },
      onAdClosed: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onAdFailed: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          widget.onAdFailed?.call();
          
          HelperFunctions.showSnackBarMessage(
            context: context,
            message: 'Unable to show ad. Please try again later.',
            color: Colors.red,
          );
        }
      },
    );
  }
}

/// Reward types for different use cases
enum RewardType {
  coins,
  points,
  hints,
  extraTime,
  freeQuiz,
  premiumFeature,
}

/// Helper class for managing different types of rewards
class RewardManager {
  /// Process different types of rewards
  static void processReward(RewardItem reward, RewardType type) {
    final amount = reward.amount.toInt();
    
    switch (type) {
      case RewardType.coins:
        _addCoins(amount);
        break;
      case RewardType.points:
        _addPoints(amount);
        break;
      case RewardType.hints:
        _addHints(amount);
        break;
      case RewardType.extraTime:
        _addExtraTime(amount);
        break;
      case RewardType.freeQuiz:
        _unlockFreeQuiz();
        break;
      case RewardType.premiumFeature:
        _unlockPremiumFeature();
        break;
    }
  }

  static void _addCoins(int amount) {
    // Implement coin addition logic
    debugPrint('Added $amount coins');
  }

  static void _addPoints(int amount) {
    // Implement points addition logic
    debugPrint('Added $amount points');
  }

  static void _addHints(int amount) {
    // Implement hints addition logic
    debugPrint('Added $amount hints');
  }

  static void _addExtraTime(int minutes) {
    // Implement extra time addition logic
    debugPrint('Added $minutes minutes of extra time');
  }

  static void _unlockFreeQuiz() {
    // Implement free quiz unlock logic
    debugPrint('Unlocked free quiz');
  }

  static void _unlockPremiumFeature() {
    // Implement premium feature unlock logic
    debugPrint('Unlocked premium feature');
  }
}

/// Usage example:
/// 
/// ```dart
/// // Initialize in main()
/// await RewardedAdManager.initialize();
/// 
/// // Use the button widget
/// RewardedAdButton(
///   buttonText: 'Watch Ad for 50 Coins',
///   rewardDescription: 'Earn coins to unlock premium features',
///   onRewardEarned: (reward) {
///     RewardManager.processReward(reward, RewardType.coins);
///   },
///   onAdFailed: () {
///     print('Failed to show rewarded ad');
///   },
///   icon: Icon(Icons.play_circle_fill),
/// )
/// ```
