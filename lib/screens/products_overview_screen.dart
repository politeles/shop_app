import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../screens/cart_screen.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = false;
  var _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // this won't work:
    // Provider.of<Products>(context).fectchAndSetProducts();
    /*
    this will work,  but it's a hack:
    Future.delayed(Duration.zero)
        .then((_) => Provider.of<Products>(context).fectchAndSetProducts());
  */
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    if (!_isInit) {
      setState(() {
        _isLoading = true;
        Provider.of<Products>(context).fectchAndSetProducts().then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      });
    }
    _isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('My shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  child: Text('Only favorites'),
                  value: FilterOptions.Favorites),
              const PopupMenuItem(
                  child: Text('Show all'), value: FilterOptions.All),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (context, value, child) => Badge(
              child: child ?? Text('null'),
              value: value.itemCount.toString(),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
