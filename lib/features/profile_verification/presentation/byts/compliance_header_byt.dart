import 'package:flutter/material.dart';


class ComplianceHeaderByt extends StatelessWidget {
  const ComplianceHeaderByt({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LSA Onboarding Gate',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'HabotConnect Data Compliance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
