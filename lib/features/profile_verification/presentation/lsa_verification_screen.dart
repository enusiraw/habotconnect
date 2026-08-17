import 'package:flutter/material.dart';
import 'byts/compliance_header_byt.dart';
import 'byts/status_banner_byt.dart';
import 'byts/lsa_id_field_byt.dart';
import 'byts/parent_consent_field_byt.dart';
import 'byts/predecessor_id_field_byt.dart';
import 'byts/verify_submit_button_byt.dart';



class LsaVerificationScreen extends StatelessWidget {
  final String lsaId;
  final String parentConsentCode;
  final String predecessorId;
  final SystemStatus status;
  final String? statusMessage;
  final bool isLoading;
  final bool isButtonLocked;
  final ValueChanged<String> onLsaIdChanged;
  final ValueChanged<String> onParentConsentCodeChanged;
  final VoidCallback onParentConsentFocus;
  final VoidCallback onSubmit;

  const LsaVerificationScreen({
    super.key,
    required this.lsaId,
    required this.parentConsentCode,
    required this.predecessorId,
    required this.status,
    this.statusMessage,
    this.isLoading = false,
    this.isButtonLocked = false,
    required this.onLsaIdChanged,
    required this.onParentConsentCodeChanged,
    required this.onParentConsentFocus,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LSA Verification'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const ComplianceHeaderByt(),
              const SizedBox(height: 24),

              // Status Banner
              StatusBannerByt(
                status: status,
                customMessage: statusMessage,
              ),
              const SizedBox(height: 32),

              // Form Fields
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LsaIdFieldByt(
                        value: lsaId,
                        onChanged: onLsaIdChanged,
                        enabled: false, // Prefilled, not editable per specification
                      ),
                      const SizedBox(height: 20),
                      ParentConsentFieldByt(
                        value: parentConsentCode,
                        onChanged: onParentConsentCodeChanged,
                        onFocus: onParentConsentFocus,
                        enabled: status == SystemStatus.idle,
                      ),
                      const SizedBox(height: 20),
                      PredecessorIdFieldByt(
                        value: predecessorId,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              VerifySubmitButtonByt(
                onPressed: onSubmit,
                isLoading: isLoading,
                enabled: !isButtonLocked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
