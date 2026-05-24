import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _isLogin = true;
  bool _showAdminField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_city,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Urban Plan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Planeamento Urbano Colaborativo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  if (!_isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: Validators.validateName,
                    ),
                  if (!_isLogin) const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Palavra-passe',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // Campo de código ADMIN - APENAS PARA REGISTRO
                  if (!_isLogin && _showAdminField)
                    TextFormField(
                      controller: _adminCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de Administrador',
                        prefixIcon: Icon(Icons.admin_panel_settings),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                  // Checkbox para ADMIN (sem hint do código)
                  if (!_isLogin)
                    Row(
                      children: [
                        Checkbox(
                          value: _showAdminField,
                          onChanged: (value) {
                            setState(() {
                              _showAdminField = value ?? false;
                              if (!_showAdminField) {
                                _adminCodeController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Registar como Administrador'),
                      ],
                    ),

                  const SizedBox(height: 24),

                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return CustomButton(
                        text: _isLogin ? 'Entrar' : 'Registar',
                        onPressed: () => _submitForm(authProvider),
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _showAdminField = false;
                        _adminCodeController.clear();
                        _formKey.currentState?.reset();
                      });
                    },
                    child: Text(_isLogin
                        ? 'Não tem conta? Registar'
                        : 'Já tem conta? Entrar'),
                  ),

                  if (_isLogin)
                    TextButton(
                      onPressed: () => _resetPassword(),
                      child: const Text('Esqueceu a palavra-passe?'),
                    ),

                  if (context.watch<AuthProvider>().errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        context.watch<AuthProvider>().errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      bool success;

      if (_isLogin) {
        success = await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        String? adminCode = _showAdminField ? _adminCodeController.text : null;
        success = await authProvider.register(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          adminCode,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Bem-vindo de volta!' : 'Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu email primeiro')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperação enviado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
}