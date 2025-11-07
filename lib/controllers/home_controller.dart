import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/user_login_model.dart';
import '../models/remote_user.dart';

class HomeController extends GetxController {
  // Remote users
  final users = <RemoteUser>[].obs;
  final loading = false.obs;
  final error = ''.obs;

  // Dio instance
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://690067a3ff8d792314b9a525.mockapi.io'));

  // Local users
  final localUsers = <User>[].obs;
  final localLoading = false.obs;

  // Hive constants
  static const String boxName = 'users';
  static const String sessionBoxName = 'session';
  static const String sessionKey = 'currentUser';

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchLocalUsers();
  }
 //TODO: add lupa pw
  //  REMOTE USERS (API) 

  /// Fetch all remote users from API
  Future<void> fetchUsers() async {
    loading.value = true;
    error.value = '';
    try {
      final resp = await dio.get('/users');
      final data = resp.data;
      if (data is List) {
        users.assignAll(
          data
              .map((e) => RemoteUser.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      } else {
        error.value = 'Response format unexpected';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  /// Create a remote user
  Future<RemoteUser?> createRemoteUser({
    required String name,
    String? avatar,
    String? address,
  }) async {
    try {
      final resp = await dio.post(
        '/users',
        data: {'name': name, 'avatar': avatar ?? '', 'address': address ?? ''},
      );
      final data = resp.data as Map<String, dynamic>;
      final created = RemoteUser.fromJson(data);
      await fetchUsers();
      return created;
    } catch (e) {
      error.value = e.toString();
      return null;
    }
  }

  /// Update a remote user
  Future<bool> updateRemoteUser({
    required String id,
    required String name,
    String? avatar,
    String? address,
  }) async {
    try {
      final resp = await dio.put(
        '/users/$id',
        data: {'name': name, 'avatar': avatar ?? '', 'address': address ?? ''},
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await fetchUsers();
        return true;
      }
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  /// Delete a remote user
  Future<bool> deleteRemoteUser(String id) async {
    try {
      final resp = await dio.delete('/users/$id');
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await fetchUsers();
        return true;
      }
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  // LOCAL USERS (HIVE) 

  /// Fetch all local users from Hive
  Future<void> fetchLocalUsers() async {
    localLoading.value = true;
    final box = await Hive.openBox<User>(boxName);
    localUsers.assignAll(box.values.toList());
    await box.close();
    localLoading.value = false;
  }

  /// Get a specific user by username
  Future<User?> getUser(String username) async {
    final box = await Hive.openBox<User>(boxName);
    final user = box.get(username);
    await box.close();
    return user;
  }

  /// Add a new local user
  Future<void> addUser(User user) async {
    final box = await Hive.openBox<User>(boxName);
    await box.put(user.username, user);
    await box.close();
    await fetchLocalUsers();
  }

  /// Update a local user
  /// Throws [Exception] when new username already exists (and is different)
  Future<void> updateUser(String oldUsername, User newUser) async {
    final box = await Hive.openBox<User>(boxName);
    // if username changed and new username exists, throw
    if (oldUsername != newUser.username && box.containsKey(newUser.username)) {
      await box.close();
      throw Exception('Username already exists');
    }
    // delete old key if changed
    if (oldUsername != newUser.username) {
      await box.delete(oldUsername);
    }
    await box.put(newUser.username, newUser);
    await box.close();
    await fetchLocalUsers();
  }

  /// Delete a local user
  Future<void> deleteUser(String username) async {
    final box = await Hive.openBox<User>(boxName);
    await box.delete(username);
    await box.close();
    await fetchLocalUsers();
  }

  /// Validate login credentials
  Future<bool> validateLogin(String username, String password) async {
    final user = await getUser(username);
    if (user == null) return false;
    return user.password == password;
  }

  // ============= SESSION MANAGEMENT =============

  /// Save login session
  Future<void> saveLoginSession(String username) async {
    final box = await Hive.openBox(sessionBoxName);
    await box.put(sessionKey, username);
    await box.close();
  }

  /// Get current logged in username
  Future<String?> getLoginSession() async {
    final box = await Hive.openBox(sessionBoxName);
    final username = box.get(sessionKey) as String?;
    await box.close();
    return username;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final username = await getLoginSession();
    return username != null && username.isNotEmpty;
  }

  /// Clear login session (logout)
  Future<void> clearLoginSession() async {
    final box = await Hive.openBox(sessionBoxName);
    await box.delete(sessionKey);
    await box.close();
  }
}
