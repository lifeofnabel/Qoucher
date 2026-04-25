import 'package:flutter/material.dart';

class ActivityListTile extends StatelessWidget {
  const ActivityListTile({
    super.key,
    required this.title,
    this.description,
    this.dateText,
    this.icon = Icons.history,
  });

  final String title;
  final String? description;
  final String? dateText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${description ?? ''}'
                '${dateText != null && dateText!.isNotEmpty ? '\n$dateText' : ''}',
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}