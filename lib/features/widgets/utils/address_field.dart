import 'package:check_van_frontend/core/theme.dart';
import 'package:check_van_frontend/model/address_suggestion.dart';
import 'package:flutter/material.dart';

class AddressField extends StatelessWidget {
  final TextEditingController streetController;
  final TextEditingController numberController;
  final FocusNode addressFocusNode;
  final bool showSuggestions;
  final bool isAddressLoading;
  final List<AddressSuggestion> addressSuggestions;
  final Function(AddressSuggestion) onSuggestionSelected;
  final String? Function(String?) streetValidator;
  final String? Function(String?) numberValidator;

  const AddressField({
    super.key,
    required this.streetController,
    required this.numberController,
    required this.addressFocusNode,
    required this.showSuggestions,
    required this.isAddressLoading,
    required this.addressSuggestions,
    required this.onSuggestionSelected,
    required this.streetValidator,
    required this.numberValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.neutral900),
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
                controller: streetController,
                focusNode: addressFocusNode,
                decoration: const InputDecoration(hintText: 'Logradouro'),
                validator: streetValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: numberController,
                decoration: const InputDecoration(hintText: 'Nº'),
                keyboardType: TextInputType.number,
                validator: numberValidator,
              ),
            ),
          ],
        ),
        // Container que exibe as sugestões de endereço
        if (showSuggestions)
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 8)],
            ),
            child: isAddressLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: addressSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = addressSuggestions[index];
                return ListTile(
                  title: Text(suggestion.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(suggestion.addressDetails),
                  onTap: () => onSuggestionSelected(suggestion), // Chama o callback
                );
              },
            ),
          ),
      ],
    );
  }
}