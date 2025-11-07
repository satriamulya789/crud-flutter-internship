import 'package:crud/controllers/home_controller.dart';
import 'package:crud/models/remote_user.dart';
import 'package:crud/models/user_login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDialogs {
  // ============= REMOTE USER DIALOGS =============

  static Future<void> showAddRemoteDialog(
    BuildContext context,
    HomeController controller,
  ) async {
    final nameCtrl = TextEditingController();
    final avatarCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add Remote User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avatarCtrl,
                decoration: InputDecoration(
                  labelText: 'Avatar URL (Optional)',
                  prefixIcon: const Icon(Icons.image),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final avatar = avatarCtrl.text.trim();
              final address = addressCtrl.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Name is required',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final created = await controller.createRemoteUser(
                name: name,
                avatar: avatar.isEmpty ? null : avatar,
                address: address.isEmpty ? null : address,
              );

              if (created != null) {
                Get.snackbar(
                  'Success',
                  'Remote user created',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to create remote user',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }

              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<void> showEditRemoteDialog(
    BuildContext context,
    HomeController controller,
    RemoteUser user,
  ) async {
    final nameCtrl = TextEditingController(text: user.name ?? '');
    final avatarCtrl = TextEditingController(text: user.avatar ?? '');
    final addressCtrl = TextEditingController(text: user.address ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Remote User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avatarCtrl,
                decoration: InputDecoration(
                  labelText: 'Avatar URL (Optional)',
                  prefixIcon: const Icon(Icons.image),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final avatar = avatarCtrl.text.trim();
              final address = addressCtrl.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Name is required',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final ok = await controller.updateRemoteUser(
                id: user.id ?? '',
                name: name,
                avatar: avatar.isEmpty ? null : avatar,
                address: address.isEmpty ? null : address,
              );

              if (ok) {
                Get.snackbar(
                  'Success',
                  'Remote user updated',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to update remote user',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }

              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  

  static Future<void> confirmDeleteRemote(
    BuildContext context,
    HomeController controller,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Remote User'),
        content: const Text(
          'Are you sure you want to delete this remote user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      final success = await controller.deleteRemoteUser(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Remote user deleted',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete remote user',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ============= LOCAL USER DIALOGS =============

  static Future<void> showAddLocalDialog(
    BuildContext context,
    HomeController controller,
  ) async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final obscurePassword = true.obs;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add Local User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameCtrl,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => TextField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        obscurePassword.value = !obscurePassword.value;
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameCtrl.text.trim();
              final password = passwordCtrl.text.trim();

              if (username.isEmpty || password.isEmpty) {
                Get.snackbar(
                  'Error',
                  'All fields are required',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              try {
                await controller.addUser(
                  User(
                    username: username,
                    password: password,
                    lastEdited: DateTime.now(),
                  ),
                );

                Get.snackbar(
                  'Success',
                  'Local user created',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );

                if (ctx.mounted) Navigator.of(ctx).pop();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to create user: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<void> showEditLocalDialog(
    BuildContext context,
    HomeController controller,
    User user,
  ) async {
    final usernameCtrl = TextEditingController(text: user.username);
    final passwordCtrl = TextEditingController(text: user.password);
    final obscurePassword = true.obs;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Local User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameCtrl,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => TextField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        obscurePassword.value = !obscurePassword.value;
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameCtrl.text.trim();
              final password = passwordCtrl.text.trim();

              if (username.isEmpty || password.isEmpty) {
                Get.snackbar(
                  'Error',
                  'All fields are required',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              try {
                await controller.updateUser(
                  user.username,
                  User(
                    username: username,
                    password: password,
                    lastEdited: DateTime.now(),
                  ),
                );

                Get.snackbar(
                  'Success',
                  'Local user updated',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );

                if (ctx.mounted) Navigator.of(ctx).pop();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update user: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<void> confirmDeleteLocal(
    BuildContext context,
    HomeController controller,
    String username,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Local User'),
        content: const Text('Are you sure you want to delete this local user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await controller.deleteUser(username);
        Get.snackbar(
          'Success',
          'Local user deleted',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete user: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ============= LOGOUT DIALOG =============

  static Future<bool> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }
}
