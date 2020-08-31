import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../providers/user.dart';
import '../providers/tasks_provider.dart' show TasksProvider;
import '../providers/task.dart';
import 'package:provider/provider.dart';

class TaskEditScreen extends StatefulWidget {
  static const routeName = '/edit-screen';

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _descirptionFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _isinit = true;
  bool _editStartDate = false;
  bool _editedDueDate = false;
  var _isLoading = false;
  var _editedTask = Task(
    id: null,
    date: null,
    description: '',
    title: '',
    notify: false,
    notificationId: 0,
    dueDate: null,
    done: false,
  );

  void timePicker(bool date) {
    try {
      FocusManager.instance.primaryFocus.unfocus();
    } catch (error) {
      debugPrint(error.message);
    }
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (datee) {
        try {
          FocusManager.instance.primaryFocus.unfocus();
        } catch (error) {
          debugPrint(error.message);
        }
        setState(() {
          if (date) {
            _editedTask.date = datee;
          } else {
            _editedTask.dueDate = datee;
          }
        });
      },
      currentTime: date ? _editedTask.date : _editedTask.dueDate,
      minTime: date ? null : _editedTask.date,
    );
  }

  var _initValues = {
    'title': '',
    'description': '',
    'date': DateTime.now(),
    'dueDate': DateTime.now(),
    'notificationId': 0,
    'done': '',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isinit) {
      final argument =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;

      if (argument.containsKey('taskId')) {
        final taskId = argument['taskId'];

        _editedTask = Provider.of<TasksProvider>(context, listen: false)
            .findTaskById(taskId);

        _initValues = {
          'title': _editedTask.title,
          'description': _editedTask.description,
          'date': argument['date'],
          'dueDate': _editedTask.dueDate,
          'notificationId': _editedTask.notificationId,
          'done': _editedTask.done.toString(),
        };
        _editedTask.dueDate = _editedTask.dueDate;
      } else {
        _initValues['date'] = argument['date'];
        _initValues['dueDate'] = argument['dueDate'];
        _initValues['notificationId'] =
            Provider.of<TasksProvider>(context, listen: false).getSize();
        _editedTask.notificationId = _initValues['notificationId'];
        _editedTask.dueDate = argument['dueDate'];
      }
      _editedTask.date = argument['date'];
    }
    _isinit = false;
  }

  Future<void> submitForm(BuildContext context) async {
    bool isValid = _formKey.currentState.validate();
    if (_editedTask.dueDate.isBefore(_editedTask.date)) {
      isValid = false;
      setState(() {
        _editedTask.notify = false;
      });
    }
    if (!isValid) return;

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;

      if (_editedTask.id != null) {
        await Provider.of<TasksProvider>(context, listen: false).editTask(
            userId,
            _editedTask.title,
            _editedTask.description,
            _editedTask.date,
            _editedTask.dueDate,
            _editedTask);
      } else {
        await Provider.of<TasksProvider>(context, listen: false)
            .addTask(_editedTask, userId);
      }
      if (_editedTask.dueDate.isAfter(DateTime.now()) && _editedTask.notify)
        Provider.of<TasksProvider>(context).showNotification(_editedTask);
      else {
        await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('Notification won\'t be scheduled',
                      style: Theme.of(context).textTheme.title.copyWith(
                            fontFamily: 'Galada',
                          )),
                  content: _editedTask.dueDate.isBefore(DateTime.now())
                      ? Text(
                          'The due date is already passed',
                        )
                      : null,
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Okay',
                          style: Theme.of(context).textTheme.title.copyWith(
                              fontSize:
                                  15 * MediaQuery.of(context).textScaleFactor),
                        ))
                  ],
                ));
      }
    } catch (error) {
      print(error);
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'))
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _descirptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final argument =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: Text(argument.containsKey('taskId') ? 'Edit Task' : 'Add Task',
            style: Theme.of(context).textTheme.title.copyWith(
                  color: Colors.white,
                )),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        initialValue: _initValues['title'],
                        onSaved: (value) {
                          _editedTask = Task(
                              id: _editedTask.id,
                              title: value,
                              notify: _editedTask.notify,
                              notificationId: _editedTask.notificationId,
                              description: _editedTask.description,
                              dueDate: _editedTask.dueDate,
                              date: _editedTask.date);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please Enter a valid Title';
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descirptionFocusNode);
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                        focusNode: _descirptionFocusNode,
                        initialValue: _initValues['description'],
                        onSaved: (value) {
                          _editedTask = Task(
                              id: _editedTask.id,
                              title: _editedTask.title,
                              notify: _editedTask.notify,
                              notificationId: _editedTask.notificationId,
                              description: value,
                              dueDate: _editedTask.dueDate,
                              date: _editedTask.date);
                        },
                        validator: (value) {
                          if (value.length < 10)
                            return 'Description must be at least 10 characters';
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, left: 8),
                            child: Text(
                              'Notify Me',
                              style: Theme.of(context).textTheme.title.copyWith(
                                  fontSize: 25 *
                                      MediaQuery.of(context).textScaleFactor),
                            ),
                          ),
                          IconButton(
                              color: Theme.of(context).primaryColorDark,
                              icon: !_editedTask.notify
                                  ? Icon(Icons.check_box_outline_blank)
                                  : Icon(Icons.check_box),
                              onPressed:
                                  _editedTask.dueDate.isBefore(DateTime.now())
                                      ? null
                                      : () {
                                          setState(() {
                                            _editedTask.notify =
                                                !_editedTask.notify;
                                          });
                                        })
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Start Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .title
                                      .copyWith(
                                          fontSize: 25 *
                                              MediaQuery.of(context)
                                                  .textScaleFactor),
                                ),
                                IconButton(
                                    icon: Icon(_editStartDate
                                        ? Icons.remove
                                        : Icons.edit),
                                    onPressed: () {
                                      timePicker(true);
                                    })
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Due Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .title
                                      .copyWith(
                                          fontSize: 25 *
                                              MediaQuery.of(context)
                                                  .textScaleFactor),
                                ),
                                IconButton(
                                    icon: Icon(_editedDueDate
                                        ? Icons.remove
                                        : Icons.edit),
                                    onPressed: () {
                                      timePicker(false);

                                      if (_editedTask.dueDate
                                          .isBefore(DateTime.now())) {
                                        setState(() {
                                          _editedTask.notify = false;
                                        });
                                      }
                                    })
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                'Save',
                                style:
                                    Theme.of(context).textTheme.title.copyWith(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                              ),
                              onPressed: () => submitForm(context),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
