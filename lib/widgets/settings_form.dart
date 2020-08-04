import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/tasks_screen.dart';
import '../providers/user.dart';

class SettingsForm extends StatefulWidget {
  final String email;
  final String username;
  SettingsForm(this.email, this.username);
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  String _oldPassword = '';
  bool _isLoading = false;
  bool _obscure = true;
  bool _newObscure = true;
  bool _editPassword = false;

  void _trySubmit() async {
    bool _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      if (_editPassword)
        try {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();

          AuthResult authResult = await user.reauthenticateWithCredential(
            EmailAuthProvider.getCredential(
              email: user.email,
              password: _oldPassword,
            ),
          );
        } catch (error) {
          print(error);
          await showDialog<Null>(
              context: context,
              builder: (ctx) {
                _isValid = false;
                return AlertDialog(
                  title: Text('Wrong Password!'),
                  content: Text('Please enter the correct passsword.'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Okay',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontFamily:
                              Theme.of(context).textTheme.title.fontFamily,
                        ),
                      ),
                    )
                  ],
                );
              });
        }
    }

    if (_isValid) {
      _email = _email.trim();
      _username = _username.trim();
      _password = _password.trim();
      await Provider.of<UserProvider>(context)
          .editUser(_username, _password, _editPassword);

      Navigator.of(context).pushReplacementNamed(TasksScreen.routeName);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextFormField(
                  enabled: false,
                  key: ValueKey('Email'),
                  decoration: InputDecoration(
                    labelText: 'email',
                  ),
                  initialValue: widget.email,
                  validator: (value) {
                    if (!value.contains('@') ||
                        !value.contains('.com') ||
                        value.isEmpty) return 'Invalid Email';
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextFormField(
                  key: ValueKey('Username'),
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  initialValue: widget.username,
                  validator: (value) {
                    if (value.length < 4)
                      return 'Username should be at least 4 characters';
                    return null;
                  },
                  onSaved: (value) {
                    _username = value;
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Password',
                      style: Theme.of(context).textTheme.title.copyWith(
                          fontSize:
                              20 * MediaQuery.of(context).textScaleFactor),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                  ),
                  IconButton(
                      icon: Icon(_editPassword ? Icons.remove : Icons.edit),
                      onPressed: () {
                        setState(() {
                          _editPassword = !_editPassword;
                        });
                      })
                ],
              ),
              if (_editPassword)
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        key: ValueKey('oldPassword'),
                        decoration: InputDecoration(
                          hintText: 'Enter your old password',
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscure,
                        validator: (value) {
                          if (value.length < 8)
                            return 'Password should be at least 8 characters';
                          return null;
                        },
                        onSaved: (value) {
                          _oldPassword = value;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        key: ValueKey('newPassword'),
                        decoration: InputDecoration(
                          hintText: 'Enter your new password',
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_newObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _newObscure = !_newObscure;
                              });
                            },
                          ),
                        ),
                        obscureText: _newObscure,
                        validator: (value) {
                          if (value.length < 8)
                            return 'Password should be at least 8 characters';
                          return null;
                        },
                        onSaved: (value) {
                          _password = value;
                        },
                      ),
                    ),
                  ],
                ),
              _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        onPressed: _trySubmit,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                Theme.of(context).textTheme.title.fontFamily,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
