class CountryModel {
  final String name;
  final String code;
  final String dialCode;
  final String mask;
  final int minLength;

  CountryModel({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.mask,
    required this.minLength,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name'],
      code: json['code'],
      dialCode: json['dial_code'],
      mask: json['mask'],
      minLength: json['min_length'],
    );
  }
}