import 'package:flutter/material.dart';

class PresenceOptions extends StatelessWidget {
  final String? selectedOption;
  final ValueChanged<String?> onChanged;

  const PresenceOptions({
    Key? key,
    required this.selectedOption,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ['Ida e volta', 'Somente Ida', 'Somente Volta', 'Não utilizará o transporte']
          .map(
            (option) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300, width: 1.0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedOption,
              onChanged: onChanged,
              activeColor: Colors.black87,
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}