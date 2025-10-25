import 'package:check_van_frontend/core/theme.dart';
import 'package:flutter/material.dart';

enum Period { morning, afternoon, night }

class PeriodSelector extends StatefulWidget {
  final ValueChanged<Period?> onPeriodSelected;
  final Period? initialPeriod;

  const PeriodSelector({
    super.key,
    required this.onPeriodSelected,
    this.initialPeriod = Period.morning,
  });

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  Period? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  String _periodToString(Period period) {
    switch (period) {
      case Period.morning:
        return 'Manhã';
      case Period.afternoon:
        return 'Tarde';
      case Period.night:
        return 'Noite';
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppPalette.neutral800,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: AppPalette.neutral300,
            border: Border.all(
              color: AppPalette.neutral300,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12),

            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: Period.values.map((period) {
              bool isSelected = _selectedPeriod == period;
              return Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                    widget.onPeriodSelected(_selectedPeriod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppPalette.primary800
                        : AppPalette.neutral300,
                    foregroundColor: isSelected
                        ? AppPalette.white
                        : AppPalette.neutral600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isSelected ? 0 : 0,
                    side: BorderSide.none,
                  ),
                  child: Text(
                    _periodToString(period),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}