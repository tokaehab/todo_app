import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../providers/user.dart';
import '../widgets/settings_form.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style:
              Theme.of(context).textTheme.title.copyWith(color: Colors.white),
        ),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SettingsForm(
                    Provider.of<UserProvider>(context).currentUser.email,
                    Provider.of<UserProvider>(context).currentUser.username),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
