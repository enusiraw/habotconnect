import 'package:flutter/material.dart';


class LsaIdFieldByt extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const LsaIdFieldByt({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
      decoration: const InputDecoration(
        labelText: 'LSA ID',
        hintText: 'Enter LSA ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.badge),
      ),
      onChanged: enabled ? onChanged : null,
    );
  }
}
