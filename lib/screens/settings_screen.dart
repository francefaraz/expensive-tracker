import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'manage_templates_screen.dart';
import 'package:provider/provider.dart';
import '../utils/currency_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 28),
            decoration: BoxDecoration(
              color: AppColors.balance,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.balance.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: const [
                Icon(Icons.settings, color: Colors.white, size: 44),
                SizedBox(height: 10),
                Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 15)),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.background.withOpacity(0.97),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.balance.withOpacity(0.08)),
                  ),
                  shadowColor: AppColors.balance.withOpacity(0.10),
                  child: ListTile(
                    leading: const Icon(Icons.flash_on, color: AppColors.expense),
                    title: const Text('Manage Quick Add Templates', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageTemplatesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 15)),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.background.withOpacity(0.97),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.balance.withOpacity(0.08)),
                  ),
                  shadowColor: AppColors.balance.withOpacity(0.10),
                  child: ListTile(
                    leading: const Icon(Icons.currency_exchange, color: AppColors.balance),
                    title: const Text('Select Currency', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () async {
                      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
                      final currencies = [
                        '₹', '₹ INR', '₹ (INR)', 'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'RUB', 'KRW', 'AUD', 'CAD', 'SGD', 'HKD', 'ZAR', 'BRL', 'IDR', 'MYR', 'THB', 'VND', 'PHP', 'PKR', 'BDT', 'LKR', 'NPR', 'MMK', 'KWD', 'SAR', 'AED', 'QAR', 'OMR', 'BHD', 'TWD', 'TRY', 'ILS', 'MXN', 'PLN', 'SEK', 'CHF', 'DKK', 'NOK', 'CZK', 'HUF', 'NZD', 'ARS', 'CLP', 'COP', 'PEN', 'EGP', 'NGN', 'KES', 'GHS', 'TZS', 'UGX', 'MAD', 'DZD', 'TND', 'LBP', 'JOD', 'IQD', 'IRR', 'SDG', 'SOS', 'ETB', 'GEL', 'UAH', 'BYN', 'AZN', 'AMD', 'UZS', 'KZT', 'MNT', 'KHR', 'LAK', 'MMK', 'BND', 'PGK', 'FJD', 'WST', 'TOP', 'VUV', 'SBD', 'XPF', 'XOF', 'XAF', 'XCD', 'BSD', 'BBD', 'BZD', 'GYD', 'SRD', 'TTD', 'JMD', 'HTG', 'DOP', 'BMD', 'KYD', 'ANG', 'AWG', 'BAM', 'HRK', 'MKD', 'RSD', 'ALL', 'MDL', 'ISK', 'MOP', 'MVR', 'SCR', 'MUR', 'NAD', 'BWP', 'SZL', 'LSL', 'ZMW', 'MWK', 'MZN', 'AOA', 'CDF', 'GNF', 'SLL', 'LRD', 'GMD', 'XAG', 'XAU', 'XDR', 'BTC', 'ETH', 'USDT', 'USDC', 'BNB', 'XRP', 'ADA', 'SOL', 'DOGE', 'DOT', 'MATIC', 'SHIB', 'TRX', 'AVAX', 'DAI', 'ATOM', 'LINK', 'UNI', 'LTC', 'BCH', 'XLM', 'ETC', 'FIL', 'APE', 'EOS', 'XTZ', 'AAVE', 'MKR', 'SUSHI', 'COMP', 'YFI', 'SNX', 'CRV', '1INCH', 'BAT', 'ENJ', 'GRT', 'CHZ', 'SAND', 'MANA', 'AXS', 'ALGO', 'FLOW', 'QNT', 'EGLD', 'KSM', 'NEAR', 'FTM', 'RUNE', 'ZEC', 'DASH', 'XEM', 'ZEN', 'KNC', 'OMG', 'ZRX', 'LRC', 'NMR', 'OCEAN', 'BAL', 'BNT', 'REN', 'SRM', 'CVC', 'REP', 'ANT', 'MLN', 'RLC', 'FET', 'AKRO', 'BAND', 'LEND', 'KAVA', 'CREAM', 'SXP', 'TWT', 'COTI', 'RAY', 'PERP', 'ALPHA', 'LINA', 'INJ', 'BAKE', 'BURGER', 'SFP', 'BEL', 'CTK', 'DODO', 'FRONT', 'WING', 'LIT', 'UNFI', 'ACM', 'ATM', 'BAR', 'JUV', 'PSG', 'ASR', 'CITY', 'OG', 'NMR', 'FOR', 'VIDT', 'TRB', 'PNT', 'DIA', 'ORN', 'UTK', 'XVS', 'SUSD', 'BUSD', 'TUSD', 'PAX', 'HUSD', 'USDP', 'GUSD', 'LUSD', 'RSR', 'AMPL', 'FEI', 'FRAX', 'UST', 'MIM', 'SPELL', 'LUNA', 'USTC', 'ANC', 'MIR', 'ORCA', 'RAY', 'SBR', 'SLND', 'SUN', 'C98', 'PORT', 'SNY', 'STEP', 'ATLAS', 'POLIS', 'SAMO', 'COPE', 'ROPE', 'AURY', 'GENE', 'TULIP', 'SOLR', 'MEDIA', 'GRAPE', 'LIKE', 'PRISM', 'SOLA', 'STARS', 'RIN', 'SHDW', 'SLIM', 'SRLY', 'WOO', 'WMT', 'XCAD', 'XPRT', 'XDEFI', 'XMON', 'XNO', 'XSGD', 'XVS', 'YGG', 'ZIL', 'ZKS', 'ZRX', 'ZUSD', 'ZYN',
                      ];
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) {
                          return Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.7,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text('Select Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: currencies.length,
                                    itemBuilder: (context, i) {
                                      final c = currencies[i];
                                      final isSelected = c == currencyProvider.currency;
                                      return ListTile(
                                        title: Text(c, style: TextStyle(
                                          color: isSelected ? AppColors.balance : AppColors.textPrimary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        )),
                                        trailing: isSelected ? const Icon(Icons.check, color: AppColors.balance) : null,
                                        onTap: () => Navigator.pop(context, c),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                              ],
                            ),
                          );
                        },
                      );
                      if (selected != null && selected != currencyProvider.currency) {
                        currencyProvider.setCurrency(selected);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Currency set to $selected')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Add more settings options here
              ],
            ),
          ),
        ],
      ),
    );
  }
} 