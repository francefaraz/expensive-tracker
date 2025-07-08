import 'package:intl/intl.dart';

const Map<String, Map<String, String>> currencyMap = {
  'USD': {'symbol': ' 24', 'locale': 'en_US'},
  'INR': {'symbol': '₹', 'locale': 'en_IN'},
  'SAR': {'symbol': '﷼', 'locale': 'ar_SA'},
  'EUR': {'symbol': '€', 'locale': 'en_IE'},
  'GBP': {'symbol': '£', 'locale': 'en_GB'},
  'JPY': {'symbol': '¥', 'locale': 'ja_JP'},
  'CNY': {'symbol': '¥', 'locale': 'zh_CN'},
  'RUB': {'symbol': '₽', 'locale': 'ru_RU'},
  'KRW': {'symbol': '₩', 'locale': 'ko_KR'},
  'AUD': {'symbol': ' 24', 'locale': 'en_AU'},
  'CAD': {'symbol': ' 24', 'locale': 'en_CA'},
  'SGD': {'symbol': ' 24', 'locale': 'en_SG'},
  'HKD': {'symbol': ' 24', 'locale': 'zh_HK'},
  'ZAR': {'symbol': 'R', 'locale': 'en_ZA'},
  'BRL': {'symbol': 'R 24', 'locale': 'pt_BR'},
  'IDR': {'symbol': 'Rp', 'locale': 'id_ID'},
  'MYR': {'symbol': 'RM', 'locale': 'ms_MY'},
  'THB': {'symbol': '฿', 'locale': 'th_TH'},
  'VND': {'symbol': '₫', 'locale': 'vi_VN'},
  'PKR': {'symbol': '₨', 'locale': 'ur_PK'},
  'BDT': {'symbol': '৳', 'locale': 'bn_BD'},
  'LKR': {'symbol': '₨', 'locale': 'si_LK'},
  'NPR': {'symbol': '₨', 'locale': 'ne_NP'},
  'KWD': {'symbol': 'د.ك', 'locale': 'ar_KW'},
  'AED': {'symbol': 'د.إ', 'locale': 'ar_AE'},
  'QAR': {'symbol': 'ر.ق', 'locale': 'ar_QA'},
  'OMR': {'symbol': 'ر.ع.', 'locale': 'ar_OM'},
  'BHD': {'symbol': 'ب.د', 'locale': 'ar_BH'},
  // Add more as needed
};

String formatCurrency(double amount, String currency) {
  final info = currencyMap[currency] ?? {'symbol': currency, 'locale': 'en_US'};
  final format = NumberFormat.currency(
    locale: info['locale']!,
    symbol: info['symbol']!,
  );
  return format.format(amount);
}
