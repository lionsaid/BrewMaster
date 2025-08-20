import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple remote JSON fetch with ETag cache repository
class RecommendRepository {
  /// Fetch JSON with ETag cache support; returns local cache on failure (if available), otherwise null
  Future<String?> getJsonWithCache(String url, {Duration timeout = const Duration(seconds: 12)}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String etagKey = 'etag:$url';
    final String cacheKey = 'cache:$url';
    final String? etag = prefs.getString(etagKey);
    final Map<String, String> headers = <String, String>{};
    if (etag != null && etag.isNotEmpty) {
      headers['If-None-Match'] = etag;
    }
    try {
      final http.Response resp = await http.get(Uri.parse(url), headers: headers).timeout(timeout);
      if (resp.statusCode == 200) {
        final String body = resp.body;
        final String? newEtag = resp.headers['etag'];
        if (newEtag != null && newEtag.isNotEmpty) {
          await prefs.setString(etagKey, newEtag);
        }
        await prefs.setString(cacheKey, body);
        return body;
      }
      if (resp.statusCode == 304) {
        final String? cached = prefs.getString(cacheKey);
        if (cached != null) return cached;
      }
    } catch (_) {
      // ignore and fall back to cache
    }
    return prefs.getString(cacheKey);
  }
}


