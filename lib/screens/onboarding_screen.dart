import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../utils/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onDone;
  const OnboardingScreen({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: AppColors.background,
      safeAreaList: [true, true, true, true], // Ensures controls are above system nav bar for all pages
      controlsPadding: const EdgeInsets.only(bottom: 24), // Extra space for nav bar
      pages: [
        PageViewModel(
          title: 'Welcome to Track My Money!',
          body: 'Easily track your expenses and income, manage your budget, and gain insights into your spending.',
          image: const Icon(Icons.account_balance_wallet, size: 120, color: AppColors.balance),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: 'Add Your Transactions',
          body: 'Tap the + button to quickly add expenses or income. Categorize and manage your money with ease.',
          image: const Icon(Icons.add_circle_outline, size: 120, color: AppColors.income),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: 'Visualize & Export',
          body: 'View reports, see trends, and export your data to CSV for free (by watching a short ad).',
          image: const Icon(Icons.bar_chart, size: 120, color: AppColors.expense),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: 'Ready to Take Control?',
          body: 'Let\'s get started!',
          image: const Icon(Icons.rocket_launch, size: 120, color: AppColors.balance),
          decoration: getPageDecoration(),
        ),
      ],
      onDone: onDone,
      onSkip: onDone,
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(color: AppColors.textPrimary)),
      next: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
      done: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.balance)),
      dotsDecorator: DotsDecorator(
        color: AppColors.textSecondary,
        activeColor: AppColors.balance,
        size: const Size(10, 10),
        activeSize: const Size(22, 10),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  PageDecoration getPageDecoration() => const PageDecoration(
    titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    bodyTextStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary),
    imagePadding: EdgeInsets.only(top: 32, bottom: 16),
    pageColor: AppColors.background,
  );
} 