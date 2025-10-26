import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'login_screen.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../core/widgets/dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister(BuildContext context) async {
    print("[RegisterScreen] Register button pressed.");
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    viewModel.resetErrorState();

    if (_formKey.currentState!.validate()) {
      print("[RegisterScreen] Form valid, calling ViewModel...");
      bool success = await viewModel.createUserWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (success && mounted) {
        print("[RegisterScreen] Registration success. Signing out user before showing dialog...");
        try {
          await FirebaseAuth.instance.signOut();
          print("[RegisterScreen] User signed out successfully after registration.");
        } catch (e) {
           print("[RegisterScreen] Error signing out after registration: $e");   
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Registrasi Berhasil!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                   SizedBox(height: 8),
                  Text(
                    'Silakan login dengan akun baru Anda.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); 
                    if (mounted) {
                       Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen())
                       );
                    }
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      print("[RegisterScreen] Form invalid.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.state == AuthState.Error && viewModel.errorMessage.isNotEmpty) {
            showErrorPopup(context, 'Registration Failed', viewModel.errorMessage);
            viewModel.resetErrorState();
          }
        });

        return Scaffold(
           appBar: AppBar( title: const Text('Daftar Akun GymBros'), automaticallyImplyLeading: false,),
           body: Center( child: SingleChildScrollView( padding: const EdgeInsets.all(24.0),
              child: Form( key: _formKey, child: Column(
                   children: [
                    Text( 'Buat Akun Baru', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
                    const SizedBox(height: 32),
                    TextFormField( controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress, validator: (value) { if (value == null || value.isEmpty || !value.contains('@')) { return 'Masukkan email yang valid'; } return null; },),
                    const SizedBox(height: 16),
                    TextFormField( controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true, validator: (value) { if (value == null || value.isEmpty || value.length < 6) { return 'Password minimal 6 karakter'; } return null; },),
                    const SizedBox(height: 16),
                     TextFormField( controller: _confirmPasswordController, decoration: const InputDecoration(labelText: 'Konfirmasi Password', prefixIcon: Icon(Icons.lock_reset_outlined)), obscureText: true, validator: (value) { if (value == null || value.isEmpty) { return 'Konfirmasi password tidak boleh kosong'; } if (value != _passwordController.text) { return 'Password tidak cocok'; } return null; },),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: viewModel.state == AuthState.Loading ? null : () => _handleRegister(context),
                      child: viewModel.state == AuthState.Loading ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),) : const Text('Daftar'),
                    ),
                     const SizedBox(height: 16),
                    TextButton( onPressed: viewModel.state == AuthState.Loading ? null : () { Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const LoginScreen()), ); }, child: const Text('Sudah punya akun? Login di sini'),),
                  ],
              ),),
           ),),
        );
      },
    );
  }
}
