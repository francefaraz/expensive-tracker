import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Ad Unit
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  static void showAd({void Function()? onAdClosed}) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          loadAd(); // Preload next ad
          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          loadAd();
          if (onAdClosed != null) onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      if (onAdClosed != null) onAdClosed();
    }
  }
} 