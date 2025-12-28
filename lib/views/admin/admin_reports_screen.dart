import 'package:flutter/material.dart';
import '../../data/models/fraud_report_model.dart';
import '../../data/repositories/fraud_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/logger.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final FraudRepository _fraudRepository = FraudRepository(FirestoreService());
  List<FraudReportModel> _allReports = [];
  List<FraudReportModel> _filteredReports = [];
  String _selectedStatusFilter = 'all';
  bool _isLoading = true;

  final List<String> _statusOptions = [
    'all',
    'pending',
    'investigating',
    'resolved',
    'dismissed',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allReports = await _fraudRepository.getAllReports();
      _applyFilter();
    } catch (e) {
      Logger.error(
        'Failed to load reports',
        tag: 'AdminReportsScreen',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load reports: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    if (_selectedStatusFilter == 'all') {
      _filteredReports = List.from(_allReports);
    } else {
      _filteredReports =
          _allReports
              .where((report) => report.status == _selectedStatusFilter)
              .toList();
    }

    // Sort by creation date (newest first)
    _filteredReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'investigating':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplay(String status) {
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _statusOptions.map((status) {
                      final isSelected = _selectedStatusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            status == 'all'
                                ? 'All Reports'
                                : _getStatusDisplay(status),
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : _getStatusColor(status),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatusFilter = status;
                              _applyFilter();
                            });
                          },
                          backgroundColor:
                              isSelected ? _getStatusColor(status) : null,
                          checkmarkColor: Colors.white,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          // Reports count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_filteredReports.length} report${_filteredReports.length != 1 ? 's' : ''} found',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),

          // Reports list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredReports.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.report_problem_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reports found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filter',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = _filteredReports[index];
                          return _buildReportCard(report);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(FraudReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToReportReview(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        report.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          report.status,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusDisplay(report.status),
                      style: TextStyle(
                        color: _getStatusColor(report.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(report.createdAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Report title
              Text(
                report.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Report type and severity
              Row(
                children: [
                  Icon(
                    _getReportTypeIcon(report.type),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getReportTypeDisplay(report.type),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: _getSeverityColor(report.severity),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Severity: ${report.severity}/5',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getSeverityColor(report.severity),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Reporter info (if not anonymous)
              if (!report.isAnonymous)
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Reporter: ${report.reporterId}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),

              // Target info
              if (report.productId != null || report.vendorId != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Target: ${report.productId != null ? 'Product' : 'Vendor'} ${report.productId ?? report.vendorId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Description preview
              const SizedBox(height: 8),
              Text(
                report.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Tap to review indicator
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to review',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'fraud':
        return Icons.warning;
      case 'fake_product':
        return Icons.shopping_bag;
      case 'scam':
        return Icons.money_off;
      default:
        return Icons.report_problem;
    }
  }

  String _getReportTypeDisplay(String type) {
    switch (type) {
      case 'fraud':
        return 'Fraud';
      case 'fake_product':
        return 'Fake Product';
      case 'scam':
        return 'Scam';
      default:
        return type.replaceAll('_', ' ').capitalize();
    }
  }

  Color _getSeverityColor(int severity) {
    if (severity >= 4) return Colors.red;
    if (severity >= 3) return Colors.orange;
    if (severity >= 2) return Colors.yellow[700]!;
    return Colors.green;
  }

  void _navigateToReportReview(FraudReportModel report) {
    Navigator.pushNamed(context, '/admin/report/review', arguments: report);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
