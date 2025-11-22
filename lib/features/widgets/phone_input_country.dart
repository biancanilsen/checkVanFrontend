import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/theme.dart';
import '../../model/country_model.dart';
import '../../services/util_service.dart';

class PhoneInputWithCountry extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final ValueChanged<String> onCountryChanged; // Retorna o DDI (+55)
  final ValueChanged<String>? onCountryIsoChanged; // Retorna a Sigla (BR)
  final String? initialDialCode; // DDI inicial para pré-seleção

  const PhoneInputWithCountry({
    super.key,
    required this.controller,
    required this.onCountryChanged,
    this.label = 'Celular',
    this.isRequired = false,
    this.initialDialCode,
    this.onCountryIsoChanged,
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
      mask: '(##) #####-####', // Máscara genérica inicial
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    final countries = await UtilService.getCountries();

    if (!mounted) return;

    setState(() {
      _countries = countries;

      // Tenta encontrar o país pelo DDI inicial passado
      // Se não achar, tenta o Brasil (BR), se não achar, pega o primeiro da lista
      _selectedCountry = countries.firstWhere(
            (c) => c.dialCode == widget.initialDialCode,
        orElse: () => countries.firstWhere(
                (c) => c.code == 'BR',
            orElse: () => countries.first
        ),
      );

      _isLoading = false;

      // Aplica a máscara do país encontrado
      _updateMask();
    });

    // Notifica o pai sobre o país selecionado inicialmente
    if (_selectedCountry != null) {
      widget.onCountryChanged(_selectedCountry!.dialCode);
      if (widget.onCountryIsoChanged != null) {
        widget.onCountryIsoChanged!(_selectedCountry!.code);
      }
    }
  }

  void _updateMask() {
    if (_selectedCountry != null) {
      _maskFormatter.updateMask(mask: _selectedCountry!.mask);

      // CORREÇÃO PRINCIPAL:
      // Se o controller já tem texto (ex: veio do banco de dados na tela de perfil),
      // nós formatamos esse texto com a máscara do país selecionado.
      if (widget.controller.text.isNotEmpty) {
        // 1. Remove tudo que não for número para ter o dado limpo
        final unmasked = widget.controller.text.replaceAll(RegExp(r'[^0-9]'), '');

        // 2. Aplica a máscara
        final formatted = _maskFormatter.maskText(unmasked);

        // 3. Atualiza o controller visualmente
        widget.controller.text = formatted;
      }
    }
  }

  String? _validatePhone(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'Campo obrigatório';
    }

    if (value != null && value.isNotEmpty && _selectedCountry != null) {
      // Pega o texto sem a máscara para validar o tamanho
      final unmaskedText = _maskFormatter.getUnmaskedText();

      if (unmaskedText.length < _selectedCountry!.minLength) {
        return 'Número incompleto';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
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
                height: 48,
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
                            Expanded(
                              child: Text(
                                country.dialCode,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppPalette.neutral600,
                                    fontSize: 12
                                ),
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
                        // Notifica mudança de Sigla (ex: BR)
                        if (widget.onCountryIsoChanged != null) {
                          widget.onCountryIsoChanged!(newValue.code);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

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
                inputFormatters: [_maskFormatter],
                validator: _validatePhone,
                decoration: InputDecoration(
                  hintText: _selectedCountry?.mask ?? '(00) 00000-0000',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}