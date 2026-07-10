import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/admin_profile.dart';
import '../../services/auth_service.dart';

class AdminEditProfileScreen extends StatefulWidget {
  final AdminProfile profile;

  const AdminEditProfileScreen({super.key, required this.profile});

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;

  File? _selectedImage;
  bool _isPickingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(
      text: widget.profile.phone == '-' ? '' : widget.profile.phone,
    );
    _emailController = TextEditingController(text: widget.profile.email);
    _roleController = TextEditingController(text: 'Admin');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || _isSaving) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (!mounted) {
        return;
      }

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _authService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageFile: _selectedImage,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profil admin berhasil diperbarui'),
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

      _showMessage(error.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: ThemeApp.white,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                color: ThemeApp.white,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 48, 18, 16),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.05,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isSaving
                ? null
                : () {
                    Navigator.pop(context, false);
                  },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 25,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Profil Admin',
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
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPhotoCard(),
            const SizedBox(height: 18),
            _buildFormCard(),
            const SizedBox(height: 22),
            _buildSaveButton(),
            const SizedBox(height: 12),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: ThemeApp.radius(26),
        border: Border.all(
          color: ThemeApp.borderGrey.withValues(alpha: 0.65),
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
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: ThemeApp.buttonColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: ThemeApp.white, width: 3),
                    ),
                    child: _isPickingImage
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              color: ThemeApp.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: ThemeApp.white,
                            size: 17,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Foto Profil',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ketuk foto untuk mengganti foto profil admin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final String imageUrl = widget.profile.profileImageUrl?.trim() ?? '';

    if (_selectedImage != null) {
      return _avatarContainer(image: FileImage(_selectedImage!));
    }

    if (imageUrl.isNotEmpty) {
      return _avatarContainer(image: NetworkImage(imageUrl));
    }

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: ThemeApp.softGreen,
        shape: BoxShape.circle,
        border: Border.all(color: ThemeApp.white, width: 4),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.10,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: ThemeApp.buttonColor,
        size: 72,
      ),
    );
  }

  Widget _avatarContainer({required ImageProvider<Object> image}) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ThemeApp.white, width: 4),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.10,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: ThemeApp.radius(26),
        border: Border.all(
          color: ThemeApp.borderGrey.withValues(alpha: 0.65),
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
          const Text(
            'Informasi Profil',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _fullNameController,
            label: 'Nama Lengkap',
            icon: Icons.badge_rounded,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }

              if (value.trim().length < 3) {
                return 'Nama lengkap minimal 3 karakter';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'No. Telepon',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'No. telepon tidak boleh kosong';
              }

              if (value.trim().length < 9) {
                return 'No. telepon tidak valid';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_rounded,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _roleController,
            label: 'Role',
            icon: Icons.verified_user_rounded,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: readOnly ? ThemeApp.textGrey : ThemeApp.textDark,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ThemeApp.textGrey,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: ThemeApp.buttonColor),
        filled: true,
        fillColor: readOnly ? ThemeApp.lightGrey : ThemeApp.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(color: ThemeApp.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(color: ThemeApp.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(color: ThemeApp.buttonColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ThemeApp.radius(18),
          borderSide: const BorderSide(color: ThemeApp.cancelledRed),
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
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(28)),
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
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        onPressed: _isSaving
            ? null
            : () {
                Navigator.pop(context, false);
              },
        style: TextButton.styleFrom(
          foregroundColor: ThemeApp.textGrey,
          shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(27)),
        ),
        child: const Text(
          'Batal',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
