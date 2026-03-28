// lib/models/account_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountEntry {
  final String? id;
  final String label;
  final String username;
  final String password;
  final String notes;
  final DateTime createdAt;

  AccountEntry({
    this.id,
    required this.label,
    required this.username,
    required this.password,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'label': label,
        'username': username,
        'password': password,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AccountEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountEntry(
      id: doc.id,
      label: data['label'] ?? '',
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AccountEntry copyWith({
    String? id,
    String? label,
    String? username,
    String? password,
    String? notes,
  }) {
    return AccountEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
