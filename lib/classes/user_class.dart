import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String firstName;
  final String lastName;
  final String email;
  final DateTime dob;
  final String privateImageUrl;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dob,
    required this.privateImageUrl,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      dob: (map['dob'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      privateImageUrl: map['privateImageUrl'] ?? '',
    );
  }
}
