// lib/models/vault_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

const List<Map<String, dynamic>> kDefaultIcons = [
  {'emoji': '🔐', 'label': 'Lock'},
  {'emoji': '📱', 'label': 'Phone'},
  {'emoji': '💼', 'label': 'Work'},
  {'emoji': '🏦', 'label': 'Bank'},
  {'emoji': '🎮', 'label': 'Game'},
  {'emoji': '📧', 'label': 'Email'},
  {'emoji': '🛒', 'label': 'Shop'},
  {'emoji': '🎵', 'label': 'Music'},
  {'emoji': '📸', 'label': 'Photo'},
  {'emoji': '🎬', 'label': 'Video'},
  {'emoji': '☁️', 'label': 'Cloud'},
  {'emoji': '💳', 'label': 'Card'},
  {'emoji': '🌐', 'label': 'Web'},
  {'emoji': '🔑', 'label': 'Key'},
  {'emoji': '👤', 'label': 'User'},
  {'emoji': '⚡', 'label': 'App'},
];

const List<Map<String, dynamic>> kCategoryColors = [
  {'name': 'Violet', 'color': 0xFF6C63FF},
  {'name': 'Cyan', 'color': 0xFF00D4FF},
  {'name': 'Emerald', 'color': 0xFF00D68F},
  {'name': 'Rose', 'color': 0xFFFF4D6A},
  {'name': 'Amber', 'color': 0xFFFFAA00},
  {'name': 'Pink', 'color': 0xFFFF6B9D},
  {'name': 'Teal', 'color': 0xFF00BFA6},
  {'name': 'Orange', 'color': 0xFFFF7043},
];

class VaultItem {
  final String? id;
  final String title;
  final String emoji;
  final int colorValue;
  final String category;
  final DateTime createdAt;
  int accountCount;

  VaultItem({
    this.id,
    required this.title,
    this.emoji = '🔐',
    this.colorValue = 0xFF6C63FF,
    this.category = 'General',
    DateTime? createdAt,
    this.accountCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'title': title,
        'emoji': emoji,
        'colorValue': colorValue,
        'category': category,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory VaultItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaultItem(
      id: doc.id,
      title: data['title'] ?? '',
      emoji: data['emoji'] ?? '🔐',
      colorValue: data['colorValue'] ?? 0xFF6C63FF,
      category: data['category'] ?? 'General',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  VaultItem copyWith({
    String? id,
    String? title,
    String? emoji,
    int? colorValue,
    String? category,
    int? accountCount,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      createdAt: createdAt,
      accountCount: accountCount ?? this.accountCount,
    );
  }
}
