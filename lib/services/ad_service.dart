import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static bool _isInitialized = false;
  static RewardedAd? _rewardedAd;
  static bool _isAdLoading = false;
  static bool _isAdReady = false;

  // Test Ad Unit IDs - Replace with your actual AdMob IDs in production
  static const String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
      : 'ca-app-pub-9870244315079084/6598222348'; // Your production ID

  // Initialize AdMob
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdMob initialized successfully');
    } catch (e) {
      print('Failed to initialize AdMob: $e');
      _isInitialized = false;
    }
  }

  // Load a rewarded ad
  static Future<bool> loadRewardedAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isAdLoading) return false;

    try {
      _isAdLoading = true;
      _isAdReady = false;

      // Dispose existing ad if any
      _rewardedAd?.dispose();

      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print('Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isAdLoading = false;
            _isAdReady = true;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('Rewarded ad closed');
                _isAdReady = false;
                ad.dispose();
              },
              onAdShowedFullScreenContent: (ad) {
                print('Rewarded ad opened');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Failed to show rewarded ad: $error');
                _isAdReady = false;
                ad.dispose();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: $error');
            _isAdLoading = false;
            _isAdReady = false;
            _rewardedAd?.dispose();
          },
        ),
      );

      return _isAdReady;
    } catch (e) {
      print('Error loading rewarded ad: $e');
      _isAdLoading = false;
      _isAdReady = false;
      return false;
    }
  }

  // Show rewarded ad
  static Future<bool> showRewardedAd() async {
    if (_rewardedAd == null || !_isAdReady) {
      print('No rewarded ad available');
      return false;
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      return true;
    } catch (e) {
      print('Error showing rewarded ad: $e');
      return false;
    }
  }

  // Check if ad is ready to show
  static bool get isAdReady => _isAdReady;

  // Check if ad is loading
  static bool get isAdLoading => _isAdLoading;

  // Check if AdMob is initialized
  static bool get isInitialized => _isInitialized;

  // Get ad loading status message
  static String getAdStatusMessage() {
    if (!_isInitialized) return 'Initializing ads...';
    if (_isAdLoading) return 'Loading ad...';
    if (_isAdReady) return 'Ad ready';
    return 'Ad not available';
  }

  // Dispose ad
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
  }
}
