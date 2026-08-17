import 'package:flutter/material.dart';

//ystem states for the status banner
enum SystemStatus {
  idle,
  processing,
  quarantined,
  success,
}


class StatusBannerByt extends StatelessWidget {
  final SystemStatus status;
  final String? customMessage;

  const StatusBannerByt({
    super.key,
    required this.status,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                ),
                if (customMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    customMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getTextColor(),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case SystemStatus.idle:
        return Colors.grey[100]!;
      case SystemStatus.processing:
        return Colors.blue[50]!;
      case SystemStatus.quarantined:
        return Colors.red[50]!;
      case SystemStatus.success:
        return Colors.green[50]!;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case SystemStatus.idle:
        return Colors.grey[300]!;
      case SystemStatus.processing:
        return Colors.blue[300]!;
      case SystemStatus.quarantined:
        return Colors.red[300]!;
      case SystemStatus.success:
        return Colors.green[300]!;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case SystemStatus.idle:
        return Icons.info_outline;
      case SystemStatus.processing:
        return Icons.hourglass_empty;
      case SystemStatus.quarantined:
        return Icons.block;
      case SystemStatus.success:
        return Icons.check_circle;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case SystemStatus.idle:
        return Colors.grey[600]!;
      case SystemStatus.processing:
        return Colors.blue[600]!;
      case SystemStatus.quarantined:
        return Colors.red[600]!;
      case SystemStatus.success:
        return Colors.green[600]!;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case SystemStatus.idle:
        return Colors.grey[700]!;
      case SystemStatus.processing:
        return Colors.blue[800]!;
      case SystemStatus.quarantined:
        return Colors.red[800]!;
      case SystemStatus.success:
        return Colors.green[800]!;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case SystemStatus.idle:
        return 'Idle';
      case SystemStatus.processing:
        return 'Processing';
      case SystemStatus.quarantined:
        return 'Quarantined (Fail-Closed)';
      case SystemStatus.success:
        return 'Success';
    }
  }
}
