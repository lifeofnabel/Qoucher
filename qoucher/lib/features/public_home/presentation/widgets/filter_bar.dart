import 'package:flutter/material.dart';

class PublicFilterBar extends StatelessWidget {
  const PublicFilterBar({
    super.key,
    required this.searchController,
    required this.selectedArea,
    required this.areas,
    required this.onAreaChanged,
    required this.onApply,
  });

  final TextEditingController searchController;
  final String selectedArea;
  final List<String> areas;
  final ValueChanged<String?> onAreaChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Suchen...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (_) => onApply(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedArea,
                decoration: InputDecoration(
                  labelText: 'Ort',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: areas
                    .map(
                      (area) => DropdownMenuItem(
                    value: area,
                    child: Text(area.isEmpty ? 'Alle Orte' : area),
                  ),
                )
                    .toList(),
                onChanged: onAreaChanged,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: onApply,
                child: const Text('Filter'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}