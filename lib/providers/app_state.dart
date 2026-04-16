import 'package:flutter/material.dart';

import '../models/service.dart';
import '../models/provider_model.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../services/mock_data.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Service> services = <Service>[];
  List<ProviderModel> providers = <ProviderModel>[];
  List<GroupModel> groups = <GroupModel>[];
  List<String> sliderImages = <String>[];

  bool isLoading = false;
  String? errorMessage;
  bool isAuthLoading = false;
  String? authError;
  bool isProfileLoading = false;
  bool isGroupMembersLoading = false;
  bool isProviderDetailsLoading = false;
  bool isLoggedIn = false;
  String? pendingOtpUserId;
  String currentUserName = 'Demo User';
  String currentUserType = 'user';
  String currentUserAvatar = 'https://i.pravatar.cc/150?img=3';
  String currentUserId = '';
  List<GroupMember> currentGroupMembers = <GroupMember>[];
  Map<String, dynamic>? currentProviderDetails;

  AppState();

  Future<bool> login({
    required String mobile,
    required String password,
    required String type,
  }) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final response = await _apiService.loginWithPassword(
        mobile: mobile,
        password: password,
        type: type,
      );

      if (!_isSuccessResponse(response)) {
        authError = _extractMessage(response) ?? 'Login failed';
        return false;
      }

      final user = _extractSingleMap(response);
      currentUserId =
          '${user?['id'] ?? user?['user_id'] ?? user?['business_id'] ?? ''}';
      currentUserName = '${user?['name'] ?? user?['business_name'] ?? 'User'}';
      currentUserType = type;
      currentUserAvatar =
          '${user?['image'] ?? user?['avatar'] ?? 'https://i.pravatar.cc/150?img=3'}';
      isLoggedIn = true;

      await loadInitialData();
      return true;
    } catch (e) {
      authError = e.toString();
      return false;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String mobile,
    required String type,
    required String email,
    required String address,
    required String categoryId,
    required String password,
    required String image,
    required String image1,
    required String image2,
    required String image3,
    required String image4,
    required String licenseNo,
    required String stateId,
    required String cityId,
    required String areaId,
    required String pincode,
    required String lattitude,
    required String longitude,
  }) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final response = await _apiService.registerUser(
        name: name,
        mobile: mobile,
        type: type,
        email: email,
        address: address,
        categoryId: categoryId,
        password: password,
        image: image,
        image1: image1,
        image2: image2,
        image3: image3,
        image4: image4,
        licenseNo: licenseNo,
        stateId: stateId,
        cityId: cityId,
        areaId: areaId,
        pincode: pincode,
        lattitude: lattitude,
        longitude: longitude,
      );

      if (!_isSuccessResponse(response)) {
        authError = _extractMessage(response) ?? 'Registration failed';
        return false;
      }

      final user = _extractSingleMap(response);
      currentUserId =
          '${user?['id'] ?? user?['user_id'] ?? user?['business_id'] ?? ''}';
      currentUserName = '${user?['name'] ?? name}';
      currentUserType = type;
      final responseImage = '${user?['image'] ?? ''}';
      currentUserAvatar = responseImage.isNotEmpty
          ? responseImage
          : (image.isNotEmpty ? image : 'https://i.pravatar.cc/150?img=3');
      isLoggedIn = true;

      await loadInitialData();
      return true;
    } catch (e) {
      authError = e.toString();
      return false;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestLoginOtp({
    required String mobile,
    required String type,
  }) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final response = await _apiService.loginWithOtp(
        mobile: mobile,
        type: type,
      );

      if (!_isSuccessResponse(response)) {
        authError = _extractMessage(response) ?? 'Failed to send OTP';
        return false;
      }

      final user = _extractSingleMap(response);
      pendingOtpUserId =
          '${response['user_id'] ?? response['id'] ?? user?['user_id'] ?? user?['id'] ?? user?['business_id'] ?? ''}'
              .trim();
      if (pendingOtpUserId == null || pendingOtpUserId!.isEmpty) {
        authError = 'Could not read user_id from OTP response';
        return false;
      }

      currentUserType = type;
      return true;
    } catch (e) {
      authError = e.toString();
      return false;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyLoginOtp({
    required String otp,
    required String type,
    String? userId,
  }) async {
    final resolvedUserId = (userId ?? pendingOtpUserId ?? '').trim();
    if (resolvedUserId.isEmpty) {
      authError = 'Missing user_id. Please request OTP again.';
      notifyListeners();
      return false;
    }

    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyOtp(
        userId: resolvedUserId,
        otp: otp,
        type: type,
      );

      if (!_isSuccessResponse(response)) {
        authError = _extractMessage(response) ?? 'OTP verification failed';
        return false;
      }

      final user = _extractSingleMap(response);
      currentUserId =
          '${user?['id'] ?? user?['user_id'] ?? user?['business_id'] ?? resolvedUserId}';
      currentUserName = '${user?['name'] ?? user?['business_name'] ?? 'User'}';
      currentUserType = type;
      currentUserAvatar =
          '${user?['image'] ?? user?['avatar'] ?? 'https://i.pravatar.cc/150?img=3'}';
      pendingOtpUserId = null;
      isLoggedIn = true;

      await loadInitialData();
      return true;
    } catch (e) {
      authError = e.toString();
      return false;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    isLoggedIn = false;
    pendingOtpUserId = null;
    currentUserId = '';
    currentUserName = 'Demo User';
    currentUserType = 'user';
    currentUserAvatar = 'https://i.pravatar.cc/150?img=3';
    authError = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    if (currentUserId.trim().isEmpty) {
      authError = 'Missing user id';
      notifyListeners();
      return null;
    }

    isProfileLoading = true;
    authError = null;
    notifyListeners();

    try {
      final response = await _apiService.getProfile(
        id: currentUserId.trim(),
        type: currentUserType.trim(),
      );

      if (!_isSuccessResponse(response)) {
        authError = _extractMessage(response) ?? 'Failed to load profile';
        return null;
      }

      final profile = _extractProfileMap(response);
      if (profile == null) {
        authError = 'Profile data not found';
        return null;
      }

      currentUserName =
          '${profile['name'] ?? profile['business_name'] ?? currentUserName}';
      final image =
          '${profile['image'] ?? profile['avatar'] ?? currentUserAvatar}';
      if (image.trim().isNotEmpty) {
        currentUserAvatar = image;
      }

      return profile;
    } catch (e) {
      authError = e.toString();
      return null;
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCurrentProfile({
    required String name,
    required String mobile,
    String email = '',
    String address = '',
    String categoryId = '',
    String password = '',
    String stateId = '',
    String cityId = '',
    String areaId = '',
    String pincode = '',
    String lattitude = '',
    String longitude = '',
    String serviceStatus = '1',
  }) async {
    if (currentUserId.trim().isEmpty) {
      authError = 'Missing user id';
      notifyListeners();
      return false;
    }

    isProfileLoading = true;
    authError = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(
        id: currentUserId.trim(),
        name: name,
        mobile: mobile,
        type: currentUserType.trim(),
        email: email,
        address: address,
        categoryId: categoryId,
        password: password,
        stateId: stateId,
        cityId: cityId,
        areaId: areaId,
        pincode: pincode,
        lattitude: lattitude,
        longitude: longitude,
        serviceStatus: serviceStatus,
      );

      if (!_isSuccessResponse(response)) {
        authError = _extractMessage(response) ?? 'Failed to update profile';
        return false;
      }

      currentUserName = name.trim().isEmpty ? currentUserName : name.trim();
      await fetchProfile();
      return true;
    } catch (e) {
      authError = e.toString();
      return false;
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCategories(),
        _loadGroups(),
        _loadSliders(cityId: '1'),
      ]);

      final categoryId = services.isNotEmpty ? services.first.id : '1';
      await _loadBusinesses(
        latitude: '18.5105046',
        longitude: '73.8104764',
        categoryId: categoryId,
      );
    } catch (e) {
      errorMessage = _toUserFacingError(e);
      debugPrint('loadInitialData error: $e');
    }

    if (services.isEmpty) {
      services = MockData.services;
    }
    if (providers.isEmpty) {
      providers = MockData.providers;
    }
    if (groups.isEmpty) {
      groups = MockData.groups;
    }

    isLoading = false;
    notifyListeners();
  }

  String? _toUserFacingError(Object error) {
    final raw = error.toString().toLowerCase();

    // Backend occasionally returns HTML fragments (e.g. </br>) before JSON.
    // This is noisy but not actionable for end users; fallback data is shown.
    if (raw.contains('formatexception') ||
        raw.contains('unexpected character') ||
        raw.contains('</br>') ||
        raw.contains('<br')) {
      return null;
    }

    if (raw.contains('socketexception') || raw.contains('failed host lookup')) {
      return 'Network issue: unable to reach server';
    }

    return 'Some data could not be loaded';
  }

  bool _isSuccessResponse(Map<String, dynamic> response) {
    final status =
        response['status'] ?? response['success'] ?? response['result'];
    if (status != null) {
      final value = '$status'.toLowerCase();
      if (value == '1' || value == 'true' || value == 'success') {
        return true;
      }
      if (value == '0' ||
          value == 'false' ||
          value == 'error' ||
          value == 'failed') {
        return false;
      }
    }

    if (response.containsKey('error') && '${response['error']}'.isNotEmpty) {
      return false;
    }

    final statusCode = _extractNestedStringByKeys(response, {'statusCode'});
    if (statusCode != null && statusCode.isNotEmpty) {
      if (statusCode == '0000' || statusCode == '0' || statusCode == '200') {
        return true;
      }
      if (statusCode != '1') {
        return false;
      }
    }

    return true;
  }

  String? _extractMessage(Map<String, dynamic> response) {
    final message =
        response['message'] ??
        response['msg'] ??
        response['error'] ??
        _extractNestedStringByKeys(response, {'statusDescription'}) ??
        _extractNestedStringByKeys(response, {'message'});
    return message == null ? null : '$message';
  }

  Map<String, dynamic>? _extractSingleMap(Map<String, dynamic> response) {
    if (response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    if (response['Response'] is Map) {
      return Map<String, dynamic>.from(response['Response'] as Map);
    }
    if (response['user'] is Map) {
      return Map<String, dynamic>.from(response['user'] as Map);
    }
    if (response['business'] is Map) {
      return Map<String, dynamic>.from(response['business'] as Map);
    }
    if (response['data'] is List &&
        (response['data'] as List).isNotEmpty &&
        (response['data'] as List).first is Map) {
      return Map<String, dynamic>.from((response['data'] as List).first as Map);
    }
    return null;
  }

  Map<String, dynamic>? _extractProfileMap(Map<String, dynamic> response) {
    final direct = _extractSingleMap(response);
    if (direct != null && _looksLikeProfileMap(direct)) {
      return direct;
    }
    return _findProfileMap(response);
  }

  bool _looksLikeProfileMap(Map<String, dynamic> map) {
    const profileKeys = {
      'name',
      'business_name',
      'mobile',
      'email',
      'address',
      'category_id',
      'city_id',
      'area_id',
      'pincode',
      'image',
      'id',
      'business_id',
      'user_id',
    };
    return map.keys.any(profileKeys.contains);
  }

  Map<String, dynamic>? _findProfileMap(dynamic node) {
    if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      if (_looksLikeProfileMap(map)) {
        return map;
      }
      for (final value in map.values) {
        final nested = _findProfileMap(value);
        if (nested != null) {
          return nested;
        }
      }
    } else if (node is List) {
      for (final item in node) {
        final nested = _findProfileMap(item);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  String? _extractNestedStringByKeys(dynamic node, Set<String> targetKeys) {
    if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      for (final entry in map.entries) {
        if (targetKeys.contains(entry.key) && entry.value != null) {
          return '${entry.value}';
        }
      }
      for (final value in map.values) {
        final nested = _extractNestedStringByKeys(value, targetKeys);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    } else if (node is List) {
      for (final item in node) {
        final nested = _extractNestedStringByKeys(item, targetKeys);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return null;
  }

  Future<void> _loadCategories() async {
    final response = await _apiService.getCategories();
    final items = _apiService.extractList(response);
    final mapped = items
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .map(
          (item) => Service(
            id: '${item['category_id'] ?? item['id'] ?? ''}',
            title:
                '${item['category_name'] ?? item['name'] ?? item['title'] ?? 'Category'}',
            iconUrl:
                '${item['image'] ?? item['icon'] ?? item['icon_url'] ?? 'https://img.icons8.com/color/96/mechanic.png'}',
          ),
        )
        .where((e) => e.id.isNotEmpty)
        .toList();

    if (mapped.isNotEmpty) {
      services = mapped;
    }
  }

  Future<void> _loadGroups() async {
    final response = await _apiService.getGroups();
    final items = _apiService.extractList(response);
    final mapped = items
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .map(
          (item) => GroupModel(
            id: '${item['group_id'] ?? item['id'] ?? ''}',
            name: '${item['group_name'] ?? item['name'] ?? 'Group'}',
            membersCount:
                int.tryParse(
                  '${item['members_count'] ?? item['member_count'] ?? item['total_members'] ?? 0}',
                ) ??
                0,
            online: '${item['status'] ?? item['online'] ?? '0'}' == '1',
          ),
        )
        .where((e) => e.id.isNotEmpty)
        .toList();

    if (mapped.isNotEmpty) {
      groups = mapped;
    }
  }

  Future<void> _loadSliders({required String cityId}) async {
    final response = await _apiService.getSlidersByCity(cityId: cityId);
    final items = _apiService.extractList(response);
    final urls = items
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .map(
          (item) =>
              '${item['image'] ?? item['image_url'] ?? item['slider_image'] ?? ''}',
        )
        .where((url) => url.startsWith('http'))
        .toList();

    if (urls.isNotEmpty) {
      sliderImages = urls;
    }
  }

  Future<void> _loadBusinesses({
    required String latitude,
    required String longitude,
    required String categoryId,
  }) async {
    final response = await _apiService.getBusinesses(
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
    );
    final items = _apiService.extractList(response);
    final mapped = items
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .map((item) {
          final city = '${item['city_name'] ?? ''}'.trim();
          final area = '${item['area_name'] ?? ''}'.trim();
          final address = '${item['address'] ?? ''}'.trim();
          final location = [
            area,
            city,
            address,
          ].where((v) => v.isNotEmpty).join(', ');

          return ProviderModel(
            id: '${item['business_id'] ?? item['id'] ?? ''}',
            name: '${item['business_name'] ?? item['name'] ?? 'Business'}',
            profession:
                '${item['category_name'] ?? item['profession'] ?? 'Service'}',
            location: location.isEmpty ? 'Unknown location' : location,
            avatarUrl:
                '${item['image'] ?? item['logo'] ?? item['avatar'] ?? 'https://i.pravatar.cc/150?img=5'}',
            online: '${item['service_status'] ?? item['status'] ?? '0'}' == '1',
            phone: '${item['mobile'] ?? item['phone'] ?? ''}',
          );
        })
        .where((e) => e.id.isNotEmpty)
        .toList();

    if (mapped.isNotEmpty) {
      providers = mapped;
    }
  }

  Future<bool> loadGroupMembers({required String groupId}) async {
    isGroupMembersLoading = true;
    errorMessage = null;
    currentGroupMembers = <GroupMember>[];
    notifyListeners();

    try {
      final response = await _apiService.getGroupById(groupId: groupId);
      if (!_isSuccessResponse(response)) {
        errorMessage =
            _extractMessage(response) ?? 'Failed to load group members';
        return false;
      }

      final members = _apiService
          .extractGroupMembers(response)
          .map((item) => GroupMember.fromJson(item))
          .where((member) => member.id.isNotEmpty)
          .toList();

      currentGroupMembers = members;
      return true;
    } catch (e) {
      errorMessage = _toUserFacingError(e) ?? 'Failed to load group members';
      return false;
    } finally {
      isGroupMembersLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadBusinessDetails({required String businessId}) async {
    isProviderDetailsLoading = true;
    errorMessage = null;
    currentProviderDetails = null;
    notifyListeners();

    try {
      final response = await _apiService.getBusinessById(
        businessId: businessId,
      );
      if (!_isSuccessResponse(response)) {
        errorMessage =
            _extractMessage(response) ?? 'Failed to load provider details';
        return false;
      }

      currentProviderDetails = _apiService.extractBusinessDetail(response);
      return currentProviderDetails != null;
    } catch (e) {
      errorMessage = _toUserFacingError(e) ?? 'Failed to load provider details';
      return false;
    } finally {
      isProviderDetailsLoading = false;
      notifyListeners();
    }
  }
}
