import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/tasks_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget buildListTile(String title, IconData icon, Function tapHandler) {
      return ListTile(
        leading: Icon(
          icon,
          size: 26,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.title.copyWith(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
        ),
        onTap: tapHandler,
      );
    }

    return Drawer(
      elevation: 5,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 45,
          ),
          buildListTile('Tasks', Icons.assignment, () {
            Navigator.of(context).pushReplacementNamed(TasksScreen.routeName);
          }),
          Divider(),
          buildListTile('Settings', Icons.settings, () {
            Navigator.of(context)
                .pushReplacementNamed(SettingsScreen.routeName);
          }),
          Divider(),
          buildListTile('Log out', Icons.exit_to_app, () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
          })
        ],
      ),
    );
  }
}
