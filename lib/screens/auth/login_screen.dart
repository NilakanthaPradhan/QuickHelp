import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isAdmin = false; // Toggle for admin login

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter username and password')));
      return;
    }

    setState(() => _isLoading = true);

    if (_isAdmin) {
      // Existing admin login flow
      final success = await ApiService.adminLogin(_usernameController.text, _passwordController.text);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
           Navigator.pushReplacementNamed(context, '/main'); // Or specifically to admin panel?
           // For now, main screen handles admin view if role is admin (need to ensure this)
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Admin Credentials')));
        }
      }
    } else {
      // User login
      final user = await ApiService.login(_usernameController.text, _passwordController.text);
      if (mounted) {
        setState(() => _isLoading = false);
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid username or password')));
        }
      }
    }
  }

  void _joinAsGuest() {
    ApiService.currentUser = User.guest();
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.handyman, size: 60, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'QuickHelp',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      
                      // Toggle User/Admin
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildToggleTab('User', !_isAdmin, () {
                              setState(() {
                                _isAdmin = false;
                                _usernameController.clear();
                                _passwordController.clear();
                              });
                            }),
                            _buildToggleTab('Admin', _isAdmin, () {
                              setState(() {
                                _isAdmin = true;
                                _usernameController.clear();
                                _passwordController.clear();
                              });
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 2,
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isAdmin ? 'Login as Admin' : 'Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      if (!_isAdmin) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            GestureDetector(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                               child: const Text('Register', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _joinAsGuest,
                          child: const Text('Continue as Guest', style: TextStyle(color: Colors.grey)),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
