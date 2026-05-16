import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/post.dart';
import '../models/profile.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;
  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
    File? photo,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Registracija nije uspjela.');
    }

    // The handle_new_user trigger has already created the profiles row
    // using `username` from auth metadata. We only need to attach a photo
    // if the user picked one.
    if (photo != null) {
      final photoUrl = await _uploadImage(
        bucket: SupabaseConfig.userPhotosBucket,
        path: '${user.id}.jpg',
        file: photo,
      );
      await _client
          .from('profiles')
          .update({'photo_url': photoUrl}).eq('id', user.id);
    }

    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<Profile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromMap(row);
  }

  Future<List<Post>> fetchPosts() async {
    final rows = await _client
        .from('posts')
        .select('id, user_id, image_url, description, created_at, '
            'profiles ( username, photo_url )')
        .order('created_at', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Post.fromJoinedMap)
        .toList();
  }

  Future<void> createPost({
    required String description,
    required File imageFile,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('Morate biti prijavljeni.');
    }
    final ts = DateTime.now().millisecondsSinceEpoch;
    final imageUrl = await _uploadImage(
      bucket: SupabaseConfig.postImagesBucket,
      path: '${user.id}/$ts.jpg',
      file: imageFile,
    );
    await _client.from('posts').insert({
      'user_id': user.id,
      'image_url': imageUrl,
      'description': description,
    });
  }

  Future<String> _uploadImage({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
