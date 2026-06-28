import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService authService = AuthService();
  final ImagePicker imagePicker = ImagePicker();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController roleController;

  File? selectedImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(
      text: widget.user.fullName,
    );

    phoneController = TextEditingController(
      text: widget.user.phone,
    );

    emailController = TextEditingController(
      text: widget.user.email,
    );

    roleController = TextEditingController(
      text: widget.user.displayRole,
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      selectedImage = File(pickedImage.path);
    });
  }

  Future<void> saveProfile() async {
    if (isSaving) {
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await authService.updateProfile(
        fullName: fullNameController.text,
        phone: phoneController.text,
        profileImageFile: selectedImage,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          duration: Duration(seconds: 1),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Column(
          children: [
            buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: ThemeApp.backgroundGradient,
                child: buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
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
            onTap: () {
              Navigator.pop(context, false);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.centerLeft,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 26,
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Edit Profile',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
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

  Widget buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            buildPhotoCard(),
            const SizedBox(height: 18),
            buildFormCard(),
            const SizedBox(height: 22),
            buildSaveButton(),
            const SizedBox(height: 12),
            buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget buildPhotoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: pickImage,
            child: Stack(
              children: [
                buildAvatar(),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: ThemeApp.buttonColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeApp.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
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
            'Ketuk foto untuk mengganti foto profil',
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

  Widget buildAvatar() {
    final hasSelectedImage = selectedImage != null;
    final hasProfileImage = widget.user.profileImageUrl.trim().isNotEmpty;

    if (hasSelectedImage) {
      return Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ThemeApp.white,
            width: 4,
          ),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.10,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
          image: DecorationImage(
            image: FileImage(selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (hasProfileImage) {
      return Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ThemeApp.white,
            width: 4,
          ),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.10,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(widget.user.profileImageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: ThemeApp.softGreen,
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeApp.white,
          width: 4,
        ),
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

  Widget buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
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
          buildTextField(
            controller: fullNameController,
            label: 'Nama Lengkap',
            icon: Icons.badge_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: phoneController,
            label: 'No. Telepon',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'No. telepon tidak boleh kosong';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: emailController,
            label: 'Email',
            icon: Icons.email_rounded,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: roleController,
            label: 'Role',
            icon: Icons.verified_user_rounded,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
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
        prefixIcon: Icon(
          icon,
          color: ThemeApp.buttonColor,
        ),
        filled: true,
        fillColor: readOnly ? ThemeApp.lightGrey : ThemeApp.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeApp.borderGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeApp.borderGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeApp.buttonColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeApp.cancelledRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: ThemeApp.cancelledRed,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSaving ? null : saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isSaving
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        onPressed: isSaving
            ? null
            : () {
                Navigator.pop(context, false);
              },
        style: TextButton.styleFrom(
          foregroundColor: ThemeApp.textGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
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