import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://ektadrivers.myclanservices.co.in/api';

  static const String _login = 'login.php';
  static const String _loginOtp = 'login_otp.php';
  static const String _verifyOtp = 'verify_otp.php';
  static const String _register = 'register.php';
  static const String _getCity = 'get_city.php';
  static const String _getArea = 'get_area.php';
  static const String _getCategories = 'get_categories.php';
  static const String _getGroups = 'get_groups.php';
  static const String _getGroupById = 'get_group_by_id.php';
  static const String _getSlidersByCity = 'get_sliders_by_city.php';
  static const String _getBusinesses = 'get_businesses.php';
  static const String _getBusinessById = 'get_business_by_id.php';
  static const String _getGarages = 'get_garages.php';
  static const String _getGarageById = 'get_garage_by_id.php';
  static const String _filter = 'filter.php';
  static const String _getProfile = 'get_profile.php';
  static const String _updateProfile = 'update_profile.php';
  static const String _updateBusinessStatus = 'update_business_status.php';
  static const String _updateBusinessImages = 'update_business_images.php';
  static const String _updateLocation = 'update_location.php';

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final response = await http.get(uri);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final jsonResponse = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    final parsedJsonResponse = _parseResponse(jsonResponse);
    if (!_isParameterListError(parsedJsonResponse)) {
      return parsedJsonResponse;
    }

    final formResponse = await http.post(
      uri,
      body: body.map((key, value) => MapEntry(key, '$value')),
    );
    return _parseResponse(formResponse);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = _decodeJsonPayload(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List) {
      return {'data': decoded};
    }

    return {'data': decoded};
  }

  dynamic _decodeJsonPayload(String rawBody) {
    final trimmed = rawBody.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty response body');
    }

    try {
      return jsonDecode(trimmed);
    } on FormatException {
      final sanitized = _extractJsonSubstring(trimmed);
      if (sanitized == null) {
        return trimmed;
      }
      try {
        return jsonDecode(sanitized);
      } on FormatException {
        return trimmed;
      }
    }
  }

  String? _extractJsonSubstring(String input) {
    final firstObject = input.indexOf('{');
    final firstArray = input.indexOf('[');
    int start = -1;
    if (firstObject >= 0 && firstArray >= 0) {
      start = firstObject < firstArray ? firstObject : firstArray;
    } else if (firstObject >= 0) {
      start = firstObject;
    } else if (firstArray >= 0) {
      start = firstArray;
    }
    if (start < 0) {
      return null;
    }

    final sliced = input.substring(start);
    final lastObject = sliced.lastIndexOf('}');
    final lastArray = sliced.lastIndexOf(']');
    final end = lastObject > lastArray ? lastObject : lastArray;
    if (end < 0) {
      return null;
    }

    final candidate = sliced.substring(0, end + 1).trim();
    return candidate.isEmpty ? null : candidate;
  }

  bool _isParameterListError(Map<String, dynamic> response) {
    bool walk(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          final key = '${entry.key}'.toLowerCase();
          final value = '${entry.value}'.toLowerCase();
          if ((key.contains('statuscode') &&
                  (value == '0002' || value == '0003')) ||
              (key.contains('statusdescription') &&
                  value.contains('parameter list'))) {
            return true;
          }
          if (walk(entry.value)) {
            return true;
          }
        }
      } else if (node is List) {
        for (final item in node) {
          if (walk(item)) {
            return true;
          }
        }
      }
      return false;
    }

    return walk(response);
  }

  Future<Map<String, dynamic>> updateLocation({
    required String userId,
    required String lat,
    required String longi,
  }) {
    return _post(_updateLocation, {
      'user_id': userId,
      'lat': lat,
      'longi': longi,
    });
  }

  Future<Map<String, dynamic>> getSlidersByCity({required String cityId}) {
    return _post(_getSlidersByCity, {'city_id': cityId});
  }

  Future<Map<String, dynamic>> getGroups() {
    return _get(_getGroups);
  }

  Future<Map<String, dynamic>> getGroupById({required String groupId}) {
    return _post(_getGroupById, {'group_id': groupId});
  }

  Future<Map<String, dynamic>> getCity() {
    return _get(_getCity);
  }

  Future<Map<String, dynamic>> getAreaByCityId({required String cityId}) {
    return _post(_getArea, {'city_id': cityId});
  }

  Future<Map<String, dynamic>> getCategories() {
    return _get(_getCategories);
  }

  Future<Map<String, dynamic>> getBusinesses({
    required String latitude,
    required String longitude,
    required String categoryId,
  }) {
    return _post(_getBusinesses, {
      'lattitude': latitude,
      'longitude': longitude,
      'category_id': categoryId,
    });
  }

  Future<Map<String, dynamic>> getBusinessById({required String businessId}) {
    return _post(_getBusinessById, {'business_id': businessId});
  }

  Future<Map<String, dynamic>> getGarages({required String cityId}) {
    return _post(_getGarages, {'city_id': cityId});
  }

  Future<Map<String, dynamic>> getGarageById({required String garageId}) {
    return _post(_getGarageById, {'garage_id': garageId});
  }

  Future<Map<String, dynamic>> filter({
    required String categoryId,
    required String cityId,
    required String areaId,
  }) {
    return _post(_filter, {
      'category_id': categoryId,
      'city_id': cityId,
      'area_id': areaId,
    });
  }

  Future<Map<String, dynamic>> loginWithOtp({
    required String mobile,
    required String type,
  }) {
    return _post(_loginOtp, {'mobile': mobile, 'type': type});
  }

  Future<Map<String, dynamic>> loginWithPassword({
    required String mobile,
    required String password,
    required String type,
  }) {
    return _post(_login, {
      'mobile': mobile,
      'password': password,
      'type': type,
    });
  }

  Future<Map<String, dynamic>> registerUser({
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
  }) {
    return _post(_register, {
      'name': name,
      'mobile': mobile,
      'type': type,
      'email': email,
      'address': address,
      'category_id': categoryId,
      'password': password,
      'image': image,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'image4': image4,
      'license_no': licenseNo,
      'state_id': stateId,
      'city_id': cityId,
      'area_id': areaId,
      'pincode': pincode,
      'lattitude': lattitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
    required String type,
  }) {
    return _post(_verifyOtp, {'user_id': userId, 'otp': otp, 'type': type});
  }

  Future<Map<String, dynamic>> updateBusinessStatus({
    required String businessId,
    required String status,
  }) {
    return _post(_updateBusinessStatus, {
      'business_id': businessId,
      'status': status,
    });
  }

  Future<Map<String, dynamic>> updateBusinessImages({
    required String businessId,
    required String pos,
    required String image,
  }) {
    return _post(_updateBusinessImages, {
      'business_id': businessId,
      'pos': pos,
      'image': image,
    });
  }

  Future<Map<String, dynamic>> updateProfile({
    required String id,
    required String name,
    required String mobile,
    required String type,
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
  }) {
    return _post(_updateProfile, {
      'id': id,
      'name': name,
      'mobile': mobile,
      'type': type,
      'email': email,
      'address': address,
      'category_id': categoryId,
      'password': password,
      'state_id': stateId,
      'city_id': cityId,
      'area_id': areaId,
      'pincode': pincode,
      'lattitude': lattitude,
      'longitude': longitude,
      'service_status': serviceStatus,
    });
  }

  Future<Map<String, dynamic>> getProfile({
    required String id,
    required String type,
  }) {
    return _post(_getProfile, {'id': id, 'type': type});
  }

  List<dynamic> extractList(Map<String, dynamic> response) {
    const candidateKeys = [
      'data',
      'result',
      'results',
      'list',
      'groups',
      'businesses',
      'categories',
      'cities',
      'areas',
      'sliders',
      'members',
    ];

    for (final key in candidateKeys) {
      final value = response[key];
      if (value is List) {
        return value;
      }
    }

    if (response.length == 1) {
      final onlyValue = response.values.first;
      if (onlyValue is List) {
        return onlyValue;
      }
    }

    return const [];
  }

  List<Map<String, dynamic>> extractGroupMembers(
    Map<String, dynamic> response,
  ) {
    final members = _extractListByPath(response, const [
      ['GroupResponse', 'memberData'],
      ['groupResponse', 'memberData'],
      ['memberData'],
      ['data'],
      ['members'],
    ]);
    return members.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Map<String, dynamic>? extractBusinessDetail(Map<String, dynamic> response) {
    final items = _extractListByPath(response, const [
      ['businessResponse', 'businessData'],
      ['BusinessResponse', 'businessData'],
      ['businessData'],
      ['data'],
      ['business'],
    ]);
    if (items.isNotEmpty) {
      return Map<String, dynamic>.from(items.first);
    }

    final direct = response['business'];
    if (direct is Map) {
      return Map<String, dynamic>.from(direct);
    }
    return null;
  }

  List<Map<String, dynamic>> _extractListByPath(
    Map<String, dynamic> response,
    List<List<String>> candidatePaths,
  ) {
    for (final path in candidatePaths) {
      dynamic current = response;
      var validPath = true;
      for (final key in path) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          validPath = false;
          break;
        }
      }
      if (!validPath) {
        continue;
      }
      if (current is List) {
        return current.whereType<Map>().cast<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
