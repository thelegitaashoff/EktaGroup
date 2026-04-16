import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _stateIdController = TextEditingController();
  final _cityIdController = TextEditingController();
  final _areaIdController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _categoryIdController.dispose();
    _stateIdController.dispose();
    _cityIdController.dispose();
    _areaIdController.dispose();
    _pincodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final state = context.read<AppState>();
    final profile = await state.fetchProfile();
    if (!mounted) {
      return;
    }

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.authError ?? 'Failed to load profile')),
      );
      return;
    }

    _nameController.text =
        '${profile['name'] ?? profile['business_name'] ?? state.currentUserName}';
    _mobileController.text = '${profile['mobile'] ?? ''}';
    _emailController.text = '${profile['email'] ?? ''}';
    _addressController.text = '${profile['address'] ?? ''}';
    _categoryIdController.text = '${profile['category_id'] ?? ''}';
    _stateIdController.text = '${profile['state_id'] ?? ''}';
    _cityIdController.text = '${profile['city_id'] ?? ''}';
    _areaIdController.text = '${profile['area_id'] ?? ''}';
    _pincodeController.text = '${profile['pincode'] ?? ''}';
    _latitudeController.text =
        '${profile['lattitude'] ?? profile['latitude'] ?? ''}';
    _longitudeController.text = '${profile['longitude'] ?? ''}';

    setState(() {
      _loaded = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = context.read<AppState>();
    final success = await state.updateCurrentProfile(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      categoryId: _categoryIdController.text.trim(),
      stateId: _stateIdController.text.trim(),
      cityId: _cityIdController.text.trim(),
      areaId: _areaIdController.text.trim(),
      pincode: _pincodeController.text.trim(),
      lattitude: _latitudeController.text.trim(),
      longitude: _longitudeController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully'
              : (state.authError ?? 'Failed to update profile'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: state.isProfileLoading && !_loaded
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ProfileHeader(
                        name: state.currentUserName,
                        avatarUrl: state.currentUserAvatar,
                      ),
                      const SizedBox(height: 14),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _SectionCard(
                              title: 'Basic Details',
                              child: Column(
                                children: [
                                  _field(
                                    _nameController,
                                    'Name',
                                    requiredField: true,
                                    icon: Icons.person_outline,
                                  ),
                                  _field(
                                    _mobileController,
                                    'Mobile',
                                    requiredField: true,
                                    keyboardType: TextInputType.phone,
                                    icon: Icons.phone_android,
                                  ),
                                  _field(
                                    _emailController,
                                    'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    icon: Icons.email_outlined,
                                  ),
                                  _field(
                                    _addressController,
                                    'Address',
                                    icon: Icons.location_on_outlined,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'Service & Location',
                              child: Column(
                                children: [
                                  _field(
                                    _categoryIdController,
                                    'Category ID',
                                    keyboardType: TextInputType.number,
                                    icon: Icons.category_outlined,
                                  ),
                                  _field(
                                    _stateIdController,
                                    'State ID',
                                    keyboardType: TextInputType.number,
                                  ),
                                  _field(
                                    _cityIdController,
                                    'City ID',
                                    keyboardType: TextInputType.number,
                                  ),
                                  _field(
                                    _areaIdController,
                                    'Area ID',
                                    keyboardType: TextInputType.number,
                                  ),
                                  _field(
                                    _pincodeController,
                                    'Pincode',
                                    keyboardType: TextInputType.number,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _field(
                                          _latitudeController,
                                          'Latitude',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _field(
                                          _longitudeController,
                                          'Longitude',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: state.isProfileLoading
                                    ? null
                                    : _saveProfile,
                                icon: state.isProfileLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(
                                  state.isProfileLoading
                                      ? 'Updating...'
                                      : 'Update Profile',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF374151)),
          prefixIcon: icon == null
              ? null
              : Icon(icon, color: Colors.red.shade300),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.6),
          ),
        ),
        validator: (v) {
          if (!requiredField) {
            return null;
          }
          if (v == null || v.trim().isEmpty) {
            return 'Enter $label';
          }
          return null;
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const _ProfileHeader({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE53935), Color(0xFFEF4444)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.grey, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.trim().isEmpty ? 'User' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
