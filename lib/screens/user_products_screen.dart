import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../screens/edit_products_screen.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    // adding listen to false t
    await Provider.of<Products>(context, listen: false).fectchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    //note that we can use the provider inside the body,
    // to optimize the build process, use const in the constructors
    final productsData = Provider.of<Products>(context);
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add),
            ),
          ],
          title: const Text('Your products'),
        ),
        drawer: AppDrawer(),
        body: RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListView.builder(
              itemBuilder: (context, index) => Column(
                children: [
                  UserProductItem(
                      id: productsData.items[index].id,
                      title: productsData.items[index].title,
                      imageUrl: productsData.items[index].imageUrl),
                  Divider(),
                ],
              ),
              itemCount: productsData.items.length,
            ),
          ),
        ));
  }
}
