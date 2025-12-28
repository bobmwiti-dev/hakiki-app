import '../../../../core/app_export.dart';
import '../viewmodels/admin_viewmodel.dart';
import 'vendor_review_screen.dart';
import 'report_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.store_mall_directory), text: 'Vendors'),
            Tab(icon: Icon(Icons.report_problem), text: 'Reports'),
          ],
        ),
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dashboard',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, viewModel),
              _buildVendorsTab(context, viewModel),
              _buildReportsTab(context, viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AdminViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Vendors',
                  '${viewModel.pendingVendors.length}',
                  Icons.store,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending Reports',
                  '${viewModel.pendingReports.length}',
                  Icons.report,
                  Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  '${viewModel.totalUsers}',
                  Icons.people,
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Vendors',
                  '${viewModel.approvedVendors}',
                  Icons.verified,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.store),
                  label: const Text('Review Vendors'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(2),
                  icon: const Icon(Icons.report),
                  label: const Text('Review Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.recentActivity.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = viewModel.recentActivity[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActivityColor(activity['type']),
                    child: Icon(
                      _getActivityIcon(activity['type']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(activity['title']),
                  subtitle: Text(activity['description']),
                  trailing: Text(
                    _formatTimestamp(activity['timestamp']),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsTab(BuildContext context, AdminViewModel viewModel) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Icon(Icons.store, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Pending Vendor Applications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text('${viewModel.pendingVendors.length}'),
                backgroundColor: Colors.orange,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        // Vendor List
        Expanded(
          child: viewModel.pendingVendors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No Pending Applications',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('All vendor applications have been reviewed'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.pendingVendors.length,
                  itemBuilder: (context, index) {
                    final vendor = viewModel.pendingVendors[index];
                    return _buildVendorCard(context, vendor, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(BuildContext context, AdminViewModel viewModel) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Icon(Icons.report_problem, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Pending Fraud Reports',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text('${viewModel.pendingReports.length}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        // Reports List
        Expanded(
          child: viewModel.pendingReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No Pending Reports',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('All fraud reports have been reviewed'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.pendingReports.length,
                  itemBuilder: (context, index) {
                    final report = viewModel.pendingReports[index];
                    return _buildReportCard(context, report as ReportModel, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, VendorModel vendor, AdminViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            vendor.businessName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(vendor.businessName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${vendor.businessType}'),
            Text('Applied: ${_formatDate(vendor.createdAt)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'review',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Review'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'approve',
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Approve'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reject',
              child: Row(
                children: [
                  Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  const Text('Reject'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleVendorAction(context, value, vendor, viewModel),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report, AdminViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(report.severity),
          child: const Icon(
            Icons.report_problem,
            color: Colors.white,
          ),
        ),
        title: Text(report.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${report.type}'),
            Text('Severity: ${report.severity}'),
            Text('Reported: ${_formatDate(report.createdAt)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'review',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Review'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'approve',
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Approve'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reject',
              child: Row(
                children: [
                  Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  const Text('Reject'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleReportAction(context, value, report, viewModel),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _handleVendorAction(BuildContext context, String action, VendorModel vendor, AdminViewModel viewModel) {
    switch (action) {
      case 'review':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorReviewScreen(vendor: vendor),
          ),
        );
        break;
      case 'approve':
        _showApproveVendorDialog(context, vendor, viewModel);
        break;
      case 'reject':
        _showRejectVendorDialog(context, vendor, viewModel);
        break;
    }
  }

  void _handleReportAction(BuildContext context, String action, ReportModel report, AdminViewModel viewModel) {
    switch (action) {
      case 'review':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportReviewScreen(report: report),
          ),
        );
        break;
      case 'approve':
        _showApproveReportDialog(context, report, viewModel);
        break;
      case 'reject':
        _showRejectReportDialog(context, report, viewModel);
        break;
    }
  }

  void _showApproveVendorDialog(BuildContext context, VendorModel vendor, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Vendor'),
        content: Text('Are you sure you want to approve ${vendor.businessName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              final success = await viewModel.approveVendor(vendor.id, 'Approved by admin');
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('${vendor.businessName} approved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectVendorDialog(BuildContext context, VendorModel vendor, AdminViewModel viewModel) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${vendor.businessName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Please provide a reason...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final errorColor = Theme.of(context).colorScheme.error;
              Navigator.pop(context);
              final success = await viewModel.rejectVendor(vendor.id, reasonController.text);
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('${vendor.businessName} rejected'),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showApproveReportDialog(BuildContext context, ReportModel report, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Report'),
        content: const Text('Mark this report as valid and take action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await viewModel.approveReport(report.id);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Report approved and action taken'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectReportDialog(BuildContext context, ReportModel report, AdminViewModel viewModel) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mark this report as invalid?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Why is this report invalid?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final errorColor = Theme.of(context).colorScheme.error;
              Navigator.pop(context);
              await viewModel.rejectReport(report.id, reasonController.text);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('Report rejected'),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'vendor_registration':
        return Theme.of(context).primaryColor;
      case 'fraud_report':
        return Theme.of(context).colorScheme.error;
      case 'vendor_approved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'vendor_registration':
        return Icons.store;
      case 'fraud_report':
        return Icons.report_problem;
      case 'vendor_approved':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 5:
      case 4:
        return Theme.of(context).colorScheme.error; // High severity
      case 3:
        return Colors.orange; // Medium severity
      case 2:
      case 1:
        return Colors.blue; // Low severity
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
