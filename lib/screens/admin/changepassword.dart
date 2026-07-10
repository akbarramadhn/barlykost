import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({super.key});

  @override
  State<AdminChangePasswordScreen> createState() =>
      _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState
    extends State<AdminChangePasswordScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (_isSaving) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui'),
            duration: Duration(seconds: 1),
          ),
        );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: ThemeApp.cancelledRed,
            content: Text(
              error.toString().replaceAll('Exception: ', ''),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: Scaffold(
        backgroundColor: ThemeApp.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPasswordCard(),
                        const SizedBox(height: 22),
                        _buildSaveButton(),
                        const SizedBox(height: 10),
                        _buildCancelButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        border: const Border(
          bottom: BorderSide(
            color: ThemeApp.borderGrey,
            width: 0.8,
          ),
        ),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.04,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _isSaving
                ? null
                : () {
                    Navigator.pop(context, false);
                  },
            borderRadius: ThemeApp.radius(20),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 24,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Ubah Password',
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.textDark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(
            width: 42,
            height: 42,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: ThemeApp.radius(24),
        border: Border.all(
          color: ThemeApp.borderGrey,
          width: 1,
        ),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: ThemeApp.softBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeApp.borderGrey,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: ThemeApp.buttonColor,
                size: 46,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Perbarui Password',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Masukkan password saat ini, kemudian buat password baru untuk akun admin.',
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Password Saat Ini',
            icon: Icons.lock_outline_rounded,
            obscureText: _hideCurrentPassword,
            textInputAction: TextInputAction.next,
            onToggleVisibility: () {
              setState(() {
                _hideCurrentPassword = !_hideCurrentPassword;
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Password saat ini wajib diisi';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Password Baru',
            icon: Icons.password_rounded,
            obscureText: _hideNewPassword,
            textInputAction: TextInputAction.next,
            onToggleVisibility: () {
              setState(() {
                _hideNewPassword = !_hideNewPassword;
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Password baru wajib diisi';
              }

              if (value.length < 8) {
                return 'Password baru minimal 8 karakter';
              }

              if (value == _currentPasswordController.text) {
                return 'Password baru harus berbeda';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Konfirmasi Password Baru',
            icon: Icons.verified_user_outlined,
            obscureText: _hideConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _savePassword();
            },
            onToggleVisibility: () {
              setState(() {
                _hideConfirmPassword = !_hideConfirmPassword;
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password wajib diisi';
              }

              if (value != _newPasswordController.text) {
                return 'Konfirmasi password tidak sesuai';
              }

              return null;
            },
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ThemeApp.softBackground,
              borderRadius: ThemeApp.radius(14),
              border: Border.all(
                color: ThemeApp.borderGrey,
                width: 0.9,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: ThemeApp.buttonColor,
                  size: 21,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Password baru minimal 8 karakter dan harus berbeda dari password saat ini.',
                    style: TextStyle(
                      color: ThemeApp.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    required TextInputAction textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: ThemeApp.textDark,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ThemeApp.textGrey,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: ThemeApp.buttonColor,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: ThemeApp.textGrey,
          ),
        ),
        filled: true,
        fillColor: ThemeApp.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(
            color: ThemeApp.borderGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(
            color: ThemeApp.borderGrey,
            width: 1.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(
            color: ThemeApp.buttonColor,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(
            color: ThemeApp.cancelledRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(
            color: ThemeApp.cancelledRed,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _savePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: ThemeApp.radius(28),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: ThemeApp.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Simpan Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: TextButton(
        onPressed: _isSaving
            ? null
            : () {
                Navigator.pop(context, false);
              },
        style: TextButton.styleFrom(
          foregroundColor: ThemeApp.textGrey,
          shape: RoundedRectangleBorder(
            borderRadius: ThemeApp.radius(26),
          ),
        ),
        child: const Text(
          'Batal',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
