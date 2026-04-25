import 'package:cloud_firestore/cloud_firestore.dart';

class ScannedCustomerModel {
  final String id;
  final String uid;
  final String firstName;
  final String username;
  final String email;
  final String? liveCode;
  final int points;
  final Map<String, dynamic> stampCards;
  final List<dynamic> activeCoupons;
  final DateTime? updatedAt;

  const ScannedCustomerModel({
    required this.id,
    required this.uid,
    required this.firstName,
    required this.username,
    required this.email,
    required this.points,
    required this.stampCards,
    required this.activeCoupons,
    this.liveCode,
    this.updatedAt,
  });

  factory ScannedCustomerModel.fromMap(
      Map<String, dynamic> map, {
        String? documentId,
      }) {
    return ScannedCustomerModel(
      id: documentId ?? (map['id'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
      firstName: (map['firstName'] ?? '') as String,
      username: (map['username'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      liveCode: map['liveCode'] as String?,
      points: _readInt(map['points']),
      stampCards: Map<String, dynamic>.from(map['stampCards'] ?? {}),
      activeCoupons: List<dynamic>.from(map['activeCoupons'] ?? []),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  factory ScannedCustomerModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return ScannedCustomerModel.fromMap(data, documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'username': username,
      'email': email,
      'liveCode': liveCode,
      'points': points,
      'stampCards': stampCards,
      'activeCoupons': activeCoupons,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ScannedCustomerModel copyWith({
    String? id,
    String? uid,
    String? firstName,
    String? username,
    String? email,
    String? liveCode,
    int? points,
    Map<String, dynamic>? stampCards,
    List<dynamic>? activeCoupons,
    DateTime? updatedAt,
  }) {
    return ScannedCustomerModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      username: username ?? this.username,
      email: email ?? this.email,
      liveCode: liveCode ?? this.liveCode,
      points: points ?? this.points,
      stampCards: stampCards ?? this.stampCards,
      activeCoupons: activeCoupons ?? this.activeCoupons,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _readInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}