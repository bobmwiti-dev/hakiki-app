import '../viewmodels/home_viewmodel.dart';
import '../../../../core/app_export.dart';
import '../widgets/quick_stats_card_widget.dart';
import '../widgets/recent_verification_item_widget.dart';
import '../widgets/trust_score_widget.dart';
import '../widgets/user_greeting_widget.dart';
import '../widgets/verified_vendor_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakiki'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
            await viewModel.loadData();
          },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeSection(context, viewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Quick actions
                  _buildQuickActions(context, viewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Trust Score Section
                  _buildTrustScoreSection(context, viewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Dashboard stats (for admin/vendor)
                  if (viewModel.currentUser?.role == 'admin' ||
                      viewModel.currentUser?.role == 'vendor')
                    _buildDashboardStats(context, viewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Recent activity
                  _buildRecentActivity(context, viewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Verified Vendors
                  _buildVerifiedVendors(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, HomeViewModel viewModel) {
    final user = viewModel.currentUser;
    
    return UserGreetingWidget(
      userName: user?.displayName ?? 'User',
      trustScore: user?.trustScore ?? 0,
      userAvatar: user?.photoUrl ?? 'https://via.placeholder.com/150',
    );
  }

  Widget _buildQuickActions(BuildContext context, HomeViewModel viewModel) {
    final quickStats = [
      {
        "title": "Verified Today",
        "value": "12",
        "subtitle": "+3 from yesterday",
        "backgroundColor": Theme.of(context).primaryColor,
        "textColor": Colors.white,
        "iconName": "verified",
      },
      {
        "title": "Reports Submitted",
        "value": "3",
        "subtitle": "This month",
        "backgroundColor": Colors.green,
        "textColor": Colors.white,
        "iconName": "report",
      },
      {
        "title": "Community Impact",
        "value": "247",
        "subtitle": "People helped",
        "backgroundColor": Colors.orange,
        "textColor": Colors.white,
        "iconName": "people",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 16.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickStats.length,
            itemBuilder: (context, index) {
              final stat = quickStats[index];
              return QuickStatsCardWidget(
                title: stat["title"] as String,
                value: stat["value"] as String,
                subtitle: stat["subtitle"] as String,
                backgroundColor: stat["backgroundColor"] as Color,
                textColor: stat["textColor"] as Color,
                iconName: stat["iconName"] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrustScoreSection(BuildContext context, HomeViewModel viewModel) {
    final user = viewModel.currentUser;
    final trustScore = user?.trustScore ?? 0;
    
    return TrustScoreWidget(
      trustScore: trustScore,
      trustLevel: _getTrustLevel(trustScore),
      improvementTips: const [
        "Verify 5 more products this week",
        "Submit detailed fraud reports",
        "Help other community members",
        "Complete your profile verification",
      ],
    );
  }

  String _getTrustLevel(int score) {
    if (score >= 90) return "Excellent";
    if (score >= 80) return "Very Good";
    if (score >= 70) return "Good";
    if (score >= 60) return "Fair";
    return "Needs Improvement";
  }

  Widget _buildDashboardStats(BuildContext context, HomeViewModel viewModel) {
    final stats = viewModel.dashboardStats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              title: 'Total Users',
              value: '${stats['totalUsers'] ?? 0}',
              icon: Icons.people,
              color: Theme.of(context).primaryColor,
            ),
            _buildStatCard(
              context,
              title: 'Total Products',
              value: '${stats['totalProducts'] ?? 0}',
              icon: Icons.inventory,
              color: Colors.green,
            ),
            _buildStatCard(
              context,
              title: 'Total Reports',
              value: '${stats['totalReports'] ?? 0}',
              icon: Icons.report,
              color: Colors.orange,
            ),
            _buildStatCard(
              context,
              title: 'Pending Reports',
              value: '${stats['pendingReports'] ?? 0}',
              icon: Icons.pending,
              color: Colors.red,
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/activity');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.recentReports.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by scanning products or reporting fraud',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...viewModel.recentReports.take(3).map((report) {
            return RecentVerificationItemWidget(
              verification: {
                "id": report.id,
                "productName": report.title,
                "brand": "Unknown",
                "status": report.status,
                "timestamp": _formatDate(report.createdAt),
                "productImage": "",
              },
              onShare: () {
                // Handle share
              },
              onReport: () {
                Navigator.pushNamed(context, '/fraud-report-screen');
              },
              onViewDetails: () {
                Navigator.pushNamed(
                  context,
                  '/report-details',
                  arguments: report,
                );
              },
            );
          }),
      ],
    );
  }

  Widget _buildVerifiedVendors(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.verifiedVendors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Verified Vendors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/vendors');
              },
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.verifiedVendors.length,
            itemBuilder: (context, index) {
              final vendor = viewModel.verifiedVendors[index];
              return VerifiedVendorCardWidget(
                vendor: vendor,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/vendor-details',
                    arguments: vendor,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
