import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // toggles between login and signup

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (isLogin) {
      // just fake a login for now
      userProvider.setUser(User(id: 'afafafafafaf', name: 'Existing User', email: email));
    } else {
      // fake signup
      userProvider.setUser(User(id: id,name: name, email: email));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isLogin ? 'Logged in!' : 'Signed up!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isLogin)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter your email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      v!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isLogin ? 'Login' : 'Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => isLogin = !isLogin);
                  },
                  child: Text(
                    isLogin
                        ? 'Don’t have an account? Sign up'
                        : 'Already have an account? Log in',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}