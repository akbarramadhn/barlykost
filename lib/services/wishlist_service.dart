import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kost.dart';

class WishlistService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> getCurrentUserId() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return '';
      }

      final email = authUser.email?.trim().toLowerCase() ?? '';

      Map<String, dynamic>? response = await supabase
          .from('users')
          .select('id')
          .eq('id', authUser.id)
          .maybeSingle();

      if (response != null) {
        return response['id']?.toString() ?? '';
      }

      if (email.isEmpty) {
        return '';
      }

      response = await supabase
          .from('users')
          .select('id')
          .ilike('email', email)
          .maybeSingle();

      if (response == null) {
        return '';
      }

      return response['id']?.toString() ?? '';
    } catch (error) {
      debugPrint('Get current user id wishlist error: $error');
      return '';
    }
  }

  Future<bool> isWishlisted(String kostId) async {
    try {
      final userId = await getCurrentUserId();

      if (userId.trim().isEmpty || kostId.trim().isEmpty) {
        return false;
      }

      final response = await supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', userId)
          .eq('kost_id', kostId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      debugPrint('Check wishlist error: $error');
      return false;
    }
  }

  Future<bool> addWishlist(String kostId) async {
    try {
      final userId = await getCurrentUserId();

      if (userId.trim().isEmpty || kostId.trim().isEmpty) {
        return false;
      }

      final exists = await isWishlisted(kostId);

      if (exists) {
        return true;
      }

      await supabase.from('wishlists').insert({
        'user_id': userId,
        'kost_id': kostId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (error) {
      debugPrint('Add wishlist error: $error');
      return false;
    }
  }

  Future<bool> removeWishlist(String kostId) async {
    try {
      final userId = await getCurrentUserId();

      if (userId.trim().isEmpty || kostId.trim().isEmpty) {
        return false;
      }

      await supabase
          .from('wishlists')
          .delete()
          .eq('user_id', userId)
          .eq('kost_id', kostId);

      return true;
    } catch (error) {
      debugPrint('Remove wishlist error: $error');
      return false;
    }
  }

  Future<bool> toggleWishlist(String kostId) async {
    try {
      final exists = await isWishlisted(kostId);

      if (exists) {
        return await removeWishlist(kostId);
      }

      return await addWishlist(kostId);
    } catch (error) {
      debugPrint('Toggle wishlist error: $error');
      return false;
    }
  }

  Future<List<KostModel>> fetchWishlistKosts() async {
    try {
      final userId = await getCurrentUserId();

      if (userId.trim().isEmpty) {
        return [];
      }

      final wishlistResponse = await supabase
          .from('wishlists')
          .select('kost_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final wishlistRows = List<Map<String, dynamic>>.from(
        wishlistResponse.map((item) => Map<String, dynamic>.from(item)),
      );

      final List<KostModel> result = [];

      for (final wishlist in wishlistRows) {
        final kostId = wishlist['kost_id']?.toString() ?? '';

        if (kostId.trim().isEmpty) {
          continue;
        }

        final kostResponse = await supabase
            .from('kosts')
            .select(
              'id, harga, lokasi, rating, owner_id, tersedia, deskripsi, nama_kost, created_at',
            )
            .eq('id', kostId)
            .maybeSingle();

        if (kostResponse == null) {
          continue;
        }

        String imageUrl = '';

        final imageResponse = await supabase
            .from('kost_images')
            .select('image_url')
            .eq('kost_id', kostId)
            .limit(1);

        if (imageResponse.isNotEmpty) {
          imageUrl = imageResponse.first['image_url']?.toString() ?? '';
        }

        final kostMap = Map<String, dynamic>.from(kostResponse);
        kostMap['image_url'] = imageUrl;

        result.add(KostModel.fromMap(kostMap));
      }

      return result;
    } catch (error) {
      debugPrint('Fetch wishlist kosts error: $error');
      return [];
    }
  }

  Future<int> countWishlist() async {
    try {
      final wishlistKosts = await fetchWishlistKosts();
      return wishlistKosts.length;
    } catch (error) {
      debugPrint('Count wishlist error: $error');
      return 0;
    }
  }
}