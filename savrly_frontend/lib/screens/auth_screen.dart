import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import '../models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _showPassword = false; 

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String apiUrl = dotenv.env['BACKEND_URL']!;

  void _forgotPassword() {
    // Implement forgot password functionality
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    try {
      if (isLogin) {
        final authUrl = '$apiUrl/Auth';
        final response = await http.post(
          Uri.parse(authUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': _passwordController.text.trim(),
          }),
        );

        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login unsuccessful: ${response.body}')),
          );
          return;
        }

        Map<String, dynamic> responseData = jsonDecode(response.body);
        String token = responseData['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userProvider.setUser(
          User(
            id: decodedToken['userId'],
            name: decodedToken['name'],
            email: decodedToken['email'],
            token: token,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const MyHomePage(title: 'Welcome to Savrly')),
        );
      } else {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': _passwordController.text.trim(),
            'name': name,
          }),
        );

        if (response.statusCode != 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup unsuccessful: ${response.body}')),
          );
          return;
        }

        setState(() {
          isLogin = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Auth exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final greenGradient = const LinearGradient(
      colors: [Color.fromRGBO(184, 205, 159, 0.5), Color.fromRGBO(184, 205, 159, 0.5)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color.fromRGBO(184, 205, 159, 0.5), Color.fromRGBO(184, 205, 159, 0.5)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isLogin ? 'Hello, From Savrly' : 'Welcome to Savrly',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isLogin ? 'Sign in to your account' : 'Create your account',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                if (!isLogin)
                  _buildInputField(
                    controller: _nameController,
                    icon: Icons.person,
                    hint: 'Name',
                  ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _emailController,
                  icon: Icons.email,
                  hint: 'Email',
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hint: 'Password',
                  obscure: true, 
                ),
                const SizedBox(height: 10),
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    decoration: BoxDecoration(
                      gradient: greenGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin ? 'Sign in' : 'Sign up',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text.rich(
                      TextSpan(
                        text: isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                        children: [
                          TextSpan(
                            text: isLogin ? 'Create' : 'Log in',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure && !_showPassword, 
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: obscure
              ? IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null,
        ),
        validator: (v) => v!.isEmpty ? 'Please enter $hint' : null,
      ),
    );
  }
}
