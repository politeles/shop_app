import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    print('toggle product called');
    final url = Uri.parse(
        'https://shopapp-fef7a-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );

      if (response.statusCode >= 400) {
        print('after webservice');
        print(response.statusCode);
        isFavorite = oldStatus;
      } else {
        print('else');
      }
    } catch (error) {
      isFavorite = oldStatus;
      print(error.toString());
      print('error here');
    } finally {
      notifyListeners();
    }
  }
}
