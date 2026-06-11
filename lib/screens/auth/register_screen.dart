import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await authService.register(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil. Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration underlineInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: Colors.black,
        size: 25,
      ),
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(
        color: Colors.black,
        fontSize: 19,
        fontWeight: FontWeight.w400,
      ),
      filled: false,
      contentPadding: const EdgeInsets.only(
        top: 12,
        bottom: 8,
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.5,
        ),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.5,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.5,
        ),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.5,
        ),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double logoSize = screenHeight < 750 ? 90 : 110;
    final double titleSize = screenHeight < 750 ? 30 : 36;
    final double registerTitleSize = screenHeight < 750 ? 27 : 31;
    final double buttonHeight = screenHeight < 750 ? 56 : 62;
    final double fieldSpacing = screenHeight < 750 ? 14 : 18;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: ThemeApp.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  Icon(
                    Icons.home_work_rounded,
                    size: logoSize,
                    color: Colors.black,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Barly Kost',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const Spacer(flex: 1),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: registerTitleSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(height: fieldSpacing),

                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    decoration: underlineInputDecoration(
                      hintText: 'Name',
                      prefixIcon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }

                      if (value.trim().length < 3) {
                        return 'Nama minimal 3 karakter';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: fieldSpacing),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    decoration: underlineInputDecoration(
                      hintText: 'Nomor Telepon',
                      prefixIcon: Icons.phone_android_outlined,
                      prefixText: '+62  ',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor telepon wajib diisi';
                      }

                      if (value.trim().length < 8) {
                        return 'Nomor telepon tidak valid';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: fieldSpacing),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    decoration: underlineInputDecoration(
                      hintText: 'Email ID',
                      prefixIcon: Icons.alternate_email,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }

                      if (!value.contains('@')) {
                        return 'Format email tidak valid';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: fieldSpacing),

                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    decoration: underlineInputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password wajib diisi';
                      }

                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Dengan mendaftar, Anda menyetujui Syarat &\nKetentuan dan Kebijakan Privasi Kami',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeApp.buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}