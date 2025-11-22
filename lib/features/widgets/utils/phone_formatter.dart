import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../services/util_service.dart';

class PhoneFormatter {
  static Future<String> format(String? phoneNumber, String? countryCode) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return 'Não informado';

    if (countryCode == null) return phoneNumber;

    try {
      final countries = await UtilService.getCountries();

      final country = countries.firstWhere(
            (c) => c.code == countryCode,
        orElse: () => countries.first,
      );

      String cleanNumber = phoneNumber;
      if (cleanNumber.startsWith(country.dialCode)) {
        cleanNumber = cleanNumber.substring(country.dialCode.length);
      } else if (cleanNumber.startsWith('+')) {
        return phoneNumber;
      }

      var maskFormatter = MaskTextInputFormatter(
          mask: country.mask,
          filter: { "#": RegExp(r'[0-9]') }
      );

      return maskFormatter.maskText(cleanNumber);

    } catch (e) {
      return phoneNumber;
    }
  }
}