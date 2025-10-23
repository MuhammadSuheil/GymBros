import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../tracking/view/workout_tracking_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- PERUBAHAN: Handle navigasi setelah sukses ---
  void _handleLogin(BuildContext context) async { // Tambah async
    print("[LoginScreen] Login button pressed.");
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    viewModel.resetErrorState();

    if (_formKey.currentState!.validate()) {
       print("[LoginScreen] Form valid, calling ViewModel...");
       // Panggil ViewModel dan TUNGGU hasilnya
       bool success = await viewModel.signInWithEmail(
         email: _emailController.text.trim(),
         password: _passwordController.text.trim(),
       );

        // Jika berhasil, navigasi ke layar utama
       if (success && mounted) {
          print("[LoginScreen] Login success, navigating to Main App.");
          Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const WorkoutTrackingScreen()) // Ganti ke HomeScreen nanti
          );
       }
       // Jika gagal, Snackbar akan ditampilkan oleh Consumer
    } else {
       print("[LoginScreen] Form invalid.");
    }
  }
  // --- Akhir Perubahan ---

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>( /* ... (Consumer sama) ... */
      builder: (context, viewModel, child) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.state == AuthState.Error && viewModel.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar( content: Text(viewModel.errorMessage), backgroundColor: Colors.redAccent,),
            );
            viewModel.resetErrorState();
          }
        });

        return Scaffold( /* ... (UI sama) ... */
          appBar: AppBar( title: const Text('Login GymBros'), automaticallyImplyLeading: false,),
          body: Center( child: SingleChildScrollView( padding: const EdgeInsets.all(24.0),
              child: Form( key: _formKey, child: Column( /* ... form fields sama ... */
                   children: [
                    Text( 'Selamat Datang Kembali!', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center, ),
                    const SizedBox(height: 32),
                    TextFormField( controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress, validator: (value) { if (value == null || value.isEmpty || !value.contains('@')) { return 'Masukkan email yang valid'; } return null; },),
                    const SizedBox(height: 16),
                    TextFormField( controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true, validator: (value) { if (value == null || value.isEmpty || value.length < 6) { return 'Password minimal 6 karakter'; } return null; },),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: viewModel.state == AuthState.Loading ? null : () => _handleLogin(context),
                      child: viewModel.state == AuthState.Loading ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),) : const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    TextButton( onPressed: viewModel.state == AuthState.Loading ? null : () { Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const RegisterScreen()), ); }, child: const Text('Belum punya akun? Daftar di sini'), ),
                  ],
              ),),
           ),),
        );
      },
    );
  }
}

