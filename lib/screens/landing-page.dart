import 'package:e_commerce/screens/constants.dart';
import 'package:e_commerce/screens/home_page.dart';
import 'package:e_commerce/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // if snapshot has error
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }
        //Connection Initialized - Firebase app is running
        if (snapshot.connectionState == ConnectionState.done) {
          //StreamBuilder can check login status live
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, streamSnapshot){
              //if Streamsnapshot has error
              if (streamSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${streamSnapshot.error}"),
                  ),
                );
              }

              //Connection state active - Do the user login check inside if statement
              if (streamSnapshot.connectionState == ConnectionState.active) {
                //Get the user
                User _user = streamSnapshot.data;

                //If the user is null, we're not log in
                if(_user == null) {
                    //user not logged in , head to the login
                  return LoginPage();
                } else {
                  // The user is logged in , head to the homepage
                  return HomePage();
                }
              }

              //Checking the auth state - loaing
              return Scaffold(
                body: Center(
                  child: Text(
                    "Checking authentication.....",
                    style: Constants.regularHeading,
                  ),
                ),
              );
            },
          );
        }
        //Connecting to the Firebase
        return Scaffold(
          body: Center(
            child: Text(
              "Initializing the App.....",
              style: Constants.regularHeading,
            ),
          ),
        );
      },
    );
  }
}
