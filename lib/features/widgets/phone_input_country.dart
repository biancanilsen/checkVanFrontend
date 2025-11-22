import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/theme.dart';
import '../../model/country_model.dart';
import '../../services/util_service.dart';

class PhoneInputWithCountry extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final ValueChanged<String> onCountryChanged;
  final String? initialDialCode;

  const PhoneInputWithCountry({
    super.key,
    required this.controller,
    required this.onCountryChanged,
    this.label = 'Celular',
    this.isRequired = false,
    this.initialDialCode,
  });

  @override
  State<PhoneInputWithCountry> createState() => _PhoneInputWithCountryState();
}

class _PhoneInputWithCountryState extends State<PhoneInputWithCountry> {
  List<CountryModel> _countries = [];
  CountryModel? _selectedCountry;
  bool _isLoading = true;
  late MaskTextInputFormatter _maskFormatter;

  @override
  void initState() {
    super.initState();
    _maskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    final countries = await UtilService.getCountries();
    if (mounted) {
      setState(() {
        _countries = countries;
        _selectedCountry = countries.firstWhere(
              (c) => c.dialCode == widget.initialDialCode,
          orElse: () => countries.firstWhere((c) => c.code == 'BR', orElse: () => countries.first),
        );
        _updateMask();
        _isLoading = false;
      });
      // Notifica o pai do DDI inicial
      if (_selectedCountry != null) {
        widget.onCountryChanged(_selectedCountry!.dialCode);
      }
    }
  }

  void _updateMask() {
    if (_selectedCountry != null) {
      _maskFormatter.updateMask(mask: _selectedCountry!.mask);

      if (widget.controller.text.isNotEmpty) {
        final unmasked = widget.controller.text.replaceAll(RegExp(r'[^0-9]'), '');
        final formatted = _maskFormatter.maskText(unmasked);
        widget.controller.text = formatted;
      }
    }
  }

  String? _validatePhone(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'Campo obrigatório';
    }

    if (value != null && _selectedCountry != null) {
      final unmaskedText = _maskFormatter.getUnmaskedText();

      if (unmaskedText.length < _selectedCountry!.minLength) {
        return 'Número incompleto';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LinearProgressIndicator());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110, // Largura um pouco maior para caber DDI
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DDI',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 48, // Altura ajustada para isDense
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppPalette.neutral75,
                  border: Border.all(color: AppPalette.primary100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CountryModel>(
                    value: _selectedCountry,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppPalette.neutral600),
                    items: _countries.map((CountryModel country) {
                      return DropdownMenuItem<CountryModel>(
                        value: country,
                        child: Row(
                          children: [
                            Text(
                              country.code,
                              style: const TextStyle(
                                  color: AppPalette.neutral900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              country.dialCode,
                              style: const TextStyle(
                                  color: AppPalette.neutral600,
                                  fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (CountryModel? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCountry = newValue;
                          _updateMask();
                        });
                        widget.onCountryChanged(newValue.dialCode);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // --- CAMPO DO NÚMERO ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(text: widget.label),
                    if (widget.isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: AppPalette.red700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.number,
                inputFormatters: [_maskFormatter], // Aplica a máscara
                validator: _validatePhone, // Aplica a validação de tamanho
                decoration: InputDecoration(
                  hintText: _selectedCountry?.mask ?? '(00) 00000-0000',
                  // Prefixo visual apenas estético dentro do input, se desejar
                  // prefixText: '${_selectedCountry?.dialCode} ',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}