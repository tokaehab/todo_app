import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/user.dart';
import './tasks_screen.dart';
import '../widgets/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  void submitFn(
      String email, String username, String password, BuildContext ctx) async {
    final _auth = FirebaseAuth.instance;
    AuthResult authResult;
    try {
      setState(() {
        isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        var un = await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .get();
        Provider.of<UserProvider>(context, listen: false)
            .setUser(authResult.user.uid, email, un.data['username']);

        await Provider.of<TasksProvider>(context, listen: false)
            .fetchTasks(authResult.user.uid);
      } else {
        authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .setData({
          'username': username,
          'email': email,
        });
        Provider.of<UserProvider>(context, listen: false)
            .setUser(authResult.user.uid, email, username);
      }
      Navigator.of(context).pushReplacementNamed(TasksScreen.routeName);
    } on PlatformException catch (error) {
      var message = 'An error occurred, Please check your credentials';
      if (error.message != null) {
        message = error.message;
      }
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print(error);
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('An error occurred, Please try again.'),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Center(
            child: Text(
              'Todo List',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                fontFamily: Theme.of(context).textTheme.title.fontFamily,
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Card(
              elevation: 10,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AuthForm(submitFn, isLoading, isLogin),
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      isLogin
                          ? 'Create new account'
                          : 'I already have an account?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      !isLogin ? 'Login Now' : 'Register Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
