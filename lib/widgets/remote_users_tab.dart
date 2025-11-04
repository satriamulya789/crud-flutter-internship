import 'package:crud/controllers/home_controller.dart';
import 'package:crud/widgets/user_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemoteUsersTab extends StatelessWidget {
  final HomeController controller;

  const RemoteUsersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No remote users yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    UserDialogs.showAddRemoteDialog(context, controller),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add User',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: controller.users.length,
        itemBuilder: (context, index) {
          final user = controller.users[index];
          final name = user.name ?? 'Unknown';
          final id = user.id ?? '';
          final address = user.address ?? '';
          final avatar = user.avatar;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? NetworkImage(avatar)
                    : null,
                child: (avatar == null || avatar.isEmpty)
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: $id',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              isThreeLine: address.isNotEmpty,
              onTap: () => Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        backgroundImage: (avatar != null && avatar.isNotEmpty)
                            ? NetworkImage(avatar)
                            : null,
                        child: (avatar == null || avatar.isEmpty)
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(name, style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('ID: $id'),
                        ],
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(address)),
                          ],
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => UserDialogs.showEditRemoteDialog(
                      context,
                      controller,
                      user,
                    ),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => UserDialogs.confirmDeleteRemote(
                      context,
                      controller,
                      id,
                    ),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
