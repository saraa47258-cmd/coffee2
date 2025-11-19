import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ty_cafe/features/auth/presentation/pages/login_page.dart';
import 'package:ty_cafe/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:ty_cafe/features/orders/presentation/pages/orders_page.dart';
import 'package:ty_cafe/features/profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _avatarPath;
  User? _firebaseUser;

  @override
  void initState() {
    super.initState();
    _syncFirebaseUser();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final picked = await p.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (picked == null) return;
    setState(() => _avatarPath = picked.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _updateFirebaseProfile();
      final profile = Profile(
        id: 'local_user',
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        avatarPath: _avatarPath,
      );
      context.read<ProfileBloc>().add(ProfileUpdateRequested(profile));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<void> _updateFirebaseProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty && name != (user.displayName ?? '')) {
      await user.updateDisplayName(name);
      await user.reload();
      _firebaseUser = FirebaseAuth.instance.currentUser;
    }
  }
  Future<void> _syncFirebaseUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _firebaseUser = user;
      if (_nameCtrl.text.isEmpty && (user.displayName?.isNotEmpty ?? false)) {
        _nameCtrl.text = user.displayName!;
      }
      if (_emailCtrl.text.isEmpty && (user.email?.isNotEmpty ?? false)) {
        _emailCtrl.text = user.email!;
      }
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.read<ProfileBloc>().add(ProfileClearRequested());
      context.read<CartBloc>().add(CartClear());
      context.read<FavoriteBloc>().add(FavoriteClearAll());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }


  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.subtleText.withValues(alpha: 0.14),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.darkText,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.profile != null) {
            setState(() {
              _nameCtrl.text = state.profile!.name.isNotEmpty
                  ? state.profile!.name
                  : (_firebaseUser?.displayName ?? _nameCtrl.text);
              _emailCtrl.text = state.profile!.email.isNotEmpty
                  ? state.profile!.email
                  : (_firebaseUser?.email ?? _emailCtrl.text);
              _phoneCtrl.text = state.profile!.phone;
              _avatarPath = state.profile!.avatarPath;
            });
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withValues(alpha: 0.12),
                          AppColors.whiteBackground,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOutCubic,
                                child: CircleAvatar(
                                  key: ValueKey<String?>(_avatarPath),
                                  radius: 44,
                                  backgroundColor: AppColors.subtleText
                                      .withValues(alpha: 0.12),
                                  backgroundImage: _avatarPath != null
                                      ? FileImage(File(_avatarPath!))
                                      : null,
                                  child: _avatarPath == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 36,
                                          color: AppColors.subtleText,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: Material(
                                  shape: const CircleBorder(),
                                  elevation: 4,
                                  color: Colors.white,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _pickImage,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameCtrl.text.isNotEmpty
                                    ? _nameCtrl.text
                                    : 'Guest User',
                                style: const TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _emailCtrl.text.isNotEmpty
                                    ? _emailCtrl.text
                                    : 'you@example.com',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.subtleText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: AppColors.primaryColor,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Member',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Invite friends',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              SizedBox(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: _inputDecoration(
                              'Full name',
                              hint: 'John Doe',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name required'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailCtrl,
                            decoration: _inputDecoration(
                              'Email',
                              hint: 'you@example.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email required';
                              }
                              final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!pattern.hasMatch(v.trim())) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: _inputDecoration(
                              'Phone',
                              hint: '+62 812 3456 7890',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Phone required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.lock_outline),
                                  label: const Text('Change password'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _logout(),
                                  icon: const Icon(Icons.logout_outlined),
                                  label: const Text('Logout'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrdersPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('عرض الطلبات'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      _StatCard(title: 'Orders', value: '12'),
                      const SizedBox(width: 12),
                      _StatCard(title: 'Favorites', value: '4'),
                      const SizedBox(width: 12),
                      _StatCard(title: 'Credits', value: '9.2 ر.ع.'),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.lerp(
                      AppColors.primaryColor,
                      Colors.orange,
                      0.6,
                    )!,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primaryColor.withValues(alpha: 0.25),
                  ),
                  onPressed: () => _save(),
                  child: const Text(
                    'Save changes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.whiteText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.subtleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
