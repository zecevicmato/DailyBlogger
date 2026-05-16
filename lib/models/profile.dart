class Profile {
  final String id;
  final String username;
  final String? photoUrl;

  const Profile({
    required this.id,
    required this.username,
    this.photoUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        username: (map['username'] as String?) ?? '',
        photoUrl: map['photo_url'] as String?,
      );

  Map<String, dynamic> toInsertMap() => {
        'id': id,
        'username': username,
        if (photoUrl != null) 'photo_url': photoUrl,
      };
}
