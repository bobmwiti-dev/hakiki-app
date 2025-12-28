/// Admin Dashboard Screen
///
/// Admin-only screen for managing vendors, reports, and system operations.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../data/repositories/admin_repository.dart';
import 'vendor_review_screen.dart';
import 'report_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final adminRepository = AdminRepositoryImpl();
      final stats = await adminRepository.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminDashboard)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadStats,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // System stats
                      Text(
                        AppStrings.systemStats,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Total Users',
                              value: _formatNumber(_stats['totalUsers'] ?? 0),
                              icon: Icons.people,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Vendors',
                              value: _formatNumber(_stats['totalVendors'] ?? 0),
                              icon: Icons.store,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Pending Reports',
                              value: _formatNumber(
                                _stats['pendingReports'] ?? 0,
                              ),
                              icon: Icons.report,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Pending Vendors',
                              value: _formatNumber(
                                _stats['pendingVendors'] ?? 0,
                              ),
                              icon: Icons.pending,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Quick actions
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.report_problem),
                        title: const Text(AppStrings.pendingReports),
                        subtitle: Text(
                          '${_stats['pendingReports'] ?? 0} reports need review',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigateToPendingReports(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.store),
                        title: const Text(AppStrings.vendorApplications),
                        subtitle: Text(
                          '${_stats['pendingVendors'] ?? 0} applications pending',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigateToPendingVendors(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text(AppStrings.userManagement),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.userManagement);
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Future<void> _navigateToPendingReports(BuildContext context) async {
    try {
      // Capture context before async operation
      final capturedContext = context;
      final adminRepository = AdminRepositoryImpl();
      final reports = await adminRepository.getPendingReports();

      if (!mounted) return;

      if (reports.isEmpty) {
        ScaffoldMessenger.of(
          capturedContext,
        ).showSnackBar(const SnackBar(content: Text('No pending reports')));
        return;
      }

      // Show list of pending reports
      showModalBottomSheet(
        context: capturedContext,
        isScrollControlled: true,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Reports (${reports.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.report_problem,
                              color: Colors.orange,
                            ),
                            title: Text(report.title),
                            subtitle: Text(
                              'Type: ${report.type} | Severity: ${report.severity}/5',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ReportReviewScreen(report: report),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading reports: $e')));
      }
    }
  }

  Future<void> _navigateToPendingVendors(BuildContext context) async {
    try {
      // Capture context before async operation
      final capturedContext = context;
      final adminRepository = AdminRepositoryImpl();
      final vendors = await adminRepository.getPendingVendors();

      if (!mounted) return;

      if (vendors.isEmpty) {
        ScaffoldMessenger.of(capturedContext).showSnackBar(
          const SnackBar(content: Text('No pending vendor applications')),
        );
        return;
      }

      // Show list of pending vendors
      showModalBottomSheet(
        context: capturedContext,
        isScrollControlled: true,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Vendors (${vendors.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = vendors[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.store,
                              color: Colors.blue,
                            ),
                            title: Text(vendor.businessName),
                            subtitle: Text('Type: ${vendor.businessType}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => VendorReviewScreen(vendor: vendor),
                                ),
                              ).then((_) => _loadStats());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading vendors: $e')));
      }
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
