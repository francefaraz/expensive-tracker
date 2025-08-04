import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'utils/currency_provider.dart';
import 'screens/main_nav_screen.dart';
import 'utils/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'widgets/interstitial_ad_helper.dart';
import 'widgets/rewarded_ad_helper.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  InterstitialAdHelper.loadAd(); // Preload interstitial ad
  RewardedAdHelper.loadAd(); // Preload rewarded ad
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _showOnboarding;
  bool _ratePromptShown = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _maybeShowRatePrompt();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;
    setState(() {
      _showOnboarding = !seen;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  Future<void> _maybeShowRatePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRated = prefs.getBool('hasRated') ?? false;
    if (hasRated) return;
    final now = DateTime.now();
    final firstLaunchMillis = prefs.getInt('firstLaunchMillis');
    if (firstLaunchMillis == null) {
      await prefs.setInt('firstLaunchMillis', now.millisecondsSinceEpoch);
      return;
    }
    final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMillis);
    if (now.difference(firstLaunch).inDays >= 3 && !_ratePromptShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showRateDialog());
      _ratePromptShown = true;
    }
  }

  void _showRateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enjoying Track My Money?'),
        content: const Text('If you like the app, please take a moment to rate us on the Play Store!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourcompany.expensetracker'; // Replace with your real link
              await prefs.setBool('hasRated', true);
              Navigator.pop(context);
              await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    return ChangeNotifierProvider(
      create: (_) => CurrencyProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Track My Money',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
          useMaterial3: true,
        ),
        home: _showOnboarding!
            ? OnboardingScreen(onDone: _completeOnboarding)
            : const MainNavScreen(),
      ),
    );
  }
}
