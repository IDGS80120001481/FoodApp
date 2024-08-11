import 'package:flutter/material.dart';
import 'package:flutter_foodapp/services/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Maasai Food Restaurante",
              style: TextStyle(fontSize: 32, color: Colors.blue),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              child: TextField(
                style: TextStyle(color: Colors.blue.shade900),
                controller: _userController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Usuario: ',
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              child: TextField(
                style: TextStyle(color: Colors.blue.shade900),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Contraseña: ',
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await login(
                    _userController.text, _passwordController.text, context);
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.blue,
                textStyle: TextStyle(color: Colors.blue.shade900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(300, 50),
              ),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
