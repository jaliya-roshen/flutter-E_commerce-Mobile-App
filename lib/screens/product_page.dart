import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/screens/constants.dart';
import 'package:e_commerce/services/firebase_services.dart';
import 'package:e_commerce/widgets/custom_action_bar.dart';
import 'package:e_commerce/widgets/image_swipe.dart';
import 'package:e_commerce/widgets/product_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  ProductPage({this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

FirebaseServices _firebaseServices = FirebaseServices();

class _ProductPageState extends State<ProductPage> {

   // User -> UserID (Document) -> Cart -> ProductId(Document)


  String _selectedProductSize = "0";

  Future _addToCart() {
    return _firebaseServices.usersRef
        .doc(_firebaseServices.getUserId())
        .collection("cart")
        .doc(widget.productId)
        .set({"size": _selectedProductSize});
  }

  Future _addToSave() {
    return _firebaseServices.usersRef
        .doc(_firebaseServices.getUserId())
        .collection("Save")
        .doc(widget.productId)
        .set({"size": _selectedProductSize});
  }

  //Add snackbar to Display message when add a Product to the cart
  final SnackBar _snackBar = SnackBar(content: Text("Product added to the cart"),);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _firebaseServices.productsRef.doc(widget.productId).get(),
            builder: (context, snapshot) {
              if(snapshot.hasError){
                  return Scaffold(
                    body: Center(
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
              }
              if(snapshot.connectionState == ConnectionState.done){
                //Firebase Document Data Map
                Map<String, dynamic> documentData = snapshot.data.data();

                //List of Images
                List imageList = documentData['images'];
                //List of Sizes
                List productSizes = documentData['size'];
                //Set the initial Size
                _selectedProductSize = productSizes[0];

                return ListView(
                  padding: EdgeInsets.all(0),
                  children: [
                    ImageSwipe(imageList: imageList),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 24.0,
                        right: 24.0,
                        bottom: 4.0,
                      ),
                      child: Text(
                        "${documentData['name']}",
                        style: Constants.boldHeading,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                        "\$${documentData['price']}",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                        "${documentData['desc']}",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 24.0,
                      ),
                      child: Text("Select Size",
                        style: Constants.regularDarkText,
                      ),
                    ),
                    ProductSize(
                      productSizes: productSizes,
                      onSelected: (size) {
                        _selectedProductSize = size;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment : MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap:() async{
                              await _addToSave();
                              Scaffold.of(context).showSnackBar(_snackBar);
                            },
                            child: Container(
                              width: 65.0,
                              height: 65.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFDCDCDC),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: Alignment.center,
                              child: Image(
                                image: AssetImage(
                                  "assets/images/tab_saved.png"
                                ),
                                height: 21.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                  await _addToCart();
                                  Scaffold.of(context).showSnackBar(_snackBar);
                              },
                              child: Container(
                                height: 65.0,
                                margin: EdgeInsets.only(
                                  left: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12.0),

                                ),
                                alignment: Alignment.center,
                                child: Text("Add to Cart",
                                  style: TextStyle(
                                      color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              }

              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          CustomActionBar(
            hasBackArrow: true,
            hasTitle: false,
            hasBackground: false,
          )
        ],
      ),
    );
  }
}
