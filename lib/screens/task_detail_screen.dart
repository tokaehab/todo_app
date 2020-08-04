import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/user.dart';
import './task_edit_screen.dart';
import '../providers/tasks_provider.dart';
import 'package:provider/provider.dart';
import '../providers/task.dart';

class TaskDetailScreen extends StatefulWidget {
  static const routeName = '/detail-screen';

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final taskId = ModalRoute.of(context).settings.arguments as String;
    final Task task =
        Provider.of<TasksProvider>(context, listen: false).findTaskById(taskId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: Theme.of(context).textTheme.title.copyWith(
                color: Colors.white,
              ),
        ),
        iconTheme: new IconThemeData(color: Colors.white),
        actions: <Widget>[
          FittedBox(
            child: Column(
              children: <Widget>[
                IconButton(
                    icon: Icon(task.done
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onPressed: () async {
                      try {
                        await Provider.of<TasksProvider>(context).toggleDone(
                            Provider.of<UserProvider>(context).currentUser.id,
                            task);
                      } catch (error) {
                        throw error;
                      }
                    }),
                Text(
                  'Done',
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: 17 * MediaQuery.of(context).textScaleFactor,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Title',
                      style: Theme.of(context).textTheme.title,
                    ),
                    Text(
                      '${task.title}',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.left,
                      softWrap: true,
                    ),
                    Container(margin: EdgeInsets.all(5), child: Divider()),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.title,
                    ),
                    Text(
                      '${task.description}',
                      style: TextStyle(fontSize: 18),
                      softWrap: true,
                    ),
                    Container(margin: EdgeInsets.all(5), child: Divider()),
                    Text(
                      'Start Date',
                      style: Theme.of(context).textTheme.title,
                    ),
                    Text(
                      '${DateFormat.yMEd().format(task.date)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text('${DateFormat.Hms().format(task.date)}'),
                    Container(margin: EdgeInsets.all(5), child: Divider()),
                    Text(
                      'Due Date',
                      style: Theme.of(context).textTheme.title,
                    ),
                    Text(
                      '${DateFormat.yMEd().format(task.dueDate)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text('${DateFormat.Hms().format(task.dueDate)}'),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: Theme.of(context).textTheme.title.fontFamily,
                  ),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                      TaskEditScreen.routeName,
                      arguments: {
                        'date': task.date,
                        'taskId': task.id,
                      });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              SizedBox(
                width: 215,
              ),
              RaisedButton(
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: Theme.of(context).textTheme.title.fontFamily,
                  ),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Provider.of<TasksProvider>(context, listen: false).removeTask(
                      taskId,
                      Provider.of<UserProvider>(context).currentUser.id);
                  Navigator.of(context).pop();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
