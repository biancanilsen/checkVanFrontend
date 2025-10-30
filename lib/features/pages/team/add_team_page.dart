import 'dart:async';
import 'dart:math';
import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/address_suggestion.dart';
import '../../../provider/geocoding_provider.dart';
import '../../../provider/school_provider.dart';
import '../../../provider/team_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/team/period_selector.dart';

class AddTeamPage extends StatefulWidget {
  const AddTeamPage({super.key});

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final _formKey = GlobalKey<FormState>();

  // Campos existentes
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  // Novos campos
  final _addressController = TextEditingController();
  final _vanNameController = TextEditingController(); // nome da van (mapeado para plate)
  final _vanPlateController = TextEditingController(); // placa da van (mapeado para nickname)
  final _vanCapacityController = TextEditingController();

  // Estado/localizações
  Period? _selectedPeriod = Period.morning;
  bool _isGeneratingCode = false;

  // Escola
  int? _selectedSchoolId;

  // Endereço/autocomplete
  final _addressFocusNode = FocusNode();
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isAddressLoading = false;
  bool _showSuggestions = false;
  bool _isFetchingCoords = false;
  Timer? _debounce;

  // Coordenadas obtidas via geocoding
  double? _selectedLat;
  double? _selectedLon;

  @override
  void initState() {
    super.initState();
    // Carregar escolas após primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).getSchools();
    });

    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();

    _addressController.dispose();
    _vanNameController.dispose();
    _vanPlateController.dispose();
    _vanCapacityController.dispose();

    _addressFocusNode.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isGeneratingCode = true;
    });

    // TODO: Substituir por chamada real ao backend caso necessário
    await Future.delayed(const Duration(seconds: 1));
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    if (mounted) {
      setState(() {
        _codeController.text = code;
        _isGeneratingCode = false;
        _formKey.currentState?.validate();
      });
    }
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final pattern = _addressController.text.trim();
      if (pattern.length < 3) {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
            _addressSuggestions = [];
          });
        }
        return;
      }
      setState(() {
        _isAddressLoading = true;
        _showSuggestions = true;
      });

      try {
        final suggestions = await context.read<GeocodingProvider>().fetchSuggestions(pattern);
        if (mounted) {
          setState(() {
            _addressSuggestions = suggestions;
            _isAddressLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _addressSuggestions = [];
            _isAddressLoading = false;
          });
        }
      }
    });
  }

  void _onFocusChanged() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_addressFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  Future<void> _selectSuggestion(AddressSuggestion suggestion) async {
    // Preenche o campo e fecha as sugestões
    _addressController.removeListener(_onAddressChanged);
    setState(() {
      _addressController.text = suggestion.fullDescription;
      _showSuggestions = false;
      _isFetchingCoords = true;
      _selectedLat = null;
      _selectedLon = null;
    });
    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.unfocus();

    // Buscar coordenadas via provider
    try {
      final details = await context.read<GeocodingProvider>().getPlaceDetails(suggestion.placeId);
      if (mounted) {
        setState(() {
          _selectedLat = details['lat'];
          _selectedLon = details['lon'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter coordenadas do endereço.'),
          backgroundColor: AppPalette.red500,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingCoords = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a escola.'),
          backgroundColor: AppPalette.red500,
        ),
      );
      return;
    }

    if (_selectedLat == null || _selectedLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um endereço válido da lista para obter as coordenadas.'),
          backgroundColor: AppPalette.red500,
        ),
      );
      return;
    }

    final teamProvider = context.read<TeamProvider>();
    final success = await teamProvider.addTeam(
      name: _nameController.text.trim(),
      schoolId: _selectedSchoolId!,
      startingLat: _selectedLat!,
      startingLon: _selectedLon!,
      // Mapeamento solicitado:
      // plate = nome da van, nickname = placa da van
      plate: _vanNameController.text.trim(),
      nickname: _vanPlateController.text.trim(),
      capacity: int.tryParse(_vanCapacityController.text.trim()) ?? 0,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turma adicionada com sucesso!'),
          backgroundColor: AppPalette.green500,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(teamProvider.error ?? 'Erro ao adicionar turma.'),
          backgroundColor: AppPalette.red500,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;

    final schoolProvider = context.watch<SchoolProvider>();
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nova turma'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.primary900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nome da turma',
                hint: 'Ex: Turma da tarde',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome da turma é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Código Field Row (mantém, mas NÃO envia ao backend) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppPalette.neutral800,
                      ),
                      children: const [
                        TextSpan(text: 'Código'),
                        TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Clique em Gerar',
                            border: inputDecorationTheme.border ?? const OutlineInputBorder(),
                            enabledBorder: inputDecorationTheme.enabledBorder?.copyWith(
                              borderSide: const BorderSide(color: AppPalette.neutral200),
                            ),
                            focusedBorder: inputDecorationTheme.focusedBorder,
                            errorBorder: inputDecorationTheme.errorBorder,
                            focusedErrorBorder: inputDecorationTheme.focusedErrorBorder,
                            filled: true,
                            fillColor: AppPalette.neutral100,
                            hintStyle: inputDecorationTheme.hintStyle,
                            contentPadding: inputDecorationTheme.contentPadding,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Gere um código';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: ElevatedButton.icon(
                          icon: _isGeneratingCode
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppPalette.neutral800,
                                  ),
                                )
                              : const Icon(Icons.refresh, size: 20),
                          label: const Text('Gerar'),
                          onPressed: _isGeneratingCode ? null : _generateCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.neutral150,
                            foregroundColor: AppPalette.neutral800,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // --- End Código Field Row ---

              const SizedBox(height: 24),

              // Endereço com autocomplete (Google Maps via backend)
              _buildAddressField(),

              const SizedBox(height: 16),

              // Escola (select que chama o backend)
              _buildDropdownField<int>(
                label: 'Escola',
                hint: schoolProvider.isLoading ? 'Carregando...' : 'Selecione a escola',
                value: _selectedSchoolId,
                items: schoolProvider.schools
                    .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: schoolProvider.isLoading
                    ? null
                    : (value) => setState(() => _selectedSchoolId = value),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              // Campos da Van
              CustomTextField(
                controller: _vanNameController,
                label: 'Nome da van',
                hint: 'Ex: Van Escolar 01',
                isRequired: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _vanPlateController,
                label: 'Placa da van',
                hint: 'Ex: ABC1D23',
                isRequired: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _vanCapacityController,
                label: 'Capacidade da van',
                hint: 'Quantidade de passageiros',
                isRequired: true,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Informe um número válido';
                  return null;
                },
              ),

              if (_isFetchingCoords)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Buscando coordenadas...'),
                    ],
                  ),
                )
              else if (_selectedLat != null && _selectedLon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Coordenadas: lat ${_selectedLat!.toStringAsFixed(6)}, lon ${_selectedLon!.toStringAsFixed(6)}',
                    style: const TextStyle(color: AppPalette.neutral500, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 24),

              PeriodSelector(
                initialPeriod: _selectedPeriod,
                onPeriodSelected: (period) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: (teamProvider.isLoading || _isFetchingCoords) ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary800,
                  foregroundColor: AppPalette.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: teamProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Adicionar turma'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Campo de endereço com autocomplete e lista de sugestões
  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.neutral900),
            children: [
              TextSpan(text: 'Endereço de partida'),
              TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          decoration: const InputDecoration(hintText: 'Digite o endereço (use a lista de sugestões)'),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Obrigatório';
            if (_selectedLat == null || _selectedLon == null) {
              return 'Selecione um item da lista para confirmar o endereço';
            }
            return null;
          },
        ),
        if (_showSuggestions)
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 8)],
            ),
            child: _isAddressLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: _addressSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _addressSuggestions[index];
                      return ListTile(
                        title: Text(suggestion.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(suggestion.addressDetails),
                        onTap: () => _selectSuggestion(suggestion),
                      );
                    },
                  ),
          ),
      ],
    );
  }

  // Dropdown helper similar ao usado no cadastro de aluno
  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              TextSpan(text: label),
              const TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hint, style: Theme.of(context).inputDecorationTheme.hintStyle),
          decoration: const InputDecoration(),
          borderRadius: BorderRadius.circular(12.0),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
