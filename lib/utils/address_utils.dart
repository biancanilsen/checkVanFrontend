import 'package:flutter/material.dart';

class AddressUtils {
  /// Preenche os controllers de rua e número a partir de um endereço completo.
  ///
  /// Tenta dividir a `fullAddress` em "Rua" e "Número" pela última vírgula.
  /// Se a parte após a vírgula não for um número, assume que é um endereço
  /// em formato antigo e coloca tudo no campo de rua.
  static void splitAddressForEditing({
    required String? fullAddress,
    required TextEditingController streetController,
    required TextEditingController numberController,
  }) {
    final String address = fullAddress ?? '';

    try {
      int lastCommaIndex = address.lastIndexOf(',');

      // Verifica se encontrou uma vírgula E se não é a primeira coisa (ex: ",123")
      if (lastCommaIndex > 0) {
        String potentialStreet = address.substring(0, lastCommaIndex).trim();
        String potentialNumber = address.substring(lastCommaIndex + 1).trim();

        // Verifica se a parte após a vírgula é um número
        if (int.tryParse(potentialNumber) != null) {
          // Formato novo: "Rua Exemplo, 123"
          streetController.text = potentialStreet;
          numberController.text = potentialNumber;
        } else {
          // Formato antigo: "Rua Exemplo - Bairro, Cidade"
          streetController.text = address;
          numberController.text = '';
        }
      } else {
        // Sem vírgula, coloque tudo na rua
        streetController.text = address;
        numberController.text = '';
      }
    } catch (e) {
      // Fallback para qualquer erro
      streetController.text = address;
      numberController.text = '';
    }
  }
}