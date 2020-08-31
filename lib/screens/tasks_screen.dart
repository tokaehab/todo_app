import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './task_edit_screen.dart';
import '../widgets/main_drawer.dart';
import '../widgets/task_card.dart';
import '../providers/tasks_provider.dart';
import '../providers/task.dart';
import '../providers/user.dart' show UserProvider;

class TasksScreen extends StatefulWidget {
  static const String routeName = '/tasks-screen';
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isinit = true;
  bool _isLoading = false;

  void _datePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2021),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isinit) {
      _isinit = false;
      setState(() {
        _isLoading = true;
      });
      await Provider.of<TasksProvider>(context, listen: false)
          .fetchTasks(Provider.of<UserProvider>(context).currentUser.id);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List<Task> tasks =
    //     Provider.of<TasksProvider>(context).getTasks(_selectedDate);

    Widget body(List<Task> tasks) {
      return Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 60,
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tasks',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            Theme.of(context).textTheme.title.fontFamily,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(TaskEditScreen.routeName, arguments: {
                          'date': _selectedDate,
                          'dueDate': _selectedDate,
                        });
                      })
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      return TaskCard(tasks[i],
                          Provider.of<UserProvider>(context).currentUser.id);
                    }),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            '${DateFormat.EEEE().format(_selectedDate)}',
            style:
                Theme.of(context).textTheme.title.copyWith(color: Colors.white),
          ),
          iconTheme: new IconThemeData(color: Colors.white),
          actions: <Widget>[
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.calendar_today),
              onPressed: _datePicker,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(
                text: 'One-Day Tasks',
              ),
              Tab(
                text: 'Long-Term Tasks',
              ),
            ],
          ),
        ),
        drawer: MainDrawer(),
        body: TabBarView(
          children: <Widget>[
            Tab(
              child: body(Provider.of<TasksProvider>(context)
                  .getOneDayTasks(_selectedDate)),
            ),
            Tab(
              child: body(Provider.of<TasksProvider>(context)
                  .getLongTasks(_selectedDate)),
            ),
          ],
        ),
      ),
    );
  }
}
