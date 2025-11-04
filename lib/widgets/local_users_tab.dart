import 'package:crud/controllers/home_controller.dart';
import 'package:crud/models/user_login_model.dart';
import 'package:crud/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalUsersTab extends StatefulWidget {
  const LocalUsersTab({super.key});

  @override
  State<LocalUsersTab> createState() => _LocalUsersTabState();
}

class _LocalUsersTabState extends State<LocalUsersTab> {
  final HomeController controller = Get.find<HomeController>();
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUsername = await controller.getLoginSession();
    setState(() {});
  }

  Future<void> _showAddDialog() async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add local user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final u = usernameCtrl.text.trim();
              final p = passwordCtrl.text;
              if (u.isEmpty || p.isEmpty) return;

              // Gunakan controller untuk cek dan simpan
              final existingUser = await controller.getUser(u);
              if (existingUser != null) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username already exists')),
                  );
                }
                return;
              }

              await controller.addUser(User(username: u, password: p));

              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(User user) async {
    final usernameCtrl = TextEditingController(text: user.username);
    final passwordCtrl = TextEditingController(text: user.password);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newU = usernameCtrl.text.trim();
              final newP = passwordCtrl.text;
              if (newU.isEmpty || newP.isEmpty) return;

              try {
                // Gunakan controller untuk update
                await controller.updateUser(
                  user.username,
                  User(username: newU, password: newP),
                );

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String username) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Delete user "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      // Cek apakah user yang dihapus adalah current user
      final isCurrentUser = username == _currentUsername;

      // Gunakan controller untuk hapus
      await controller.deleteUser(username);

      if (mounted) {
        if (isCurrentUser) {
          // Jika current user yang dihapus, tampilkan error dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.red, size: 28),
                  SizedBox(width: 8),
                  Text('Error Data'),
                ],
              ),
              content: const Text(
                'Akun Anda telah dihapus dari database lokal. Anda akan logout otomatis.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );

          // Logout otomatis menggunakan controller
          await controller.clearLoginSession();

          if (mounted) {
            Get.offAll(() => const RegisterPage());
          }
        } else {
          // User biasa berhasil dihapus
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.localLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.localUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No local users'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
              ),
            ],
          ),
        );
      }

      return Scaffold(
        body: ListView.separated(
          itemCount: controller.localUsers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final lu = controller.localUsers[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(lu.username),
              subtitle: const Text('local'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(lu),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(lu.username),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }
}
