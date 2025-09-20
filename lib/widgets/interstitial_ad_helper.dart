import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-6920519399704945/9735083231', // Real Interstitial Ad Unit ID
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

  static void showAd({void Function()? onAdClosed}) async {
    // Add minimum delay to comply with Google Play Store policies
    // This ensures ads don't show immediately after user actions
    await Future.delayed(const Duration(milliseconds: 1000));
    
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