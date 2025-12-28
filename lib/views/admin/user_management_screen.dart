/// User Management Screen
///
/// Admin screen for managing users - view, search, filter, and manage user accounts.
/// Allows admins to change roles, activate/deactivate users, and view user details.
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/logger.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserRepository _userRepository = UserRepository(FirestoreService());
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  String _selectedRoleFilter = 'all';
  String _selectedStatusFilter = 'all';
  bool _isLoading = true;
  String _searchQuery = '';

  final List<String> _roleOptions = ['all', 'user', 'vendor', 'admin'];
  final List<String> _statusOptions = ['all', 'active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allUsers = await _userRepository.getAllUsers();
      _applyFilters();
    } catch (e) {
      Logger.error('Failed to load users', tag: 'UserManagementScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredUsers = _allUsers.where((user) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          user.email.toLowerCase().contains(_searchQuery) ||
          (user.displayName?.toLowerCase().contains(_searchQuery) ?? false) ||
          user.id.toLowerCase().contains(_searchQuery);

      // Role filter
      final matchesRole = _selectedRoleFilter == 'all' || user.role == _selectedRoleFilter;

      // Status filter
      final matchesStatus = _selectedStatusFilter == 'all' ||
          (_selectedStatusFilter == 'active' && user.isActive) ||
          (_selectedStatusFilter == 'inactive' && !user.isActive);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();

    // Sort by creation date (newest first)
    _filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      final newStatus = !user.isActive;
      await _userRepository.updateUser(user.copyWith(isActive: newStatus));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${newStatus ? 'activated' : 'deactivated'} successfully')),
        );
        _loadUsers(); // Refresh the list
      }
    } catch (e) {
      Logger.error('Failed to update user status', tag: 'UserManagementScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user status: $e')),
        );
      }
    }
  }

  Future<void> _updateUserRole(UserModel user, String newRole) async {
    try {
      await _userRepository.updateUserRole(user.id, newRole);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role updated to $newRole')),
        );
        _loadUsers(); // Refresh the list
      }
    } catch (e) {
      Logger.error('Failed to update user role', tag: 'UserManagementScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user role: $e')),
        );
      }
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', user.id),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Name', user.displayName ?? 'Not provided'),
              _buildDetailRow('Phone', user.phoneNumber ?? 'Not provided'),
              _buildDetailRow('Role', user.role.toUpperCase()),
              _buildDetailRow('Trust Score', user.trustScore.toString()),
              _buildDetailRow('Verified', user.isVerified ? 'Yes' : 'No'),
              _buildDetailRow('Active', user.isActive ? 'Yes' : 'No'),
              _buildDetailRow('Created', DateFormat('MMM dd, yyyy').format(user.createdAt)),
              _buildDetailRow('Last Updated', DateFormat('MMM dd, yyyy').format(user.updatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserActions(user);
            },
            child: const Text('Actions'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showUserActions(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                color: user.isActive ? Colors.red : Colors.green,
              ),
              title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
              onTap: () {
                Navigator.pop(context);
                _toggleUserStatus(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Change Role'),
              onTap: () {
                Navigator.pop(context);
                _showRoleSelection(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: Text(user.isVerified ? 'Remove Verification' : 'Verify User'),
              onTap: () {
                Navigator.pop(context);
                _toggleVerification(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleVerification(UserModel user) async {
    try {
      final newVerificationStatus = !user.isVerified;
      await _userRepository.updateUser(user.copyWith(isVerified: newVerificationStatus));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${newVerificationStatus ? 'verified' : 'unverified'} successfully')),
        );
        _loadUsers(); // Refresh the list
      }
    } catch (e) {
      Logger.error('Failed to update user verification', tag: 'UserManagementScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user verification: $e')),
        );
      }
    }
  }

  void _showRoleSelection(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['user', 'vendor', 'admin'].map((role) {
            return RadioListTile<String>(
              title: Text(role.toUpperCase()),
              value: role,
              groupValue: user.role,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  _updateUserRole(user, value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by email, name, or ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    // Role filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRoleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: _roleOptions.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role == 'all' ? 'All Roles' : role.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoleFilter = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status == 'all' ? 'All Status' : status.capitalize()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatusFilter = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // User count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_filteredUsers.length} user${_filteredUsers.length != 1 ? 's' : ''} found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: _getRoleColor(user.role),
                child: Text(
                  (user.displayName?.isNotEmpty ?? false)
                      ? user.displayName![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? user.email,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        _buildStatusChip(user.role.toUpperCase(), _getRoleColor(user.role)),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          user.isActive ? 'ACTIVE' : 'INACTIVE',
                          user.isActive ? Colors.green : Colors.red,
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 8),
                          _buildStatusChip('VERIFIED', Colors.blue),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Trust score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTrustScoreColor(user.trustScore),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${user.trustScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'vendor':
        return Colors.orange;
      case 'user':
      default:
        return Colors.blue;
    }
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}