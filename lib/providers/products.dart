import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../screens/product_detail_screen.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String token;
  final String userId;
  Products(this.token, this._items, this.userId);

  var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fectchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    print('filter screen is ' + filterString);
    final url = Uri.parse(
        'https://shopapp-fef7a-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$token&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      final url2 = Uri.parse(
          'https://shopapp-fef7a-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$token');
      final response2 = await http.get(url2);
      final favoriteData = json.decode(response2.body);

      extractedData.forEach((prodId, prodData) {
        print(prodId);
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      //throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shopapp-fef7a-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$token');
    // removed the return sentence, with async is not neccesary
    // now we can use a different syntax to call response
    // to handle the error, we wrap in a try/catch block
    try {
      final value = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
            //         'isFavorite': product.isFavorite,
          }));
      final newProduct = Product(
        id: json.decode(value.body)['name'], //DateTime.now().toString(),
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      //_items.insert(0, newProduct);//at the start of the list
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.parse(
        'https://shopapp-fef7a-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$token');
    final prodIndex =
        _items.indexWhere((element) => element.id == newProduct.id);
    if (prodIndex >= 0) {
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    // optimistic delete with check
    final url = Uri.parse(
        'https://shopapp-fef7a-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$token');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];

    http.delete(url).then((response) {
      print(response);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct!);
    });
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
