import 'package:crud/models/user_login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;

  // state to track whether username exists
  bool _userFound = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // Check if username exists in Hive before showing password fields
  Future<void> _checkUsername() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter username',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _loading = true);
    Box? box;
    try {
      box = await Hive.openBox('users');
      final stored = box.get(username);
      if (stored == null) {
        setState(() {
          _userFound = false;
        });
        Get.snackbar(
          'Not found',
          'Username tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        setState(() {
          _userFound = true;
        });
        Get.snackbar(
          'Found',
          'Username ditemukan, silakan reset password',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memeriksa username',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      await box?.close();
      setState(() => _loading = false);
    }
  }

  // Reset password: supports Map values or User model objects (basic attempts)
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_userFound) {
      Get.snackbar(
        'Error',
        'Periksa username dulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _loading = true);
    final username = _usernameCtrl.text.trim();
    final newPassword = _passwordCtrl.text;

    Box? box;
    try {
      box = await Hive.openBox('users');
      final stored = box.get(username);

      if (stored == null) {
        Get.snackbar(
          'Error',
          'User not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _userFound = false);
        return;
      }

      if (stored is Map) {
        final updated = Map<String, dynamic>.from(stored);
        updated['password'] = newPassword;
        await box.put(username, updated);
      } else {
        final dynamic s = stored;
        var saved = false;

        // Try direct assignment if field exists
        try {
          s.password = newPassword;
          await box.put(username, s);
          saved = true;
        } catch (_) {}

        // Try toJson -> update -> save Map
        if (!saved) {
          try {
            final map = (s.toJson() as Map).cast<String, dynamic>();
            map['password'] = newPassword;
            await box.put(username, map);
            saved = true;
          } catch (_) {}
        }

        // Try copyWith
        if (!saved) {
          try {
            final newObj = s.copyWith(password: newPassword);
            await box.put(username, newObj);
            saved = true;
          } catch (_) {}
        }

        if (!saved) {
          Get.snackbar(
            'Error',
            'Tipe data user tidak dapat di-update',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      Get.snackbar(
        'Sukses',
        'Password berhasil di-reset',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mereset password',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      await box?.close();
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.toNamed('/login'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.key_rounded, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              'Reset Your Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 32),

            // Username row with check button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _checkUsername,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Check'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Password fields only when username found
            if (_userFound) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter new password';
                        if (value.length < 6)
                          return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please confirm password';
                        if (value != _passwordCtrl.text)
                          return 'Password tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Reset Password'),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Tekan "Check" untuk memverifikasi username sebelum mereset password',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
