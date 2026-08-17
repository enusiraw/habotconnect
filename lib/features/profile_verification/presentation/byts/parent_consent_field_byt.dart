import 'package:flutter/material.dart';

class ParentConsentFieldByt extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFocus;
  final bool enabled;

  const ParentConsentFieldByt({
    super.key,
    required this.value,
    required this.onChanged,
    this.onFocus,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && onFocus != null) {
          onFocus!();
        }
      },
      child: TextField(
        enabled: enabled,
        controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
        decoration: const InputDecoration(
          labelText: 'Parent Consent Code',
          hintText: 'Enter parent consent code',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.verified_user),
        ),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
