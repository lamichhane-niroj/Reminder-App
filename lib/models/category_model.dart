// Category model for advanced category info
class Category {
  final int id;
  final String name;
  final int totalTaskCount;
  final int dueTaskCount;

  Category({
    required this.id,
    required this.name,
    required this.totalTaskCount,
    required this.dueTaskCount,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      totalTaskCount: map['totalTaskCount'] as int? ?? 0,
      dueTaskCount: map['dueTaskCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalTaskCount': totalTaskCount,
      'dueTaskCount': dueTaskCount,
    };
  }
} 