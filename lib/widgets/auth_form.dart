import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final Function submitFn;
  final bool isLoading;
  final bool isLogin;
  AuthForm(this.submitFn, this.isLoading, this.isLogin);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  bool _obscure = true;

  void _trySubmit() {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (_isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _email.trim(),
        _username.trim(),
        _password.trim(),
        context,
      );
    }
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
              TextFormField(
                key: ValueKey('email'),
                decoration: InputDecoration(
                  labelText: 'email',
                ),
                validator: (value) {
                  if (!value.contains('@') ||
                      !value.contains('.com') ||
                      value.isEmpty) return 'Invalid Email';
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              if (!widget.isLogin)
                TextFormField(
                  key: ValueKey('username'),
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if (value.length < 4)
                      return 'Username should be at least 4 characters';
                    return null;
                  },
                  onSaved: (value) {
                    _username = value;
                  },
                ),
              TextFormField(
                key: ValueKey('password'),
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      !_obscure ? Icons.visibility : Icons.visibility_off,
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
                  _password = value;
                },
              ),
              widget.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : RaisedButton(
                      onPressed: _trySubmit,
                      child: Text(
                        widget.isLogin ? 'Log in' : 'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              Theme.of(context).textTheme.title.fontFamily,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
