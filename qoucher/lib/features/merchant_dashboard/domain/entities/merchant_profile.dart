class MerchantProfile {
  final String id;
  final String uid;
  final String businessName;
  final String email;
  final String phone;
  final String? contactName;
  final String? description;
  final String? address;
  final String? logoUrl;
  final List<String> categories;
  final bool isActive;

  const MerchantProfile({
    required this.id,
    required this.uid,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.categories,
    required this.isActive,
    this.contactName,
    this.description,
    this.address,
    this.logoUrl,
  });

  MerchantProfile copyWith({
    String? id,
    String? uid,
    String? businessName,
    String? email,
    String? phone,
    String? contactName,
    String? description,
    String? address,
    String? logoUrl,
    List<String>? categories,
    bool? isActive,
  }) {
    return MerchantProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      contactName: contactName ?? this.contactName,
      description: description ?? this.description,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      categories: categories ?? this.categories,
      isActive: isActive ?? this.isActive,
    );
  }
}