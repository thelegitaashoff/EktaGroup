import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _defaultLatitude = '18.5105046';
  static const String _defaultLongitude = '73.8104764';
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  String _type = 'user';
  bool _isLoadingDropdowns = false;
  bool _showImageError = false;
  bool _showLicenseImageError = false;
  List<_OptionItem> _cities = <_OptionItem>[];
  List<_OptionItem> _areas = <_OptionItem>[];
  List<_OptionItem> _categories = <_OptionItem>[];

  String? _selectedCityId;
  String? _selectedAreaId;
  String? _selectedCategoryId;
  XFile? _selectedImageFile;
  String? _selectedImageBase64;
  XFile? _selectedLicenseImageFile;
  String? _selectedLicenseImageBase64;

  @override
  void initState() {
    super.initState();
    _loadInitialDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImageFile = file;
      _selectedImageBase64 = base64Encode(bytes);
      _showImageError = false;
    });
  }

  Future<void> _pickLicenseImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedLicenseImageFile = file;
      _selectedLicenseImageBase64 = base64Encode(bytes);
      _showLicenseImageError = false;
    });
  }

  String _normalizedCategoryLabel(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  bool get _requiresLicensePhoto {
    if (_type != 'business' || _selectedCategoryId == null) {
      return false;
    }
    final selected = _categories
        .where((item) => item.id == _selectedCategoryId)
        .map((item) => _normalizedCategoryLabel(item.label))
        .firstWhere((_) => true, orElse: () => '');
    if (selected.isEmpty) {
      return false;
    }
    return selected.contains('bus driver') ||
        selected.contains('car driver') ||
        selected.contains('truck driver') ||
        selected.contains('track driver');
  }

  Future<void> _loadInitialDropdownData() async {
    setState(() => _isLoadingDropdowns = true);
    try {
      final responses = await Future.wait([
        _apiService.getCity(),
        _apiService.getCategories(),
      ]);

      final cityItems = _extractOptions(
        responses[0],
        nameKeys: const ['city_name', 'name', 'title'],
      );
      final categoryItems = _extractOptions(
        responses[1],
        nameKeys: const ['category_name', 'name', 'title'],
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _cities = cityItems;
        _categories = categoryItems;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load cities/categories')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingDropdowns = false);
      }
    }
  }

  Future<void> _loadAreasByCity(String cityId) async {
    setState(() {
      _isLoadingDropdowns = true;
      _areas = <_OptionItem>[];
      _selectedAreaId = null;
    });

    try {
      final response = await _apiService.getAreaByCityId(cityId: cityId);
      final areaItems = _extractOptions(
        response,
        nameKeys: const ['area_name', 'name', 'title'],
      );
      if (!mounted) {
        return;
      }
      setState(() => _areas = areaItems);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load areas for selected city')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingDropdowns = false);
      }
    }
  }

  List<_OptionItem> _extractOptions(
    Map<String, dynamic> response, {
    required List<String> nameKeys,
  }) {
    final maps = <Map<String, dynamic>>[];

    void walk(dynamic node) {
      if (node is Map) {
        final map = Map<String, dynamic>.from(node);
        if (map.containsKey('id')) {
          maps.add(map);
        }
        for (final value in map.values) {
          walk(value);
        }
      } else if (node is List) {
        for (final item in node) {
          walk(item);
        }
      }
    }

    walk(response);

    final seen = <String>{};
    final output = <_OptionItem>[];
    for (final map in maps) {
      final id = '${map['id'] ?? ''}'.trim();
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      String label = '';
      for (final key in nameKeys) {
        final value = '${map[key] ?? ''}'.trim();
        if (value.isNotEmpty) {
          label = value;
          break;
        }
      }
      if (label.isEmpty) {
        label = 'ID $id';
      }
      seen.add(id);
      output.add(_OptionItem(id: id, label: label));
    }
    return output;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if ((_selectedImageBase64 ?? '').isEmpty) {
      setState(() => _showImageError = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }
    if (_requiresLicensePhoto && (_selectedLicenseImageBase64 ?? '').isEmpty) {
      setState(() => _showLicenseImageError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select license photo')),
      );
      return;
    }

    if (_type == 'business') {
      if (_selectedCategoryId == null ||
          _selectedCityId == null ||
          _selectedAreaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'For business, please select category, city and area',
            ),
          ),
        );
        return;
      }
    }

    final mobile = _mobileController.text.trim();
    final autoEmail = 'user$mobile@ektadrivers.app';
    final state = context.read<AppState>();
    final success = await state.register(
      name: _nameController.text.trim(),
      mobile: mobile,
      type: _type,
      email: autoEmail,
      address: _addressController.text.trim(),
      categoryId: _type == 'business' ? (_selectedCategoryId ?? '') : '1',
      password: _passwordController.text.trim(),
      image: _selectedImageBase64 ?? '',
      image1: _selectedLicenseImageBase64 ?? '',
      image2: '',
      image3: '',
      image4: '',
      licenseNo: '',
      stateId: '',
      cityId: _type == 'business' ? (_selectedCityId ?? '') : '',
      areaId: _type == 'business' ? (_selectedAreaId ?? '') : '',
      pincode: '',
      lattitude: _defaultLatitude,
      longitude: _defaultLongitude,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.authError ?? 'Registration failed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTypeSelector(),
                        const SizedBox(height: 16),
                        _field(
                          _nameController,
                          'Full Name',
                          requiredField: true,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 4),
                        _buildImagePicker(),
                        if (_showImageError) ...[
                          const SizedBox(height: 4),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Please select image',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else
                          const SizedBox(height: 12),
                        _field(
                          _mobileController,
                          'Mobile Number',
                          requiredField: true,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_android,
                        ),
                        _field(
                          _passwordController,
                          'Password',
                          requiredField: true,
                          obscureText: true,
                          icon: Icons.lock_outline,
                        ),
                        _field(
                          _addressController,
                          'Address',
                          requiredField: true,
                          icon: Icons.location_on_outlined,
                        ),
                        if (_type == 'business') ...[
                          _dropdown(
                            label: 'Category',
                            value: _selectedCategoryId,
                            items: _categories,
                            onChanged: (v) {
                              setState(() {
                                _selectedCategoryId = v;
                                _showLicenseImageError = false;
                              });
                            },
                          ),
                          if (_requiresLicensePhoto) ...[
                            _buildLicenseImagePicker(),
                            if (_showLicenseImageError) ...[
                              const SizedBox(height: 4),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Please select license photo',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ] else
                              const SizedBox(height: 12),
                          ],
                          _dropdown(
                            label: 'City',
                            value: _selectedCityId,
                            items: _cities,
                            onChanged: (v) {
                              setState(() => _selectedCityId = v);
                              if (v != null && v.isNotEmpty) {
                                _loadAreasByCity(v);
                              }
                            },
                          ),
                          _dropdown(
                            label: 'Area',
                            value: _selectedAreaId,
                            items: _areas,
                            onChanged: (v) =>
                                setState(() => _selectedAreaId = v),
                          ),
                        ],
                        if (_isLoadingDropdowns) ...[
                          const SizedBox(height: 6),
                          const LinearProgressIndicator(),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isAuthLoading ? null : _submit,
                            child: state.isAuthLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Register'),
                          ),
                        ),
                        TextButton(
                          onPressed: state.isAuthLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Back to login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _typeChip('user')),
          const SizedBox(width: 8),
          Expanded(child: _typeChip('business')),
        ],
      ),
    );
  }

  Widget _typeChip(String value) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = value;
          if (_type != 'business') {
            _selectedCityId = null;
            _selectedAreaId = null;
            _selectedCategoryId = null;
            _selectedLicenseImageFile = null;
            _selectedLicenseImageBase64 = null;
            _showLicenseImageError = false;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<_OptionItem> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: Colors.white,
        items: items
            .map(
              (e) =>
                  DropdownMenuItem<String>(value: e.id, child: Text(e.label)),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF374151)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
        ),
        validator: (v) {
          if (_type == 'business' && (v == null || v.trim().isEmpty)) {
            return 'Select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Image', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: _selectedImageFile == null
              ? const Text('No image selected')
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImageFile!.path),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLicenseImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'License Photo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: _selectedLicenseImageFile == null
              ? const Text('No license photo selected')
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedLicenseImageFile!.path),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickLicenseImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickLicenseImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
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

class _OptionItem {
  final String id;
  final String label;

  const _OptionItem({required this.id, required this.label});
}
