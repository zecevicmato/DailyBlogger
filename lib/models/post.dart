class Post {
  final String id;
  final String userId;
  final String? username;
  final String? userPhotoUrl;
  final String imageUrl;
  final String description;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
  });

  factory Post.fromJoinedMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return Post(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      username: profile?['username'] as String?,
      userPhotoUrl: profile?['photo_url'] as String?,
      imageUrl: (map['image_url'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
