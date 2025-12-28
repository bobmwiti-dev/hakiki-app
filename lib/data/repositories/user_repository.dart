import '../../core/utils/logger.dart';
import '../../core/services/firestore_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  // Collection name removed as it's not used with current FirestoreService implementation

  UserRepository(this._firestoreService);

  // Create a new user
  Future<UserModel> createUser(UserModel user) async {
    try {
      Logger.info('Creating user: ${user.email}', tag: 'UserRepository');
      
      await _firestoreService.createUser(user);
      final createdUser = user;
      
      Logger.info('User created successfully: ${createdUser.id}', tag: 'UserRepository');
      return createdUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to create user: ${user.email}', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      Logger.debug('Getting user by ID: $userId', tag: 'UserRepository');
      
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        Logger.debug('User found: ${user.email}', tag: 'UserRepository');
        return user;
      }
      
      Logger.debug('User not found: $userId', tag: 'UserRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get user by ID: $userId', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      Logger.debug('Getting user by email: $email', tag: 'UserRepository');
      
      // Use getUserByEmail method if available, otherwise return null for now
      // TODO: Implement getUserByEmail in FirestoreService if needed
      Logger.debug('getUserByEmail not implemented in FirestoreService', tag: 'UserRepository');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get user by email: $email', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      Logger.info('Updating user: ${user.id}', tag: 'UserRepository');
      
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateUser(user.id, user.toJson());
      
      Logger.info('User updated successfully: ${user.id}', tag: 'UserRepository');
      return updatedUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to update user: ${user.id}', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user trust score
  Future<UserModel> updateTrustScore(String userId, int newScore) async {
    try {
      Logger.info('Updating trust score for user: $userId to $newScore', tag: 'UserRepository');
      
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }
      
      final updatedUser = user.copyWith(
        trustScore: newScore,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateUser(userId, updatedUser.toJson());
      
      Logger.info('Trust score updated successfully for user: $userId', tag: 'UserRepository');
      return updatedUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to update trust score for user: $userId', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role, {int? limit}) async {
    try {
      Logger.debug('Getting users by role: $role', tag: 'UserRepository');
      
      // getUsers method not available in FirestoreService
      // TODO: Implement getUsers or getUsersByRole in FirestoreService if needed
      Logger.debug('getUsersByRole not implemented in FirestoreService', tag: 'UserRepository');
      return <UserModel>[];
    } catch (e, stackTrace) {
      Logger.error('Failed to get users by role: $role', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query, {int? limit}) async {
    try {
      Logger.debug('Searching users with query: $query', tag: 'UserRepository');
      
      // searchUsers method not available in FirestoreService
      // TODO: Implement searchUsers in FirestoreService if needed
      Logger.debug('searchUsers not implemented in FirestoreService', tag: 'UserRepository');
      final users = <UserModel>[];
      
      Logger.debug('Found ${users.length} users matching query: $query', tag: 'UserRepository');
      return users;
    } catch (e, stackTrace) {
      Logger.error('Failed to search users with query: $query', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Deactivate user
  Future<UserModel> deactivateUser(String userId) async {
    try {
      Logger.info('Deactivating user: $userId', tag: 'UserRepository');
      
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }
      
      final deactivatedUser = user.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateUser(userId, deactivatedUser.toJson());
      
      Logger.info('User deactivated successfully: $userId', tag: 'UserRepository');
      return deactivatedUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to deactivate user: $userId', 
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers({int? limit}) async {
    try {
      Logger.debug('Getting all users', tag: 'UserRepository');

      // Use FirestoreService to get all users
      final users = await _firestoreService.getAllUsers(limit: limit);

      Logger.debug('Retrieved ${users.length} users', tag: 'UserRepository');
      return users;
    } catch (e, stackTrace) {
      Logger.error('Failed to get all users',
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user role
  Future<UserModel> updateUserRole(String userId, String newRole) async {
    try {
      Logger.info('Updating user role for $userId to $newRole', tag: 'UserRepository');

      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final updatedUser = user.copyWith(
        role: newRole,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateUser(userId, updatedUser.toJson());

      Logger.info('User role updated successfully for $userId', tag: 'UserRepository');
      return updatedUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to update user role for $userId',
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user status
  Future<UserModel> updateUserStatus(String userId, String newStatus) async {
    try {
      Logger.info('Updating user status for $userId to $newStatus', tag: 'UserRepository');

      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final updatedUser = user.copyWith(
        role: newStatus,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateUser(userId, updatedUser.toJson());

      Logger.info('User status updated successfully for $userId', tag: 'UserRepository');
      return updatedUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to update user status for $userId',
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      Logger.debug('Getting user statistics', tag: 'UserRepository');

      // User statistics methods not available in FirestoreService
      // TODO: Implement getUserStatistics in FirestoreService if needed
      Logger.debug('getUserStatistics not implemented in FirestoreService', tag: 'UserRepository');

      const totalUsers = 0;
      const activeUsers = 0;
      const verifiedUsers = 0;
      const adminUsers = 0;
      const vendorUsers = 0;

      final stats = {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'verifiedUsers': verifiedUsers,
        'adminUsers': adminUsers,
        'vendorUsers': vendorUsers,
      };

      Logger.debug('User statistics retrieved: $stats', tag: 'UserRepository');
      return stats;
    } catch (e, stackTrace) {
      Logger.error('Failed to get user statistics',
          tag: 'UserRepository', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete user (soft delete by deactivating)
  Future<void> deleteUser(String userId) async {
    await deactivateUser(userId);
  }
}
