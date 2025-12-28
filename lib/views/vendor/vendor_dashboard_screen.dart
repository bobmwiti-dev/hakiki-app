/// Vendor Dashboard Screen
///
/// Dashboard for vendors to manage their business profile,
/// view analytics, and manage products.
library;

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../data/models/vendor_model.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/logger.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final VendorRepository _vendorRepository = VendorRepository(
    FirestoreService(),
  );
  VendorModel? _vendor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuthService().currentUser;
      if (user != null) {
        _vendor = await _vendorRepository.getVendorByUserId(user.uid);
      }
    } catch (e) {
      Logger.error(
        'Failed to load vendor data',
        tag: 'VendorDashboard',
        error: e,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_vendor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vendor Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No Vendor Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Register as a vendor to access the dashboard'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.vendorRegistration);
                },
                icon: const Icon(Icons.add_business),
                label: const Text('Register as Vendor'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVendorData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadVendorData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vendor status card
              Card(
                color: _getStatusColor(
                  _vendor!.verificationStatus,
                ).withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(_vendor!.verificationStatus),
                        size: 48,
                        color: _getStatusColor(_vendor!.verificationStatus),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vendor!.businessName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${_vendor!.verificationStatus.toUpperCase()}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: _getStatusColor(
                                  _vendor!.verificationStatus,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Statistics
              Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Trust Score',
                      value: '${_vendor!.trustScore}',
                      icon: Icons.verified,
                      color: _getTrustScoreColor(_vendor!.trustScore),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Products',
                      value: '${_vendor!.totalProducts}',
                      icon: Icons.inventory,
                      color: Colors.blue,
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
                      title: 'Reports',
                      value: '${_vendor!.totalReports}',
                      icon: Icons.report,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Verifications',
                      value: '${_vendor!.totalProducts * 2}', // Placeholder
                      icon: Icons.qr_code_scanner,
                      color: Colors.green,
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
              if (_vendor!.verificationStatus == 'approved') ...[
                ListTile(
                  leading: const Icon(Icons.add_circle),
                  title: const Text('Add Product'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.addProduct);
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Business Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.profile);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('View QR Code'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show vendor QR code
                  _showQRCodeDialog(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('View Analytics'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to analytics
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showQRCodeDialog(BuildContext context) {
    final qrCode = _vendor?.metadata?['qrCode'] ?? 'Not available';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Your Vendor QR Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    qrCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share this QR code with customers to verify your business',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
