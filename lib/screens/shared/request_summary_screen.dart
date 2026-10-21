import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/campus_request_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class RequestSummaryScreen extends StatefulWidget {
  const RequestSummaryScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<RequestSummaryScreen> createState() => _RequestSummaryScreenState();
}

class _RequestSummaryScreenState extends State<RequestSummaryScreen> {
  final _repository = CampusRequestRepository();
  late Future<Map<String, dynamic>?> _request;

  @override
  void initState() {
    super.initState();
    _request = _repository.fetchFromServer(widget.requestId);
  }

  void _retry() =>
      setState(() => _request = _repository.fetchFromServer(widget.requestId));

  String _campusDate(Object? value) {
    if (value is! Timestamp) return 'Not available';
    final campusDate = value.toDate().toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );
    return '${campusDate.day.toString().padLeft(2, '0')}/${campusDate.month.toString().padLeft(2, '0')}/${campusDate.year}';
  }

  @override
  Widget build(BuildContext context) => PageContainer(
    title: 'Request Verification',
    subtitle: 'This summary is loaded from Cloud Firestore using your request reference.',
    child: FutureBuilder<Map<String, dynamic>?>(
      future: _request,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return _messageCard(
            icon: Icons.cloud_off_outlined,
            title: 'Could not verify the saved request',
            message: 'The request may already be saved. Check your connection and retry this read; do not submit it again.',
            action: FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry verification'),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return _messageCard(
            icon: Icons.search_off_outlined,
            title: 'Request not found for this account',
            message:
                'Reference: ${widget.requestId}. Sign in with the same account that created this request.',
            action: FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Check again'),
            ),
          );
        }
        return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: Column(children: [
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7D2028), AppTheme.red]), borderRadius: BorderRadius.circular(22)), child: Column(children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 38)),
            const SizedBox(height: 14), const Text('Request submitted successfully', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7), const Text('Your request is saved in SGU Student Campus. Keep the reference below for follow-up.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, height: 1.4)),
          ])),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.receipt_long_outlined, color: AppTheme.red), SizedBox(width: 10), Text('Request summary', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppTheme.navy))]),
            const SizedBox(height: 18),
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .055), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('REFERENCE NUMBER', style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppTheme.muted, fontWeight: FontWeight.w800)), const SizedBox(height: 6), SelectableText(widget.requestId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.navy))])),
            const SizedBox(height: 18),
            _detail('Subject', data['subject']?.toString() ?? ''),
            _detail('Service', data['serviceCategory']?.toString() ?? ''),
            _detail('Status', data['status']?.toString() ?? ''),
            _detail('Preferred date', _campusDate(data['preferredDate'])),
            const SizedBox(height: 20),
            Wrap(spacing: 10, runSpacing: 10, children: [FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Return to form')), OutlinedButton.icon(onPressed: _retry, icon: const Icon(Icons.refresh), label: const Text('Refresh verification'))]),
          ]))),
        ])));

      },
    ),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(color: AppTheme.muted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _messageCard({
    required IconData icon,
    required String title,
    required String message,
    required Widget action,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.warning, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          SelectableText('Reference: ${widget.requestId}'),
          const SizedBox(height: 16),
          action,
        ],
      ),
    ),
  );
}
