/// Home Dashboard Screen
/// 
/// Main dashboard screen showing user overview, quick actions, and recent activity.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/activity_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/logger.dart';
import 'package:intl/intl.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final ActivityService _activityService = ActivityService();
  final UserRepository _userRepository = UserRepository(FirestoreService());
  List<ActivityModel> _activities = [];
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuthService().currentUser;
      if (user != null) {
        _currentUser = await _userRepository.getUserById(user.uid);
        _activities = await _activityService.getRecentActivities(
          userId: user.uid,
          limit: 5,
        );
      }
    } catch (e) {
      Logger.error('Failed to load dashboard data', tag: 'HomeDashboard', error: e);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Text(
                      'Welcome back${_currentUser?.displayName != null ? ', ${_currentUser!.displayName}' : ''}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    // Quick actions
                    Text(
                      AppStrings.quickActions,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.qr_code_scanner,
                            title: AppStrings.scanProduct,
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.qrScanner);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.report_problem,
                            title: AppStrings.reportFraud,
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.fraudReport);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Trust score section
                    Text(
                      AppStrings.trustScore,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, size: 48, color: Colors.green),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Trust Score',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_currentUser?.trustScore ?? 0}/100',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Recent activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.recentActivity,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_activities.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to full activity history
                            },
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_activities.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No recent activity',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start by scanning a product or reporting fraud',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ..._activities.map((activity) => _buildActivityItem(context, activity)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.reportHistory);
                            },
                            child: const Text('View All Reports'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityModel activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'verification':
        icon = Icons.qr_code_scanner;
        color = Colors.green;
        break;
      case 'report':
        icon = Icons.report_problem;
        color = Colors.orange;
        break;
      case 'trust_score_change':
        icon = Icons.trending_up;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(activity.title),
        subtitle: Text(activity.description),
        trailing: Text(
          _formatTime(activity.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          // Navigate based on activity type
          if (activity.type == 'verification' && activity.productId != null) {
            // TODO: Navigate to product details
          } else if (activity.type == 'report' && activity.reportId != null) {
            // TODO: Navigate to report details
          }
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

