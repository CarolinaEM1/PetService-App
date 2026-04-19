import 'package:flutter/material.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final String usuarioCorrecto = 'admin';
  final String passwordCorrecta = 'canina123';

  bool ocultarPassword = true;

  void iniciarSesion() {
    final usuario = usuarioController.text.trim();
    final password = passwordController.text.trim();

    if (usuario == usuarioCorrecto && password == passwordCorrecta) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ListaCitasScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos'),
        ),
      );
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration decorarCampo({
    required String label,
    required IconData icono,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pets,
                    size: 70,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pet Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: usuarioController,
                    decoration: decorarCampo(
                      label: 'Usuario',
                      icono: Icons.person,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: ocultarPassword,
                    decoration: decorarCampo(
                      label: 'Contraseña',
                      icono: Icons.lock,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            ocultarPassword = !ocultarPassword;
                          });
                        },
                        icon: Icon(
                          ocultarPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}