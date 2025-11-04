import 'package:crud/controllers/home_controller.dart';
import 'package:crud/pages/login_page.dart';
import 'package:crud/widgets/remote_users_tab.dart';
import 'package:crud/widgets/local_users_tab.dart';
import 'package:crud/widgets/user_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());
  int _selectedTab = 0; // 0 = remote, 1 = local

  Future<void> _logout() async {
    final confirmed = await UserDialogs.confirmLogout(context);
    if (confirmed) {
      final sessionBox = await Hive.openBox('session');
      await sessionBox.delete('currentUser');
      await sessionBox.close();

      Get.offAll(() => const LoginPage());
    }
  }

  Future<void> _showAddDialog() async {
    if (_selectedTab == 0) {
      await UserDialogs.showAddRemoteDialog(context, controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          _selectedTab == 0 ? 'Remote Users' : 'Local Users',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 20,
        actions: [
          if (_selectedTab == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => controller.fetchUsers(),
              tooltip: 'Refresh',
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedTab == 0) {
            await controller.fetchUsers();
          }
        },
        child: _selectedTab == 0
            ? RemoteUsersTab(controller: controller)
            : const LocalUsersTab(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: _selectedTab == 0 ? 'Add Remote User' : 'Add Local User',
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                setState(() => _selectedTab = 0);
              },
              icon: Icon(
                Icons.cloud,
                color: _selectedTab == 0 ? Colors.deepPurple : Colors.grey,
                size: 30,
              ),
              tooltip: 'Remote Users',
            ),
            IconButton(
              onPressed: () {
                setState(() => _selectedTab = 1);
              },
              icon: Icon(
                Icons.person,
                color: _selectedTab == 1 ? Colors.deepPurple : Colors.grey,
                size: 30,
              ),
              tooltip: 'Local Users',
            ),
          ],
        ),
      ),
    );
  }
}
