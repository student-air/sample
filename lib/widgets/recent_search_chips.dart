import 'package:flutter/material.dart';
import '../utils/theme.dart';

class RecentSearchChips extends StatelessWidget {
  final List<String> cities;
  final ValueChanged<String> onSelected;

  const RecentSearchChips({
    super.key,
    required this.cities,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = cities[index];
          return GestureDetector(
            onTap: () => onSelected(city),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded, size: 13, color: AppColors.secondaryText),
                  const SizedBox(width: 5),
                  Text(
                    city,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
