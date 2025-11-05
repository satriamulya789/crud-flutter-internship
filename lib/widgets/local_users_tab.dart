import 'package:crud/controllers/home_controller.dart';
import 'package:crud/models/user_login_model.dart';
import 'package:crud/pages/login_page.dart';
import 'package:crud/widgets/user_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  String _formatLastEdited(DateTime? lastEdited) {
    if (lastEdited == null) return 'Never edited';
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return 'Edited: ${formatter.format(lastEdited)}';
  }

  Future<void> _showAddDialog() async {
    await UserDialogs.showAddLocalDialog(context, controller);
  }

  Future<void> _showEditDialog(User user) async {
    await UserDialogs.showEditLocalDialog(context, controller, user);
  }

  Future<void> _confirmDelete(String username) async {
    await UserDialogs.confirmDeleteLocal(context, controller, username);

    // Setelah delete, cek apakah user yang dihapus adalah current user
    final currentUsername = await controller.getLoginSession();
    if (currentUsername == null && _currentUsername == username) {
      // User yang login telah dihapus
      if (mounted) {
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
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        Get.offAll(() => const LoginPage());
      }
    } else {
      // Refresh current username jika perlu
      await _loadCurrentUser();
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
              subtitle: Text(_formatLastEdited(lu.lastEdited)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(lu),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
