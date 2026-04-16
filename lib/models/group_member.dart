class GroupMember {
  final String id;
  final String name;
  final String phone;
  final String cityId;
  final String image;
  final String latitude;
  final String longitude;

  const GroupMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.cityId,
    required this.image,
    required this.latitude,
    required this.longitude,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      phone: '${json['mobile'] ?? json['phone'] ?? ''}',
      cityId: '${json['city_id'] ?? ''}',
      image: '${json['image'] ?? ''}',
      latitude: '${json['latitude'] ?? json['lattitude'] ?? ''}',
      longitude: '${json['longitude'] ?? ''}',
    );
  }
}
