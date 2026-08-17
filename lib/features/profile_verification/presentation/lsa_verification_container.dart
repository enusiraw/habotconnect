import 'package:flutter/material.dart';

import '../../../core/friction/friction_event.dart';
import '../../../core/friction/friction_tracker.dart';
import '../domain/errors.dart';
import '../domain/models.dart';
import '../domain/submission_controller.dart';
import 'byts/status_banner_byt.dart';
import 'lsa_verification_screen.dart';

// State container for the LSA verification screen

class LsaVerificationContainer extends StatefulWidget {
  const LsaVerificationContainer({super.key});

  @override
  State<LsaVerificationContainer> createState() =>
      _LsaVerificationContainerState();
}

class _LsaVerificationContainerState extends State<LsaVerificationContainer> {
  late final SubmissionController _submissionController;
  late final FrictionTracker _frictionTracker;

  // Form state (
  final String _lsaId = 'LSA-7049'; // Prefilled value
  String _parentConsentCode = ''; // User enters consent code
  final String _predecessorId = 'PRED-9982-XYZ'; // System value, read-only

  // UI state
  bool _isLoading = false;
  bool _isButtonLocked = false;
  SystemStatus _status = SystemStatus.idle;
  String? _statusMessage;
  final List<FrictionEvent> _frictionEvents = [];

  @override
  void initState() {
    super.initState();
    _submissionController = SubmissionController();
    _frictionTracker = FrictionTracker(
      onFrictionEvent: (event) {
        setState(() {
          _frictionEvents.add(event);
        });
      },
    );
  }

  @override
  void dispose() {
    _frictionTracker.dispose();
    super.dispose();
  }

  void _handleLsaIdChanged(String value) {
    // This handler is kept for consistency but does nothing
    _frictionTracker.recordInteraction('lsa_id');
    setState(() {
      _statusMessage = null;
    });
  }

  void _handleParentConsentCodeChanged(String value) {
    _frictionTracker.recordInteraction('parent_consent_code');
    setState(() {
      _parentConsentCode = value;
      _statusMessage = null;
    });
  }

  void _handleParentConsentFocus() {
    // Start friction tracking for parent_consent_code
    _frictionTracker.startTracking('parent_consent_code');
  }

  Future<void> _handleSubmit() async {
    if (_isLoading || _isButtonLocked) return;

    setState(() {
      _isLoading = true;
      _status = SystemStatus.processing;
      _statusMessage = null;
    });

    final request = LsaVerificationRequest(
      lsaId: _lsaId,
      parentConsentCode: _parentConsentCode,
      predecessorId: _predecessorId,
    );

    final result = await _submissionController.submit(request);

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _status = SystemStatus.success;
        _statusMessage = result.data?.message ?? 'LSA verification successful';
      } else {
        // Handle different error types
        if (result.error is LineageFailure) {
          _status = SystemStatus.quarantined;
          _statusMessage = 'Data Quarantined – Compliance Failure';
          _isButtonLocked = true;
        } else if (result.error is ServerFailure) {
          // Case 3: Null API response / HTTP 500
          _status = SystemStatus.quarantined;
          _statusMessage = 'Data Quarantined – Compliance Failure';
          _isButtonLocked = true;
          // Purge volatile memory (reset form state)
          _parentConsentCode = '';
        } else {
          _status = SystemStatus.quarantined;
          _statusMessage = result.error?.message ?? 'Submission failed';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LsaVerificationScreen(
      lsaId: _lsaId,
      parentConsentCode: _parentConsentCode,
      predecessorId: _predecessorId,
      status: _status,
      statusMessage: _statusMessage,
      isLoading: _isLoading,
      isButtonLocked: _isButtonLocked,
      onLsaIdChanged: _handleLsaIdChanged,
      onParentConsentCodeChanged: _handleParentConsentCodeChanged,
      onParentConsentFocus: _handleParentConsentFocus,
      onSubmit: _handleSubmit,
    );
  }
}
