import 'dart:async';
import 'dart:convert';

import 'package:flutter_advanced_maps/models/reverse_result.dart';
import 'package:flutter_advanced_maps/models/search_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart' show required;
import 'package:flutter/services.dart';

typedef OnSearch(List<SearchResult> items);
typedef OnReverse(ReverseResult result);

class Nominatim {
  final apiHost = 'https://nominatim.openstreetmap.org';
  StreamSubscription _searchSub, _reverseSub;
  OnSearch onSearch;
  OnReverse onReverse;

  Future<void> search(String query) async {
    try {
      final url =
          "$apiHost/search.php?q=${Uri.encodeFull(query)}&polygon_geojson=1&format=json";

      _searchSub?.cancel();
      _searchSub = http.get(url).asStream().listen((response) {
        if (response.statusCode == 200 && onSearch != null) {
          final items = (jsonDecode(response.body) as List)
              .map((item) => SearchResult.fromJson(item))
              .toList();
          onSearch(items);
        }
      });
    } catch (e) {
      print("search error: $e");
    }
  }

  Future<void> reverse(LatLng position) async {
    try {
      final url =
          "$apiHost/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json";

      _reverseSub?.cancel();
      _reverseSub = http.get(url).asStream().listen((response) {
        print("reverse ${response.statusCode}");
        if (response.statusCode == 200 && onReverse != null) {
          final parsed = jsonDecode(response.body);
          onReverse(ReverseResult.fromJson(parsed));
        }
      });
    } catch (e) {
      print("reverse error: $e");
    }
  }

  dispose() {
    _searchSub?.cancel();
    _reverseSub?.cancel();
  }
}
