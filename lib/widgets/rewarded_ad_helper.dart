import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdHelper {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;

  static void loadAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-6920519399704945/8422001568', // Real Rewarded Ad Unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  static void showAd({required void Function() onRewarded, void Function()? onAdClosed, void Function()? onAdFailed}) {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          loadAd();
          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          loadAd();
          if (onAdFailed != null) onAdFailed();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );
      _rewardedAd = null;
      _isAdLoaded = false;
    } else {
      if (onAdFailed != null) onAdFailed();
    }
  }
} 