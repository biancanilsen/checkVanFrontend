import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../model/address_suggestion.dart';

class SchoolAddressSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController numberController;
  final FocusNode addressFocusNode;
  final bool showSuggestions;
  final bool isLoading;
  final List<AddressSuggestion> suggestions;
  final Function(AddressSuggestion) onSuggestionSelected;

  const SchoolAddressSection({
    super.key,
    required this.addressController,
    required this.numberController,
    required this.addressFocusNode,
    required this.showSuggestions,
    required this.isLoading,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppPalette.neutral900,
            ),
            children: [
              TextSpan(text: 'Endereço'),
              TextSpan(text: ' *', style: TextStyle(color: AppPalette.red500)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: addressController,
                focusNode: addressFocusNode,
                decoration: const InputDecoration(hintText: 'Digite para buscar o endereço'),
                validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: numberController,
                decoration: const InputDecoration(hintText: 'Nº'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        if (showSuggestions)
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : suggestions.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Nenhum endereço encontrado.')))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(suggestion.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(suggestion.addressDetails),
                  onTap: () => onSuggestionSelected(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}