import 'package:flutter/material.dart';
import 'package:quiz_app1/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isRegisterMode = false;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshSession();
  }

  Future<void> _refreshSession() async {
    setState(() => _isLoading = true);
    final user = await _authService.currentUser();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isRegisterMode) {
        await _authService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      _passwordController.clear();
      await _refreshSession();
    } on StateError catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }

    _showMessage('Wylogowano.');
    setState(() {
      _currentUser = null;
      _isRegisterMode = false;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _currentUser == null ? _buildAuthForm() : _buildProfileCard(),
              ),
            ),
    );
  }

  Widget _buildAuthForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRegisterMode ? 'Załóż konto' : 'Zaloguj się',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRegisterMode
                  ? 'Stwórz konto, aby mieć swój profil.'
                  : 'Zaloguj się, aby zobaczyć swój profil użytkownika.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            if (_isRegisterMode) ...[
              _buildInput(
                controller: _nameController,
                label: 'Nazwa użytkownika',
                icon: Icons.person,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.length < 3) {
                    return 'Nazwa musi mieć min. 3 znaki';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            _buildInput(
              controller: _emailController,
              label: 'E-mail',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (!trimmed.contains('@') || !trimmed.contains('.')) {
                  return 'Podaj poprawny e-mail';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildInput(
              controller: _passwordController,
              label: 'Hasło',
              icon: Icons.lock,
              obscureText: true,
              validator: (value) {
                final raw = value ?? '';
                if (raw.length < 6) {
                  return 'Hasło musi mieć min. 6 znaków';
                }
                return null;
              },
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isRegisterMode ? 'Zarejestruj się' : 'Zaloguj się',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() => _isRegisterMode = !_isRegisterMode);
                      },
                child: Text(
                  _isRegisterMode
                      ? 'Masz konto? Zaloguj się'
                      : 'Nie masz konta? Zarejestruj się',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = _currentUser!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C28),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF6A5AE0),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: Colors.white24),
              const Text(
                'Data utworzenia konta',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 6),
              Text(
                '${user.createdAt.day.toString().padLeft(2, '0')}.${user.createdAt.month.toString().padLeft(2, '0')}.${user.createdAt.year}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Wyloguj'),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1C1C28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}